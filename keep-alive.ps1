# Keeps NOVA and its public link up: run every few minutes by the "NOVA keep-alive" scheduled task.
# The server is restarted if it stopped; the link is renewed if it stopped answering twice in a row
# (a temporary Cloudflare link dies when the laptop sleeps). The current link is always in PUBLIC-LINK.txt.
# Install:  powershell -ExecutionPolicy Bypass -File keep-alive.ps1 -Install
# Remove:   powershell -ExecutionPolicy Bypass -File keep-alive.ps1 -Uninstall
param([switch]$Install, [switch]$Uninstall)

$root  = Split-Path -Parent $MyInvocation.MyCommand.Path
$logs  = Join-Path $root 'server\data\public'
$state = Join-Path $logs 'keep-alive.state'
$log   = Join-Path $logs 'keep-alive.log'
$task  = 'NOVA keep-alive'
function Note([string]$m) { Add-Content -Path $log -Value "$(Get-Date -Format s)  $m" -Encoding utf8 }

if ($Uninstall) { Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue; Write-Host 'keep-alive removed'; exit 0 }
if ($Install) {
  $action   = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
  $triggers = @(
    (New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 3) -RepetitionDuration (New-TimeSpan -Days 3650)),
    (New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME)
  )
  $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
  Register-ScheduledTask -TaskName $task -Action $action -Trigger $triggers -Settings $settings -Force | Out-Null
  Write-Host "keep-alive installed: checks every 3 minutes"
  exit 0
}

New-Item -ItemType Directory -Force $logs | Out-Null
$serverUp = [bool](Get-NetTCPConnection -LocalPort 8787 -State Listen -ErrorAction SilentlyContinue)
$url = (Get-Content (Join-Path $root 'PUBLIC-LINK.txt') -ErrorAction SilentlyContinue | Select-Object -First 1)
$tunnelUp = $false
if ($url -and (Get-Process cloudflared -ErrorAction SilentlyContinue)) {
  try { $tunnelUp = (Invoke-WebRequest -UseBasicParsing -TimeoutSec 20 "$url/api/auth/signup-status").StatusCode -eq 200 } catch { $tunnelUp = $false }
}

if (-not $serverUp -and $tunnelUp) { Note 'server down - restarting it (same link)'; & (Join-Path $root 'start-public.ps1') -RestartServer | Out-Null; exit 0 }
if ($tunnelUp) { Set-Content $state '0'; exit 0 }

# one failed check can be a network blip; two in a row (or no tunnel at all) means the link is gone
$fails = [int](Get-Content $state -ErrorAction SilentlyContinue) + 1
Set-Content $state "$fails"
if ($fails -lt 2 -and (Get-Process cloudflared -ErrorAction SilentlyContinue)) { exit 0 }
Note "link not answering ($url) - starting a new one"
& (Join-Path $root 'start-public.ps1') | Out-Null
Set-Content $state '0'
Note "new link: $(Get-Content (Join-Path $root 'PUBLIC-LINK.txt') -ErrorAction SilentlyContinue)"
