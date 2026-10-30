# Starts NOVA and a public Cloudflare link in the background, independent of any open window.
# Run it again after a restart: it prints the new link and saves it to PUBLIC-LINK.txt.
# Usage:  powershell -ExecutionPolicy Bypass -File start-public.ps1
#         powershell -ExecutionPolicy Bypass -File start-public.ps1 -RestartServer   (after an update: new code, same link)
param([switch]$RestartServer)

$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$server = Join-Path $root 'server'
$logs   = Join-Path $server 'data\public'
$cf     = Join-Path $env:LOCALAPPDATA 'Programs\cloudflared\cloudflared.exe'
New-Item -ItemType Directory -Force $logs | Out-Null
if (-not (Test-Path $cf)) { Write-Host 'cloudflared is missing: expected at' $cf; exit 1 }

# processes created through WMI are not tied to this window, so closing it does not stop them
function Start-Detached([string]$cmd, [string]$dir) {
  $r = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $cmd; CurrentDirectory = $dir }
  if ($r.ReturnValue -ne 0) { throw "could not start: $cmd" }
}

if ($RestartServer) {
  # stop only the server; the tunnel keeps running so the public link does not change
  Get-NetTCPConnection -LocalPort 8787 -State Listen -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
  Start-Sleep 1
  Start-Detached "cmd /c node src/server.ts > `"$logs\server.log`" 2>&1" $server
  for ($i = 0; $i -lt 30 -and -not (Get-NetTCPConnection -LocalPort 8787 -State Listen -ErrorAction SilentlyContinue); $i++) { Start-Sleep 1 }
  Write-Host "NOVA restarted. Public link unchanged: $(Get-Content (Join-Path $root 'PUBLIC-LINK.txt') -ErrorAction SilentlyContinue)"
  exit 0
}

# 1. NOVA server on port 8787 (left alone if it is already running)
if (-not (Get-NetTCPConnection -LocalPort 8787 -State Listen -ErrorAction SilentlyContinue)) {
  Start-Detached "cmd /c node src/server.ts > `"$logs\server.log`" 2>&1" $server
  for ($i = 0; $i -lt 30 -and -not (Get-NetTCPConnection -LocalPort 8787 -State Listen -ErrorAction SilentlyContinue); $i++) { Start-Sleep 1 }
}

# 2. a fresh public link (an older tunnel is stopped first)
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item "$logs\tunnel.log" -ErrorAction SilentlyContinue
Start-Detached "`"$cf`" tunnel --no-autoupdate --url http://localhost:8787 --logfile `"$logs\tunnel.log`"" $root

$url = ''
for ($i = 0; $i -lt 40 -and -not $url; $i++) {
  Start-Sleep 1
  $url = ([regex]'https://[a-z0-9-]+\.trycloudflare\.com').Match((Get-Content "$logs\tunnel.log" -Raw -ErrorAction SilentlyContinue)).Value
}
if (-not $url) { Write-Host "No link yet - see $logs\tunnel.log"; exit 1 }
Set-Content -Path (Join-Path $root 'PUBLIC-LINK.txt') -Value $url -Encoding utf8
Write-Host "NOVA public link: $url"
