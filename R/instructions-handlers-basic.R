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
#' Installs the canonical `development-governance` instruction text and
#' scaffolds the standard `dev/` governance framework in the target repository.
#'
#' @param path Character scalar path to the target repository root.
#' @param overwrite Logical scalar; whether handler-owned files may be
#'   overwritten.
#' @param ... Reserved for future extensibility.
#'
#' @return A standard module result object.
#' @keywords internal
module_development_governance <- function(path = ".", overwrite = FALSE, ...) {
  path <- validate_scalar_character(path, "path")

  if (!dir.exists(path)) {
    stop("`path` must be an existing directory: ", path, call. = FALSE)
  }

  if (!is.logical(overwrite) || length(overwrite) != 1 || is.na(overwrite)) {
    stop("`overwrite` must be TRUE/FALSE.", call. = FALSE)
  }

  install <- install_module_text(
    module_name = "development-governance",
    path = path,
    overwrite = overwrite
  )

  dirs_created <- install$dirs_created
  files_written <- install$files_written
  files_skipped <- install$files_skipped

  dir_paths <- c(
    file.path(path, "dev"),
    file.path(path, "dev", "decisions"),
    file.path(path, "dev", "instructions"),
    file.path(path, "dev", "sessions")
  )

  for (dir_path in dir_paths) {
    dir_info <- ensure_dir(dir_path)
    if (isTRUE(dir_info$created)) {
      dirs_created <- c(dirs_created, dir_info$path)
    }
  }

  today <- format(Sys.Date(), "%Y-%m-%d")

  plan_lines <- c(
    "# Project Plan",
    "",
    paste0("Last updated: ", today),
    "",
    "## Purpose",
    "This file is the canonical ordered task list for active development work.",
    "",
    "## How to use",
    "- Keep tasks small and concrete.",
    "- Record definitions of done where helpful.",
    "- Update this file when design discussions create follow-up work.",
    "- When resuming work, read this file and `dev/10_design.md`.",
    "",
    "## Now",
    "- [ ] Add immediate next task",
    "",
    "## Upcoming",
    "- [ ] Add next milestone or task group"
  )

  design_lines <- c(
    "# Design",
    "",
    paste0("Last updated: ", today),
    "",
    "## Purpose",
    "This document records the current stable architecture, operating assumptions, and capability boundaries for the repository.",
    "",
    "## Document map",
    "- Plan: `dev/05_plan.md`",
    "- Schemas: `dev/40_schemas.md`",
    "- Decisions: `dev/decisions/`",
    "- Instructions: `dev/instructions/`",
    "- Sessions: `dev/sessions/`",
    "",
    "## Current design",
    "Add stable architecture and design notes here.",
    "",
    "## Open questions",
    "- [ ] Add unresolved design questions here"
  )

  schema_lines <- c(
    "# Schemas",
    "",
    paste0("Last updated: ", today),
    "",
    "## Purpose",
    "This document records important structural contracts used by the repository, including data objects, files, tables, configuration structures, and other interfaces whose shape must remain explicit.",
    "",
    "## How to use",
    "- Add schemas for any durable data structures that other code depends on.",
    "- Record required fields, types, constraints, and invariants where relevant.",
    "- Update this file when new structured artifacts are introduced or existing ones change.",
    "",
    "## Schemas",
    "",
    "### Example schema",
    "| Field | Type | Required | Notes |",
    "|---|---|---|---|",
    "| id | character | yes | Stable identifier |"
  )

  decisions_readme_lines <- c(
    "# Decision Records",
    "",
    "This directory stores durable design and architecture decisions.",
    "",
    "Use this directory for decisions that:",
    "- materially affect future work",
    "- involve tradeoffs or alternatives",
    "- should remain easy to review over time",
    "",
    "Do not use this directory for task tracking or transient session notes."
  )

  scaffold_files <- list(
    "dev/05_plan.md" = plan_lines,
    "dev/10_design.md" = design_lines,
    "dev/40_schemas.md" = schema_lines,
    "dev/decisions/README.md" = decisions_readme_lines
  )

  for (relative_path in names(scaffold_files)) {
    write_info <- write_text_file_if_needed(
      path = file.path(path, relative_path),
      lines = scaffold_files[[relative_path]],
      overwrite = overwrite
    )

    if (isTRUE(write_info$written)) {
      files_written <- c(files_written, write_info$path)
    }
    if (isTRUE(write_info$skipped)) {
      files_skipped <- c(files_skipped, write_info$path)
    }
  }

  new_module_result(
    module_name = "development-governance",
    instruction_source = install$source,
    instruction_target = install$target,
    dirs_created = unique(dirs_created),
    files_written = unique(files_written),
    files_skipped = unique(files_skipped),
    next_steps = c(
      "Review `dev/05_plan.md`.",
      "Review `dev/10_design.md`.",
      "Review `dev/40_schemas.md`.",
      "Add decision records under `dev/decisions/` as needed."
    )
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
