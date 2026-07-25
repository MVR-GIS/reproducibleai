# Apply an approved agentic-context migration

Creates replacement content, validates the new structure, and only then
removes superseded legacy files. Files requiring manual review prevent
application.

## Usage

``` r
apply_agentic_context_migration(plan, approved = FALSE, quiet = FALSE)
```

## Arguments

- plan:

  A plan returned by
  [`plan_agentic_context_migration()`](https://mvr-gis.github.io/reproducibleai/reference/plan_agentic_context_migration.md).

- approved:

  Must be `TRUE`.

- quiet:

  Suppress progress messages.

## Value

An object of class `agentic_context_migration_result`.
