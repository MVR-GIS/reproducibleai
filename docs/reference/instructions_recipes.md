# List recommended instruction-module recipes

Returns named recipe vectors that compose public instruction modules
into recommended starting points for common repository types or
workflows.

## Usage

``` r
instructions_recipes()
```

## Value

A named list of character vectors. Each element is a recipe composed of
public module names suitable for passing directly to
[`use_instructions()`](https://mvr-gis.github.io/reproducibleai/reference/use_instructions.md).

## Details

Recipes are intentionally lightweight: they are simple ordered character
vectors of public module names. They do not bypass
[`use_instructions()`](https://mvr-gis.github.io/reproducibleai/reference/use_instructions.md)
and they do not replace direct module selection when custom composition
is preferred.

Recipes are part of the package's instruction-first interface:

- canonical instruction content remains static markdown in
  `inst/instructions/`

- recipes provide recommended compositions of those modules

- [`use_instructions()`](https://mvr-gis.github.io/reproducibleai/reference/use_instructions.md)
  installs the selected modules into a target repository

## Examples

``` r
recipes <- instructions_recipes()
names(recipes)
#> [1] "r_package"                 "r_package_governed"       
#> [3] "python_package_governed"   "quarto_book"              
#> [5] "quarto_book_user_manual"   "shiny_golem"              
#> [7] "shiny_golem_help_governed"
recipes$r_package
#> [1] "chat-manual" "goals"       "r-package"  
```
