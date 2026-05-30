test_that("instructions_recipes() returns a named list of character vectors", {
  rec <- instructions_recipes()

  expect_type(rec, "list")
  expect_true(length(rec) > 0)
  expect_true(!is.null(names(rec)))
  expect_true(all(nzchar(names(rec))))

  for (x in rec) {
    expect_type(x, "character")
    expect_true(length(x) > 0)
  }
})

test_that("instructions_recipes() includes expected modest recipe set", {
  rec <- instructions_recipes()

  expect_true("r_package" %in% names(rec))
  expect_true("r_package_governed" %in% names(rec))
  expect_true("python_package_governed" %in% names(rec))
  expect_true("quarto_book" %in% names(rec))
  expect_true("quarto_book_user_manual" %in% names(rec))
  expect_true("shiny_golem" %in% names(rec))
  expect_true("shiny_golem_help_governed" %in% names(rec))
})

test_that("instructions_recipes() references only available modules", {
  rec <- instructions_recipes()
  avail <- instructions_available()

  used <- unique(unlist(rec, use.names = FALSE))
  expect_true(all(used %in% avail))
})

test_that("r_package_governed recipe has expected composition", {
  rec <- instructions_recipes()

  expect_identical(
    rec$r_package_governed,
    c(
      "chat-manual",
      "goals",
      "r-package",
      "development-governance"
    )
  )
})

test_that("shiny_golem_help_governed recipe has expected composition", {
  rec <- instructions_recipes()

  expect_identical(
    rec$shiny_golem_help_governed,
    c(
      "chat-manual",
      "goals",
      "r-package",
      "shiny-golem",
      "parameterized-help",
      "development-governance"
    )
  )
})
