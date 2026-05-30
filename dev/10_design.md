## Development-governance capability

### Purpose
`reproducibleai` standardizes a development-governance framework for AI-assisted repositories that use iterative chat sessions as part of normal development work.

The goal is to make important outcomes from chat sessions durable, concise, and reviewable by promoting them into structured repository artifacts rather than leaving them only in archived transcripts.

### Governance model
The package assumes that internal development-state artifacts live in a repository `dev/` directory, while user-facing package documentation is communicated through standard package surfaces such as:
- `README`
- roxygen/man pages
- vignettes/articles
- pkgdown site pages

### Standard internal artifacts
The governance framework centers on these artifacts:

- `dev/05_plan.md` for active work planning
- `dev/10_design.md` for stable current-state architecture and design
- `dev/decisions/` for decision records
- `dev/instructions/` for modular chat/developer guidance
- `dev/sessions/` for archived transcripts

An optional `dev/40_schemas.md` may be used when exact structural contracts need centralized documentation.

### Behavioral enforcement
This capability is enforced primarily through instruction modules rather than through heavy automation.

The intended workflow is:
1. scaffold the governance structure in the repository
2. use instruction modules to condition chat sessions to monitor for governance-update triggers
3. require the chat session to provide paste-ready updates to the relevant `dev/` artifacts when durable project state changes

### Scope boundaries
This governance capability is distinct from domain-specific package functionality.

It governs:
- documentation roles
- document precedence
- session-to-document promotion
- durable design capture

It does not govern:
- package-specific implementation logic
- user-facing instructional content except where governance boundaries must be clarified

### Package responsibilities
`reproducibleai` should support this capability through:
- scaffolding functions that establish the `dev/` governance structure
- instruction modules that define chat behavior for maintaining it
- published package documentation that explains the governance framework to users



## Parameterized-help capability

### Purpose
`reproducibleai` standardizes a reusable pattern for contextual help in `golem`-based Shiny apps developed as R packages.

This capability is intended to help teams implement help systems that are:
- structured as package data
- composed from stable reusable records
- rendered through shared helper functions
- maintainable as app functionality evolves

### Scope
This capability governs:
- help-data architecture
- help-data storage and package-data conventions
- stable help IDs
- composition and rendering of contextual help
- help-specific CSS support
- integrity and drift review practices

It does not govern:
- app domain logic
- general Shiny architecture
- general package governance outside the help system

### Standard architecture
The package assumes a help-data workflow with:
- `data-raw/create_help_data.R` as the authoring script
- `data/help_data.rda` as the package dataset
- `R/help_data.R` as dataset documentation
- stable `id`, `title`, `summary`, and `detail` fields
- overview and granular help records composed into app surfaces

### Runtime helper model
The preferred model is for app packages to import reusable help helpers from `reproducibleai` rather than copying them into each app repository.

`reproducibleai` should provide the reusable runtime behavior, while app repositories should own:
- their help content
- their help composition choices
- their app-specific help wording

### Maintenance model
This capability assumes that help is part of the app’s maintained interface.

When app functionality changes, help should be reviewed for:
- missing IDs
- stale names
- stale formulas
- stale unit descriptions
- composition mismatches with current UI surfaces
