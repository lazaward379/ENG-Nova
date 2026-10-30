# NOVA Engineering AI

AI-assisted engineering design, CAD, compliance and submission-preparation platform for
engineering consultancies in Abu Dhabi. Release 0.1 is the first working vertical slice.

> Engineering support tool. It does not grant authority approvals, does not replace licensed
> professionals, and ships **no verified Abu Dhabi regulation** — see
> [docs/ABU_DHABI_REGULATORY_STRATEGY.md](docs/ABU_DHABI_REGULATORY_STRATEGY.md).

## Requirements

- Node.js **24 or newer** (uses built-in `node:sqlite` and native TypeScript type stripping)
- No Python, Docker or database server is needed for this release.

## Run it

```bash
npm --prefix server install
npm --prefix web install
npm --prefix web run build
npm --prefix server start
```

Open http://127.0.0.1:8787, choose **Create organization**, then create a project and upload
`samples/sample-villa-ground-floor.dxf` (a synthetic test fixture, not a real plot).

Frontend development with hot reload (keep the server running in another terminal):

```bash
npm --prefix web run dev
```

then open http://127.0.0.1:5173 (API calls are proxied to port 8787).

## Test

```bash
npm --prefix server test
npm --prefix server run typecheck
npm --prefix web run build
```

## Configuration (environment variables, optional `server/.env`)

| Variable | Default | Purpose |
|---|---|---|
| `PORT` / `HOST` | `8787` / `127.0.0.1` | listen address |
| `NOVA_DATA_DIR` | `server/data` | database and file storage |
| `NOVA_ALLOW_SIGNUP` | `true` | set `false` to disable self-service organisation sign-up |
| `ANTHROPIC_API_KEY` | — | enables the optional LLM copilot provider |
| `NOVA_LLM_MODEL` | `claude-opus-5-5` | model for the LLM provider |

## Layout

```
docs/      specification, architecture, data model, regulatory strategy, security, testing, roadmap, limitations
server/    Fastify + Zod + node:sqlite API, geometry engine, DXF I/O, rule engine, copilot
web/       React + Vite UI, Canvas2D CAD workspace, bilingual EN/AR shell
samples/   synthetic DXF fixture (regenerate: npm --prefix server run sample)
```
