# Ensure that a directory exists

Creates a directory recursively if needed and reports whether it was
created.

## Usage

``` r
ensure_dir(dir_path)
```

## Arguments

- dir_path:

  Character scalar directory path.

## Value

A named list with elements:

- path:

  Character scalar directory path.

- created:

  Logical scalar; `TRUE` if created by this call.
