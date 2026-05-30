#' List recommended instruction-module recipes
#'
#' Returns named recipe vectors that compose public instruction modules into
#' recommended starting points for common repository types or workflows.
#'
#' Recipes are intentionally lightweight: they are simple ordered character
#' vectors of public module names. They do not bypass `use_instructions()` and
#' they do not replace direct module selection when custom composition is
#' preferred.
#'
#' @return A named list of character vectors. Each element is a recipe composed
#'   of public module names suitable for passing directly to `use_instructions()`.
#'
#' @details
#' Recipes are part of the package's instruction-first interface:
#' \itemize{
#'   \item canonical instruction content remains static markdown in `inst/instructions/`
#'   \item recipes provide recommended compositions of those modules
#'   \item `use_instructions()` installs the selected modules into a target repository
#' }
#'
#' @examples
#' recipes <- instructions_recipes()
#' names(recipes)
#' recipes$r_package
#'
#' @export
instructions_recipes <- function() {
  list(
    r_package = c("chat-manual", "goals", "r-package"),
    shiny_golem = c("chat-manual", "goals", "r-package", "shiny-golem"),
    quarto_book = c("chat-manual", "goals", "quarto-book"),
    python_package = c("chat-manual", "goals", "python-package")
  )
}
