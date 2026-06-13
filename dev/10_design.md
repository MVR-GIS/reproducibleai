# Design

Last updated: 2026-05-30

## Purpose
This document records the current stable architecture, operating assumptions, and capability boundaries for `reproducibleai`.

The package is intended to support reproducible AI-assisted development workflows by standardizing:
- modular chat instructions
- recipe-based instruction composition
- transparent deployment of reviewed instruction text into target repositories
- lightweight configuration support where specific modules require supporting repository structure

## Document map
- Plan: `dev/05_plan.md`
- Schemas: `dev/40_schemas.md`
- Decisions: `dev/decisions/`
- Instructions: `dev/instructions/`
- Sessions: `dev/sessions/`

## Core architecture

### Instruction-first model
`reproducibleai` remains instruction-first.

The primary user-facing workflow is still:
1. discover available instruction modules
2. compose modules into a recipe
3. install them into a target repository with `use_instructions()`

This design is intentional. The package prioritizes:
- natural-language instruction definitions
- easy review by non-programmers
- simple UX through recipe composition
- visible, versioned static instruction text
- consistency across team repositories
- low conceptual complexity in a new workflow domain

### Static canonical instruction text
Canonical instruction module text is stored as static markdown in:

- `inst/instructions/`

These files are the authoritative reviewed instruction contents. They are intended to remain:
- easy to diff in Git
- readable by non-programmers
- stable across installations
- consistent across repositories using the same package version

Handlers and orchestration code must not rewrite or dynamically customize the substantive wording of these canonical instruction files.

### Handler-based installation model
Each public instruction module has a corresponding handler function named:

- `module_<module_name>()`

where:
- the public module name remains kebab-case
- the handler function name uses snake_case

Examples:
- `development-governance` -> `module_development_governance()`
- `parameterized-help` -> `module_parameterized_help()`

Each handler has two responsibilities:
1. copy the module’s canonical static instruction text from `inst/instructions/` into the target repository’s `dev/instructions/`
2. perform any module-specific repository configuration needed to support use of that module

If a module has no configuration needs, the configuration step is a no-op, but the handler still exists.

This provides one uniform execution model without giving up the static, reviewable instruction architecture.

### `use_instructions()` orchestration role
`use_instructions()` remains the main public entry point for installing instructions.

Its role is to:
- accept module names or recipe outputs
- normalize and validate requested modules
- resolve module handlers
- invoke handlers in order
- aggregate and summarize results

`use_instructions()` should not contain module-specific setup logic beyond generic orchestration. Module-specific behavior belongs in the corresponding handler.

### Module categories
The current architecture supports two practical categories of modules.

#### Simple handlers
These modules:
- install static instruction text
- return a standard result object
- perform no additional repo configuration

Examples include:
- `chat-manual`
- `goals`
- `r-package`
- `python-package`
- `quarto-book`
- `user-manual`

#### Config-aware handlers
These modules:
- install static instruction text
- scaffold or validate supporting repository structure
- return a standard result object that records installation and configuration actions

The first config-aware module is:
- `development-governance`

A later config-aware module is expected for:
- `parameterized-help`

## Development-governance capability

### Purpose
`reproducibleai` standardizes a development-governance framework for AI-assisted repositories that use iterative chat sessions as part of normal development work.

The goal is to make important outcomes from chat sessions durable, concise, and reviewable by promoting them into structured repository artifacts rather than leaving them only in archived session transcripts.

### Governance model
The package assumes that internal development-state artifacts live in a repository `dev/` directory, while user-facing package documentation is communicated through standard package surfaces such as:
- `README`
- roxygen/man pages
- vignettes/articles
- pkgdown site pages

### Standard internal artifacts
The development-governance framework centers on these required artifacts:

- `dev/05_plan.md` for active work planning
- `dev/10_design.md` for stable current-state architecture and design
- `dev/40_schemas.md` for structural contracts and schema documentation
- `dev/decisions/` for decision records
- `dev/instructions/` for modular chat/developer guidance
- `dev/sessions/` for archived transcripts

`dev/40_schemas.md` is required, not optional. In AI-assisted data science repositories, undocumented schemas and implicit structural assumptions are a common source of fragile, buggy behavior. Structural contracts should therefore be documented explicitly.

### Behavioral enforcement
This capability is enforced primarily through instruction modules and chat behavior rather than through heavy automation of substantive document writing.

The intended workflow is:
1. install the development-governance instruction module
2. scaffold the governance structure in the repository through the module handler
3. use instruction modules to condition chat sessions to monitor for governance-update triggers
4. require the chat session to provide paste-ready updates to the relevant `dev/` artifacts when durable project state changes

### Handler support model
The `development-governance` module is the first config-aware module in the handler architecture.

Its handler is responsible for:
- installing canonical `development-governance` instruction text into `dev/instructions/`
- scaffolding the required governance artifacts in the target repository
- preserving existing files by default unless overwrite is explicitly requested

Its handler is not responsible for:
- generating repo-specific design content
- writing actual plans or ADRs for the user
- replacing the chat session’s role in producing paste-ready governance updates during real work

### Scope boundaries
This governance capability is distinct from domain-specific package functionality.

It governs:
- documentation roles
- document precedence
- session-to-document promotion
- durable design capture
- explicit schema documentation as part of development continuity

It does not govern:
- package-specific implementation logic
- user-facing instructional content except where governance boundaries must be clarified

### Package responsibilities
`reproducibleai` should support this capability through:
- canonical static instruction modules in `inst/instructions/`
- module handlers that install instructions and scaffold required supporting structure
- `use_instructions()` as the high-level orchestration entry point
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

This capability also reinforces the importance of explicit schema documentation, since the help system itself defines a maintained structured data contract.

### Runtime helper model
The preferred model is for app packages to import reusable help helpers from `reproducibleai` rather than copying them into each app repository.

`reproducibleai` should provide the reusable runtime behavior, while app repositories should own:
- their help content
- their help composition choices
- their app-specific help wording

### Handler support model
The `parameterized-help` module is expected to become a config-aware module under the same handler architecture used by development-governance.

Its handler should be responsible for:
- installing canonical `parameterized-help` instruction text
- scaffolding the package-data help framework where appropriate
- supporting a consistent help-data architecture across applications

### Maintenance model
This capability assumes that help is part of the app’s maintained interface.

When app functionality changes, help should be reviewed for:
- missing IDs
- stale names
- stale formulas
- stale unit descriptions
- composition mismatches with current UI surfaces

## Design invariants
The following are current architectural invariants:

- Canonical instruction text remains static in `inst/instructions/`.
- Every public instruction module has a corresponding handler function.
- Handlers install static instruction text and may perform module-specific configuration.
- Handlers do not rewrite substantive canonical instruction text.
- `use_instructions()` remains the main public entry point.
- Recipes remain simple compositions of public module names.
- `dev/40_schemas.md` is a required development-governance artifact.
- Development-governance is the first config-aware module in the handler architecture.
- Parameterized-help is expected to become a later config-aware module.

## Open questions
- Finalize helper implementations and tests for the handler-based refactor.
- Decide whether `use_instructions()` should return its combined result visibly or invisibly.
- Decide how `instructions_available()` should validate consistency between canonical source files and implemented handlers.

***

## Active architecture extension

The current stable package architecture remains instruction-first and handler-based as described above.

In parallel, the package is actively developing a broader architecture direction for local and hybrid AI workflows. That work extends the current package model toward:
- hybrid frontier-model and local-model methodology
- client-facing runtime rule artifacts derived from canonical instruction sources
- competency-question-based evaluation of AI workflows
- MCP-aware integration for exposing governed resources, tools, and prompts to compatible clients

This work is not yet considered part of the stable implemented architecture recorded in this document.

The active design proposal and follow-up plan for that extension currently live in:
- `dev/15_local_ai_architecture.md`
- `dev/decisions/adr-0004-hybrid-ai-methodology-and-mcp-aware-integration.md`
- `dev/05_plan.md` under Milestone G

Stable outcomes from that work may later require updates to this design document.
