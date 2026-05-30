#' List available instruction modules shipped with the package
#'
#' Discovers instruction modules from `inst/instructions/*.md` at runtime.
#' These module names are the public identifiers used in recipes and
#' `use_instructions()`.
#'
#' Canonical instruction content remains static markdown stored in
#' `inst/instructions/`. Installation into a target repository is handled by
#' internal module handlers, but the discovered module names remain the public
#' user-facing interface.
#'
#' @param include_path Logical; if `TRUE`, return a data frame with module names
#'   and file paths. If `FALSE` (default), return a character vector of module
#'   names.
#'
#' @return If `include_path = FALSE`, a character vector of public module names.
#'   If `include_path = TRUE`, a data frame with columns:
#' \describe{
#'   \item{module}{Public module name in kebab-case.}
#'   \item{path}{Installed package path to the canonical markdown file.}
#' }
#'
#' @examples
#' instructions_available()
#' instructions_available(include_path = TRUE)
#'
#' @export
instructions_available <- function(include_path = FALSE) {
  stopifnot(is.logical(include_path), length(include_path) == 1)

  dir <- system.file("instructions", package = "reproducibleai")
  if (!nzchar(dir) || !dir.exists(dir)) {
    stop(
      "No instructions directory found in installed package. ",
      "Expected 'inst/instructions' to be installed and discoverable via system.file().",
      call. = FALSE
    )
  }

  paths <- list.files(dir, pattern = "\\.md$", full.names = TRUE)
  paths <- paths[!grepl("/_", paths)]  # ignore underscore files (_manifest.md, etc.)

  modules <- sub("\\.md$", "", basename(paths))

  ord <- order(modules)
  modules <- modules[ord]
  paths <- paths[ord]

  if (!include_path) {
    return(modules)
  }

  data.frame(
    module = modules,
    path = paths,
    stringsAsFactors = FALSE
  )
}
