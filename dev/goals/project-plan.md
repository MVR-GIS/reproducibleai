# Project plan

## Purpose

Develop `{reproducibleai}` as the reusable implementation of durable agentic
context for repositories, then build quantitative routing evaluation only after
target repositories adopt that standard.

## Current objective

Complete agentic-context standard 0.1:

- deterministic scaffolding for new repositories;
- advisory profile detection;
- read-only migration planning;
- explicitly approved create–validate–remove migration;
- structured validation for interactive use and CI;
- clean removal of instruction modules and transcript tooling; and
- self-adoption by `{reproducibleai}`.

Status: implemented on `feat/agentic-context-standard-v0.1`.

## Acceptance criteria

- `base` and `r-package` profiles produce deterministic, idempotent output.
- Existing differing files are never overwritten.
- Migration planning writes nothing.
- Untracked, modified, or unresolved legacy sources block removal.
- Migration copies mapped content, validates replacements, and removes sources last.
- Every removal is recorded in a durable migration report.
- Structural validation distinguishes errors from repository-owned drift warnings.
- Public documentation and tests describe only the new model.
- R package checks pass in a compatible restored environment.

## Verification record

- 60 `testthat` expectations passed with no failures, warnings, or skips.
- A source tarball was built with both vignettes.
- `R CMD check --no-manual` on the source tarball completed with `Status: OK`.
- The pkgdown site rebuilt with the new API and agentic-context article.
- Installed-package self-adoption is idempotent and validation reports zero findings.

## Rollout after this branch

1. Review the generic output against `FG-architecture` without copying its
   organization-specific content into the package.
2. Plan and apply migrations for `fluvgeo` and `ohwm2`, which contain known
   calls to the removed instruction API.
3. Inventory the remaining FluvialGeomorph repositories and add only profiles
   justified by observed repository types.
4. Establish comparable routing fixtures across adopted repositories.
5. Begin a separate routing-evaluation feature branch.

## Deferred work

- Codex CLI or SDK execution
- repeated-run competency questions
- routing sensitivity analysis
- quantitative health reports
- prompt or specification tuning
- automatic semantic migration
- nested `AGENTS.md` generation
- automatic three-way standard upgrades
