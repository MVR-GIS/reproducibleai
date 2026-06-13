# Project Plan

Last updated: 2026-05-30

## Purpose
This file is the canonical ordered task list for active development work.

## How to use
- Keep tasks small and concrete.
- Record definitions of done where helpful.
- Update this file when design discussions create follow-up work.
- When resuming work, read this file and `dev/10_design.md`.

## Now
- [ ] F1: Add a vignette describing the governed R package workflow using `r_package_governed`
- [ ] F2: Decide whether `instructions_recipes()` should remain a pure static recipe registry or regain optional internal validation
- [ ] F3: Decide whether to add stronger end-to-end coverage for `r_package_governed`

## Milestone A — establish handler architecture foundation

- [x] A1: Define internal helper layer for handler-based instruction installation
  - Definition of done:
    - Internal helpers exist for source path resolution, target path resolution, directory creation, static instruction installation, handler resolution, result construction, result aggregation, and module normalization/validation.
    - Helper behavior is covered by unit tests for normal and failure cases.
  - Completed:
    - helper implementations added in `R/instructions-helpers.R`
    - helper tests added in `tests/testthat/`
    - Rd files generated for helper functions

- [x] A2: Define standard handler contract and result object structure
  - Definition of done:
    - A consistent handler pattern is established for all modules.
    - A standard result object constructor exists and is used by handlers.
    - Handler naming convention is recorded in package design docs.
  - Completed:
    - handler/result contract implemented in helpers and handlers
    - naming and result schema documented in `dev/10_design.md` and `dev/40_schemas.md`
    - result-shape tests added

## Milestone B — migrate existing modules to handlers

- [x] B1: Implement simple handlers for all current instruction modules
  - Definition of done:
    - Every module returned by `instructions_available()` has a corresponding `module_<module_name>()` handler.
    - Simple handlers install canonical static module text from `inst/instructions/`.
    - Existing instruction content remains unchanged.
  - Completed:
    - basic handlers implemented in `R/instructions-handlers-basic.R`
    - config-aware handlers later extended for governance/help modules

- [x] B2: Add architecture test to verify every available module has a handler
  - Definition of done:
    - A test fails if any available public module lacks a corresponding handler function.
  - Completed:
    - handler coverage test added in `tests/testthat/`

## Milestone C — refactor orchestration

- [x] C1: Refactor `use_instructions()` to dispatch through module handlers
  - Definition of done:
    - `use_instructions()` normalizes modules, validates availability, resolves handlers, invokes them in order, aggregates results, and prints a concise summary.
    - Public UX remains recipe-first and module-name-based.
  - Completed:
    - `use_instructions()` now dispatches through handlers
    - public install flow preserved with `CHAT_INSTRUCTIONS.md` entrypoint writing

- [x] C2: Preserve recipe compatibility and deduplication behavior
  - Definition of done:
    - Existing recipe workflows still work.
    - Duplicate modules are removed while preserving first occurrence order.
  - Completed:
    - tests added for deduplication and ordering
    - recipe-based end-to-end flows added

## Milestone D — activate development-governance as first config-aware module

- [x] D1: Implement `module_development_governance()`
  - Definition of done:
    - Installs canonical `development-governance` instruction text into `dev/instructions/`.
    - Scaffolds required governance structure:
      - `dev/05_plan.md`
      - `dev/10_design.md`
      - `dev/40_schemas.md`
      - `dev/decisions/`
      - `dev/decisions/README.md`
      - `dev/instructions/`
      - `dev/sessions/`
    - Respects `overwrite = FALSE` by default.
  - Completed:
    - governance handler implementation added
    - scaffold helper writers added
    - overwrite/preservation tests added

- [x] D2: Document development-governance capability in package docs
  - Definition of done:
    - Reference docs explain what `module_development_governance()` does and does not do.
    - Package design docs capture the handler-based architecture and governance scaffold requirement.
  - Completed:
    - roxygen docs updated
    - README and package docs updated
    - design and decision docs updated earlier in session

## Milestone E — stabilize and validate refactor

- [x] E1: Add end-to-end tests for handler-based installation workflow
  - Definition of done:
    - A temporary repo fixture can install a recipe through `use_instructions()` and confirm expected outputs.
    - At least one flow includes `development-governance`.
  - Completed:
    - end-to-end tests added for standard install, governance install, parameterized-help install, and governed/help recipe workflows

- [x] E2: Update README/pkgdown guidance if needed
  - Definition of done:
    - Public documentation accurately describes the package’s instruction-first model.
    - If handler behavior is mentioned, it is described as internal support for static modules rather than a replacement for them.
  - Completed:
    - `README.Rmd` updated
    - `README.md` regenerated
    - package-level documentation and reference docs updated

## Milestone F — next additions

- [ ] F1: Add a vignette describing the governed R package workflow using `r_package_governed`
  - Definition of done:
    - A vignette explains what the governed recipe installs.
    - The vignette explains the roles of `dev/05_plan.md`, `dev/10_design.md`, `dev/40_schemas.md`, `dev/decisions/`, `dev/instructions/`, and `dev/sessions/`.
    - The vignette shows how to start a governed workflow with `use_instructions(instructions_recipes()$r_package_governed)`.
  - Expected artifacts:
    - new vignette in `vignettes/`
    - vignette listed by `vignette(package = "reproducibleai")`

- [ ] F2: Decide whether `instructions_recipes()` should remain a pure static recipe registry or regain optional internal validation
  - Definition of done:
    - The intended contract for `instructions_recipes()` is explicit and stable.
    - Tests match that contract without ambiguity.
  - Expected artifacts:
    - function docs update if needed
    - test cleanup if needed

- [ ] F3: Add end-to-end test for `r_package_governed`
  - Definition of done:
    - An end-to-end test installs `instructions_recipes()$r_package_governed`.
    - The test verifies both installed module files and governance scaffold artifacts.
  - Expected artifacts:
    - test added in `tests/testthat/test-use_instructions_e2e.R`


## Milestone G — define local and hybrid AI methodology

- [ ] G1: Define governed AI context resource classification
  - Definition of done:
    - A stable first-pass classification exists for repository artifacts that should be treated as governed AI context.
    - The classification identifies at least the initial roles of:
      - `dev/05_plan.md`
      - `dev/10_design.md`
      - `dev/40_schemas.md`
      - `dev/decisions/`
      - `dev/instructions/`
    - The classification is documented in the local AI architecture design work and is specific enough to guide future deployment helpers and evaluation.
  - Expected artifacts:
    - updates to `dev/15_local_ai_architecture.md`
    - possible later promotion into `dev/10_design.md`

- [ ] G2: Define first formal rule-tier and runtime-artifact architecture
  - Definition of done:
    - A first formal package taxonomy exists for:
      - canonical instruction sources
      - core runtime rules
      - task overlays
      - local-adapted runtime artifacts
    - The taxonomy explains how human-readable sources relate to client-facing runtime artifacts.
    - Traceability expectations between source instructions and derived runtime artifacts are documented.
  - Expected artifacts:
    - updates to `dev/15_local_ai_architecture.md`
    - possible later updates to `inst/instructions/` or `dev/instructions/`

- [ ] G3: Define first Continue deployment pattern
  - Definition of done:
    - A first supported deployment pattern is defined for Continue workspace-local runtime artifacts.
    - The design clarifies which artifacts belong in user-level client configuration versus workspace-level repository artifacts.
    - The pattern is specific enough to guide future handler or helper implementation.
  - Expected artifacts:
    - updates to `dev/15_local_ai_architecture.md`
    - possible later handler/helper design in `R/`

- [ ] G4: Define first MCP-aware integration slice
  - Definition of done:
    - A first package-level MCP integration concept is defined.
    - The design identifies the initial governed resources, tools, and prompts most appropriate for MCP exposure.
    - The package boundary is clear about what `reproducibleai` will scaffold or define versus what external MCP tooling should provide.
  - Expected artifacts:
    - updates to `dev/15_local_ai_architecture.md`
    - possible later ADR if MCP-aware integration becomes a formal package direction

- [ ] G5: Define competency-question evaluation structure for local and hybrid workflows
  - Definition of done:
    - A first evaluation structure is defined for competency-question-based workflow testing.
    - The design identifies how local-context-aware behavior will be evaluated.
    - The design identifies how hosted, local, and MCP-enabled workflows may be compared where appropriate.
  - Expected artifacts:
    - updates to `dev/15_local_ai_architecture.md`
    - possible later test scaffolding in `tests/testthat/`

- [ ] G6: Decide whether local/hybrid AI methodology should become a formal package decision
  - Definition of done:
    - The team has enough design and implementation clarity to decide whether this architecture direction should be promoted into:
      - `dev/10_design.md`
      - a new ADR in `dev/decisions/`
    - Promotion criteria are explicit enough to avoid premature stabilization.
  - Expected artifacts:
    - possible update to `dev/10_design.md`
    - possible new ADR in `dev/decisions/`
    