#' Create a flat competency-review table
#'
#' Converts a generated benchmark into the human-review surface used by
#' `write_agentic_routing_review()`. Reviewers may edit `review_status`,
#' `review_note`, `prompt`, and `canonical_answer`. All other columns are locked
#' provenance and are verified when the review is applied.
#'
#' @param benchmark A generated `agentic_routing_benchmark`.
#'
#' @return A base R data frame with one row per competency question.
#' @export
as_agentic_routing_review <- function(benchmark) {
  routing_validate_benchmark(benchmark)
  questions <- benchmark$questions
  data.frame(
    review_status = vapply(questions, `[[`, character(1), "review_status"),
    review_note = vapply(
      questions, function(x) x$review_note %||% "", character(1)
    ),
    id = vapply(questions, `[[`, character(1), "id"),
    artifact_type = vapply(
      questions, function(x) x$artifact_type %||% "", character(1)
    ),
    source_path = vapply(
      questions, function(x) paste(x$required_paths, collapse = " | "),
      character(1)
    ),
    source_heading = vapply(
      questions, function(x) x$source_heading %||% "", character(1)
    ),
    prompt = vapply(questions, `[[`, character(1), "prompt"),
    canonical_answer = vapply(
      questions, function(x) x$canonical_answer %||% "", character(1)
    ),
    source_hash = vapply(
      questions, function(x) x$source_hash %||% "", character(1)
    ),
    derivation_template = vapply(
      questions, function(x) x$derivation_template %||% "", character(1)
    ),
    benchmark_repository = rep(benchmark$repository, length(questions)),
    benchmark_git_sha = rep(
      if (is.na(benchmark$git_sha)) "" else benchmark$git_sha,
      length(questions)
    ),
    generator_version = rep(benchmark$generator_version, length(questions)),
    rules_hash = rep(benchmark$rules_hash, length(questions)),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

#' Write a competency-review sheet
#'
#' Writes a pending or partially reviewed benchmark as an external review
#' directory containing `questions.csv`, `exclusions.csv`, and `REVIEW.md`.
#' This is the artifact bundle a human opens, reviews, edits, and saves before
#' applying the decisions back to the benchmark.
#'
#' @param benchmark A generated `agentic_routing_benchmark`.
#' @param path Destination directory outside the evaluated repository.
#' @param overwrite Replace known files in an existing review directory.
#'
#' @return The normalized review-sheet path, invisibly.
#' @export
write_agentic_routing_review <- function(benchmark, path, overwrite = FALSE) {
  routing_validate_benchmark(benchmark)
  path <- routing_scalar_character(path, "path")
  overwrite <- validate_flag(overwrite, "overwrite")
  target <- attr(benchmark, "target_path", exact = TRUE)
  if (!is.null(target) && path_within(path, target)) {
    stop(
      "Review sheets contain gold answers and must remain outside the repository being evaluated.",
      call. = FALSE
    )
  }
  if (file.exists(path) && !overwrite) {
    stop("Routing review path already exists: ", path, call. = FALSE)
  }
  if (file.exists(path) && !dir.exists(path)) {
    stop("Routing review path must be a directory: ", path, call. = FALSE)
  }
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  known <- file.path(path, c("questions.csv", "exclusions.csv", "REVIEW.md"))
  if (!overwrite && any(file.exists(known))) {
    stop("Routing review bundle already exists: ", path, call. = FALSE)
  }
  utils::write.csv(
    as_agentic_routing_review(benchmark),
    file = known[[1]],
    row.names = FALSE,
    na = "",
    fileEncoding = "UTF-8"
  )
  utils::write.csv(
    benchmark$exclusions,
    file = known[[2]],
    row.names = FALSE,
    na = "",
    fileEncoding = "UTF-8"
  )
  writeLines(
    routing_review_instructions(benchmark),
    con = known[[3]],
    useBytes = TRUE
  )
  invisible(normalizePath(path, winslash = "/", mustWork = TRUE))
}

#' Apply a completed competency-review sheet
#'
#' Imports the four editable review columns while rejecting changes to question
#' identifiers, source evidence, or benchmark provenance.
#'
#' @param benchmark The original generated `agentic_routing_benchmark`.
#' @param path Review directory written by
#'   `write_agentic_routing_review()`, or its edited `questions.csv`.
#' @param require_complete Require every row to be approved or rejected.
#'
#' @return The reviewed benchmark, ready to freeze when review is complete.
#' @export
apply_agentic_routing_review <- function(benchmark,
                                          path,
                                          require_complete = TRUE) {
  routing_validate_benchmark(benchmark)
  path <- routing_scalar_character(path, "path")
  require_complete <- validate_flag(require_complete, "require_complete")
  review_path <- if (dir.exists(path)) file.path(path, "questions.csv") else path
  if (!file.exists(review_path)) {
    stop("Routing review sheet does not exist: ", review_path, call. = FALSE)
  }
  review <- tryCatch(
    utils::read.csv(
      review_path,
      stringsAsFactors = FALSE,
      check.names = FALSE,
      na.strings = character(),
      colClasses = "character",
      fileEncoding = "UTF-8"
    ),
    error = function(e) {
      stop("Unable to read routing review sheet: ", conditionMessage(e), call. = FALSE)
    }
  )
  review[] <- lapply(review, function(x) {
    x[is.na(x)] <- ""
    x
  })
  expected <- as_agentic_routing_review(benchmark)
  required <- names(expected)
  if (!all(required %in% names(review))) {
    stop(
      "Routing review sheet is missing required columns: ",
      paste(setdiff(required, names(review)), collapse = ", "),
      call. = FALSE
    )
  }
  review <- review[, required, drop = FALSE]
  if (nrow(review) != nrow(expected) || anyDuplicated(review$id) ||
      !setequal(review$id, expected$id)) {
    stop(
      "Routing review sheet must contain each original question exactly once.",
      call. = FALSE
    )
  }
  review <- review[match(expected$id, review$id), , drop = FALSE]
  locked <- setdiff(
    required,
    c("review_status", "review_note", "prompt", "canonical_answer")
  )
  changed <- locked[vapply(locked, function(column) {
    observed <- as.character(review[[column]])
    criterion <- as.character(expected[[column]])
    observed[criterion == "" & observed == "NA"] <- ""
    !identical(observed, criterion)
  }, logical(1))]
  if (length(changed)) {
    stop(
      "Locked review provenance was changed: ",
      paste(changed, collapse = ", "),
      call. = FALSE
    )
  }
  statuses <- trimws(as.character(review$review_status))
  invalid <- !statuses %in% c("pending", "approved", "rejected")
  if (any(invalid)) {
    stop(
      "Review status must be pending, approved, or rejected for: ",
      paste(review$id[invalid], collapse = ", "),
      call. = FALSE
    )
  }
  if (require_complete && any(statuses == "pending")) {
    stop(
      "Review is incomplete; resolve every pending question or use `require_complete = FALSE`.",
      call. = FALSE
    )
  }
  for (i in seq_along(benchmark$questions)) {
    benchmark$questions[[i]]$review_status <- statuses[[i]]
    benchmark$questions[[i]]$prompt <- routing_scalar_character(
      as.character(review$prompt[[i]]), "prompt"
    )
    benchmark$questions[[i]]$canonical_answer <- routing_scalar_character(
      as.character(review$canonical_answer[[i]]), "canonical_answer"
    )
    note <- trimws(as.character(review$review_note[[i]]))
    benchmark$questions[[i]]$review_note <- if (nzchar(note)) note else NULL
  }
  attr(benchmark, "review_path") <- normalizePath(
    review_path, winslash = "/", mustWork = TRUE
  )
  benchmark
}

routing_review_instructions <- function(benchmark) {
  git_sha <- if (is.na(benchmark$git_sha)) "unknown" else benchmark$git_sha
  c(
    "# Agentic-routing competency review",
    "",
    paste0("- Repository: `", benchmark$repository, "`"),
    paste0("- Target Git SHA: `", git_sha, "`"),
    paste0("- Generator: `", benchmark$generator_version, "`"),
    paste0("- Rules hash: `", benchmark$rules_hash, "`"),
    paste0("- Candidate questions: ", length(benchmark$questions)),
    paste0("- Generator exclusions: ", nrow(benchmark$exclusions)),
    "",
    "Keep this directory outside the repository being evaluated because it contains gold answers.",
    "",
    "## What to review",
    "",
    "Open `questions.csv`. For every row:",
    "",
    "1. Open `source_path` in the target repository and locate `source_heading`.",
    "2. Confirm that the prompt is unambiguous and does not reveal its evidence path or answer.",
    "3. Confirm that `canonical_answer` is correct, current, minimally sufficient, and supported by that source.",
    "4. Edit `prompt` or `canonical_answer` when human clarification is needed.",
    "5. Set `review_status` to `approved` or `rejected` and explain non-obvious decisions in `review_note`.",
    "",
    "Then inspect `exclusions.csv`. Determine whether each exclusion is acceptable or exposes a competency gap that needs a manually authored question or better maintained context.",
    "",
    "## Editable columns",
    "",
    "- `review_status`: `pending`, `approved`, or `rejected`",
    "- `review_note`: optional rationale or follow-up",
    "- `prompt`: task presented to Codex",
    "- `canonical_answer`: private gold answer used for grounding scores",
    "",
    "Do not edit any other column. Import validates identifiers, source evidence, and benchmark provenance.",
    "",
    "## Complete the review",
    "",
    "Save `questions.csv`, then apply it in R:",
    "",
    "```r",
    "reviewed <- apply_agentic_routing_review(benchmark, \"path/to/this-directory\")",
    "write_agentic_routing_benchmark(reviewed, \"path/outside/target/benchmark.json\")",
    "```"
  )
}

routing_validate_benchmark <- function(benchmark) {
  if (!inherits(benchmark, "agentic_routing_benchmark") ||
      !is.list(benchmark$questions) || !length(benchmark$questions)) {
    stop(
      "`benchmark` must come from `derive_agentic_routing_questions()` or `read_agentic_routing_benchmark()`.",
      call. = FALSE
    )
  }
  invisible(benchmark)
}
