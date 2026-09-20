# Agent instructions

## Identity and scope

`reproducibleai` is the current repository. Treat its code, tests, configuration, and maintained documentation as the authoritative evidence for repository-local behavior.

## Always-applicable rules

- Inspect repository and Git evidence before making consequential changes.
- Keep this file concise; route detailed knowledge into maintained artifacts under `dev/`.
- Preserve unrelated user changes and keep work within the requested repository scope.
- Distinguish verified evidence, reasonable inference, and unknowns.
- Before implementation, read the workflow named by the matching route and use it to choose the change; finding or linking it is not sufficient.

## Conditional context routes

- Goals, scope, or success criteria: `dev/goals/`
- Architecture, dependencies, or ownership boundaries: `dev/architecture/`
- Consequential and durable choices: `dev/decisions/`
- Governance or artifact lifecycle: `dev/governance/`
- Repeatable development procedures: `dev/workflows/`
- Exact structural contracts: `dev/schemas/`
- Cohesive user-visible capabilities: `dev/features/`
- Resumable unfinished work: `dev/checkpoints/current/`
- R package code, dependencies, tests, documentation, build/check tooling or development automation: read `dev/workflows/r-package-development.md` before choosing tools or editing; inspect the relevant package sources and metadata.
- Agentic-routing questions, experiments, scoring, or reports: `dev/features/agentic-routing-evaluation.md`, `dev/schemas/project-schemas.md`, and `dev/workflows/agentic-routing-evaluation.md`

Full session transcripts are not normal context sources. Use maintained durable artifacts and concise checkpoints.

## Completion governance

Before declaring meaningful work complete, update the existing artifact that owns the changed goal, design, contract, workflow or behavior. Keep current instructions there; remove conflicting or superseded guidance. Dated records may retain necessary evidence, but must not be required reading for standing instructions. Check that the task route leads directly to the current procedure. Create a checkpoint only when useful unfinished state remains; do not add a completion report by default.

## Verification and information governance

Run checks proportionate to the change, inspect Git status and diff, and confirm the change boundary. Never record secrets, credentials, PII, restricted data, or unnecessarily large logs in agentic-context artifacts.
