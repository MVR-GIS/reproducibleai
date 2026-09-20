# R package development

## Trigger and evidence

Read this workflow before changing R package code, dependencies, tests,
documentation, build/check tooling or development automation. Inspect the relevant
`DESCRIPTION`, `NAMESPACE`, `R/`, `tests/testthat/`, roxygen/`man/`,
`README.md` or `README.Rmd`, vignettes and pkgdown configuration.

## Choose the standard facility first

| Task | Usual entry point |
| --- | --- |
| Load development code | `devtools::load_all()` or `pkgload::load_all()` |
| Test behavior | `devtools::test()` or `testthat::test_local()` |
| Generate function documentation | `devtools::document()` or `roxygen2::roxygenise()` |
| Build/check the package | `devtools::check()` or standard `R CMD build` / `R CMD check` |
| Build the documentation site | `pkgdown::build_site()` |

Before adding or retaining a wrapper, inspect the existing tool's supported
options. Use metadata and configuration when they meet the need. Custom code must
address a demonstrated gap; record the standard facility considered, the gap and
when the workaround can be removed in a short code comment or existing workflow.
A script's existence or successful execution is not justification for keeping it.
Keep installation and workstation setup explicit and independently usable.

## Placement and verification

- Keep installed behavior in `R/`; regression assertions and controlled fixtures
  in the standard package test workflow. Use temporary outputs and scoped cleanup.
- Evaluate explicit opt-in conditions for live integration tests. Do not use real
  analyst data as automatic fixtures. Retain separate diagnostics only where
  their inputs or execution requirements warrant it.
- `dev/` may hold necessary developer tools; it must not become a parallel test
  suite or a replacement package-management interface. Do not add frameworks or
  dependencies solely to reorganize existing scripts.
- Keep implementation, exports, help, examples and tests aligned. Run focused
  tests first, then broader checks proportionate to the change; do not rebuild
  every artifact for dev-only prose edits.

## Completion

Review the diff for duplicate responsibilities, implicit side effects and
superseded wrappers. Update the existing workflow to describe the current
procedure, removing conflicting instructions. Verify that the AGENTS route and
this workflow suffice to choose the normal commands without reading a dated
report. Report relevant verification and remaining exceptions in the response;
do not create a routine completion narrative. Review generated changes separately.
