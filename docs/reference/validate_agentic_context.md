# Validate durable agentic context

Checks the structural contract, manifest, routes, and seeded-file drift.
This validator does not judge the scientific or semantic quality of
repository content.

## Usage

``` r
validate_agentic_context(path = ".", strict = FALSE)
```

## Arguments

- path:

  Existing repository root.

- strict:

  When `TRUE`, error if validation errors are found.

## Value

An object of class `agentic_context_validation`.
