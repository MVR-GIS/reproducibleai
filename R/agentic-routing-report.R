#' Summarize an agentic-routing evaluation
#'
#' @param evaluation Result from `run_agentic_routing_evaluation()`.
#'
#' @return An object of class `agentic_routing_health`.
#' @export
summarize_agentic_routing <- function(evaluation) {
  if (!inherits(evaluation, "agentic_routing_evaluation")) {
    stop(
      "`evaluation` must come from `run_agentic_routing_evaluation()`.",
      call. = FALSE
    )
  }
  runs <- evaluation$runs
  ids <- unique(runs$question_id)
  rows <- lapply(ids, function(id) {
    x <- runs[runs$question_id == id, , drop = FALSE]
    completed <- x[x$completed, , drop = FALSE]
    data.frame(
      question_id = id,
      runs = nrow(x),
      completion_rate = mean(x$completed),
      mean_score = mean(x$score),
      score_sd = if (nrow(x) > 1L) stats::sd(x$score) else NA_real_,
      minimum_score = min(x$score),
      route_recall = routing_mean_na(completed$route_recall),
      route_precision = routing_mean_na(completed$route_precision),
      term_recall = routing_mean_na(completed$term_recall),
      answer_score = routing_mean_na(completed$answer_score),
      forbidden_rate = routing_mean_na(completed$forbidden_rate),
      mean_input_tokens = routing_mean_na(x$input_tokens),
      mean_cached_input_tokens = routing_mean_na(x$cached_input_tokens),
      mean_output_tokens = routing_mean_na(x$output_tokens),
      mean_tool_calls = routing_mean_na(x$tool_calls),
      mean_elapsed_seconds = routing_mean_na(x$elapsed_seconds),
      stringsAsFactors = FALSE
    )
  })
  by_question <- do.call(rbind, rows)
  rownames(by_question) <- NULL
  weighted_score <- stats::weighted.mean(runs$score, runs$weight)
  completed_runs <- runs[runs$completed, , drop = FALSE]
  recommendations <- routing_recommendations(by_question)

  structure(
    list(
      schema_version = 1L,
      repository = evaluation$path,
      git_sha = evaluation$git_sha,
      model = evaluation$model,
      codex_version = evaluation$codex_version,
      created_at = evaluation$created_at,
      health_score = 100 * weighted_score,
      runs = nrow(runs),
      questions = nrow(by_question),
      completion_rate = mean(runs$completed),
      route_recall = routing_mean_na(completed_runs$route_recall),
      route_precision = routing_mean_na(completed_runs$route_precision),
      answer_score = routing_mean_na(completed_runs$answer_score),
      mean_input_tokens = routing_mean_na(completed_runs$input_tokens),
      mean_cached_input_tokens = routing_mean_na(
        completed_runs$cached_input_tokens
      ),
      mean_output_tokens = routing_mean_na(completed_runs$output_tokens),
      mean_tool_calls = routing_mean_na(completed_runs$tool_calls),
      mean_elapsed_seconds = routing_mean_na(completed_runs$elapsed_seconds),
      by_question = by_question,
      recommendations = recommendations
    ),
    class = "agentic_routing_health"
  )
}

#' Write an agentic-routing health report
#'
#' Writes an aggregate Markdown report suitable for a durable `dev/` artifact.
#' Raw prompts, private rubrics, answers, and event traces are intentionally
#' omitted.
#'
#' @param health Result from `summarize_agentic_routing()`.
#' @param path Destination Markdown path.
#' @param overwrite Replace an existing report.
#'
#' @return The normalized report path, invisibly.
#' @export
write_agentic_routing_report <- function(health, path, overwrite = FALSE) {
  if (!inherits(health, "agentic_routing_health")) {
    stop("`health` must come from `summarize_agentic_routing()`.", call. = FALSE)
  }
  path <- routing_scalar_character(path, "path")
  overwrite <- validate_flag(overwrite, "overwrite")
  if (file.exists(path) && !overwrite) {
    stop("Routing report already exists: ", path, call. = FALSE)
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(routing_report_text(health), path, useBytes = TRUE)
  invisible(normalizePath(path, winslash = "/", mustWork = TRUE))
}

routing_report_text <- function(health) {
  git_sha <- if (
    is.null(health$git_sha) || !length(health$git_sha) ||
      is.na(health$git_sha) || !nzchar(health$git_sha)
  ) {
    "unknown"
  } else {
    health$git_sha
  }
  table_lines <- c(
    "| Question | Runs | Complete | Score | SD | Recall | Precision | Answer | Input | Cached | Output | Tools | Seconds |",
    "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
  )
  for (i in seq_len(nrow(health$by_question))) {
    x <- health$by_question[i, ]
    table_lines <- c(table_lines, paste0(
      "| `", x$question_id, "` | ",
      x$runs, " | ",
      routing_percent(x$completion_rate), " | ",
      routing_percent(x$mean_score), " | ",
      routing_decimal(x$score_sd), " | ",
      routing_percent(x$route_recall), " | ",
      routing_percent(x$route_precision), " | ",
      routing_percent(x$answer_score), " | ",
      routing_decimal(x$mean_input_tokens, digits = 0), " | ",
      routing_decimal(x$mean_cached_input_tokens, digits = 0), " | ",
      routing_decimal(x$mean_output_tokens, digits = 0), " | ",
      routing_decimal(x$mean_tool_calls, digits = 1), " | ",
      routing_decimal(x$mean_elapsed_seconds), " |"
    ))
  }
  recommendations <- if (length(health$recommendations)) {
    paste0("- ", health$recommendations)
  } else {
    "- No threshold-based routing recommendations were generated."
  }
  c(
    "# Agentic routing health",
    "",
    paste0("- Repository: `", basename(health$repository), "`"),
    paste0("- Git SHA: `", git_sha, "`"),
    paste0("- Model: `", health$model, "`"),
    paste0("- Codex CLI: `", health$codex_version, "`"),
    paste0("- Evaluated: ", health$created_at),
    paste0("- Questions: ", health$questions),
    paste0("- Runs: ", health$runs),
    paste0("- Completion rate: ", routing_percent(health$completion_rate)),
    paste0("- Weighted health score: ", sprintf("%.1f/100", health$health_score)),
    paste0("- Mean required-evidence recall: ", routing_percent(health$route_recall)),
    paste0("- Mean relevant-evidence precision: ", routing_percent(health$route_precision)),
    paste0("- Mean answer score: ", routing_percent(health$answer_score)),
    paste0("- Mean input tokens: ", routing_decimal(health$mean_input_tokens, digits = 0)),
    paste0("- Mean cached input tokens: ", routing_decimal(
      health$mean_cached_input_tokens, digits = 0
    )),
    paste0("- Mean output tokens: ", routing_decimal(health$mean_output_tokens, digits = 0)),
    paste0("- Mean tool calls: ", routing_decimal(health$mean_tool_calls, digits = 1)),
    paste0("- Mean elapsed seconds: ", routing_decimal(health$mean_elapsed_seconds)),
    "",
    "The score summarizes repeated stochastic runs; it is not a deterministic proof of correctness.",
    "Private rubrics and raw traces are intentionally stored outside the evaluated repository.",
    if (all(health$by_question$runs < 2L)) {
      "This pilot has one observation per question and cannot estimate run-to-run stability."
    } else {
      "Question-level standard deviations describe observed run-to-run stability."
    },
    "Token and timing metrics are descriptive until compared with a maintained baseline or threshold.",
    "",
    "## Question results",
    "",
    table_lines,
    "",
    "## Recommendations",
    "",
    recommendations,
    "",
    "## Scoring contract",
    "",
    "- 40% required evidence recall",
    "- 20% relevant evidence precision",
    "- 30% canonical-answer token F1 for generated questions, or expected-term recall for authored questions",
    "- 10% successful execution and structured response",
    "- The combined score is multiplied by one minus the forbidden-term rate.",
    "",
    "Review recommendations against the underlying runs before changing repository instructions."
  )
}

routing_recommendations <- function(by_question) {
  out <- character()
  for (i in seq_len(nrow(by_question))) {
    x <- by_question[i, ]
    prefix <- paste0("`", x$question_id, "`: ")
    if (x$completion_rate < 1) {
      out <- c(out, paste0(
        prefix, "investigate execution or structured-response failures before interpreting routing."
      ))
    }
    if (x$completion_rate == 0) next
    if (x$route_recall < 0.8) {
      out <- c(out, paste0(
        prefix, "clarify the AGENTS.md route or make required evidence more discoverable."
      ))
    }
    if (x$route_precision < 0.8) {
      out <- c(out, paste0(
        prefix, "narrow the route or remove distracting context."
      ))
    }
    if (x$answer_score < 0.8) {
      out <- c(out, paste0(
        prefix, "inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence."
      ))
    }
    if (!is.na(x$score_sd) && x$score_sd > 0.10) {
      out <- c(out, paste0(
        prefix, "run additional repetitions and inspect formulation sensitivity."
      ))
    }
  }
  unique(out)
}

routing_mean_na <- function(x) {
  if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
}

routing_percent <- function(x) {
  if (is.na(x)) "NA" else sprintf("%.1f%%", 100 * x)
}

routing_decimal <- function(x, digits = 2) {
  if (is.na(x)) "NA" else format(round(x, digits), nsmall = digits, trim = TRUE)
}
