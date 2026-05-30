test_that("use_instructions() writes selected modules and CHAT_INSTRUCTIONS.md", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  out <- use_instructions(
    spec = c("chat-manual", "goals"),
    dest_dir = dest_dir,
    quiet = TRUE
  )

  expect_type(out, "character")
  expect_true(all(file.exists(out)))

  expect_equal(
    sort(basename(out)),
    sort(c("chat-manual.md", "goals.md", "CHAT_INSTRUCTIONS.md"))
  )

  src_dir <- system.file("instructions", package = "reproducibleai")
  expect_true(nzchar(src_dir))

  expect_identical(
    readLines(file.path(dest_dir, "chat-manual.md"), warn = FALSE),
    readLines(file.path(src_dir, "chat-manual.md"), warn = FALSE)
  )

  entry <- paste(readLines(file.path(dest_dir, "CHAT_INSTRUCTIONS.md"), warn = FALSE), collapse = "\n")
  expect_match(entry, "Selected recipe", fixed = FALSE)
  expect_match(entry, 'c\\("chat-manual", "goals"\\)', perl = TRUE)
  expect_match(entry, "- chat-manual", fixed = TRUE)
  expect_match(entry, "- goals", fixed = TRUE)
  expect_match(entry, "dev/instructions/chat-manual.md", fixed = TRUE)
  expect_match(entry, "dev/instructions/goals.md", fixed = TRUE)
})

test_that("use_instructions() validates spec", {
  expect_error(use_instructions(), "`spec` is required", fixed = FALSE)
  expect_error(use_instructions(spec = character()), "non-empty character", fixed = FALSE)
  expect_error(use_instructions(spec = NA_character_), "missing/empty", fixed = FALSE)
  expect_error(use_instructions(spec = "  "), "missing/empty", fixed = FALSE)
})

test_that("use_instructions() errors on unknown modules and prints available modules", {
  expect_error(
    use_instructions(
      spec = c("does-not-exist"),
      dest_dir = file.path(withr::local_tempdir(), "dev", "instructions"),
      quiet = TRUE
    ),
    "Available modules",
    fixed = FALSE
  )
})

test_that("use_instructions() requires dest_dir to align with dev/instructions", {
  tmp <- withr::local_tempdir()

  expect_error(
    use_instructions(
      spec = c("chat-manual"),
      dest_dir = file.path(tmp, "somewhere", "else"),
      quiet = TRUE
    ),
    "must be `dev/instructions` or end with `/dev/instructions`",
    fixed = TRUE
  )
})

test_that("use_instructions() honors overwrite=FALSE for module files", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  out1 <- use_instructions(
    spec = c("chat-manual"),
    dest_dir = dest_dir,
    overwrite = TRUE,
    quiet = TRUE
  )
  expect_true(all(file.exists(out1)))

  out2 <- use_instructions(
    spec = c("chat-manual"),
    dest_dir = dest_dir,
    overwrite = FALSE,
    quiet = TRUE
  )

  expect_false("chat-manual.md" %in% basename(out2))
  expect_true("CHAT_INSTRUCTIONS.md" %in% basename(out2))
})

test_that("use_instructions() de-duplicates spec while preserving order", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  out <- use_instructions(
    spec = c("goals", "goals", "chat-manual"),
    dest_dir = dest_dir,
    quiet = TRUE
  )

  expect_equal(
    sort(basename(out)),
    sort(c("goals.md", "chat-manual.md", "CHAT_INSTRUCTIONS.md"))
  )

  entry <- paste(readLines(file.path(dest_dir, "CHAT_INSTRUCTIONS.md"), warn = FALSE), collapse = "\n")
  expect_match(entry, 'c\\("goals", "chat-manual"\\)', perl = TRUE)
})

test_that("use_instructions(write_entrypoint=FALSE) writes only module files", {
  tmp <- withr::local_tempdir()
  dest_dir <- file.path(tmp, "dev", "instructions")

  out <- use_instructions(
    spec = c("chat-manual", "goals"),
    dest_dir = dest_dir,
    write_entrypoint = FALSE,
    quiet = TRUE
  )

  expect_equal(sort(basename(out)), sort(c("chat-manual.md", "goals.md")))
  expect_false(file.exists(file.path(dest_dir, "CHAT_INSTRUCTIONS.md")))
})
