test_that("every available module has a corresponding handler", {
  mods <- instructions_available()

  handler_names <- vapply(mods, module_name_to_handler, character(1))

  missing_handlers <- handler_names[!vapply(
    handler_names,
    exists,
    logical(1),
    mode = "function",
    inherits = TRUE
  )]

  expect_length(missing_handlers, 0)
})

test_that("simple handlers install module text and return standard result objects", {
  tmp <- withr::local_tempdir()

  mods <- instructions_available()

  for (mod in mods) {
    handler <- get_module_handler(mod)

    out <- handler(path = tmp, overwrite = FALSE)

    target <- file.path(tmp, "dev", "instructions", paste0(mod, ".md"))

    expect_identical(out$module_name, mod)
    expect_true(file.exists(target))
    expect_identical(out$instruction_target, target)
    expect_true(file.exists(out$instruction_source))
    expect_true(
      target %in% c(out$files_written, out$files_skipped),
      info = paste("Target not reported as written or skipped for module:", mod)
    )
  }
})
