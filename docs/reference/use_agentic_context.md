# Scaffold durable agentic context

Creates a versioned repository context structure centered on `AGENTS.md`
and durable artifacts under `dev/`. Existing files are never
overwritten.

## Usage

``` r
use_agentic_context(
  path = ".",
  profiles = c("base", "r-package"),
  quiet = FALSE
)
```

## Arguments

- path:

  Existing repository root.

- profiles:

  Character vector of profiles. `base` is always included.

- quiet:

  Suppress progress messages.

## Value

An object of class `agentic_context_result`.
