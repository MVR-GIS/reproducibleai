# Agentic-context standard

## User outcome

A repository owner can create or adopt a compact, durable context structure that
Codex can discover automatically and that humans can review in ordinary Git
workflows.

## Supported journeys

### New repository

1. Detect or choose profiles.
2. Call `use_agentic_context()`.
3. Review the created `AGENTS.md`, routed artifacts, and manifest.
4. Run `validate_agentic_context()`.

### Existing repository

1. Call `plan_agentic_context_migration()` without changing the repository.
2. Review every create, preserve, move, remove, and manual-review operation.
3. Resolve manual-review items.
4. Apply the reviewed plan with explicit approval.
5. Review the durable migration report and Git diff.

### Continuous validation

Call `validate_agentic_context(strict = TRUE)` in tests or CI. Structural errors
fail validation; repository-owned edits relative to seed hashes remain warnings.

## Behavioral invariants

- Scaffolding never overwrites differing files.
- Profile detection never applies its recommendation.
- Planning never writes.
- Application never removes an untracked or modified source.
- Replacement structure validates before legacy removal starts.
- Destructive source hashes are rechecked immediately before mutation.
- Every applied removal is recorded.
- Package templates stop being authoritative after they are seeded.
- No model or Codex session is invoked by standard 0.1.

## Related authority

- Architecture: `dev/architecture/design.md`
- Decision: `dev/decisions/adr-0006-agentic-context-standard.md`
- Manual governance extension:
  `dev/governance/human-agent-decision-governance.md`
- Stabilizing decision:
  `dev/decisions/adr-0010-lean-human-agent-collaboration.md`
- Consequential-change workflow:
  `dev/workflows/investigate-decide-implement.md`
- Schemas: `dev/schemas/project-schemas.md`
- User article: `vignettes/agentic-context.Rmd`
