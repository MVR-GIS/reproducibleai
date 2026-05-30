# Write selected instruction modules into a working directory

Installs instruction modules shipped with the package into a local
repository `dev/instructions` folder for reference in reproducible chat
sessions. Also writes an entrypoint file (`CHAT_INSTRUCTIONS.md`)
describing the selected recipe and read order.

## Usage

``` r
use_instructions(
  spec,
  dest_dir = "dev/instructions",
  overwrite = TRUE,
  write_entrypoint = TRUE,
  quiet = FALSE
)
```

## Arguments

- spec:

  Character vector of module tokens, e.g.
  `c("chat-manual", "goals", "r-package")`.

- dest_dir:

  Character. Destination directory (default: "dev/instructions"). This
  must correspond to `<repo>/dev/instructions`, because instruction
  modules are installed through handlers that target the repository's
  standard `dev/instructions/` location.

- overwrite:

  Logical. Overwrite existing module files? (default: `TRUE`). Note: the
  entrypoint file `CHAT_INSTRUCTIONS.md` is always overwritten.

- write_entrypoint:

  Logical. Write `CHAT_INSTRUCTIONS.md`? (default: `TRUE`).

- quiet:

  Logical. Suppress informational messages? (default: `FALSE`).

## Value

Character vector of file paths written during the call (invisibly),
including the entrypoint file when `write_entrypoint = TRUE`. Existing
module files preserved because `overwrite = FALSE` are not included.

## Details

Internally, module installation is delegated to module handler
functions.
