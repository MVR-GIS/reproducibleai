# Local AI Run Summary

- Timestamp: 2026-07-19T14:40:29.0416147-05:00
- Status: FAIL
- Message: Cannot overwrite variable PID because it is read-only or constant.

## What this launcher validates
- Workspace path anchoring from repo root
- MCP config generation + command resolvability
- Ollama health endpoint reachability
- Open WebUI process launch and port 8080 readiness

## Problems solved in this iteration
- Switched to latest-only logs (no timestamped files).
- Removed ConvertFrom-Json -AsHashtable usage.
- Added human-readable latest-run-summary.md.

## Paths
- Diag Log: C:\workspace\MVR-GIS\reproducibleai\dev\sessions\local-ai\latest-launch-diag.log
- WebUI Log: C:\workspace\MVR-GIS\reproducibleai\dev\sessions\local-ai\latest-open-webui.log
- MCP Config: C:\Users\B5PMMMPD\AppData\Local\LocalAIStack\open-webui-data\mcp_config.json
- Data Dir: C:\Users\B5PMMMPD\AppData\Local\LocalAIStack\open-webui-data

## Endpoints
- Open WebUI: http://localhost:8080
- Ollama: http://localhost:11434