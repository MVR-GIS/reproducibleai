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

test_that("the structured-response schema uses the supported Codex subset", {
  schema <- jsonlite::read_json(
    reproducibleai:::routing_result_schema_path(),
    simplifyVector = FALSE
  )

  expect_false(
    "uniqueItems" %in% names(schema$properties$evidence_paths)
  )
  expect_false(is.null(schema$properties$evidence_paths$items$type))
  expect_false(isTRUE(schema$additionalProperties))
})

test_that("competency derivation is deterministic and independent of AGENTS", {
  target <- withr::local_tempdir()
  use_agentic_context(target, profiles = "base", quiet = TRUE)
  writeLines(c(
    "# Project plan", "", "## Current objective", "",
    "Build deterministic routing evidence from maintained development context."
  ), file.path(target, "dev", "goals", "project-plan.md"))
  decision <- file.path(target, "dev", "decisions", "adr-0001-test.md")
  dir.create(dirname(decision), recursive = TRUE, showWarnings = FALSE)
  writeLines(c(
    "# ADR-0001: Test", "", "## Decision", "",
    "Use repository files as the independent criterion for routing evaluation."
  ), decision)
  agents <- file.path(target, "AGENTS.md")
  write(
    "SECRET ROUTING ANSWER THAT MUST NOT BE DERIVED",
    file = agents, append = TRUE
  )

  first <- derive_agentic_routing_questions(target, max_per_type = 5)
  second <- derive_agentic_routing_questions(target, max_per_type = 5)
  answers <- vapply(first$questions, function(x) x$canonical_answer, character(1))

  expect_identical(first$questions, second$questions)
  expect_true(all(vapply(
    first$questions, function(x) identical(x$review_status, "pending"), logical(1)
  )))
  expect_false(any(grepl("SECRET ROUTING", answers, fixed = TRUE)))
  expect_true(any(grepl("independent criterion", answers, fixed = TRUE)))
})

test_that("generated benchmarks require review and round-trip outside target", {
  target <- withr::local_tempdir()
  use_agentic_context(target, profiles = "base", quiet = TRUE)
  writeLines(c(
    "# Project plan", "", "## Current objective", "",
    "Measure whether maintained context reaches a fresh agentic session."
  ), file.path(target, "dev", "goals", "project-plan.md"))
  benchmark <- derive_agentic_routing_questions(target, max_per_type = 1)
  ids <- vapply(benchmark$questions, function(x) x$id, character(1))

  expect_error(
    reproducibleai:::normalize_routing_questions(benchmark),
    "explicit human review"
  )
  expect_error(
    write_agentic_routing_benchmark(benchmark, tempfile(fileext = ".json")),
    "Resolve every pending"
  )
  reviewed <- review_agentic_routing_benchmark(
    benchmark, approve = ids[[1]], reject = ids[-1]
  )
  expect_length(reproducibleai:::normalize_routing_questions(reviewed), 1)
  expect_error(
    review_agentic_routing_benchmark(benchmark, approve = "unknown"),
    "Unknown"
  )
  expect_error(
    write_agentic_routing_benchmark(
      reviewed, file.path(target, "private-benchmark.json")
    ),
    "outside"
  )

  frozen <- tempfile(fileext = ".json")
  write_agentic_routing_benchmark(reviewed, frozen)
  restored <- read_agentic_routing_benchmark(frozen)
  expect_s3_class(restored, "agentic_routing_benchmark")
  expect_identical(restored$questions, reviewed$questions)
  expect_identical(restored$rules_hash, reviewed$rules_hash)
})

test_that("flat review sheets support editable QA and protect provenance", {
  target <- withr::local_tempdir()
  use_agentic_context(target, profiles = "base", quiet = TRUE)
  writeLines(c(
    "# Project plan", "", "## Current objective", "",
    "Measure whether maintained context reaches a fresh agentic session."
  ), file.path(target, "dev", "goals", "project-plan.md"))
  benchmark <- derive_agentic_routing_questions(target, max_per_type = 1)
  review_path <- tempfile("routing-review-")

  write_agentic_routing_review(benchmark, review_path)
  questions_path <- file.path(review_path, "questions.csv")
  expect_true(file.exists(file.path(review_path, "REVIEW.md")))
  expect_true(file.exists(file.path(review_path, "exclusions.csv")))
  review <- utils::read.csv(
    questions_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  expect_s3_class(as_agentic_routing_review(benchmark), "data.frame")
  expect_true(all(c(
    "review_status", "review_note", "prompt", "canonical_answer",
    "source_path", "source_hash", "rules_hash"
  ) %in% names(review)))

  review$review_status <- "rejected"
  review$review_status[[1]] <- "approved"
  review$review_note[[1]] <- "Source and answer verified."
  review$prompt[[1]] <- paste(review$prompt[[1]], "Be concise.")
  review$canonical_answer[[1]] <- paste(
    review$canonical_answer[[1]], "This sentence was verified by the reviewer."
  )
  utils::write.csv(
    review, questions_path, row.names = FALSE, fileEncoding = "UTF-8"
  )
  applied <- apply_agentic_routing_review(benchmark, review_path)

  expect_identical(applied$questions[[1]]$review_status, "approved")
  expect_identical(
    applied$questions[[1]]$review_note, "Source and answer verified."
  )
  expect_match(applied$questions[[1]]$prompt, "Be concise", fixed = TRUE)
  expect_match(
    applied$questions[[1]]$canonical_answer,
    "verified by the reviewer",
    fixed = TRUE
  )

  incomplete <- review
  incomplete$review_status[[1]] <- "pending"
  utils::write.csv(
    incomplete, questions_path, row.names = FALSE, fileEncoding = "UTF-8"
  )
  expect_error(
    apply_agentic_routing_review(benchmark, review_path),
    "Review is incomplete"
  )
  expect_s3_class(
    apply_agentic_routing_review(
      benchmark, review_path, require_complete = FALSE
    ),
    "agentic_routing_benchmark"
  )

  tampered <- review
  tampered$source_path[[1]] <- "dev/goals/not-the-source.md"
  utils::write.csv(
    tampered, questions_path, row.names = FALSE, fileEncoding = "UTF-8"
  )
  expect_error(
    apply_agentic_routing_review(benchmark, review_path),
    "Locked review provenance"
  )
  expect_error(
    write_agentic_routing_review(
      benchmark, file.path(target, "gold-review.csv")
    ),
    "outside"
  )
})

test_that("derivation rejects complex sections conservatively", {
  target <- withr::local_tempdir()
  use_agentic_context(target, profiles = "base", quiet = TRUE)
  writeLines(c(
    "# Project plan", "", "## Current objective", "",
    "| Field | Value |", "|---|---|", "| objective | hidden |"
  ), file.path(target, "dev", "goals", "project-plan.md"))

  benchmark <- derive_agentic_routing_questions(target)
  paths <- vapply(
    benchmark$questions, function(x) x$required_paths[[1]], character(1)
  )
  expect_false("dev/goals/project-plan.md" %in% paths)
  expect_true(any(
    benchmark$exclusions$path == "dev/goals/project-plan.md" &
      benchmark$exclusions$reason == "section contains Markdown table"
  ))
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

test_that("generated questions use canonical-answer token F1", {
  question <- new_agentic_routing_question(
    id = "grounding",
    prompt = "State the objective.",
    required_paths = "dev/goals/project-plan.md",
    canonical_answer = "alpha beta beta gamma"
  )
  score <- score_agentic_routing_run(question, list(
    answer = "alpha beta extra",
    evidence_paths = list("dev/goals/project-plan.md"),
    route_summary = "Used the maintained goal.",
    confidence = 1
  ))

  expect_equal(score$answer_precision, 2 / 3)
  expect_equal(score$answer_recall, 2 / 4)
  expect_equal(score$answer_f1, 4 / 7)
  expect_equal(score$answer_score, score$answer_f1)
  expect_equal(score$score, 0.4 + 0.2 + 0.3 * (4 / 7) + 0.1)
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
  expect_true(all(vapply(
    calls,
    function(x) !"--ask-for-approval" %in% x$args,
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
  expect_false(any(grepl(
    "clarify the AGENTS.md route",
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

test_that("routing prerequisite checks are diagnostic and do not run a model", {
  calls <- list()
  fake_run <- function(command, args, timeout) {
    calls[[length(calls) + 1L]] <<- list(
      command = command, args = args, timeout = timeout
    )
    if (identical(args, "--version")) {
      return(list(
        status = 0L, stdout = "codex-cli test-version", stderr = character()
      ))
    }
    if (identical(args, c("login", "status"))) {
      return(list(
        status = 0L, stdout = "Logged in using ChatGPT", stderr = character()
      ))
    }
    if (identical(args, c("exec", "--help"))) {
      return(list(
        status = 0L,
        stdout = paste(
          "--cd --sandbox --ephemeral --ignore-user-config --json",
          "--output-schema --output-last-message"
        ),
        stderr = character()
      ))
    }
    stop("unexpected command")
  }

  status <- reproducibleai:::routing_prerequisite_status(
    codex = "test-codex",
    run = fake_run
  )

  expect_s3_class(status, "agentic_routing_prerequisites")
  expect_true(status$ready)
  expect_true(status$cli_available)
  expect_true(status$exec_compatible)
  expect_identical(status$codex_version, "codex-cli test-version")
  expect_identical(status$authentication, "authenticated")
  expect_identical(status$network_policy, "not_tested")
  expect_length(calls, 3)
  expect_identical(calls[[1]]$args, "--version")
  expect_identical(calls[[2]]$args, c("login", "status"))
  expect_identical(calls[[3]]$args, c("exec", "--help"))
})

test_that("preflight rejects an incompatible codex exec interface", {
  fake_run <- function(command, args, timeout) {
    if (identical(args, "--version")) {
      return(list(status = 0L, stdout = "codex-cli old", stderr = character()))
    }
    if (identical(args, c("login", "status"))) {
      return(list(status = 0L, stdout = "Logged in", stderr = character()))
    }
    list(status = 0L, stdout = "--sandbox --json", stderr = character())
  }

  status <- reproducibleai:::routing_prerequisite_status(
    codex = "old-codex",
    run = fake_run
  )

  expect_false(status$ready)
  expect_false(status$exec_compatible)
  expect_match(status$limitations, "incompatible")
})

test_that("restricted environments remain usable for offline capabilities", {
  unavailable <- function(command, args, timeout) {
    list(status = 1L, stdout = character(), stderr = "execution prohibited")
  }

  status <- reproducibleai:::routing_prerequisite_status(
    codex = "blocked-codex",
    run = unavailable
  )

  expect_false(status$ready)
  expect_false(status$cli_available)
  expect_identical(status$authentication, "unavailable")
  expect_match(status$limitations, "runnable standalone Codex CLI")

  question <- new_agentic_routing_question(
    id = "offline",
    prompt = "Find the plan.",
    required_paths = "dev/goals/project-plan.md"
  )
  score <- score_agentic_routing_run(
    question,
    list(
      answer = "The plan is maintained under project goals.",
      evidence_paths = list("dev/goals/project-plan.md"),
      route_summary = "Used the project goals route.",
      confidence = 1
    )
  )
  expect_gt(score$score, 0)
})

test_that("Windows discovery includes the no-admin standalone install path", {
  skip_if_not(.Platform$OS.type == "windows")
  candidates <- reproducibleai:::routing_codex_candidates()
  expect_true(any(grepl(
    "Programs.OpenAI.Codex.bin.codex[.]exe$",
    candidates
  )))
})

test_that("the default live runner uses only base R process execution", {
  script <- tempfile(fileext = ".R")
  stdout <- tempfile()
  stderr <- tempfile()
  writeLines("cat('runner-ok\\n')", script)
  command <- file.path(R.home("bin"), "Rscript.exe")
  if (!file.exists(command)) command <- file.path(R.home("bin"), "Rscript")

  result <- reproducibleai:::routing_process_runner(
    command = command,
    args = script,
    wd = tempdir(),
    stdout = stdout,
    stderr = stderr,
    timeout = 30
  )

  expect_identical(result$status, 0L)
  expect_identical(readLines(stdout), "runner-ok")
  expect_length(readLines(stderr), 0)
})
