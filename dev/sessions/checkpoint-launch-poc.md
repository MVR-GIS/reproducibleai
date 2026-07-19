# Session Checkpoint: Open WebUI + MCP Launch POC

**Date:** July 19, 2026  
**Purpose:** Preserve full context to restart in a fresh Copilot chat without losing momentum.

---

## Objective

Build a reliable `inst/local-workstation/launch.ps1` for local POC validation that:

1. Generates MCP config deterministically
2. Launches Open WebUI reliably
3. Verifies service readiness
4. Captures concise, useful diagnostics
5. Uses latest-only logs (not timestamp accumulation)

---

## Confirmed Signal

- Open WebUI successfully loaded after commit:  
  `bc81ad11beb1dfe5e9091d49a4bb049f18db2646`

This confirms launch viability and shifts focus to repeatability + MCP proof + clean logging.

---

## Key Requirements (User Decisions)

1. **Provide full paste-ready scripts** (no partial diff-only instructions)
2. **Prioritize speed for POC** over full hardening
3. Maintain a human-readable summary file in `dev/sessions/local-ai/`
4. Avoid log accumulation; use **latest-only** pattern
5. Remove recurring `ConvertFrom-Json -AsHashtable` noise/errors
6. Include timestamped log pruning capability (requested for later iteration, then accepted)

---

## Intended Logging Model

Use only these active files:

- `dev/sessions/local-ai/latest-terminal.log` *(from `load.ps1`)*
- `dev/sessions/local-ai/latest-launch-diag.log`
- `dev/sessions/local-ai/latest-open-webui.log`
- `dev/sessions/local-ai/latest-run-summary.md`

Optional/implemented cleanup target for old files:

- `open-webui-*.log`
- `launch-diag-*.log`
- `run-summary-*.md`
- `terminal-run-*.log`

---

## Technical Direction Chosen

### Pathing and execution
- Anchor script paths using `$PSScriptRoot` (not current working directory)
- Avoid requiring `cd` into script folder

### MCP config behavior
- Build defaults in script:
  - `local_filesystem`
  - `local_git`
- Merge optional overrides from:
  - `dev/config/open-webui-mcp-routing.json`
- Resolve tokens:
  - `${APPDATA}`, `${USERPROFILE}`, `${WORKSPACE_ROOT}`
- Validate command resolvability using:
  - `Test-Path` for path-like commands
  - `Get-Command` for PATH-resolved commands
- **Do not use** `ConvertFrom-Json -AsHashtable`

### Open WebUI launch behavior
- Primary launch:
  - `python -m open_webui serve`
- Fallback:
  - `open-webui.exe serve`
- Foreground debug option:
  - `-DebugForeground`

### Health checks
- Ollama:
  - `http://localhost:11434/api/tags`
- Open WebUI:
  - `http://localhost:8080`

---

## Scope Boundaries for Next Iteration

### In scope (POC-critical)
1. Deterministic MCP config generation
2. Reliable Open WebUI launch path
3. Basic readiness checks
4. Clear latest-only logs and summary output

### Out of scope (later hardening)
- Deep process ownership guarantees
- Exhaustive edge-case compatibility
- Multi-user operational hardening

---

## Known Pitfalls to Avoid

1. Reintroducing `-AsHashtable` path
2. CWD-dependent path calculations
3. Reintroducing timestamped log sprawl
4. Overcomplicating beyond MCP POC validation

---

## Suggested Fresh-Session Prompt

Use this in a new Copilot chat:

> Continue from this checkpoint. I’m building a local Open WebUI + MCP POC.  
> Please provide a **single full paste-ready `inst/local-workstation/launch.ps1`** with these constraints:
> - anchor paths via `$PSScriptRoot`
> - latest-only logs: `latest-launch-diag.log`, `latest-open-webui.log`, `latest-run-summary.md`
> - include pruning of legacy timestamped logs
> - no `ConvertFrom-Json -AsHashtable`
> - MCP config from defaults + optional `dev/config/open-webui-mcp-routing.json`
> - validate MCP command resolvability
> - set `MCP_CONFIG_PATH` and `ENABLE_MCP=true`
> - ensure Ollama reachable at `http://localhost:11434/api/tags`
> - launch with `python -m open_webui serve`, fallback to `open-webui.exe`
> - verify `http://localhost:8080` reachable
> - write human-readable run summary including MCP JSON preview
> Keep output formatting minimal and stable for copy/paste.

---

## Session Outcome

The session produced a clear architecture and operating model for `launch.ps1`, but output formatting instability in the web UI made copy/paste unreliable. This checkpoint is intended to preserve the agreed technical direction and allow clean restart in a new session.