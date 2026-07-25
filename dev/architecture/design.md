# Agentic-context standard 0.1 design

## System boundary

`{reproducibleai}` owns generic, deterministic R functions and versioned static
templates for creating, migrating, and validating repository context. A target
repository owns every file after it is seeded.

`FG-architecture` owns FluvialGeomorph-specific architecture and adoption
policy. Model execution and routing evaluation are not part of standard 0.1.

## Context model

```text
task prompt
  -> applicable AGENTS.md
  -> conditional route
  -> maintained repository evidence
  -> implementation and verification
  -> durable artifact update
  -> checkpoint only when unfinished work must resume
```

Root `AGENTS.md` contains concise, always-applicable rules and routes. Detailed
goals, architecture, decisions, governance, workflows, schemas, features, and
checkpoints live under `dev/`. Full transcripts are not working context.

## Profiles

The required `base` profile defines the common context structure. Declarative
overlays add repository-type routes and artifacts. Standard 0.1 includes only
`r-package`.

Profile detection returns candidates and evidence. It never mutates a
repository or silently applies a profile.

## Scaffolding

Templates live under `inst/agentic-context/<standard-version>/<profile>/`.
Rendering substitutes only deterministic repository metadata and profile
routes. Scaffolding preflights all targets:

- absent target: create;
- identical target: preserve;
- differing target: stop before writing anything.

There is no overwrite option.

## Manifest and ownership

`dev/agentic-context.yml` records:

- manifest schema version;
- agentic-context standard version;
- installing package and package version;
- hash algorithm;
- selected profiles; and
- seeded file hashes.

Hashes identify drift from the seed; they do not make the package authoritative
over later edits. A changed seeded file is a validation warning.

## Migration

Migration is deliberately separated:

1. `plan_agentic_context_migration()` inventories and classifies without writes.
2. A human reviews the structured operations.
3. `apply_agentic_context_migration(..., approved = TRUE)` rechecks source
   hashes, creates the scaffold, copies mapped artifacts, and validates.
4. Only after validation does it remove superseded sources.
5. It writes a durable report enumerating adaptations and removals.

Untracked sources, uncommitted source changes, conflicting destinations, and
unknown content become `manual_review` operations and block application.

## Validation

Validation returns a structured object with `valid` and a findings data frame.
Errors cover missing structural requirements, missing routes, unsupported
versions, and missing seeded files. Warnings cover repository-owned drift and
remaining legacy context.

Validation evaluates structure, not scientific correctness or semantic quality.

## Public API

- `use_agentic_context()`
- `detect_agentic_context_profiles()`
- `plan_agentic_context_migration()`
- `apply_agentic_context_migration()`
- `validate_agentic_context()`

SBOM functions remain separate package capabilities.
