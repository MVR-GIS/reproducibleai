# Construct a standard module handler result object

Creates the standard structured result returned by module handlers.

## Usage

``` r
new_module_result(
  module_name,
  instruction_source = character(),
  instruction_target = character(),
  dirs_created = character(),
  files_written = character(),
  files_skipped = character(),
  warnings = character(),
  next_steps = character()
)
```

## Arguments

- module_name:

  Character scalar public module name in kebab-case.

- instruction_source:

  Character scalar source file path.

- instruction_target:

  Character scalar target file path.

- dirs_created:

  Character vector of created directories.

- files_written:

  Character vector of written files.

- files_skipped:

  Character vector of skipped files.

- warnings:

  Character vector of non-fatal warnings.

- next_steps:

  Character vector of recommended follow-up actions.

## Value

A named list representing a module result object.
