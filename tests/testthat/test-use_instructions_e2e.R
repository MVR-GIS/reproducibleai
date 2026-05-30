test_that("end-to-end: use_instructions installs a standard recipe into dev/instructions", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  out <- use_instructions(
    spec = c("chat-manual", "goals", "r-package"),
    dest_dir = dest_dir,
    overwrite = TRUE,
    write_entrypoint = TRUE,
    quiet = TRUE
  )

  expect_type(out, "character")
  expect_true(all(file.exists(out)))

  expect_true(file.exists(file.path(tmp, "dev", "instructions", "chat-manual.md")))
  expect_true(file.exists(file.path(tmp, "dev", "instructions", "goals.md")))
  expect_true(file.exists(file.path(tmp, "dev", "instructions", "r-package.md")))
  expect_true(file.exists(file.path(tmp, "dev", "instructions", "CHAT_INSTRUCTIONS.md")))

  entry <- paste(
    readLines(file.path(tmp, "dev", "instructions", "CHAT_INSTRUCTIONS.md"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(entry, 'c\\("chat-manual", "goals", "r-package"\\)', perl = TRUE)
  expect_match(entry, "dev/instructions/chat-manual.md", fixed = TRUE)
  expect_match(entry, "dev/instructions/goals.md", fixed = TRUE)
  expect_match(entry, "dev/instructions/r-package.md", fixed = TRUE)
})

test_that("end-to-end: development-governance scaffolds required dev artifacts through use_instructions", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  out <- use_instructions(
    spec = c("chat-manual", "development-governance"),
    dest_dir = dest_dir,
    overwrite = FALSE,
    write_entrypoint = TRUE,
    quiet = TRUE
  )

  expect_true(all(file.exists(out)))

  # Installed instruction files
  expect_true(file.exists(file.path(tmp, "dev", "instructions", "chat-manual.md")))
  expect_true(file.exists(file.path(tmp, "dev", "instructions", "development-governance.md")))
  expect_true(file.exists(file.path(tmp, "dev", "instructions", "CHAT_INSTRUCTIONS.md")))

  # Governance scaffold
  expect_true(file.exists(file.path(tmp, "dev", "05_plan.md")))
  expect_true(file.exists(file.path(tmp, "dev", "10_design.md")))
  expect_true(file.exists(file.path(tmp, "dev", "40_schemas.md")))
  expect_true(file.exists(file.path(tmp, "dev", "decisions", "README.md")))

  expect_true(dir.exists(file.path(tmp, "dev")))
  expect_true(dir.exists(file.path(tmp, "dev", "decisions")))
  expect_true(dir.exists(file.path(tmp, "dev", "instructions")))
  expect_true(dir.exists(file.path(tmp, "dev", "sessions")))
})

test_that("end-to-end: repeated governance install with overwrite = FALSE preserves edited scaffold files", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  use_instructions(
    spec = c("development-governance"),
    dest_dir = dest_dir,
    overwrite = FALSE,
    write_entrypoint = TRUE,
    quiet = TRUE
  )

  plan_path <- file.path(tmp, "dev", "05_plan.md")
  design_path <- file.path(tmp, "dev", "10_design.md")

  writeLines("custom plan content", plan_path)
  writeLines("custom design content", design_path)

  out <- use_instructions(
    spec = c("development-governance"),
    dest_dir = dest_dir,
    overwrite = FALSE,
    write_entrypoint = TRUE,
    quiet = TRUE
  )

  expect_identical(readLines(plan_path, warn = FALSE), "custom plan content")
  expect_identical(readLines(design_path, warn = FALSE), "custom design content")

  # On a second run with overwrite = FALSE, only the entrypoint should be written.
  expect_true("CHAT_INSTRUCTIONS.md" %in% basename(out))
  expect_false("05_plan.md" %in% basename(out))
  expect_false("10_design.md" %in% basename(out))
})

test_that("end-to-end: repeated governance install with overwrite = TRUE refreshes scaffold files", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  use_instructions(
    spec = c("development-governance"),
    dest_dir = dest_dir,
    overwrite = FALSE,
    write_entrypoint = TRUE,
    quiet = TRUE
  )

  plan_path <- file.path(tmp, "dev", "05_plan.md")
  writeLines("custom plan content", plan_path)

  out <- use_instructions(
    spec = c("development-governance"),
    dest_dir = dest_dir,
    overwrite = TRUE,
    write_entrypoint = TRUE,
    quiet = TRUE
  )

  expect_false(identical(readLines(plan_path, warn = FALSE), "custom plan content"))
  expect_true("development-governance.md" %in% basename(out))
  expect_true("CHAT_INSTRUCTIONS.md" %in% basename(out))
})

test_that("end-to-end: mixed recipe with development-governance preserves module order in entrypoint", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  use_instructions(
    spec = c("goals", "development-governance", "chat-manual"),
    dest_dir = dest_dir,
    overwrite = TRUE,
    write_entrypoint = TRUE,
    quiet = TRUE
  )

  entry <- paste(
    readLines(file.path(tmp, "dev", "instructions", "CHAT_INSTRUCTIONS.md"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(
    entry,
    'c\\("goals", "development-governance", "chat-manual"\\)',
    perl = TRUE
  )

  expect_match(entry, "- goals", fixed = TRUE)
  expect_match(entry, "- development-governance", fixed = TRUE)
  expect_match(entry, "- chat-manual", fixed = TRUE)
})

test_that("end-to-end: parameterized-help scaffolds help framework through use_instructions", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  out <- use_instructions(
    spec = c("chat-manual", "parameterized-help"),
    dest_dir = dest_dir,
    overwrite = FALSE,
    write_entrypoint = TRUE,
    quiet = TRUE
  )

  expect_true(all(file.exists(out)))

  expect_true(file.exists(file.path(tmp, "dev", "instructions", "parameterized-help.md")))
  expect_true(file.exists(file.path(tmp, "data-raw", "create_help_data.R")))
  expect_true(file.exists(file.path(tmp, "R", "help_data.R")))
  expect_true(file.exists(file.path(tmp, "inst", "app", "www", "help.css")))
  expect_true(file.exists(file.path(tmp, "dev", "instructions", "CHAT_INSTRUCTIONS.md")))
})
