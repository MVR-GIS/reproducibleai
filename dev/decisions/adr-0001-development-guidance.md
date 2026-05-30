# ADR-0001: Adopt development-governance as a first-class `reproducibleai` capability

## Status
Accepted

## Context
`reproducibleai` is intended to support reproducible AI-assisted workflows across repositories and chat sessions. In practice, long-form AI-assisted development work produces important requirements, architectural decisions, workflow conventions, and implementation plans that should not remain only in chat transcripts.

The team has found that a repository-local `dev/` framework with separate documents for plan, design, decisions, instructions, and session archives provides strong continuity across sessions and helps maintain a concise record of project state.

## Decision
`reproducibleai` will adopt development governance as a first-class package capability.

This capability will standardize:
- the use of `dev/` artifacts for internal project governance
- the distinction between internal governance documents and user-facing package documentation
- instruction modules that require chat sessions to promote important durable outcomes into structured repository artifacts
- scaffolding support for establishing the governance structure in new repositories

For R packages, user-facing workflow and operational guidance should normally be published through vignettes/articles and pkgdown rather than through a separate internal runbook.

## Consequences
### Positive
- durable capture of architecture, decisions, and work plans
- improved continuity across chat sessions
- less reliance on raw transcripts as the source of truth
- reusable governance conventions across team repositories

### Tradeoffs
- requires deliberate maintenance of `dev/` artifacts
- introduces more structured documentation conventions than a minimal package workflow
- relies on instruction-module compliance by chat sessions and developers

## Notes
This decision establishes the governance framework as separate from package-specific functional modules such as parameterized help for `golem`-based Shiny apps.
