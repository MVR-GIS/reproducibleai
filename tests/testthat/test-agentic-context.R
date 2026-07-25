local_git_repository <- function() {
  tmp <- tempfile()
  dir.create(tmp)
  system2("git", c("-C", shQuote(tmp), "init", "--quiet"))
  system2("git", c("-C", shQuote(tmp), "config", "user.email", "test@example.com"))
  system2("git", c("-C", shQuote(tmp), "config", "user.name", "Test User"))
  tmp
}

git_commit_all <- function(path) {
  system2("git", c("-C", shQuote(path), "add", "."))
  system2("git", c("-C", shQuote(path), "commit", "--quiet", "-m", "fixture"))
}

test_that("use_agentic_context() creates a deterministic base R package scaffold", {
  tmp <- withr::local_tempdir()
  writeLines(c("Package: example", "Version: 0.0.1"), file.path(tmp, "DESCRIPTION"))

  out <- use_agentic_context(tmp, profiles = c("base", "r-package"), quiet = TRUE)

  expect_s3_class(out, "agentic_context_result")
  expect_identical(out$profiles, c("base", "r-package"))
  expect_true(file.exists(file.path(tmp, "AGENTS.md")))
  expect_true(file.exists(file.path(tmp, "dev", "agentic-context.yml")))
  expect_true(file.exists(file.path(
    tmp, "dev", "workflows", "r-package-development.md"
  )))
  expect_false(dir.exists(file.path(tmp, "dev", "instructions")))
  expect_false(dir.exists(file.path(tmp, "dev", "sessions")))

  agents <- paste(readLines(file.path(tmp, "AGENTS.md")), collapse = "\n")
  expect_match(agents, paste0("`", basename(tmp), "`"), fixed = TRUE)
  expect_match(agents, "tests/testthat/", fixed = TRUE)

  repeated <- use_agentic_context(
    tmp, profiles = c("base", "r-package"), quiet = TRUE
  )
  expect_length(repeated$files_written, 0)
  expect_gt(length(repeated$files_skipped), 0)
})

test_that("use_agentic_context() never overwrites repository-owned content", {
  tmp <- withr::local_tempdir()
  writeLines("custom instructions", file.path(tmp, "AGENTS.md"))

  expect_error(
    use_agentic_context(tmp, profiles = "base", quiet = TRUE),
    "would overwrite repository-owned files"
  )
  expect_identical(readLines(file.path(tmp, "AGENTS.md")), "custom instructions")
  expect_false(dir.exists(file.path(tmp, "dev")))
})

test_that("detect_agentic_context_profiles() is advisory", {
  tmp <- withr::local_tempdir()
  writeLines(c("Package: example", "Version: 0.0.1"), file.path(tmp, "DESCRIPTION"))

  detected <- detect_agentic_context_profiles(tmp)

  expect_identical(detected$profile, c("base", "r-package"))
  expect_true(all(detected$detected))
  expect_identical(list.files(tmp), "DESCRIPTION")
})

test_that("validate_agentic_context() reports structural errors and local drift", {
  tmp <- withr::local_tempdir()
  use_agentic_context(tmp, profiles = "base", quiet = TRUE)

  valid <- validate_agentic_context(tmp)
  expect_s3_class(valid, "agentic_context_validation")
  expect_true(valid$valid)
  expect_length(valid$findings$level, 0)

  writeLines("repository-specific goals", file.path(tmp, "dev", "goals", "README.md"))
  drift <- validate_agentic_context(tmp)
  expect_true(drift$valid)
  expect_true(any(drift$findings$code == "repository_owned_change"))

  unlink(file.path(tmp, "dev", "architecture", "README.md"))
  invalid <- validate_agentic_context(tmp)
  expect_false(invalid$valid)
  expect_error(validate_agentic_context(tmp, strict = TRUE), "validation failed")
})

test_that("migration planning is read-only and classifies legacy artifacts", {
  tmp <- local_git_repository()
  dir.create(file.path(tmp, "dev", "instructions"), recursive = TRUE)
  writeLines("old instructions", file.path(tmp, "dev", "instructions", "legacy.md"))
  writeLines("old plan", file.path(tmp, "dev", "05_plan.md"))
  git_commit_all(tmp)
  before <- sort(list.files(tmp, recursive = TRUE, all.files = TRUE))

  plan <- plan_agentic_context_migration(tmp, profiles = "base")
  after <- sort(list.files(tmp, recursive = TRUE, all.files = TRUE))

  expect_s3_class(plan, "agentic_context_migration_plan")
  expect_identical(after, before)
  expect_true(any(
    plan$operations$action == "move" &
      plan$operations$source == "dev/05_plan.md"
  ))
  expect_true(any(
    plan$operations$action == "remove" &
      plan$operations$source == "dev/instructions/legacy.md"
  ))
  expect_false(any(plan$operations$status == "manual_review"))
})

test_that("approved migration creates, validates, then removes legacy files", {
  tmp <- local_git_repository()
  dir.create(file.path(tmp, "dev", "instructions"), recursive = TRUE)
  dir.create(file.path(tmp, "dev", "sessions"), recursive = TRUE)
  writeLines("old instructions", file.path(tmp, "dev", "instructions", "legacy.md"))
  writeLines("old transcript", file.path(tmp, "dev", "sessions", "session.md"))
  writeLines("old plan", file.path(tmp, "dev", "05_plan.md"))
  git_commit_all(tmp)

  plan <- plan_agentic_context_migration(tmp, profiles = "base")
  expect_error(
    apply_agentic_context_migration(plan),
    "requires `approved = TRUE`"
  )

  result <- apply_agentic_context_migration(
    plan, approved = TRUE, quiet = TRUE
  )

  expect_s3_class(result, "agentic_context_migration_result")
  expect_true(result$validation$valid)
  expect_true(file.exists(file.path(tmp, "AGENTS.md")))
  expect_identical(
    readLines(file.path(tmp, "dev", "goals", "project-plan.md")),
    "old plan"
  )
  expect_false(file.exists(file.path(tmp, "dev", "05_plan.md")))
  expect_false(dir.exists(file.path(tmp, "dev", "instructions")))
  expect_false(dir.exists(file.path(tmp, "dev", "sessions")))
  expect_true(file.exists(file.path(tmp, "dev", "governance", "migration-0.1.md")))
})

test_that("migration refuses untracked or changed destructive sources", {
  tmp <- local_git_repository()
  dir.create(file.path(tmp, "dev", "sessions"), recursive = TRUE)
  writeLines("untracked transcript", file.path(tmp, "dev", "sessions", "session.md"))

  plan <- plan_agentic_context_migration(tmp, profiles = "base")
  expect_true(any(plan$operations$status == "manual_review"))
  expect_error(
    apply_agentic_context_migration(plan, approved = TRUE, quiet = TRUE),
    "manual-review"
  )
  expect_true(file.exists(file.path(tmp, "dev", "sessions", "session.md")))
})
