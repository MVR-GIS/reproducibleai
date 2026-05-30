# ADR-0002: Adopt parameterized help for `golem`-based Shiny apps as a `reproducibleai` capability

## Status
Accepted

## Context
The team has developed and validated a contextual-help pattern in a `golem`-based Shiny app in which help content is stored as structured package data, referenced by stable IDs, and composed into multiple UI surfaces through reusable rendering helpers.

This pattern proved useful for maintaining consistency across help surfaces, reducing duplication, and supporting drift review as app functionality evolved.

## Decision
`reproducibleai` will adopt parameterized contextual help for `golem`-based Shiny apps as a first-class package capability.

This capability will standardize:
- structured help data with required fields
- package-data storage conventions for help content
- stable IDs as the contract between help data and UI references
- reusable runtime helpers for composing and rendering help
- scaffolding support for help-system setup in app repositories
- maintenance expectations for integrity checks and drift review

The default model is that app repositories import reusable runtime helpers from `reproducibleai` rather than copying those helpers locally.

## Consequences
### Positive
- improves consistency and maintainability of contextual help systems
- reduces duplicated prose across app surfaces
- supports integrity checking and drift review
- makes the pattern reusable across multiple `golem` apps

### Tradeoffs
- introduces an opinionated help-system architecture
- requires deliberate maintenance of help data during app evolution
- assumes a package-based app structure and is not intended as a generic pattern for all Shiny contexts

## Notes
This capability is separate from the broader development-governance capability. Development governance covers how repositories maintain durable design and decision records; parameterized help covers how a Shiny app implements and maintains contextual help as part of its user interface.
