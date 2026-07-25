test_that("routing questions round-trip through the versioned JSON fixture", {
  question <- new_agentic_routing_question(
    id = "current-priority",
    prompt = "What is the current project priority?",
    required_paths = "dev/goals/project-plan.md",
    allowed_paths = c("AGENTS.md", "dev/architecture/"),
    expected_terms = c("current objective", "routing"),
    forbidden_terms = "session transcript",
    weight = 2
  )
  path <- tempfile(fileext = ".json")

  written <- write_agentic_routing_questions(question, path)
  read <- read_agentic_routing_questions(path)

  expect_true(file.exists(written))
  expect_length(read, 1)
  expect_s3_class(read[[1]], "agentic_routing_question")
  expect_identical(read[[1]]$id, question$id)
  expect_identical(read[[1]]$required_paths, question$required_paths)
  expect_identical(read[[1]]$allowed_paths, question$allowed_paths)
  expect_identical(read[[1]]$weight, 2)
  expect_error(
    write_agentic_routing_questions(question, path),
    "already exists"
  )
})

test_that("routing question validation rejects ambiguous fixtures", {
  expect_error(
    new_agentic_routing_question(
      id = "bad id",
      prompt = "Prompt",
      required_paths = "AGENTS.md"
    ),
    "must start"
  )
  expect_error(
    new_agentic_routing_question(
      id = "duplicate",
      prompt = "Prompt",
      required_paths = character()
    ),
    "must contain"
  )
  question <- new_agentic_routing_question(
    id = "duplicate",
    prompt = "Prompt",
    required_paths = "AGENTS.md"
  )
  expect_error(
    reproducibleai:::normalize_routing_questions(list(question, question)),
    "must be unique"
  )
})

test_that("offline routing scoring is transparent and path-aware", {
  question <- new_agentic_routing_question(
    id = "route",
    prompt = "Find the plan.",
    required_paths = c("AGENTS.md", "dev/goals/"),
    allowed_paths = "dev/architecture/design.md",
    expected_terms = c("routing", "evaluation"),
    forbidden_terms = "legacy transcript"
  )
  response <- list(
    answer = "Routing evaluation is the current work.",
    evidence_paths = list(
      "AGENTS.md",
      "dev/goals/project-plan.md",
      "README.md"
    ),
    route_summary = "Followed the goals route.",
    confidence = 0.9
  )

  score <- score_agentic_routing_run(question, response)

  expect_equal(score$route_recall, 1)
  expect_equal(score$route_precision, 2 / 3)
  expect_equal(score$term_recall, 1)
  expect_equal(score$forbidden_rate, 0)
  expect_equal(score$score, 0.4 + 0.2 * (2 / 3) + 0.3 + 0.1)
})

test_that("repeated evaluation uses isolated structured Codex runs", {
  target <- withr::local_tempdir()
  use_agentic_context(target, profiles = "base", quiet = TRUE)
  writeLines(
    c("# Plan", "", "Routing evaluation is the current objective."),
    file.path(target, "dev", "goals", "project-plan.md")
  )
  question <- new_agentic_routing_question(
    id = "current-priority",
    prompt = "What is the current objective?",
    required_paths = "dev/goals/project-plan.md",
    allowed_paths = "AGENTS.md",
    expected_terms = c("routing evaluation", "current objective"),
    forbidden_terms = "session transcript"
  )
  output <- tempfile("routing-output-")
  calls <- list()
  fake_runner <- function(command, args, wd, stdout, stderr, timeout) {
    calls[[length(calls) + 1L]] <<- list(
      command = command, args = args, wd = wd, timeout = timeout
    )
    response_path <- args[[match("--output-last-message", args) + 1L]]
    response <- list(
      answer = "Routing evaluation is the current objective.",
      evidence_paths = list(
        "AGENTS.md",
        "dev/goals/project-plan.md"
      ),
      route_summary = "AGENTS.md routed the task to project goals.",
      confidence = 0.95
    )
    jsonlite::write_json(response, response_path, auto_unbox = TRUE)
    events <- c(
      jsonlite::toJSON(
        list(type = "thread.started", thread_id = "thread-test"),
        auto_unbox = TRUE
      ),
      jsonlite::toJSON(
        list(
          type = "item.completed",
          item = list(type = "command_execution")
        ),
        auto_unbox = TRUE
      ),
      jsonlite::toJSON(
        list(
          type = "turn.completed",
          usage = list(
            input_tokens = 100,
            cached_input_tokens = 60,
            output_tokens = 20
          )
        ),
        auto_unbox = TRUE
      )
    )
    writeLines(events, stdout)
    writeLines(character(), stderr)
    list(status = 0L)
  }

  evaluation <- run_agentic_routing_evaluation(
    path = target,
    questions = question,
    repetitions = 2,
    approved = TRUE,
    output_dir = output,
    codex = "fake-codex",
    model = "test-model",
    runner = fake_runner,
    quiet = TRUE
  )

  expect_s3_class(evaluation, "agentic_routing_evaluation")
  expect_equal(nrow(evaluation$runs), 2)
  expect_true(all(evaluation$runs$completed))
  expect_equal(evaluation$runs$score, c(1, 1))
  expect_equal(evaluation$runs$input_tokens, c(100, 100))
  expect_equal(evaluation$runs$cached_input_tokens, c(60, 60))
  expect_equal(evaluation$runs$tool_calls, c(1, 1))
  expect_identical(evaluation$codex_version, "injected-runner")
  expect_length(calls, 2)
  expect_true(all(vapply(
    calls,
    function(x) all(c(
      "--ephemeral", "--json", "--ignore-user-config",
      "--output-schema", "--output-last-message"
    ) %in% x$args),
    logical(1)
  )))
  expect_true(all(vapply(
    calls,
    function(x) {
      identical(x$args[[match("--sandbox", x$args) + 1L]], "read-only")
    },
    logical(1)
  )))
  expect_false(reproducibleai:::path_within(evaluation$output_dir, target))
})

test_that("failed execution scores zero and remains reportable", {
  target <- withr::local_tempdir()
  use_agentic_context(target, profiles = "base", quiet = TRUE)
  question <- new_agentic_routing_question(
    id = "failure",
    prompt = "Find the plan.",
    required_paths = "dev/goals/README.md"
  )
  runner <- function(command, args, wd, stdout, stderr, timeout) {
    writeLines("authentication failed", stderr)
    list(status = 1L, error = "Codex failed")
  }
  evaluation <- run_agentic_routing_evaluation(
    target, question, repetitions = 1, approved = TRUE,
    output_dir = tempfile("routing-failure-"),
    runner = runner, quiet = TRUE
  )
  health <- summarize_agentic_routing(evaluation)
  report <- tempfile(fileext = ".md")
  write_agentic_routing_report(health, report)

  expect_false(evaluation$runs$completed)
  expect_equal(evaluation$runs$score, 0)
  expect_equal(health$health_score, 0)
  expect_true(any(grepl(
    "execution or structured-response failures",
    readLines(report),
    fixed = TRUE
  )))
  expect_false(any(grepl(question$prompt, readLines(report), fixed = TRUE)))
})

test_that("repeated model execution requires explicit approval", {
  target <- withr::local_tempdir()
  use_agentic_context(target, profiles = "base", quiet = TRUE)
  question <- new_agentic_routing_question(
    id = "approval",
    prompt = "Find goals.",
    required_paths = "dev/goals/README.md"
  )

  expect_error(
    run_agentic_routing_evaluation(
      target, question,
      runner = function(...) stop("runner should not be called"),
      quiet = TRUE
    ),
    "requires `approved = TRUE`"
  )
})

test_that("fixtures and raw output inside the evaluated repo are rejected", {
  target <- withr::local_tempdir()
  use_agentic_context(target, profiles = "base", quiet = TRUE)
  question <- new_agentic_routing_question(
    id = "isolation",
    prompt = "Find goals.",
    required_paths = "dev/goals/README.md"
  )
  fixture <- file.path(target, "private-questions.json")
  write_agentic_routing_questions(question, fixture)
  loaded <- read_agentic_routing_questions(fixture)

  expect_error(
    run_agentic_routing_evaluation(
      target, loaded, approved = TRUE, output_dir = tempfile("external-"),
      runner = function(...) list(status = 1L),
      quiet = TRUE
    ),
    "fixtures must remain outside"
  )
  expect_error(
    run_agentic_routing_evaluation(
      target, question, approved = TRUE,
      output_dir = file.path(target, "raw-runs"),
      runner = function(...) list(status = 1L),
      quiet = TRUE
    ),
    "must be outside"
  )
})
