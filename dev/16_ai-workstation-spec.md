# AI Workstation Spec (POC): Open WebUI + MCP + Local Model Runtime

## Purpose
Document the current proof-of-concept architecture for a local/hybrid AI workstation aligned to `reproducibleai` governance and Milestone G integration goals.

## Architecture (POC)
- **Model runtime:** Ollama (`http://localhost:11434`)
- **UI/orchestrator:** Open WebUI (`http://localhost:8080`)
- **Tool integration:** Native STDIO MCP servers launched from local command wrappers
- **Repo-governed MCP routing:** `dev/config/open-webui-mcp-routing.json`
- **Launcher:** `inst/local-workstation/launch.ps1`

## Verified constraint findings (environment-driven)
1. Some Python/Rust installer flows can fail under strict endpoint controls and file locking.
2. Isolated process contexts may not inherit expected global JS/Node path assumptions.
3. Enterprise network controls can block/alter installer fetch behavior.
4. Open WebUI persisted config can override current env values unless persistent config is constrained.

## POC operating decisions
- Keep POC implementation simple and deterministic.
- Prefer latest-only logs over timestamp accumulation.
- Build MCP config from defaults + optional repo override.
- Resolve path tokens at runtime (`${APPDATA}`, `${USERPROFILE}`, `${WORKSPACE_ROOT}`).
- Validate MCP command resolvability before launch.
- Disable persistent Open WebUI config for this POC path (`ENABLE_PERSISTENT_CONFIG=false`).

## Active runtime artifacts (latest-only)
- `dev/sessions/local-ai/latest-launch-diag.log`
- `dev/sessions/local-ai/latest-open-webui.log`
- `dev/sessions/local-ai/latest-run-summary.md`
- `dev/sessions/local-ai/latest-mcp-config.resolved.json`

## Acceptance criteria for this POC
1. Launcher generates resolved MCP JSON deterministically.
2. Launcher sets `ENABLE_MCP=true` and `MCP_CONFIG_PATH`.
3. Ollama health endpoint responds (`/api/tags`) or failure is clearly logged.
4. Open WebUI launch attempts primary and fallback modes with clear diagnostics.
5. Open WebUI reachability check is performed and summarized.
6. Run summary includes MCP server validation + JSON preview.

## Governance boundary
This POC defines repository-scaffolded launch behavior and MCP routing conventions.  
It does **not** attempt to turn `reproducibleai` into:
- a general model runtime,
- a generic MCP host,
- or a full local workstation management platform.

That boundary remains aligned with ADR-0004.