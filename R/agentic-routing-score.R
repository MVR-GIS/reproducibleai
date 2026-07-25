#' Score one agentic-routing response
#'
#' Scores evidence routing, expected answer content, forbidden content, and
#' completion using a fixed transparent rubric. This function supports offline
#' scoring without invoking Codex.
#'
#' @param question A question created by `new_agentic_routing_question()`.
#' @param response A list with `answer`, `evidence_paths`, `route_summary`, and
#'   `confidence`.
#' @param completed Whether execution and structured-response parsing succeeded.
#'
#' @return A named list of component metrics and the combined score.
#' @export
score_agentic_routing_run <- function(question, response, completed = TRUE) {
  if (!inherits(question, "agentic_routing_question")) {
    stop("`question` must be an agentic-routing question.", call. = FALSE)
  }
  completed <- validate_flag(completed, "completed")
  if (!is.list(response)) response <- list()

  answer <- as.character(response$answer %||% "")[1]
  route_summary <- as.character(response$route_summary %||% "")[1]
  evidence <- normalize_routing_paths(
    as.character(unlist(response$evidence_paths %||% character(), use.names = FALSE))
  )
  evidence <- unique(evidence[nzchar(evidence)])
  confidence <- routing_number(response$confidence)
  if (is.na(confidence) || confidence < 0 || confidence > 1) confidence <- NA_real_

  required_hits <- vapply(
    question$required_paths,
    routing_path_present,
    logical(1),
    evidence = evidence
  )
  route_recall <- mean(required_hits)

  relevant <- unique(c(question$required_paths, question$allowed_paths))
  evidence_relevant <- if (!length(evidence)) {
    logical()
  } else {
    vapply(evidence, function(candidate) {
      any(vapply(
        relevant,
        function(expected) routing_path_matches(expected, candidate),
        logical(1)
      ))
    }, logical(1))
  }
  route_precision <- if (!length(evidence)) 0 else mean(evidence_relevant)

  expected_hits <- routing_term_hits(answer, question$expected_terms)
  forbidden_hits <- routing_term_hits(answer, question$forbidden_terms)
  term_recall <- if (length(expected_hits)) mean(expected_hits) else 1
  forbidden_rate <- if (length(forbidden_hits)) mean(forbidden_hits) else 0

  completion_score <- as.numeric(completed)
  score <- (
    0.40 * route_recall +
      0.20 * route_precision +
      0.30 * term_recall +
      0.10 * completion_score
  ) * (1 - forbidden_rate)
  if (!completed) score <- 0

  list(
    score = score,
    route_recall = route_recall,
    route_precision = route_precision,
    term_recall = term_recall,
    forbidden_rate = forbidden_rate,
    completed = completed,
    confidence = confidence,
    answer = answer,
    route_summary = route_summary,
    evidence_paths = evidence
  )
}

routing_path_present <- function(expected, evidence) {
  any(vapply(
    evidence,
    function(candidate) routing_path_matches(expected, candidate),
    logical(1)
  ))
}

routing_path_matches <- function(expected, candidate) {
  expected <- normalize_routing_paths(expected)
  candidate <- normalize_routing_paths(candidate)
  if (endsWith(expected, "/")) {
    startsWith(candidate, expected)
  } else {
    identical(candidate, expected)
  }
}

routing_term_hits <- function(answer, terms) {
  if (!length(terms)) return(logical())
  vapply(
    terms,
    function(term) grepl(tolower(term), tolower(answer), fixed = TRUE),
    logical(1)
  )
}
