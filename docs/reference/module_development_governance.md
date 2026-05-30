# Install the development-governance instruction module

Installs the canonical `development-governance` instruction text and
scaffolds the standard `dev/` governance framework in the target
repository.

## Usage

``` r
module_development_governance(path = ".", overwrite = FALSE, ...)
```

## Arguments

- path:

  Character scalar path to the target repository root.

- overwrite:

  Logical scalar; whether handler-owned files may be overwritten.

- ...:

  Reserved for future extensibility.

## Value

A standard module result object.
