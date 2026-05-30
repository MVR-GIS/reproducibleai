# Checkpoint: handler-based instruction architecture and governance/schema consolidation

Date: 2026-05-30

## Summary
This checkpoint consolidates the design refactor that preserves `reproducibleai` as an instruction-first package while adding a uniform handler-based installation model for instruction modules.

## Key decisions captured
- `reproducibleai` remains instruction-first.
- Canonical instruction module text remains static markdown in `inst/instructions/`.
- Every public instruction module has a corresponding handler function named `module_<module_name>()`.
- Each handler:
  1. installs canonical static instruction text into `dev/instructions/`
  2. performs any module-specific configuration required for the target repository
- `use_instructions()` remains the main public entry point and is refactored to orchestrate handler dispatch rather than directly copying instruction files.
- Handlers must not rewrite substantive canonical instruction text.
- Recipes remain simple compositions of public module names.
- `dev/40_schemas.md` is a required development-governance artifact, not an optional one.

## Development-governance updates
- Development-governance is now the first config-aware module in the handler architecture.
- Its scaffold is defined to include:
  - `dev/05_plan.md`
  - `dev/10_design.md`
  - `dev/40_schemas.md`
  - `dev/decisions/`
  - `dev/decisions/README.md`
  - `dev/instructions/`
  - `dev/sessions/`
- Governance documentation now explicitly treats schema documentation as first-class and mandatory for AI-assisted data-science repositories.

## Parameterized-help updates
- Parameterized-help remains a static reviewed instruction module.
- It now explicitly recognizes the help-data contract as a maintained schema that should also be reflected in `dev/40_schemas.md`.
- It is expected to become a later config-aware module under the same handler architecture.

## Documentation artifacts drafted/updated
This design work produced draft or paste-ready updates for:
- `dev/05_plan.md`
- `dev/10_design.md`
- `dev/40_schemas.md`
- `dev/decisions/ADR-0002-handler-based-instruction-installation.md`
- `inst/instructions/development-governance.md`
- `inst/instructions/parameterized-help.md`

## Implementation direction
The agreed refactor sequence is:

1. implement internal helpers for handler-based installation
2. create simple handlers for all existing modules
3. refactor `use_instructions()` to dispatch through handlers
4. implement `module_development_governance()` as the first config-aware handler
5. later implement `module_parameterized_help()`

## Intent
This checkpoint preserves the original strengths of the modular chat-instructions architecture:
- natural-language static instructions
- reviewability by non-programmers
- simple recipe-based UX
- visible versioned changes in Git
- consistency across repositories
- minimal unnecessary complexity

while making room for stronger validation, scaffolding, and future extensibility where specific modules require operational support.
