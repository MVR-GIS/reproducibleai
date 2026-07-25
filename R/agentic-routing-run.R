#' Run repeated agentic-routing evaluations
#'
#' Runs each competency question in a fresh, ephemeral, read-only `codex exec`
#' session and captures JSONL events plus schema-constrained final responses.
#' Gold rubrics are never included in model prompts.
#'
#' Raw output defaults to a temporary directory outside the target repository.
#' This prevents earlier results from contaminating later repetitions. Live
#' execution also requires a clean Git repository and verifies that its commit
#' and worktree remain unchanged across the run.
#'
#' @param path Git repository to evaluate.
#' @param questions One question, a list of questions, or a fully reviewed
#'   benchmark created by `derive_agentic_routing_questions()`.
#' @param repetitions Positive number of independent runs per question.
#' @param approved Must be `TRUE`. Repeated model execution can consume paid
#'   usage and is never started implicitly.
#' @param output_dir Directory for raw event and response files. It must be
#'   outside `path`.
#' @param codex `NULL` to discover a standalone Codex CLI automatically, or a
#'   CLI command or absolute executable path. Live evaluation requires this
#'   optional external program and existing CLI authentication. Use
#'   `check_agentic_routing_prerequisites()` before the first run.
#' @param model Optional model override. `NULL` uses the configured default.
#' @param timeout Maximum seconds for each run.
#' @param runner Optional process runner for testing or custom execution. It
#'   receives `command`, `args`, `wd`, `stdout`, `stderr`, and `timeout`.
#' @param quiet Suppress progress messages.
#'
#' @return An object of class `agentic_routing_evaluation`.
#' @export
run_agentic_routing_evaluation <- function(
    path = ".",
    questions,
    repetitions = 3L,
    approved = FALSE,
    output_dir = NULL,
    codex = NULL,
    model = NULL,
    timeout = 900,
    runner = NULL,
    quiet = FALSE) {
  root <- agentic_context_root(path)
  validate_agentic_context(root, strict = TRUE)
  questions <- normalize_routing_questions(questions)
  repetitions <- routing_positive_integer(repetitions, "repetitions")
  approved <- validate_flag(approved, "approved")
  if (!approved) {
    stop(
      "Routing evaluation requires `approved = TRUE` because it starts repeated Codex runs.",
      call. = FALSE
    )
  }
  if (!is.null(codex)) codex <- routing_scalar_character(codex, "codex")
  if (!is.null(model)) model <- routing_scalar_character(model, "model")
  if (!is.numeric(timeout) || length(timeout) != 1L || is.na(timeout) ||
      !is.finite(timeout) || timeout <= 0) {
    stop("`timeout` must be one positive finite number of seconds.", call. = FALSE)
  }
  quiet <- validate_flag(quiet, "quiet")
  if (!is.null(runner) && !is.function(runner)) {
    stop("`runner` must be NULL or a function.", call. = FALSE)
  }
  default_runner <- is.null(runner)
  if (default_runner) {
    runner <- routing_process_runner
    cli <- routing_resolve_codex(codex)
    codex <- cli$path
    codex_version <- cli$version
    authentication <- routing_codex_authentication(codex)
    if (!authentication$authenticated) {
      stop(
        "The standalone Codex CLI is not authenticated.",
        "\nRun `codex login` where local policy permits, then retry.",
        call. = FALSE
      )
    }
  } else {
    if (is.null(codex)) codex <- "codex"
    codex_version <- "injected-runner"
  }
  git_sha <- routing_git_sha(root)
  if (default_runner && is.na(git_sha)) {
    stop(
      "The evaluated path must be a Git repository with a readable HEAD commit.",
      call. = FALSE
    )
  }
  if (default_runner && routing_git_dirty(root)) {
    stop(
      "The evaluated repository must be clean. Commit each specification ",
      "variant in a dedicated worktree before running the evaluation.",
      call. = FALSE
    )
  }

  fixture_path <- attr(questions, "fixture_path", exact = TRUE)
  if (!is.null(fixture_path) && path_within(fixture_path, root)) {
    stop(
      "Question fixtures must remain outside the repository being evaluated.",
      call. = FALSE
    )
  }

  if (is.null(output_dir)) {
    output_dir <- tempfile("agentic-routing-evaluation-")
  }
  output_dir <- normalizePath(
    routing_scalar_character(output_dir, "output_dir"),
    winslash = "/", mustWork = FALSE
  )
  if (path_within(output_dir, root)) {
    stop(
      "`output_dir` must be outside the repository being evaluated to avoid ",
      "cross-run contamination.",
      call. = FALSE
    )
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(output_dir)) {
    stop("Unable to create output directory: ", output_dir, call. = FALSE)
  }

  schema <- routing_result_schema_path()
  runs <- list()
  index <- 0L
  for (question in questions) {
    for (repetition in seq_len(repetitions)) {
      index <- index + 1L
      if (!quiet) {
        message(
          "Running ", question$id, " (", repetition, "/", repetitions, ")"
        )
      }
      runs[[index]] <- run_agentic_routing_once(
        root = root,
        question = question,
        repetition = repetition,
        output_dir = output_dir,
        codex = codex,
        model = model,
        timeout = timeout,
        runner = runner,
        schema = schema
      )
    }
  }
  run_table <- routing_runs_data_frame(runs)
  if (default_runner && (
    !identical(routing_git_sha(root), git_sha) || routing_git_dirty(root)
  )) {
    stop(
      "The evaluated repository changed during execution; raw runs were retained ",
      "but the evaluation is invalid.",
      call. = FALSE
    )
  }
  structure(
    list(
      schema_version = 1L,
      path = root,
      git_sha = git_sha,
      model = if (is.null(model)) "configured-default" else model,
      codex_version = codex_version,
      repetitions = repetitions,
      questions = questions,
      runs = run_table,
      output_dir = normalizePath(output_dir, winslash = "/", mustWork = TRUE),
      created_at = format(
        as.POSIXct(Sys.time(), tz = "UTC"), "%Y-%m-%dT%H:%M:%SZ"
      )
    ),
    class = "agentic_routing_evaluation"
  )
}

run_agentic_routing_once <- function(root, question, repetition, output_dir,
                                     codex, model, timeout, runner, schema) {
  stem <- paste0(question$id, "-run-", sprintf("%03d", repetition))
  event_path <- file.path(output_dir, paste0(stem, ".jsonl"))
  stderr_path <- file.path(output_dir, paste0(stem, ".stderr.log"))
  response_path <- file.path(output_dir, paste0(stem, ".response.json"))
  prompt <- routing_evaluation_prompt(question$prompt)
  args <- routing_codex_args(
    root = root,
    prompt = prompt,
    response_path = response_path,
    schema = schema,
    model = model
  )

  started <- Sys.time()
  execution <- tryCatch(
    runner(
      command = codex,
      args = args,
      wd = root,
      stdout = event_path,
      stderr = stderr_path,
      timeout = timeout
    ),
    error = function(e) {
      list(status = 1L, error = conditionMessage(e))
    }
  )
  elapsed <- as.numeric(difftime(Sys.time(), started, units = "secs"))
  status <- routing_execution_status(execution)
  execution_error <- if (is.list(execution) && !is.null(execution$error)) {
    as.character(execution$error)[1]
  } else {
    ""
  }

  response <- routing_read_response(response_path)
  events <- routing_read_events(event_path)
  metrics <- routing_event_metrics(events)
  completed <- identical(status, 0L) && isTRUE(response$valid)
  score <- score_agentic_routing_run(
    question = question,
    response = response$value,
    completed = completed
  )

  list(
    question_id = question$id,
    repetition = repetition,
    weight = question$weight,
    completed = completed,
    exit_status = status,
    score = score$score,
    route_recall = score$route_recall,
    route_precision = score$route_precision,
    term_recall = score$term_recall,
    answer_precision = score$answer_precision,
    answer_recall = score$answer_recall,
    answer_f1 = score$answer_f1,
    answer_score = score$answer_score,
    forbidden_rate = score$forbidden_rate,
    confidence = score$confidence,
    input_tokens = metrics$input_tokens,
    cached_input_tokens = metrics$cached_input_tokens,
    output_tokens = metrics$output_tokens,
    tool_calls = metrics$tool_calls,
    elapsed_seconds = elapsed,
    answer = score$answer,
    route_summary = score$route_summary,
    evidence_paths = list(score$evidence_paths),
    error = paste(
      c(execution_error, response$error)[nzchar(c(execution_error, response$error))],
      collapse = " | "
    ),
    event_path = normalizePath(event_path, winslash = "/", mustWork = FALSE),
    response_path = normalizePath(
      response_path, winslash = "/", mustWork = FALSE
    ),
    stderr_path = normalizePath(stderr_path, winslash = "/", mustWork = FALSE)
  )
}

routing_process_runner <- function(command, args, wd, stdout, stderr, timeout) {
  previous <- setwd(wd)
  on.exit(setwd(previous), add = TRUE)
  status <- suppressWarnings(system2(
    command = command,
    args = vapply(args, shQuote, character(1)),
    stdout = stdout,
    stderr = stderr,
    timeout = ceiling(timeout)
  ))
  list(status = as.integer(status))
}

routing_codex_args <- function(root, prompt, response_path, schema, model) {
  args <- c(
    "exec",
    "--cd", root,
    "--sandbox", "read-only",
    "--ask-for-approval", "never",
    "--ignore-user-config",
    "--ephemeral",
    "--json",
    "--output-schema", schema,
    "--output-last-message", response_path
  )
  if (!is.null(model)) args <- c(args, "--model", model)
  c(args, prompt)
}

routing_evaluation_prompt <- function(prompt) {
  paste(
    "You are participating in a read-only evaluation of repository context routing.",
    "Follow the repository's active AGENTS.md instructions.",
    "Do not modify files.",
    "Inspect only the evidence needed to answer the task.",
    "In evidence_paths, list repository-relative paths you actually inspected.",
    "Do not claim a path you did not inspect.",
    "",
    "Task:",
    prompt,
    sep = "\n"
  )
}

routing_result_schema_path <- function() {
  installed <- system.file(
    "agentic-routing", "1", "result-schema.json",
    package = "reproducibleai"
  )
  if (nzchar(installed) && file.exists(installed)) return(installed)
  source <- file.path("inst", "agentic-routing", "1", "result-schema.json")
  if (file.exists(source)) {
    return(normalizePath(source, winslash = "/", mustWork = TRUE))
  }
  stop("Agentic-routing result schema is unavailable.", call. = FALSE)
}

routing_read_response <- function(path) {
  if (!file.exists(path)) {
    return(list(valid = FALSE, value = list(), error = "Final response is missing."))
  }
  value <- tryCatch(
    jsonlite::read_json(path, simplifyVector = FALSE),
    error = function(e) e
  )
  if (inherits(value, "error")) {
    return(list(
      valid = FALSE, value = list(),
      error = paste("Final response is invalid JSON:", conditionMessage(value))
    ))
  }
  required <- c("answer", "evidence_paths", "route_summary", "confidence")
  if (!is.list(value) || !all(required %in% names(value))) {
    return(list(
      valid = FALSE, value = value,
      error = "Final response does not satisfy the required routing schema."
    ))
  }
  list(valid = TRUE, value = value, error = "")
}

routing_read_events <- function(path) {
  if (!file.exists(path)) return(list())
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  lines <- lines[nzchar(trimws(lines))]
  lapply(lines, function(line) {
    tryCatch(
      jsonlite::fromJSON(line, simplifyVector = FALSE),
      error = function(e) NULL
    )
  })
}

routing_event_metrics <- function(events) {
  events <- Filter(Negate(is.null), events)
  completed <- Filter(
    function(x) identical(x$type, "turn.completed") && is.list(x$usage),
    events
  )
  usage <- if (length(completed)) completed[[length(completed)]]$usage else list()
  tool_types <- c(
    "command_execution", "mcp_tool_call", "web_search", "file_change"
  )
  tool_calls <- sum(vapply(events, function(x) {
    identical(x$type, "item.completed") &&
      is.list(x$item) &&
      as.character(x$item$type %||% "") %in% tool_types
  }, logical(1)))
  list(
    input_tokens = routing_number(usage$input_tokens),
    cached_input_tokens = routing_number(usage$cached_input_tokens),
    output_tokens = routing_number(usage$output_tokens),
    tool_calls = tool_calls
  )
}

routing_execution_status <- function(execution) {
  status <- if (is.list(execution)) execution$status else execution
  status <- suppressWarnings(as.integer(status)[1])
  if (is.na(status)) 1L else status
}

routing_runs_data_frame <- function(runs) {
  scalar_names <- setdiff(names(runs[[1]]), "evidence_paths")
  out <- do.call(rbind, lapply(runs, function(x) {
    as.data.frame(x[scalar_names], stringsAsFactors = FALSE)
  }))
  out$evidence_paths <- I(lapply(runs, function(x) x$evidence_paths[[1]]))
  rownames(out) <- NULL
  out
}

routing_positive_integer <- function(x, arg) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x < 1 || x != as.integer(x)) {
    stop("`", arg, "` must be one positive integer.", call. = FALSE)
  }
  as.integer(x)
}

routing_git_sha <- function(root) {
  out <- tryCatch(
    suppressWarnings(system2(
      "git", c("-C", shQuote(root), "rev-parse", "HEAD"),
      stdout = TRUE, stderr = FALSE
    )),
    error = function(e) character()
  )
  if (length(out) && grepl("^[0-9a-f]{40}$", out[[1]])) out[[1]] else NA_character_
}

routing_git_dirty <- function(root) {
  out <- tryCatch(
    suppressWarnings(system2(
      "git",
      c("-C", shQuote(root), "status", "--porcelain", "--untracked-files=all"),
      stdout = TRUE,
      stderr = FALSE
    )),
    error = function(e) "unknown"
  )
  length(out) > 0L
}

path_within <- function(path, root) {
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  identical(path, root) || startsWith(path, paste0(root, "/"))
}

routing_number <- function(x) {
  value <- suppressWarnings(as.numeric(x)[1])
  if (is.na(value)) NA_real_ else value
}

`%||%` <- function(x, y) if (is.null(x) || !length(x)) y else x
