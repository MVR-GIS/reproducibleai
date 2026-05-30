#' Write selected instruction modules into a working directory
#'
#' Installs instruction modules shipped with the package into a local repository
#' `dev/instructions` folder for reference in reproducible chat sessions.
#' Also writes an entrypoint file (`CHAT_INSTRUCTIONS.md`) describing the
#' selected recipe and read order.
#'
#' Internally, module installation is delegated to module handler functions.
#'
#' @param spec Character vector of module tokens, e.g.
#'   `c("chat-manual", "goals", "r-package")`.
#' @param dest_dir Character. Destination directory (default: "dev/instructions").
#'   This must correspond to `<repo>/dev/instructions`, because instruction
#'   modules are installed through handlers that target the repository's
#'   standard `dev/instructions/` location.
#' @param overwrite Logical. Overwrite existing module files? (default: `TRUE`).
#'   Note: the entrypoint file `CHAT_INSTRUCTIONS.md` is always overwritten.
#' @param write_entrypoint Logical. Write `CHAT_INSTRUCTIONS.md`? (default: `TRUE`).
#' @param quiet Logical. Suppress informational messages? (default: `FALSE`).
#'
#' @return Character vector of written file paths (invisibly), including the
#'   entrypoint file when `write_entrypoint = TRUE`.
#'
#' @export
use_instructions <- function(spec,
                             dest_dir = "dev/instructions",
                             overwrite = TRUE,
                             write_entrypoint = TRUE,
                             quiet = FALSE) {
  # Validate inputs ----
  if (missing(spec)) {
    stop("`spec` is required (character vector of module tokens).", call. = FALSE)
  }
  if (!is.character(spec) || length(spec) == 0) {
    stop("`spec` must be a non-empty character vector.", call. = FALSE)
  }
  if (anyNA(spec) || any(!nzchar(trimws(spec)))) {
    stop("`spec` contains missing/empty module tokens.", call. = FALSE)
  }
  if (!is.character(dest_dir) || length(dest_dir) != 1 || !nzchar(dest_dir)) {
    stop("`dest_dir` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!is.logical(overwrite) || length(overwrite) != 1 || is.na(overwrite)) {
    stop("`overwrite` must be TRUE/FALSE.", call. = FALSE)
  }
  if (!is.logical(write_entrypoint) || length(write_entrypoint) != 1 || is.na(write_entrypoint)) {
    stop("`write_entrypoint` must be TRUE/FALSE.", call. = FALSE)
  }
  if (!is.logical(quiet) || length(quiet) != 1 || is.na(quiet)) {
    stop("`quiet` must be TRUE/FALSE.", call. = FALSE)
  }

  # Normalize and validate requested modules ----
  spec <- normalize_module_names(spec)
  validate_modules_available(spec)

  # Align legacy dest_dir interface with handler-based architecture ----
  dest_dir <- trimws(dest_dir)
  normalized_dest <- gsub("\\\\", "/", dest_dir)
  expected_suffix <- "dev/instructions"

  if (!identical(normalized_dest, expected_suffix) &&
      !endsWith(normalized_dest, paste0("/", expected_suffix))) {
    stop(
      "`dest_dir` must be `dev/instructions` or end with `/dev/instructions` ",
      "so it aligns with handler-based installation.",
      call. = FALSE
    )
  }

  repo_path <- sub(
    paste0("(/)?", expected_suffix, "$"),
    "",
    normalized_dest
  )

  if (!nzchar(repo_path)) {
    repo_path <- "."
  }

  if (!dir.exists(repo_path)) {
    ok <- dir.create(repo_path, recursive = TRUE, showWarnings = FALSE)
    if (!ok || !dir.exists(repo_path)) {
      stop("Failed to create repository root directory: ", repo_path, call. = FALSE)
    }
  }

  out_paths <- character(0)

  # Install modules through handlers ----
  for (mod in spec) {
    handler <- get_module_handler(mod)
    result <- handler(path = repo_path, overwrite = overwrite)

    if (length(result$files_written) > 0) {
      out_paths <- c(out_paths, result$files_written)
      if (!quiet) {
        for (path_written in result$files_written) {
          message("Wrote: ", path_written)
        }
      }
    }

    if (length(result$files_skipped) > 0 && !quiet) {
      for (path_skipped in result$files_skipped) {
        message("Skipped existing file: ", path_skipped)
      }
    }
  }

  # Write entrypoint file (ALWAYS overwrite) ----
  if (write_entrypoint) {
    entry_path <- file.path(repo_path, "dev", "instructions", "CHAT_INSTRUCTIONS.md")

    dir_info <- ensure_dir(dirname(entry_path))
    if (isTRUE(dir_info$created) && !quiet) {
      message("Created directory: ", dir_info$path)
    }

    spec_r <- paste(sprintf("%s", shQuote(spec)), collapse = ", ")
    spec_bullets <- paste0("- ", spec, collapse = "\n")
    file_list <- paste0(
      seq_along(spec), ". `", file.path("dev", "instructions", paste0(spec, ".md")), "`",
      collapse = "\n"
    )

    entry_text <- paste(
      "# Chat instructions for this repository (start here)",
      "",
      "This file is the entrypoint for **instruction modules** that govern a reproducible chat session for this repository.",
      "",
      "## How to start a new chat session",
      "In your first message, specify the target GitHub repository and direct the assistant to follow these instructions.",
      "",
      "Suggested prompt template:",
      "",
      "> Target repo: OWNER/REPO  ",
      "> Read `dev/instructions/CHAT_INSTRUCTIONS.md` and follow the instruction modules listed under **Selected instruction modules (read in order)**.",
      "",
      "## Instruction model used here (base + overlays)",
      "We use a composable instruction system:",
      "",
      "- **Base modules**: cross-cutting rules that apply to all chats (interaction protocol + quality goals).",
      "- **Overlay modules**: domain-specific guidance that applies when relevant (e.g., Quarto books, Shiny golem apps).",
      "",
      "Overlays are intended to be **thin** and should not duplicate the base modules.",
      "",
      "## Selected recipe (this repository)",
      "Selected recipe (R syntax):",
      "",
      "```r",
      paste0("c(", spec_r, ")"),
      "```",
      "",
      "Selected modules (tokens, in order):",
      "",
      spec_bullets,
      "",
      "## Selected instruction modules (read in order)",
      "Read these files in order:",
      "",
      file_list,
      "",
      "## If the assistant cannot read repository files",
      "If the chat platform cannot access repository files, paste the contents of:",
      "1) this file (`CHAT_INSTRUCTIONS.md`), then",
      "2) each of the modules listed above (in order),",
      "into the chat.",
      "",
      sep = "\n"
    )

    writeLines(entry_text, con = entry_path, useBytes = TRUE)

    out_paths <- c(out_paths, entry_path)
    if (!quiet) message("Wrote: ", entry_path)
  }

  invisible(out_paths)
}
