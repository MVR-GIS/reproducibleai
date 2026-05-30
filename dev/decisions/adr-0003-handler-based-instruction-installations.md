# ADR-0003: Adopt handler-based installation for static instruction modules

## Status
Accepted

## Date
2026-05-30

## Context
`reproducibleai` is built around a modular chat-instructions architecture. The package’s core strengths are:

- natural-language static instruction definitions
- instruction text that is easy to review by non-programmers
- simple user experience through recipe composition
- static instruction files stored in `inst/instructions/`, making version changes clear in Git
- consistency of deployed instructions across team repositories
- minimal complexity in a workflow domain that is still new and unfamiliar to many reviewers

The original installation model centered primarily on copying static instruction files into a target repository. As the package design evolved, some modules began to require supporting repository configuration in addition to instruction installation.

Examples include:
- development-governance, which requires scaffolding a standard `dev/` governance framework
- parameterized-help, which is expected to require supporting package-data and helper configuration for contextual help systems

A fully code-defined instruction system was considered, but rejected because it would weaken several important properties of the existing design:
- static reviewability of instruction text
- visibility of instruction changes in version control
- accessibility of instruction content to non-programmers
- trust and comprehensibility in a new workflow domain

A compromise architecture was therefore needed: one that preserves static instruction text as the canonical reviewed artifact while allowing module-specific setup behavior where necessary.

## Decision
`reproducibleai` will adopt a handler-based installation architecture for instruction modules.

Under this architecture:

1. Canonical instruction module text remains static markdown stored in:
   - `inst/instructions/`

2. Each public instruction module has a corresponding handler function named:
   - `module_<module_name>()`

3. Each handler has two responsibilities:
   - install the module’s canonical static instruction text into the target repository
   - perform any module-specific repository configuration required to support that module

4. If a module has no current configuration requirements, its handler still exists and performs a no-op configuration step.

5. `use_instructions()` remains the primary public entry point and becomes the orchestration layer that:
   - accepts module names or recipe outputs
   - normalizes and validates module selections
   - resolves module handlers
   - invokes handlers in order
   - aggregates and summarizes results

6. Handlers must not rewrite or dynamically customize the substantive wording of canonical instruction module text.

## Consequences

### Positive
- preserves the instruction-first design of the package
- keeps canonical instruction content static, reviewable, and easy to diff
- preserves simple recipe-based UX
- provides a uniform execution model for all modules
- allows module-specific setup and validation without forcing all modules into a code-defined content system
- supports future config-aware capabilities such as development-governance and parameterized-help
- keeps complexity localized within module handlers rather than in `use_instructions()`

### Tradeoffs
- adds implementation complexity relative to pure file copying
- requires a handler function for every public module
- introduces a small internal framework of helpers, result objects, and orchestration behavior
- requires tests to ensure consistency between canonical module files and implemented handlers

### Constraints
- static instruction markdown remains the authoritative instruction content
- handlers support installation and configuration, but do not redefine the module’s substantive text
- recipes remain simple compositions of public module names
- `use_instructions()` remains instruction-first rather than becoming a general automation engine

## Notes
This decision establishes the internal architecture used to implement future capabilities.

The first config-aware module under this model is:
- `development-governance`

A later config-aware module is expected for:
- `parameterized-help`

This decision also reinforces the requirement that `dev/40_schemas.md` be treated as a required governance artifact rather than an optional one in AI-assisted data-science-oriented repositories.
