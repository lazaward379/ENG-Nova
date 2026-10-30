# NOVA Engineering AI — continuation guide / دليل المتابعة

Package date: 2026-10-25 · Release 0.1 + cycles 2–7

## How to continue development / كيف تكمل التطوير
1. Extract the zip into a folder, e.g. `Documents\NOVA`.
2. Open that folder in Claude Code (desktop app → choose the folder) and say what you want next.
   Point Claude to `docs/IMPLEMENTATION_ROADMAP.md` (cycle log) and `docs/KNOWN_LIMITATIONS.md`.
3. Install and run (Node.js 24+ required):

```bash
npm --prefix server install
```
```bash
npm --prefix web install
```
```bash
npm --prefix web run build
```
```bash
npm --prefix server start
```

Open http://127.0.0.1:8787 and create an organisation (the database starts empty).

Run the tests: `npm --prefix server test` (the AutoCAD tests run only on a computer with AutoCAD installed).

## What is in the package / محتوى الحزمة
| Folder | Content |
|---|---|
| `docs/` | specification, architecture, data model, Abu Dhabi regulatory strategy (incl. Binaa), file formats, security, testing, roadmap + cycle log, known limitations |
| `server/` | API (Fastify + Zod + node:sqlite), geometry, DXF, operations/undo, rule engine, copilot, generator, AutoCAD bridge, tests |
| `web/` | React UI (bilingual EN/AR), CAD workspace |
| `samples/` | synthetic test DXF (not a real plot) |

Not included on purpose: `node_modules` (reinstalled by npm), `web/dist` (rebuilt), and `server/data`
(the local database, uploaded files and the local test account). Your projects in the running app are
therefore **not** in this zip. Back up `server/data` separately if you need them.

## Main sections / الأقسام الرئيسية (cycle 6)
- **Home / الرئيسية:** daily AI-generated architecture images (slideshow), Abu Dhabi clock (Gregorian + Hijri), weather, daily wisdom, Abu Dhabi Municipality news.
- **Design / التصميم:** seven-stage journey from brief to Binaa submission and shop drawings, with live status.
- **Review & edit / مراجعة وتعديل:** upload & review drawings, municipality comment tracker, response sheet.
- **Client presentation / عرض تقديمي:** slides + per-slide explanation, PowerPoint download.

## Features delivered so far / الميزات المنجزة
- Projects, intake wizard, facts with provenance, document register with checksums, readiness report.
- CAD workspace: DXF import/export, editing, undo/redo, checkpoints, typed walls/doors/windows.
- Bilingual copilot (Arabic/English) with preview → apply → undo.
- Rule engine (QA rules; Abu Dhabi rule templates awaiting verified sources), reports.
- Binaa: official source catalogue + manual submission workflow (no public API exists).
- Draw a new plan from a reference project.
- AutoCAD (local): DWG import/export, detailed plan sheet, elevations + section (DWG + PDF).

## Suggested next steps / الخطوات التالية المقترحة
- Upper-floor plans so elevations/sections show real upper-floor openings.
- Arabic text shaping on AutoCAD sheets.
- Register and verify official Abu Dhabi sources (needs a licensed reviewer).
