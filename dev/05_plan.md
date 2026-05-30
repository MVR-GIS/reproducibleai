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
- [ ] A1: Define internal helper layer for handler-based instruction installation
- [ ] B1: Implement simple handlers for all current instruction modules
- [ ] C1: Refactor `use_instructions()` to dispatch through module handlers

## Milestone A — establish handler architecture foundation

- [ ] A1: Define internal helper layer for handler-based instruction installation
  - Definition of done:
    - Internal helpers exist for source path resolution, target path resolution, directory creation, static instruction installation, handler resolution, result construction, result aggregation, and module normalization/validation.
    - Helper behavior is covered by unit tests for normal and failure cases.
  - Expected artifacts:
    - helper implementations in `R/`
    - helper tests in `tests/testthat/`

- [ ] A2: Define standard handler contract and result object structure
  - Definition of done:
    - A consistent handler pattern is established for all modules.
    - A standard result object constructor exists and is used by handlers.
    - Handler naming convention is recorded in package design docs.
  - Expected artifacts:
    - handler contract in code
    - design doc update
    - tests for result shape

## Milestone B — migrate existing modules to handlers

- [ ] B1: Implement simple handlers for all current instruction modules
  - Definition of done:
    - Every module returned by `instructions_available()` has a corresponding `module_<module_name>()` handler.
    - Simple handlers install canonical static module text from `inst/instructions/`.
    - Existing instruction content remains unchanged.
  - Expected artifacts:
    - handler implementations in `R/`
    - handler coverage tests

- [ ] B2: Add architecture test to verify every available module has a handler
  - Definition of done:
    - A test fails if any available public module lacks a corresponding handler function.
  - Expected artifacts:
    - handler coverage test in `tests/testthat/`

## Milestone C — refactor orchestration

- [ ] C1: Refactor `use_instructions()` to dispatch through module handlers
  - Definition of done:
    - `use_instructions()` normalizes modules, validates availability, resolves handlers, invokes them in order, aggregates results, and prints a concise summary.
    - Public UX remains recipe-first and module-name-based.
  - Expected artifacts:
    - updated `use_instructions()` implementation
    - orchestration tests

- [ ] C2: Preserve recipe compatibility and deduplication behavior
  - Definition of done:
    - Existing recipe workflows still work.
    - Duplicate modules are removed while preserving first occurrence order.
  - Expected artifacts:
    - tests for recipe compatibility
    - tests for deduplication/order preservation

## Milestone D — activate development-governance as first config-aware module

- [ ] D1: Implement `module_development_governance()`
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
  - Expected artifacts:
    - governance handler implementation
    - scaffold templates or helper writers
    - tests for file/directory creation and overwrite behavior

- [ ] D2: Document development-governance capability in package docs
  - Definition of done:
    - Reference docs explain what `module_development_governance()` does and does not do.
    - Package design docs capture the handler-based architecture and governance scaffold requirement.
  - Expected artifacts:
    - roxygen docs
    - pkgdown reference output
    - `dev/10_design.md`
    - decision record if needed

## Milestone E — stabilize and validate refactor

- [ ] E1: Add end-to-end tests for handler-based installation workflow
  - Definition of done:
    - A temporary repo fixture can install a recipe through `use_instructions()` and confirm expected outputs.
    - At least one flow includes `development-governance`.
  - Expected artifacts:
    - end-to-end tests in `tests/testthat/`

- [ ] E2: Update README/pkgdown guidance if needed
  - Definition of done:
    - Public documentation accurately describes the package’s instruction-first model.
    - If handler behavior is mentioned, it is described as internal support for static modules rather than a replacement for them.
  - Expected artifacts:
    - `README.Rmd`
    - `README.md`
    - pkgdown documentation updates
    