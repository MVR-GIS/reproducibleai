test_that("module_parameterized_help() installs instruction text and scaffolds help framework", {
  tmp <- withr::local_tempdir()

  out <- module_parameterized_help(path = tmp, overwrite = FALSE)

  expect_identical(out$module_name, "parameterized-help")

  expect_true(file.exists(file.path(tmp, "dev", "instructions", "parameterized-help.md")))
  expect_true(file.exists(file.path(tmp, "data-raw", "create_help_data.R")))
  expect_true(file.exists(file.path(tmp, "R", "help_data.R")))
  expect_true(file.exists(file.path(tmp, "inst", "app", "www", "help.css")))

  expect_true(dir.exists(file.path(tmp, "data-raw")))
  expect_true(dir.exists(file.path(tmp, "R")))
  expect_true(dir.exists(file.path(tmp, "inst", "app", "www")))

  expect_true(length(out$files_written) > 0)
  expect_true(any(grepl("40_schemas.md", out$next_steps, fixed = TRUE)))
})

test_that("module_parameterized_help() preserves existing scaffold files when overwrite = FALSE", {
  tmp <- withr::local_tempdir()

  module_parameterized_help(path = tmp, overwrite = FALSE)

  help_script_path <- file.path(tmp, "data-raw", "create_help_data.R")
  writeLines("custom help script", help_script_path)

  out <- module_parameterized_help(path = tmp, overwrite = FALSE)

  expect_identical(readLines(help_script_path, warn = FALSE), "custom help script")
  expect_true(help_script_path %in% out$files_skipped)
})

test_that("module_parameterized_help() overwrites scaffold files when overwrite = TRUE", {
  tmp <- withr::local_tempdir()

  module_parameterized_help(path = tmp, overwrite = FALSE)

  help_script_path <- file.path(tmp, "data-raw", "create_help_data.R")
  writeLines("custom help script", help_script_path)

  out <- module_parameterized_help(path = tmp, overwrite = TRUE)

  expect_false(identical(readLines(help_script_path, warn = FALSE), "custom help script"))
  expect_true(help_script_path %in% out$files_written)
})

test_that("module_parameterized_help() returns next steps", {
  tmp <- withr::local_tempdir()

  out <- module_parameterized_help(path = tmp, overwrite = FALSE)

  expect_true(length(out$next_steps) > 0)
  expect_true(any(grepl("help_data", out$next_steps, fixed = TRUE)))
})
