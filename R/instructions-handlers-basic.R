#' Install the chat-manual instruction module
#'
#' Installs the canonical `chat-manual` instruction text into the target
#' repository.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_chat_manual <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "chat-manual",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "chat-manual",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}

#' Install the goals instruction module
#'
#' Installs the canonical `goals` instruction text into the target repository.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_goals <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "goals",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "goals",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}

#' Install the python-package instruction module
#'
#' Installs the canonical `python-package` instruction text into the target
#' repository.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_python_package <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "python-package",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "python-package",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}

#' Install the quarto-book instruction module
#'
#' Installs the canonical `quarto-book` instruction text into the target
#' repository.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_quarto_book <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "quarto-book",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "quarto-book",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}

#' Install the r-package instruction module
#'
#' Installs the canonical `r-package` instruction text into the target
#' repository.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_r_package <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "r-package",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "r-package",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}

#' Install the shiny-golem instruction module
#'
#' Installs the canonical `shiny-golem` instruction text into the target
#' repository.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_shiny_golem <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "shiny-golem",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "shiny-golem",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}

#' Install the user-manual instruction module
#'
#' Installs the canonical `user-manual` instruction text into the target
#' repository.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_user_manual <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "user-manual",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "user-manual",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}

#' Install the development-governance instruction module
#'
#' Current B1 implementation installs the canonical static instruction text only.
#' Additional governance scaffolding will be added in a later config-aware
#' implementation step.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_development_governance <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "development-governance",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "development-governance",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}

#' Install the parameterized-help instruction module
#'
#' Current B1 implementation installs the canonical static instruction text only.
#' Additional help-framework scaffolding will be added in a later config-aware
#' implementation step.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether an existing installed file may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_parameterized_help <- function(path = ".", overwrite = FALSE, ...) {
  install <- install_module_text(
    module_name = "parameterized-help",
    path = path,
    overwrite = overwrite
  )

  new_module_result(
    module_name = "parameterized-help",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = install$dirs_created,
    files_written = install$files_written,
    files_skipped = install$files_skipped
  )
}
