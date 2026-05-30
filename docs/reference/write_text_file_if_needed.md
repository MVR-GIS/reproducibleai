# Write a text file if needed

Writes a text file when missing, or overwrites it if explicitly
requested.

## Usage

``` r
write_text_file_if_needed(path, lines, overwrite = FALSE)
```

## Arguments

- path:

  Character scalar file path.

- lines:

  Character vector of lines to write.

- overwrite:

  Logical scalar; whether an existing file may be overwritten.

## Value

A named list with elements:

- path:

  Character scalar file path.

- written:

  Logical scalar; `TRUE` if the file was written.

- skipped:

  Logical scalar; `TRUE` if the file was left unchanged.
