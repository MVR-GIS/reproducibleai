# Agentic-context migration 0.1

- Applied: 2026-07-24
- Profiles: base, r-package
- Policy: replacements were created and validated before tracked legacy sources were removed.

## Adapted artifacts

- `dev/05_plan.md` -> `dev/goals/project-plan.md`
- `dev/10_design.md` -> `dev/architecture/design.md`
- `dev/40_schemas.md` -> `dev/schemas/project-schemas.md`

Additional repository-specific architecture and development scripts were routed
from the `dev/` root into `dev/architecture/` and `dev/scripts/`.

## Removed artifacts

- `dev/instructions/CHAT_INSTRUCTIONS.md`: replaced by root `AGENTS.md`.
- `dev/instructions/chat-manual.md`: replaced by standing rules and conditional routes.
- `dev/instructions/development-governance.md`: adapted into governance and workflow artifacts.
- `dev/instructions/goals.md`: adapted into the goals route.
- `dev/instructions/r-package.md`: adapted into the R-package profile.
- `dev/instructions/user-manual.md`: superseded instruction copy.
- `dev/sessions/.backups/2026-04-14_backup_20260414_171631.md`: historical transcript backup.
- `dev/sessions/2026-04-14.md`: historical session transcript.
- `dev/sessions/2026-04-16.md`: historical session transcript.
- `dev/sessions/2026-04-17.md`: historical session transcript.
- `dev/sessions/2026-04-26.md`: historical session transcript.
- `dev/sessions/2026-05-30.md`: historical session transcript.
- `dev/sessions/2026-06-0-local-rag-gameplan.md`: relevant direction retained in routed architecture and decisions.
- `dev/sessions/2026-06-13.md`: historical session transcript.
- `dev/sessions/checkpoint-attention-degradation.md`: superseded checkpoint.
- `dev/sessions/checkpoint-handler-architecture-summary.md`: superseded checkpoint.
- `dev/sessions/checkpoint-launch-poc.md`: superseded checkpoint.
- `dev/sessions/checkpoint-local-ai-workstation.md`: relevant state retained in routed architecture.
- `dev/sessions/local-ai/latest-continue-mcp.resolved.json`: generated runtime output.
- `dev/sessions/local-ai/latest-deploy-diag.log`: generated diagnostic log.
- `dev/sessions/local-ai/latest-launch-diag.log`: generated diagnostic log.
- `dev/sessions/local-ai/latest-mcp-config.resolved.json`: generated runtime output.
- `dev/sessions/local-ai/latest-run-summary.md`: generated runtime summary.
- `dev/sessions/local-ai/terminal-run.log`: generated terminal log.

Raw `dev/deploy-log.md` and `dev/launch-log.md` were also removed as generated
operational history.

Two tracked files named `.webui_secret_key` were removed without inspecting or
reproducing their contents. Any credential they may have contained must be
treated as exposed through Git history and rotated.

## Verification

- Replacement files copied: 3
- Superseded files removed by the generic migration: 27
- The standard structure passed validation before removal.
- Git history remains the archive for superseded content.
