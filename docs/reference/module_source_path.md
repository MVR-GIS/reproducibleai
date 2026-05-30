# Resolve the canonical source path for an instruction module

Looks up a module's canonical static instruction file shipped with the
package in `inst/instructions/`.

## Usage

``` r
module_source_path(module_name)
```

## Arguments

- module_name:

  Character scalar public module name in kebab-case.

## Value

Character scalar path to the installed package file.
