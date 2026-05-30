# Schemas

Last updated: 2026-05-30

## Purpose
This document records important structural contracts used by the repository, including data objects, files, configuration structures, and other interfaces whose shape must remain explicit.

## How to use
- Add schemas for any durable structures that other code depends on.
- Record required fields, types, constraints, and invariants where relevant.
- Update this file when new structured artifacts are introduced or existing ones change.
- Treat instruction module contracts and handler result shapes as maintained package interfaces.

## Schemas

## Instruction module name schema

### Purpose
Define the canonical public naming convention for instruction modules.

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| `module_name` | character scalar | yes | kebab-case | Public module identifier used in recipes and `use_instructions()` |

### Invariants
- Public module names are kebab-case.
- Public module names are the canonical identifiers exposed to users.
- Recipe definitions compose public module names rather than handler function names.

### Examples
- `chat-manual`
- `goals`
- `r-package`
- `development-governance`
- `parameterized-help`

## Handler function name schema

### Purpose
Define the deterministic mapping from a public module name to its handler function.

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| `handler_name` | character scalar | yes | `module_` prefix + snake_case | Internal function name used by `use_instructions()` dispatch |

### Mapping rule
Convert a public module name to a handler name by:
1. replacing `-` with `_`
2. prefixing with `module_`

### Examples
| Public module name | Handler function |
|---|---|
| `chat-manual` | `module_chat_manual()` |
| `r-package` | `module_r_package()` |
| `development-governance` | `module_development_governance()` |
| `parameterized-help` | `module_parameterized_help()` |

### Invariants
- Every public instruction module has a corresponding handler function.
- Handler naming is deterministic.
- `use_instructions()` dispatch depends on this mapping.

## Canonical instruction source file schema

### Purpose
Define the package-side source location for canonical static instruction text.

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| `source_path` | file path | yes | `inst/instructions/<module_name>.md` | Canonical reviewed module text stored in package source |

### Invariants
- Canonical instruction text is stored as static markdown in `inst/instructions/`.
- Source instruction files are the authoritative reviewed module contents.
- Handlers must not rewrite the substantive contents of canonical instruction files.

### Examples
- `inst/instructions/chat-manual.md`
- `inst/instructions/development-governance.md`
- `inst/instructions/parameterized-help.md`

## Installed instruction target file schema

### Purpose
Define the target-repository location for installed module text.

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| `target_path` | file path | yes | `<repo>/dev/instructions/<module_name>.md` | Installed module text in target repository |

### Invariants
- Installed instruction files live in `dev/instructions/` in the target repository.
- Target file names are derived predictably from public module names.
- The canonical source text and installed target text should match substantively.

### Examples
- `dev/instructions/chat-manual.md`
- `dev/instructions/development-governance.md`

## Module handler function interface schema

### Purpose
Define the standard interface for module handler functions.

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| `path` | character scalar | yes | existing directory path | Target repository root |
| `overwrite` | logical scalar | yes | `TRUE` or `FALSE` | Whether handler-owned files may be replaced |
| `...` | variadic | yes | reserved for extensibility | Future shared handler arguments |

### Standard conceptual signature
```r
module_<name>(path = ".", overwrite = FALSE, ...)
```

### Invariants
- Every handler accepts `path` and `overwrite`.
- `overwrite = FALSE` is the safe default.
- Additional arguments must not undermine the static-text-first architecture.

## Module handler result object schema

### Purpose
Define the standard structured result returned by a module handler.

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| `module_name` | character scalar | yes | valid public module name | Module that produced the result |
| `instruction_source` | character scalar | yes | file path | Canonical source instruction file |
| `instruction_target` | character scalar | yes | file path | Installed instruction target file |
| `dirs_created` | character vector | yes | path vector, possibly empty | Directories created by handler |
| `files_written` | character vector | yes | path vector, possibly empty | Files written by handler |
| `files_skipped` | character vector | yes | path vector, possibly empty | Existing files preserved by handler |
| `warnings` | character vector | yes | possibly empty | Non-fatal warnings |
| `next_steps` | character vector | yes | possibly empty | Recommended follow-up actions |

### Invariants
- All handlers return the same result shape.
- Empty vectors are preferred over `NULL` for absent path/action collections.
- Result objects must distinguish written files from skipped files.

## `use_instructions()` combined result schema

### Purpose
Define the standard aggregate result returned after orchestrating multiple module handlers.

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| `modules_processed` | character vector | yes | ordered unique public module names | Modules run in final execution order |
| `dirs_created` | character vector | yes | aggregated path vector | Combined directories created |
| `files_written` | character vector | yes | aggregated path vector | Combined files written |
| `files_skipped` | character vector | yes | aggregated path vector | Combined files skipped |
| `warnings` | character vector | yes | aggregated warning vector | Combined non-fatal warnings |
| `next_steps` | character vector | yes | aggregated next-step vector | Combined follow-up guidance |
| `results` | list | yes | list of module handler result objects | Raw per-module results |

### Invariants
- `modules_processed` preserves execution order after deduplication.
- Each element of `results` conforms to the module handler result schema.
- Aggregate vectors are derived from the per-module results.

## Development-governance scaffold schema

### Purpose
Define the required repository artifacts created or enforced by the development-governance module.

| Artifact | Type | Required | Notes |
|---|---|---|---|
| `dev/05_plan.md` | file | yes | Canonical active work plan |
| `dev/10_design.md` | file | yes | Stable current-state design document |
| `dev/40_schemas.md` | file | yes | Explicit structural/schema contracts |
| `dev/decisions/` | directory | yes | Decision records |
| `dev/decisions/README.md` | file | yes | Directory purpose guidance |
| `dev/instructions/` | directory | yes | Installed instruction modules |
| `dev/sessions/` | directory | yes | Archived session transcripts |

### Invariants
- `dev/40_schemas.md` is required, not optional.
- Development-governance scaffolding must preserve existing user content by default.
- The development-governance handler installs both the module instruction text and the supporting governance structure.

## Parameterized-help data schema

### Purpose
Record the core structured-data contract implied by the parameterized-help capability.

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| `id` | character | yes | unique, stable | Canonical help identifier |
| `title` | character | yes | non-empty | Display title |
| `summary` | character | yes | concise | Orientation text |
| `detail` | character | yes | may be long-form | Full explanation |

### Invariants
- Help records are referenced by stable IDs.
- Help content is managed as structured package data.
- The help-data schema is part of the maintained app interface.
