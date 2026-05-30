# Validate a non-empty character scalar

Internal helper used to validate path-like and name-like scalar
arguments.

## Usage

``` r
validate_scalar_character(x, arg = "x")
```

## Arguments

- x:

  Object to validate.

- arg:

  Character scalar naming the argument for error messages.

## Value

A trimmed character scalar.
