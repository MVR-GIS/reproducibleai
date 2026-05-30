# List available instruction modules shipped with the package

Discovers instruction modules from `inst/instructions/*.md` at runtime.
These module names are the public identifiers used in recipes and
[`use_instructions()`](https://mvr-gis.github.io/reproducibleai/reference/use_instructions.md).

## Usage

``` r
instructions_available(include_path = FALSE)
```

## Arguments

- include_path:

  Logical; if `TRUE`, return a data frame with module names and file
  paths. If `FALSE` (default), return a character vector of module
  names.

## Value

If `include_path = FALSE`, a character vector of public module names. If
`include_path = TRUE`, a data frame with columns:

- module:

  Public module name in kebab-case.

- path:

  Installed package path to the canonical markdown file.

## Details

Canonical instruction content remains static markdown stored in
`inst/instructions/`. Installation into a target repository is handled
by internal module handlers, but the discovered module names remain the
public user-facing interface.

## Examples

``` r
instructions_available()
#> [1] "chat-manual"            "development-governance" "goals"                 
#> [4] "parameterized-help"     "python-package"         "quarto-book"           
#> [7] "r-package"              "shiny-golem"            "user-manual"           
instructions_available(include_path = TRUE)
#>                   module
#> 1            chat-manual
#> 2 development-governance
#> 3                  goals
#> 4     parameterized-help
#> 5         python-package
#> 6            quarto-book
#> 7              r-package
#> 8            shiny-golem
#> 9            user-manual
#>                                                                                                                                                                    path
#> 1            C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/chat-manual.md
#> 2 C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/development-governance.md
#> 3                  C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/goals.md
#> 4     C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/parameterized-help.md
#> 5         C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/python-package.md
#> 6            C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/quarto-book.md
#> 7              C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/r-package.md
#> 8            C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/shiny-golem.md
#> 9            C:/Users/B5PMMMPD/AppData/Local/R/cache/R/renv/library/reproducibleai-f2dbcda7/windows/R-4.5/x86_64-w64-mingw32/reproducibleai/instructions/user-manual.md
```
