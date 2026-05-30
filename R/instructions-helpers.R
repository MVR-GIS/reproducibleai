#' Validate a non-empty character scalar
#'
#' Internal helper used to validate path-like and name-like scalar arguments.
#'
#' @param x Object to validate.
#' @param arg Character scalar naming the argument for error messages.
#'
#' @return A trimmed character scalar.
#' @keywords internal
validate_scalar_character <- function(x, arg = "x") {
  if (!is.character(x) || length(x) != 1 || is.na(x) || !nzchar(trimws(x))) {
    stop("`", arg, "` must be a non-empty character scalar.", call. = FALSE)
  }

  trimws(x)
}

#' Resolve the canonical source path for an instruction module
#'
#' Looks up a module's canonical static instruction file shipped with the package
#' in `inst/instructions/`.
#'
#' @param module_name Character scalar public module name in kebab-case.
#'
#' @return Character scalar path to the installed package file.
#' @keywords internal
module_source_path <- function(module_name) {
  module_name <- validate_scalar_character(module_name, "module_name")

  available_df <- instructions_available(include_path = TRUE)
  idx <- match(module_name, available_df$module)

  if (is.na(idx)) {
    stop(
      "No canonical instruction source file found for module '", module_name, "'.",
      call. = FALSE
    )
  }

  src <- available_df$path[[idx]]

  if (!file.exists(src)) {
    stop(
      "Source file missing for module '", module_name, "': ", src,
      call. = FALSE
    )
  }

  src
}

#' Build the target install path for an instruction module
#'
#' Computes the repository-local target path for installing a module into
#' `dev/instructions/`.
#'
#' @param module_name Character scalar public module name in kebab-case.
#' @param path Character scalar path to the target repository root.
#'
#' @return Character scalar path to the target installed file.
#' @keywords internal
module_target_path <- function(module_name, path = ".") {
  module_name <- validate_scalar_character(module_name, "module_name")
  path <- validate_scalar_character(path, "path")

  file.path(path, "dev", "instructions", paste0(module_name, ".md"))
}

#' Ensure that a directory exists
#'
#' Creates a directory recursively if needed and reports whether it was created.
#'
#' @param dir_path Character scalar directory path.
#'
#' @return A named list with elements:
#' \describe{
#'   \item{path}{Character scalar directory path.}
#'   \item{created}{Logical scalar; `TRUE` if created by this call.}
#' }
#' @keywords internal
ensure_dir <- function(dir_path) {
  dir_path <- validate_scalar_character(dir_path, "dir_path")

  if (file.exists(dir_path) && !dir.exists(dir_path)) {
    stop("Path exists but is not a directory: ", dir_path, call. = FALSE)
  }

  created <- FALSE

  if (!dir.exists(dir_path)) {
    ok <- dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
    if (!ok || !dir.exists(dir_path)) {
      stop("Failed to create directory: ", dir_path, call. = FALSE)
    }
    created <- TRUE
  }

  list(
    path = dir_path,
    created = created
  )
}

#' Install canonical static text for an instruction module
#'
#' Copies a module's canonical static markdown file from the installed package
#' into the target repository's `dev/instructions/` directory.
#'
#' @param module_name Character scalar public module name in kebab-case.
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#'
#' @return A named list with elements:
#' \describe{
#'   \item{module_name}{Character scalar module name.}
#'   \item{source}{Character scalar source file path.}
#'   \item{target}{Character scalar target file path.}
#'   \item{dirs_created}{Character vector of directories created.}
#'   \item{files_written}{Character vector of files written.}
#'   \item{files_skipped}{Character vector of files skipped because they already existed.}
#' }
#' @keywords internal
install_module_text <- function(module_name, path = ".", overwrite = FALSE) {
  module_name <- validate_scalar_character(module_name, "module_name")
  path <- validate_scalar_character(path, "path")

  if (!dir.exists(path)) {
    stop("`path` must be an existing directory: ", path, call. = FALSE)
  }

  if (!is.logical(overwrite) || length(overwrite) != 1 || is.na(overwrite)) {
    stop("`overwrite` must be TRUE/FALSE.", call. = FALSE)
  }

  src <- module_source_path(module_name)

  target_dir <- file.path(path, "dev", "instructions")
  dir_info <- ensure_dir(target_dir)

  target <- module_target_path(module_name, path = path)

  files_written <- character()
  files_skipped <- character()

  if (file.exists(target) && !overwrite) {
    files_skipped <- c(files_skipped, target)
  } else {
    ok <- file.copy(src, target, overwrite = overwrite)
    if (!ok || !file.exists(target)) {
      stop("Failed to install instruction file: ", target, call. = FALSE)
    }
    files_written <- c(files_written, target)
  }

  list(
    module_name = module_name,
    source = src,
    target = target,
    dirs_created = if (isTRUE(dir_info$created)) dir_info$path else character(),
    files_written = files_written,
    files_skipped = files_skipped
  )
}

#' Map a public module name to its handler function name
#'
#' Converts a kebab-case public module name to the corresponding internal
#' handler function name.
#'
#' @param module_name Character scalar public module name in kebab-case.
#'
#' @return Character scalar handler function name.
#' @keywords internal
module_name_to_handler <- function(module_name) {
  module_name <- validate_scalar_character(module_name, "module_name")
  paste0("module_", gsub("-", "_", module_name, fixed = TRUE))
}

#' Resolve a module handler function
#'
#' Looks up the handler function corresponding to a public module name.
#'
#' @param module_name Character scalar public module name in kebab-case.
#'
#' @return A function object.
#' @keywords internal
get_module_handler <- function(module_name) {
  handler_name <- module_name_to_handler(module_name)

  if (!exists(handler_name, mode = "function", inherits = TRUE)) {
    stop(
      "No handler function found for module '", module_name,
      "'. Expected function `", handler_name, "()`.",
      call. = FALSE
    )
  }

  handler <- get(handler_name, mode = "function", inherits = TRUE)

  if (!is.function(handler)) {
    stop(
      "Resolved handler object for module '", module_name,
      "' is not a function: `", handler_name, "`.",
      call. = FALSE
    )
  }

  handler
}

#' Construct a standard module handler result object
#'
#' Creates the standard structured result returned by module handlers.
#'
#' @param module_name Character scalar public module name in kebab-case.
#' @param instruction_source Character scalar source file path.
#' @param instruction_target Character scalar target file path.
#' @param dirs_created Character vector of created directories.
#' @param files_written Character vector of written files.
#' @param files_skipped Character vector of skipped files.
#' @param warnings Character vector of non-fatal warnings.
#' @param next_steps Character vector of recommended follow-up actions.
#'
#' @return A named list representing a module result object.
#' @keywords internal
new_module_result <- function(module_name,
                              instruction_source = character(),
                              instruction_target = character(),
                              dirs_created = character(),
                              files_written = character(),
                              files_skipped = character(),
                              warnings = character(),
                              next_steps = character()) {
  module_name <- validate_scalar_character(module_name, "module_name")

  list(
    module_name = module_name,
    instruction_source = as.character(instruction_source),
    instruction_target = as.character(instruction_target),
    dirs_created = as.character(dirs_created),
    files_written = as.character(files_written),
    files_skipped = as.character(files_skipped),
    warnings = as.character(warnings),
    next_steps = as.character(next_steps)
  )
}

#' Combine per-module handler results
#'
#' Aggregates multiple module result objects into a single combined result
#' suitable for higher-level orchestration.
#'
#' @param results Non-empty list of module result objects.
#'
#' @return A named list containing combined module processing results.
#' @keywords internal
combine_module_results <- function(results) {
  if (!is.list(results) || length(results) == 0) {
    stop("`results` must be a non-empty list of module result objects.", call. = FALSE)
  }

  modules_processed <- vapply(results, function(x) x$module_name, character(1))

  list(
    modules_processed = modules_processed,
    dirs_created = unlist(lapply(results, function(x) x$dirs_created), use.names = FALSE),
    files_written = unlist(lapply(results, function(x) x$files_written), use.names = FALSE),
    files_skipped = unlist(lapply(results, function(x) x$files_skipped), use.names = FALSE),
    warnings = unlist(lapply(results, function(x) x$warnings), use.names = FALSE),
    next_steps = unlist(lapply(results, function(x) x$next_steps), use.names = FALSE),
    results = results
  )
}

#' Normalize and de-duplicate requested module names
#'
#' Validates a user-supplied module vector, trims whitespace, and removes
#' duplicates while preserving first occurrence order.
#'
#' @param modules Character vector of public module names.
#'
#' @return Character vector of normalized module names.
#' @keywords internal
normalize_module_names <- function(modules) {
  if (!is.character(modules) || length(modules) == 0) {
    stop("`modules` must be a non-empty character vector.", call. = FALSE)
  }

  modules <- trimws(modules)

  if (anyNA(modules) || any(!nzchar(modules))) {
    stop("`modules` contains missing/empty module names.", call. = FALSE)
  }

  modules[!duplicated(modules)]
}

#' Validate requested modules against available modules
#'
#' Confirms that all requested module names are known to the package.
#'
#' @param modules Character vector of requested public module names.
#' @param available Character vector of available public module names.
#'
#' @return Invisibly returns `TRUE` if validation succeeds.
#' @keywords internal
validate_modules_available <- function(modules,
                                       available = instructions_available()) {
  modules <- normalize_module_names(modules)

  if (!is.character(available) || length(available) == 0) {
    stop("`available` must be a non-empty character vector.", call. = FALSE)
  }

  missing_mods <- setdiff(modules, available)

  if (length(missing_mods) > 0) {
    stop(
      "Unknown instruction module(s): ", paste(missing_mods, collapse = ", "),
      "\nAvailable modules: ", paste(sort(unique(available)), collapse = ", "),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Write a text file if needed
#'
#' Writes a text file when missing, or overwrites it if explicitly requested.
#'
#' @param path Character scalar file path.
#' @param lines Character vector of lines to write.
#' @param overwrite Logical scalar; whether an existing file may be overwritten.
#'
#' @return A named list with elements:
#' \describe{
#'   \item{path}{Character scalar file path.}
#'   \item{written}{Logical scalar; `TRUE` if the file was written.}
#'   \item{skipped}{Logical scalar; `TRUE` if the file was left unchanged.}
#' }
#' @keywords internal
write_text_file_if_needed <- function(path, lines, overwrite = FALSE) {
  path <- validate_scalar_character(path, "path")

  if (!is.character(lines)) {
    stop("`lines` must be a character vector.", call. = FALSE)
  }

  if (!is.logical(overwrite) || length(overwrite) != 1 || is.na(overwrite)) {
    stop("`overwrite` must be TRUE/FALSE.", call. = FALSE)
  }

  parent <- dirname(path)
  ensure_dir(parent)

  if (file.exists(path) && !overwrite) {
    return(list(
      path = path,
      written = FALSE,
      skipped = TRUE
    ))
  }

  writeLines(lines, con = path, useBytes = TRUE)

  list(
    path = path,
    written = TRUE,
    skipped = FALSE
  )
}
