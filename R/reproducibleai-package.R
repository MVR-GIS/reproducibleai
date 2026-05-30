#' reproducibleai: Reproducible AI-assisted development workflows
#'
#' `{reproducibleai}` provides tools for building reproducible, reviewable
#' AI-assisted workflows around reusable instruction modules.
#'
#' The package is instruction-first:
#' \itemize{
#'   \item canonical instruction content is stored as static markdown in `inst/instructions/`
#'   \item public workflows compose modules by name or via lightweight recipes
#'   \item `use_instructions()` installs selected modules into `dev/instructions/`
#'   \item internal handlers support installation and, for selected modules,
#'         supporting repository scaffolding
#' }
#'
#' This design keeps instruction content easy to review and diff while allowing
#' selected modules such as `development-governance` to scaffold the repository
#' structure they depend on.
#'
#' @docType _PACKAGE
#' @name reproducibleai
NULL