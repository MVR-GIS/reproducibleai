test_that("module_source_path() resolves existing modules", {
  path <- module_source_path("chat-manual")

  expect_type(path, "character")
  expect_length(path, 1)
  expect_true(file.exists(path))
  expect_match(basename(path), "^chat-manual\\.md$")
})

test_that("module_source_path() errors for unknown modules", {
  expect_error(
    module_source_path("does-not-exist"),
    "No canonical instruction source file found",
    fixed = TRUE
  )
})

test_that("module_target_path() builds expected install path", {
  target <- module_target_path("chat-manual", path = "repo-root")

  expect_identical(
    target,
    file.path("repo-root", "dev", "instructions", "chat-manual.md")
  )
})

test_that("ensure_dir() creates missing directories", {
  tmp <- withr::local_tempdir()
  dir_path <- file.path(tmp, "a", "b", "c")

  out <- ensure_dir(dir_path)

  expect_true(dir.exists(dir_path))
  expect_identical(out$path, dir_path)
  expect_true(isTRUE(out$created))
})

test_that("ensure_dir() reports existing directories without recreating", {
  tmp <- withr::local_tempdir()
  dir_path <- file.path(tmp, "existing")
  dir.create(dir_path, recursive = TRUE)

  out <- ensure_dir(dir_path)

  expect_true(dir.exists(dir_path))
  expect_identical(out$path, dir_path)
  expect_false(isTRUE(out$created))
})

test_that("ensure_dir() errors if path exists as a file", {
  tmp <- withr::local_tempdir()
  file_path <- file.path(tmp, "not-a-dir")
  writeLines("x", file_path)

  expect_error(
    ensure_dir(file_path),
    "Path exists but is not a directory",
    fixed = TRUE
  )
})

test_that("install_module_text() creates dev/instructions and writes file", {
  tmp <- withr::local_tempdir()

  out <- install_module_text("chat-manual", path = tmp, overwrite = FALSE)

  target <- file.path(tmp, "dev", "instructions", "chat-manual.md")

  expect_true(file.exists(target))
  expect_identical(out$module_name, "chat-manual")
  expect_true(file.exists(out$source))
  expect_identical(out$target, target)
  expect_true(target %in% out$files_written)
  expect_length(out$files_skipped, 0)
  expect_true(file.path(tmp, "dev", "instructions") %in% out$dirs_created)
})

test_that("install_module_text() skips existing file when overwrite = FALSE", {
  tmp <- withr::local_tempdir()

  first <- install_module_text("chat-manual", path = tmp, overwrite = FALSE)
  second <- install_module_text("chat-manual", path = tmp, overwrite = FALSE)

  expect_length(first$files_written, 1)
  expect_length(second$files_written, 0)
  expect_true(second$target %in% second$files_skipped)
})

test_that("install_module_text() overwrites existing file when overwrite = TRUE", {
  tmp <- withr::local_tempdir()

  install_module_text("chat-manual", path = tmp, overwrite = FALSE)

  target <- file.path(tmp, "dev", "instructions", "chat-manual.md")
  writeLines("modified", target)

  out <- install_module_text("chat-manual", path = tmp, overwrite = TRUE)

  expect_true(target %in% out$files_written)

  src <- module_source_path("chat-manual")
  expect_identical(
    readLines(target, warn = FALSE),
    readLines(src, warn = FALSE)
  )
})

test_that("module_name_to_handler() maps kebab-case names correctly", {
  expect_identical(
    module_name_to_handler("development-governance"),
    "module_development_governance"
  )

  expect_identical(
    module_name_to_handler("parameterized-help"),
    "module_parameterized_help"
  )
})

test_that("get_module_handler() resolves an existing handler", {
  handler <- get_module_handler("chat-manual")

  expect_true(is.function(handler))
  expect_identical(module_name_to_handler("chat-manual"), "module_chat_manual")
})

test_that("new_module_result() returns standard result shape", {
  out <- new_module_result(
    module_name = "chat-manual",
    instruction_source = "src.md",
    instruction_target = "dest.md",
    dirs_created = "dev/instructions",
    files_written = "dev/instructions/chat-manual.md"
  )

  expect_true(all(c(
    "module_name",
    "instruction_source",
    "instruction_target",
    "dirs_created",
    "files_written",
    "files_skipped",
    "warnings",
    "next_steps"
  ) %in% names(out)))

  expect_identical(out$module_name, "chat-manual")
  expect_type(out$files_skipped, "character")
  expect_type(out$warnings, "character")
  expect_type(out$next_steps, "character")
})

test_that("combine_module_results() aggregates per-module results", {
  r1 <- new_module_result(
    module_name = "chat-manual",
    instruction_source = "src1",
    instruction_target = "dest1",
    dirs_created = "dev/instructions",
    files_written = "dest1",
    next_steps = "review chat-manual"
  )

  r2 <- new_module_result(
    module_name = "goals",
    instruction_source = "src2",
    instruction_target = "dest2",
    files_skipped = "dest2",
    warnings = "none"
  )

  out <- combine_module_results(list(r1, r2))

  expect_identical(out$modules_processed, c("chat-manual", "goals"))
  expect_true("dev/instructions" %in% out$dirs_created)
  expect_true("dest1" %in% out$files_written)
  expect_true("dest2" %in% out$files_skipped)
  expect_true("none" %in% out$warnings)
  expect_true("review chat-manual" %in% out$next_steps)
  expect_length(out$results, 2)
})

test_that("normalize_module_names() de-duplicates while preserving order", {
  out <- normalize_module_names(c(" goals ", "chat-manual", "goals", "chat-manual"))

  expect_identical(out, c("goals", "chat-manual"))
})

test_that("normalize_module_names() errors on invalid input", {
  expect_error(
    normalize_module_names(character()),
    "non-empty character vector",
    fixed = FALSE
  )

  expect_error(
    normalize_module_names(NA_character_),
    "missing/empty module names",
    fixed = FALSE
  )

  expect_error(
    normalize_module_names("  "),
    "missing/empty module names",
    fixed = FALSE
  )
})

test_that("validate_modules_available() accepts known modules and errors on unknown ones", {
  expect_no_error(validate_modules_available(c("chat-manual", "goals")))

  expect_error(
    validate_modules_available(c("chat-manual", "does-not-exist")),
    "Unknown instruction module(s): does-not-exist",
    fixed = TRUE
  )
})

test_that("write_text_file_if_needed() writes a missing file", {
  tmp <- withr::local_tempdir()
  path <- file.path(tmp, "subdir", "file.txt")

  out <- write_text_file_if_needed(
    path = path,
    lines = c("a", "b"),
    overwrite = FALSE
  )

  expect_true(file.exists(path))
  expect_true(isTRUE(out$written))
  expect_false(isTRUE(out$skipped))
  expect_identical(readLines(path, warn = FALSE), c("a", "b"))
})

test_that("write_text_file_if_needed() skips an existing file when overwrite = FALSE", {
  tmp <- withr::local_tempdir()
  path <- file.path(tmp, "file.txt")

  writeLines("original", path)

  out <- write_text_file_if_needed(
    path = path,
    lines = "new",
    overwrite = FALSE
  )

  expect_false(isTRUE(out$written))
  expect_true(isTRUE(out$skipped))
  expect_identical(readLines(path, warn = FALSE), "original")
})

test_that("write_text_file_if_needed() overwrites an existing file when overwrite = TRUE", {
  tmp <- withr::local_tempdir()
  path <- file.path(tmp, "file.txt")

  writeLines("original", path)

  out <- write_text_file_if_needed(
    path = path,
    lines = c("new1", "new2"),
    overwrite = TRUE
  )

  expect_true(isTRUE(out$written))
  expect_false(isTRUE(out$skipped))
  expect_identical(readLines(path, warn = FALSE), c("new1", "new2"))
})
