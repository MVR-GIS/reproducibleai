# Build the target install path for an instruction module

Computes the repository-local target path for installing a module into
`dev/instructions/`.

## Usage

``` r
module_target_path(module_name, path = ".")
```

## Arguments

- module_name:

  Character scalar public module name in kebab-case.

- path:

  Character scalar path to the target repository root.

## Value

Character scalar path to the target installed file.
