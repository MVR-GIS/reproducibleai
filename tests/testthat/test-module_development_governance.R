test_that("module_development_governance() installs instruction text and scaffolds governance files", {
  tmp <- withr::local_tempdir()

  out <- module_development_governance(path = tmp, overwrite = FALSE)

  expect_identical(out$module_name, "development-governance")

  expect_true(file.exists(file.path(tmp, "dev", "instructions", "development-governance.md")))
  expect_true(file.exists(file.path(tmp, "dev", "05_plan.md")))
  expect_true(file.exists(file.path(tmp, "dev", "10_design.md")))
  expect_true(file.exists(file.path(tmp, "dev", "40_schemas.md")))
  expect_true(file.exists(file.path(tmp, "dev", "decisions", "README.md")))

  expect_true(dir.exists(file.path(tmp, "dev")))
  expect_true(dir.exists(file.path(tmp, "dev", "decisions")))
  expect_true(dir.exists(file.path(tmp, "dev", "instructions")))
  expect_true(dir.exists(file.path(tmp, "dev", "sessions")))

  expect_true(length(out$files_written) > 0)
})

test_that("module_development_governance() preserves existing scaffold files when overwrite = FALSE", {
  tmp <- withr::local_tempdir()

  module_development_governance(path = tmp, overwrite = FALSE)

  plan_path <- file.path(tmp, "dev", "05_plan.md")
  writeLines("custom plan", plan_path)

  out <- module_development_governance(path = tmp, overwrite = FALSE)

  expect_identical(readLines(plan_path, warn = FALSE), "custom plan")
  expect_true(plan_path %in% out$files_skipped)
})

test_that("module_development_governance() overwrites scaffold files when overwrite = TRUE", {
  tmp <- withr::local_tempdir()

  module_development_governance(path = tmp, overwrite = FALSE)

  plan_path <- file.path(tmp, "dev", "05_plan.md")
  writeLines("custom plan", plan_path)

  out <- module_development_governance(path = tmp, overwrite = TRUE)

  expect_false(identical(readLines(plan_path, warn = FALSE), "custom plan"))
  expect_true(plan_path %in% out$files_written)
})

test_that("module_development_governance() returns next steps", {
  tmp <- withr::local_tempdir()

  out <- module_development_governance(path = tmp, overwrite = FALSE)

  expect_true(length(out$next_steps) > 0)
  expect_true(any(grepl("40_schemas.md", out$next_steps, fixed = TRUE)))
})
