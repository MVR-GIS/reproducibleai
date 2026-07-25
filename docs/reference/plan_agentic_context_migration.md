# Plan migration to durable agentic context

Inventories the target repository and returns proposed operations
without changing any files. Legacy artifacts remain in place until the
returned plan is explicitly approved and applied.

## Usage

``` r
plan_agentic_context_migration(path = ".", profiles = NULL)
```

## Arguments

- path:

  Existing repository root.

- profiles:

  Profiles to install. When `NULL`, detected profiles are used.

## Value

An object of class `agentic_context_migration_plan`.
