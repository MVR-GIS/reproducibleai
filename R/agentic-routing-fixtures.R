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
#' @param canonical_answer Optional maintained answer text used for
#'   deterministic token-level grounding scores.
#' @param review_status Whether the question is `"approved"`, `"pending"`, or
#'   `"rejected"` by human review.
#' @param artifact_type Optional generated artifact classification.
#' @param source_heading Optional generated source-section heading.
#' @param source_hash Optional hash of the source file used for derivation.
#' @param derivation_template Optional identifier of the deterministic template
#'   that generated the question.
#' @param review_note Optional human-review rationale or editing note.
#'
#' @return An object of class `agentic_routing_question`.
#' @export
new_agentic_routing_question <- function(id,
                                          prompt,
                                          required_paths,
                                          allowed_paths = character(),
                                          expected_terms = character(),
                                          forbidden_terms = character(),
                                          weight = 1,
                                          canonical_answer = NULL,
                                          review_status = "approved",
                                          artifact_type = NULL,
                                          source_heading = NULL,
                                          source_hash = NULL,
                                          derivation_template = NULL,
                                          review_note = NULL) {
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
  canonical_answer <- routing_optional_scalar(
    canonical_answer, "canonical_answer"
  )
  review_status <- match.arg(
    review_status, c("approved", "pending", "rejected")
  )
  artifact_type <- routing_optional_scalar(artifact_type, "artifact_type")
  source_heading <- routing_optional_scalar(source_heading, "source_heading")
  source_hash <- routing_optional_scalar(source_hash, "source_hash")
  derivation_template <- routing_optional_scalar(
    derivation_template, "derivation_template"
  )
  review_note <- routing_optional_scalar(review_note, "review_note")

  structure(
    list(
      id = id,
      prompt = prompt,
      required_paths = normalize_routing_paths(required_paths),
      allowed_paths = normalize_routing_paths(allowed_paths),
      expected_terms = unique(expected_terms),
      forbidden_terms = unique(forbidden_terms),
      weight = as.numeric(weight),
      canonical_answer = canonical_answer,
      review_status = review_status,
      artifact_type = artifact_type,
      source_heading = source_heading,
      source_hash = source_hash,
      derivation_template = derivation_template,
      review_note = review_note
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
    schema_version = jsonlite::unbox(2L),
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
  if (length(version) != 1L || is.na(version) || !version %in% c(1L, 2L)) {
    stop("Unsupported question fixture schema version.", call. = FALSE)
  }
  if (!is.list(payload$questions) || !length(payload$questions)) {
    stop("Question fixture must contain at least one question.", call. = FALSE)
  }
  questions <- lapply(payload$questions, routing_question_from_json)
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
    weight = jsonlite::unbox(question$weight),
    canonical_answer = routing_json_scalar(question$canonical_answer),
    review_status = jsonlite::unbox(question$review_status),
    artifact_type = routing_json_scalar(question$artifact_type),
    source_heading = routing_json_scalar(question$source_heading),
    source_hash = routing_json_scalar(question$source_hash),
    derivation_template = routing_json_scalar(question$derivation_template),
    review_note = routing_json_scalar(question$review_note)
  )
}

routing_question_from_json <- function(x) {
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
    weight = x$weight,
    canonical_answer = x$canonical_answer %||% NULL,
    review_status = x$review_status %||% "approved",
    artifact_type = x$artifact_type %||% NULL,
    source_heading = x$source_heading %||% NULL,
    source_hash = x$source_hash %||% NULL,
    derivation_template = x$derivation_template %||% NULL,
    review_note = x$review_note %||% NULL
  )
}

normalize_routing_questions <- function(questions) {
  if (inherits(questions, "agentic_routing_benchmark")) {
    fixture_path <- attr(questions, "fixture_path", exact = TRUE)
    statuses <- vapply(
      questions$questions, `[[`, character(1), "review_status"
    )
    if (any(statuses == "pending")) {
      stop(
        "Generated competency questions require explicit human review before evaluation.",
        call. = FALSE
      )
    }
    questions <- questions$questions[statuses == "approved"]
    if (!length(questions)) {
      stop("The benchmark has no approved competency questions.", call. = FALSE)
    }
    if (!is.null(fixture_path)) attr(questions, "fixture_path") <- fixture_path
  }
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

routing_optional_scalar <- function(x, arg) {
  if (is.null(x)) return(NULL)
  routing_scalar_character(x, arg)
}

routing_json_scalar <- function(x) {
  if (is.null(x)) NULL else jsonlite::unbox(x)
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
