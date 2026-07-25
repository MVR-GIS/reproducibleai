#' Define an agentic-routing competency question
#'
#' Creates a human-reviewable competency question and its scoring rubric. The
#' rubric is not included in the prompt sent to Codex.
#'
#' @param id Stable question identifier.
#' @param prompt Task prompt presented to Codex.
#' @param required_paths Repository-relative evidence paths that a successful
#'   response must cite. A path ending in `/` matches any descendant.
#' @param allowed_paths Additional relevant evidence paths that may be cited
#'   without reducing routing precision.
#' @param expected_terms Case-insensitive literal terms expected in the answer.
#' @param forbidden_terms Case-insensitive literal terms that indicate an
#'   incorrect or superseded answer.
#' @param weight Positive weight used in the aggregate health score.
#'
#' @return An object of class `agentic_routing_question`.
#' @export
new_agentic_routing_question <- function(id,
                                          prompt,
                                          required_paths,
                                          allowed_paths = character(),
                                          expected_terms = character(),
                                          forbidden_terms = character(),
                                          weight = 1) {
  id <- routing_scalar_character(id, "id")
  if (!grepl("^[A-Za-z0-9][A-Za-z0-9._-]*$", id)) {
    stop(
      "`id` must start with an alphanumeric character and contain only ",
      "letters, numbers, dots, underscores, or hyphens.",
      call. = FALSE
    )
  }
  prompt <- routing_scalar_character(prompt, "prompt")
  required_paths <- routing_character_vector(
    required_paths, "required_paths", allow_empty = FALSE
  )
  allowed_paths <- routing_character_vector(
    allowed_paths, "allowed_paths", allow_empty = TRUE
  )
  expected_terms <- routing_character_vector(
    expected_terms, "expected_terms", allow_empty = TRUE
  )
  forbidden_terms <- routing_character_vector(
    forbidden_terms, "forbidden_terms", allow_empty = TRUE
  )
  if (!is.numeric(weight) || length(weight) != 1L ||
      is.na(weight) || !is.finite(weight) || weight <= 0) {
    stop("`weight` must be one positive finite number.", call. = FALSE)
  }

  structure(
    list(
      id = id,
      prompt = prompt,
      required_paths = normalize_routing_paths(required_paths),
      allowed_paths = normalize_routing_paths(allowed_paths),
      expected_terms = unique(expected_terms),
      forbidden_terms = unique(forbidden_terms),
      weight = as.numeric(weight)
    ),
    class = "agentic_routing_question"
  )
}

#' Write agentic-routing competency questions
#'
#' Writes a versioned JSON fixture containing prompts and private scoring
#' rubrics. Keep this file outside the repository being evaluated so the model
#' cannot inspect expected answers.
#'
#' @param questions One question or a list of questions created by
#'   `new_agentic_routing_question()`.
#' @param path Destination JSON path.
#' @param overwrite Replace an existing file.
#'
#' @return The normalized destination path, invisibly.
#' @export
write_agentic_routing_questions <- function(questions,
                                             path,
                                             overwrite = FALSE) {
  questions <- normalize_routing_questions(questions)
  path <- routing_scalar_character(path, "path")
  overwrite <- validate_flag(overwrite, "overwrite")
  if (file.exists(path) && !overwrite) {
    stop("Question fixture already exists: ", path, call. = FALSE)
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)

  payload <- list(
    schema_version = jsonlite::unbox(1L),
    questions = lapply(questions, routing_question_json)
  )
  jsonlite::write_json(
    payload, path = path, pretty = TRUE, auto_unbox = FALSE, null = "null"
  )
  invisible(normalizePath(path, winslash = "/", mustWork = TRUE))
}

#' Read agentic-routing competency questions
#'
#' @param path Versioned JSON fixture written by
#'   `write_agentic_routing_questions()`.
#'
#' @return A list of `agentic_routing_question` objects.
#' @export
read_agentic_routing_questions <- function(path) {
  path <- routing_scalar_character(path, "path")
  if (!file.exists(path)) {
    stop("Question fixture does not exist: ", path, call. = FALSE)
  }
  payload <- tryCatch(
    jsonlite::read_json(path, simplifyVector = FALSE),
    error = function(e) {
      stop("Unable to parse question fixture: ", conditionMessage(e), call. = FALSE)
    }
  )
  version <- suppressWarnings(as.integer(payload$schema_version))
  if (length(version) != 1L || is.na(version) || version != 1L) {
    stop("Unsupported question fixture schema version.", call. = FALSE)
  }
  if (!is.list(payload$questions) || !length(payload$questions)) {
    stop("Question fixture must contain at least one question.", call. = FALSE)
  }
  questions <- lapply(payload$questions, function(x) {
    new_agentic_routing_question(
      id = x$id,
      prompt = x$prompt,
      required_paths = as.character(unlist(
        x$required_paths, use.names = FALSE
      )),
      allowed_paths = as.character(unlist(
        x$allowed_paths, use.names = FALSE
      )),
      expected_terms = as.character(unlist(
        x$expected_terms, use.names = FALSE
      )),
      forbidden_terms = as.character(unlist(
        x$forbidden_terms, use.names = FALSE
      )),
      weight = x$weight
    )
  })
  attr(questions, "fixture_path") <- normalizePath(
    path, winslash = "/", mustWork = TRUE
  )
  questions
}

routing_question_json <- function(question) {
  list(
    id = jsonlite::unbox(question$id),
    prompt = jsonlite::unbox(question$prompt),
    required_paths = as.list(question$required_paths),
    allowed_paths = as.list(question$allowed_paths),
    expected_terms = as.list(question$expected_terms),
    forbidden_terms = as.list(question$forbidden_terms),
    weight = jsonlite::unbox(question$weight)
  )
}

normalize_routing_questions <- function(questions) {
  fixture_path <- attr(questions, "fixture_path", exact = TRUE)
  if (inherits(questions, "agentic_routing_question")) {
    questions <- list(questions)
  }
  if (!is.list(questions) || !length(questions) ||
      !all(vapply(
        questions, inherits, logical(1), what = "agentic_routing_question"
      ))) {
    stop(
      "`questions` must be an agentic-routing question or a non-empty list of them.",
      call. = FALSE
    )
  }
  ids <- vapply(questions, `[[`, character(1), "id")
  if (anyDuplicated(ids)) {
    stop("Question identifiers must be unique.", call. = FALSE)
  }
  if (!is.null(fixture_path)) attr(questions, "fixture_path") <- fixture_path
  questions
}

routing_scalar_character <- function(x, arg) {
  if (!is.character(x) || length(x) != 1L || is.na(x) ||
      !nzchar(trimws(x))) {
    stop("`", arg, "` must be one non-empty string.", call. = FALSE)
  }
  trimws(x)
}

routing_character_vector <- function(x, arg, allow_empty) {
  if (!is.character(x) || anyNA(x)) {
    stop("`", arg, "` must be a character vector without missing values.", call. = FALSE)
  }
  x <- trimws(x)
  if (any(!nzchar(x)) || (!allow_empty && !length(x))) {
    stop("`", arg, "` must contain non-empty values.", call. = FALSE)
  }
  unique(x)
}

normalize_routing_paths <- function(paths) {
  paths <- gsub("\\\\", "/", paths)
  paths <- sub("^\\./", "", paths)
  sub("^/+", "", paths)
}
