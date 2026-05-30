# Validate requested modules against available modules

Confirms that all requested module names are known to the package.

## Usage

``` r
validate_modules_available(modules, available = instructions_available())
```

## Arguments

- modules:

  Character vector of requested public module names.

- available:

  Character vector of available public module names.

## Value

Invisibly returns `TRUE` if validation succeeds.
