# Install canonical static text for an instruction module

Copies a module's canonical static markdown file from the installed
package into the target repository's `dev/instructions/` directory.

## Usage

``` r
install_module_text(module_name, path = ".", overwrite = FALSE)
```

## Arguments

- module_name:

  Character scalar public module name in kebab-case.

- path:

  Character scalar path to the target repository root.

- overwrite:

  Logical scalar; whether an existing installed file may be overwritten.

## Value

A named list with elements:

- module_name:

  Character scalar module name.

- source:

  Character scalar source file path.

- target:

  Character scalar target file path.

- dirs_created:

  Character vector of directories created.

- files_written:

  Character vector of files written.

- files_skipped:

  Character vector of files skipped because they already existed.
