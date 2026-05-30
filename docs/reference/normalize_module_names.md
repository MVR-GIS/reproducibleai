# Normalize and de-duplicate requested module names

Validates a user-supplied module vector, trims whitespace, and removes
duplicates while preserving first occurrence order.

## Usage

``` r
normalize_module_names(modules)
```

## Arguments

- modules:

  Character vector of public module names.

## Value

Character vector of normalized module names.
