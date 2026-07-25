#' Scaffold durable agentic context
#'
#' Creates a versioned repository context structure centered on `AGENTS.md` and
#' durable artifacts under `dev/`. Existing files are never overwritten.
#'
#' @param path Existing repository root.
#' @param profiles Character vector of profiles. `base` is always included.
#' @param quiet Suppress progress messages.
#'
#' @return An object of class `agentic_context_result`.
#' @export
use_agentic_context <- function(path = ".",
                                profiles = c("base", "r-package"),
                                quiet = FALSE) {
  root <- agentic_context_root(path)
  profiles <- normalize_agentic_profiles(profiles)
  quiet <- validate_flag(quiet, "quiet")
  expected <- agentic_expected_files(root, profiles)
  manifest <- agentic_manifest_text(expected, profiles)
  manifest_path <- file.path(root, "dev", "agentic-context.yml")

  conflicts <- expected$target[
    file.exists(expected$absolute) &
      !vapply(
        seq_len(nrow(expected)),
        function(i) identical_file_text(expected$absolute[[i]], expected$content[[i]]),
        logical(1)
      )
  ]

  if (file.exists(manifest_path) &&
      !identical_file_text(manifest_path, manifest)) {
    conflicts <- c(conflicts, "dev/agentic-context.yml")
  }

  if (length(conflicts)) {
    stop(
      "Scaffolding would overwrite repository-owned files:\n- ",
      paste(unique(conflicts), collapse = "\n- "),
      "\nUse `plan_agentic_context_migration()` for an existing repository.",
      call. = FALSE
    )
  }

  written <- character()
  skipped <- character()

  for (i in seq_len(nrow(expected))) {
    target <- expected$absolute[[i]]
    if (file.exists(target)) {
      skipped <- c(skipped, target)
      next
    }
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    writeLines(expected$content[[i]], target, useBytes = TRUE)
    written <- c(written, target)
    if (!quiet) message("Created: ", target)
  }

  if (file.exists(manifest_path)) {
    skipped <- c(skipped, manifest_path)
  } else {
    dir.create(dirname(manifest_path), recursive = TRUE, showWarnings = FALSE)
    writeLines(manifest, manifest_path, useBytes = TRUE)
    written <- c(written, manifest_path)
    if (!quiet) message("Created: ", manifest_path)
  }

  structure(
    list(
      path = root,
      standard_version = agentic_standard_version(),
      profiles = profiles,
      files_written = written,
      files_skipped = skipped
    ),
    class = "agentic_context_result"
  )
}

#' Detect applicable agentic-context profiles
#'
#' Detection is advisory. It returns evidence but never changes a repository or
#' silently selects a profile for scaffolding.
#'
#' @param path Existing repository root.
#'
#' @return A data frame with candidate profiles and evidence.
#' @export
detect_agentic_context_profiles <- function(path = ".") {
  root <- agentic_context_root(path)
  out <- data.frame(
    profile = "base",
    detected = TRUE,
    evidence = "Base profile applies to every repository.",
    stringsAsFactors = FALSE
  )

  description <- file.path(root, "DESCRIPTION")
  is_r_package <- FALSE
  if (file.exists(description)) {
    fields <- tryCatch(read.dcf(description), error = function(e) NULL)
    is_r_package <- !is.null(fields) && "Package" %in% colnames(fields)
  }

  rbind(
    out,
    data.frame(
      profile = "r-package",
      detected = is_r_package,
      evidence = if (is_r_package) {
        "DESCRIPTION contains a Package field."
      } else {
        "No R package DESCRIPTION was detected."
      },
      stringsAsFactors = FALSE
    )
  )
}

#' Plan migration to durable agentic context
#'
#' Inventories the target repository and returns proposed operations without
#' changing any files. Legacy artifacts remain in place until the returned plan
#' is explicitly approved and applied.
#'
#' @param path Existing repository root.
#' @param profiles Profiles to install. When `NULL`, detected profiles are used.
#'
#' @return An object of class `agentic_context_migration_plan`.
#' @export
plan_agentic_context_migration <- function(path = ".", profiles = NULL) {
  root <- agentic_context_root(path)
  if (is.null(profiles)) {
    detected <- detect_agentic_context_profiles(root)
    profiles <- detected$profile[detected$detected]
  }
  profiles <- normalize_agentic_profiles(profiles)
  expected <- agentic_expected_files(root, profiles)
  git <- git_inventory(root)
  manifest_path <- file.path(root, "dev", "agentic-context.yml")
  manifest <- agentic_manifest_text(expected, profiles)

  operations <- new_migration_operations()
  for (i in seq_len(nrow(expected))) {
    exists <- file.exists(expected$absolute[[i]])
    same <- exists && identical_file_text(
      expected$absolute[[i]],
      expected$content[[i]]
    )
    operations <- add_migration_operation(
      operations,
      action = if (!exists) "create" else if (same) "preserve" else "manual_review",
      source = NA_character_,
      target = expected$target[[i]],
      status = if (!exists || same) "ready" else "manual_review",
      reason = if (!exists) {
        "Required scaffold file is absent."
      } else if (same) {
        "Existing file already matches the standard."
      } else {
        "Existing repository-owned content differs from the scaffold."
      },
      source_hash = NA_character_
    )
  }

  manifest_exists <- file.exists(manifest_path)
  manifest_same <- manifest_exists && identical_file_text(manifest_path, manifest)
  operations <- add_migration_operation(
    operations,
    action = if (!manifest_exists) "create" else if (manifest_same) "preserve" else "manual_review",
    source = NA_character_,
    target = "dev/agentic-context.yml",
    status = if (!manifest_exists || manifest_same) "ready" else "manual_review",
    reason = if (!manifest_exists) {
      "Version manifest is absent."
    } else if (manifest_same) {
      "Existing manifest matches the requested standard."
    } else {
      "Existing manifest differs from the requested standard."
    },
    source_hash = NA_character_
  )

  moves <- c(
    "dev/05_plan.md" = "dev/goals/project-plan.md",
    "dev/10_design.md" = "dev/architecture/design.md",
    "dev/40_schemas.md" = "dev/schemas/project-schemas.md"
  )
  for (source in names(moves)) {
    if (file.exists(file.path(root, source))) {
      operations <- add_legacy_operation(
        operations, root, git, "move", source, unname(moves[[source]]),
        "Legacy numbered artifact will be retained under its durable context route."
      )
    }
  }

  for (legacy_dir in c("dev/instructions", "dev/sessions")) {
    absolute_dir <- file.path(root, legacy_dir)
    if (!dir.exists(absolute_dir)) next
    files <- list.files(
      absolute_dir, recursive = TRUE, full.names = TRUE,
      all.files = TRUE, no.. = TRUE
    )
    files <- files[!dir.exists(files)]
    for (absolute in files) {
      source <- relative_path(absolute, root)
      operations <- add_legacy_operation(
        operations, root, git, "remove", source, NA_character_,
        if (legacy_dir == "dev/instructions") {
          "Legacy instruction copy is replaced by AGENTS.md and routed durable artifacts."
        } else {
          "Session transcript is non-authoritative; durable state belongs in maintained artifacts and Git preserves history."
        }
      )
    }
  }

  structure(
    list(
      path = root,
      standard_version = agentic_standard_version(),
      profiles = profiles,
      operations = operations
    ),
    class = "agentic_context_migration_plan"
  )
}

#' Apply an approved agentic-context migration
#'
#' Creates replacement content, validates the new structure, and only then
#' removes superseded legacy files. Files requiring manual review prevent
#' application.
#'
#' @param plan A plan returned by `plan_agentic_context_migration()`.
#' @param approved Must be `TRUE`.
#' @param quiet Suppress progress messages.
#'
#' @return An object of class `agentic_context_migration_result`.
#' @export
apply_agentic_context_migration <- function(plan,
                                             approved = FALSE,
                                             quiet = FALSE) {
  if (!inherits(plan, "agentic_context_migration_plan")) {
    stop("`plan` must come from `plan_agentic_context_migration()`.", call. = FALSE)
  }
  approved <- validate_flag(approved, "approved")
  quiet <- validate_flag(quiet, "quiet")
  if (!approved) {
    stop("Migration application requires `approved = TRUE`.", call. = FALSE)
  }
  unresolved <- plan$operations$status == "manual_review"
  if (any(unresolved)) {
    targets <- ifelse(
      is.na(plan$operations$source[unresolved]),
      plan$operations$target[unresolved],
      plan$operations$source[unresolved]
    )
    stop(
      "Migration has unresolved manual-review operations:\n- ",
      paste(targets, collapse = "\n- "),
      call. = FALSE
    )
  }

  destructive <- plan$operations$action %in% c("move", "remove")
  report_path <- character()
  if (any(destructive)) {
    report_path <- file.path(
      plan$path, "dev", "governance",
      paste0("migration-", plan$standard_version, ".md")
    )
    if (file.exists(report_path)) {
      stop("Migration report already exists: ", report_path, call. = FALSE)
    }
  }
  for (i in which(destructive)) {
    source <- file.path(plan$path, plan$operations$source[[i]])
    if (!file.exists(source)) {
      stop("Migration source changed or disappeared: ", source, call. = FALSE)
    }
    if (!identical(unname(tools::md5sum(source)), plan$operations$source_hash[[i]])) {
      stop("Migration source changed after planning: ", source, call. = FALSE)
    }
  }

  scaffold <- use_agentic_context(plan$path, plan$profiles, quiet = quiet)

  move_rows <- which(plan$operations$action == "move")
  copied <- character()
  for (i in move_rows) {
    source <- file.path(plan$path, plan$operations$source[[i]])
    target <- file.path(plan$path, plan$operations$target[[i]])
    if (file.exists(target)) {
      stop("Migration target now exists: ", target, call. = FALSE)
    }
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    if (!file.copy(source, target, overwrite = FALSE, copy.date = TRUE)) {
      stop("Failed to copy migration source to: ", target, call. = FALSE)
    }
    copied <- c(copied, target)
  }

  pre_delete <- validate_agentic_context(plan$path, strict = FALSE)
  if (any(pre_delete$findings$level == "error")) {
    stop(
      "Replacement structure failed validation; legacy files were retained.",
      call. = FALSE
    )
  }

  delete_rows <- which(destructive)
  removed <- character()
  for (i in delete_rows) {
    source <- file.path(plan$path, plan$operations$source[[i]])
    if (unlink(source, force = FALSE) != 0 || file.exists(source)) {
      stop("Failed to remove superseded file: ", source, call. = FALSE)
    }
    removed <- c(removed, source)
  }

  for (legacy_dir in c("dev/instructions", "dev/sessions")) {
    absolute <- file.path(plan$path, legacy_dir)
    if (dir.exists(absolute)) {
      remaining <- list.files(
        absolute, recursive = TRUE, all.files = TRUE, no.. = TRUE
      )
      if (!length(remaining)) unlink(absolute, recursive = TRUE, force = FALSE)
    }
  }

  validation <- validate_agentic_context(plan$path, strict = FALSE)
  if (any(validation$findings$level == "error")) {
    stop("Migration completed with structural validation errors.", call. = FALSE)
  }

  if (any(destructive)) {
    report <- migration_report_text(plan, copied, removed)
    writeLines(report, report_path, useBytes = TRUE)
  }

  structure(
    list(
      path = plan$path,
      scaffold = scaffold,
      files_copied = copied,
      files_removed = removed,
      report = report_path,
      validation = validation
    ),
    class = "agentic_context_migration_result"
  )
}

#' Validate durable agentic context
#'
#' Checks the structural contract, manifest, routes, and seeded-file drift. This
#' validator does not judge the scientific or semantic quality of repository
#' content.
#'
#' @param path Existing repository root.
#' @param strict When `TRUE`, error if validation errors are found.
#'
#' @return An object of class `agentic_context_validation`.
#' @export
validate_agentic_context <- function(path = ".", strict = FALSE) {
  root <- agentic_context_root(path)
  strict <- validate_flag(strict, "strict")
  findings <- new_validation_findings()

  required <- c(
    "AGENTS.md", "dev/README.md", "dev/agentic-context.yml",
    paste0(
      "dev/",
      c(
        "goals", "architecture", "decisions", "governance", "workflows",
        "schemas", "features", "checkpoints", "scripts"
      ),
      "/README.md"
    ),
    "dev/checkpoints/current/README.md",
    "dev/checkpoints/archive/README.md"
  )
  for (target in required) {
    if (!file.exists(file.path(root, target))) {
      findings <- add_validation_finding(
        findings, "error", "missing_required_file", target,
        "Required agentic-context file is missing."
      )
    }
  }

  agents <- file.path(root, "AGENTS.md")
  if (file.exists(agents)) {
    text <- paste(readLines(agents, warn = FALSE), collapse = "\n")
    for (route in c(
      "dev/goals/", "dev/architecture/", "dev/decisions/",
      "dev/governance/", "dev/workflows/", "dev/schemas/",
      "dev/features/", "dev/checkpoints/current/"
    )) {
      if (!grepl(route, text, fixed = TRUE)) {
        findings <- add_validation_finding(
          findings, "error", "missing_context_route", "AGENTS.md",
          paste("Missing route:", route)
        )
      }
    }
  }

  manifest_path <- file.path(root, "dev", "agentic-context.yml")
  if (file.exists(manifest_path)) {
    manifest <- parse_agentic_manifest(manifest_path)
    if (!identical(manifest$standard_version, agentic_standard_version())) {
      findings <- add_validation_finding(
        findings, "error", "unsupported_standard_version",
        "dev/agentic-context.yml",
        paste("Expected standard version", agentic_standard_version())
      )
    }
    for (target in names(manifest$files)) {
      absolute <- file.path(root, target)
      if (!file.exists(absolute)) {
        findings <- add_validation_finding(
          findings, "error", "missing_seeded_file", target,
          "File recorded in the manifest is missing."
        )
      } else if (!identical(
        unname(tools::md5sum(absolute)),
        unname(manifest$files[[target]])
      )) {
        findings <- add_validation_finding(
          findings, "warning", "repository_owned_change", target,
          "Seeded content has been modified; preserve it during upgrades."
        )
      }
    }
  }

  for (legacy in c("dev/instructions", "dev/sessions")) {
    if (dir.exists(file.path(root, legacy))) {
      findings <- add_validation_finding(
        findings, "warning", "legacy_context_present", legacy,
        "Legacy context remains; use the migration planner to classify it."
      )
    }
  }

  result <- structure(
    list(
      path = root,
      valid = !any(findings$level == "error"),
      findings = findings
    ),
    class = "agentic_context_validation"
  )
  if (strict && !result$valid) {
    stop(
      "Agentic-context validation failed with ",
      sum(findings$level == "error"),
      " error(s).",
      call. = FALSE
    )
  }
  result
}

agentic_standard_version <- function() "0.1"

validate_scalar_character <- function(x, arg = "x") {
  if (!is.character(x) || length(x) != 1 || is.na(x) || !nzchar(trimws(x))) {
    stop("`", arg, "` must be a non-empty character scalar.", call. = FALSE)
  }
  trimws(x)
}

agentic_context_root <- function(path) {
  path <- validate_scalar_character(path, "path")
  if (!dir.exists(path)) {
    stop("`path` must be an existing directory: ", path, call. = FALSE)
  }
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

validate_flag <- function(x, arg) {
  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    stop("`", arg, "` must be TRUE or FALSE.", call. = FALSE)
  }
  x
}

normalize_agentic_profiles <- function(profiles) {
  if (!is.character(profiles) || !length(profiles) || anyNA(profiles)) {
    stop("`profiles` must be a non-empty character vector.", call. = FALSE)
  }
  profiles <- unique(trimws(profiles))
  if (any(!nzchar(profiles))) {
    stop("`profiles` contains an empty profile.", call. = FALSE)
  }
  profiles <- unique(c("base", profiles[profiles != "base"]))
  available <- c("base", "r-package")
  unknown <- setdiff(profiles, available)
  if (length(unknown)) {
    stop(
      "Unknown agentic-context profile(s): ",
      paste(unknown, collapse = ", "),
      ". Available profiles: ",
      paste(available, collapse = ", "),
      call. = FALSE
    )
  }
  profiles
}

agentic_template_root <- function() {
  installed <- system.file(
    "agentic-context", agentic_standard_version(),
    package = "reproducibleai"
  )
  if (nzchar(installed) && dir.exists(installed)) return(installed)
  source <- file.path("inst", "agentic-context", agentic_standard_version())
  if (dir.exists(source)) return(normalizePath(source, winslash = "/"))
  stop("Agentic-context templates are not available.", call. = FALSE)
}

agentic_expected_files <- function(root, profiles) {
  template_root <- agentic_template_root()
  rows <- list()
  for (profile in profiles) {
    profile_root <- file.path(template_root, profile)
    files <- list.files(
      profile_root, recursive = TRUE, full.names = TRUE,
      all.files = TRUE, no.. = TRUE
    )
    files <- files[!dir.exists(files)]
    for (source in files) {
      target <- relative_path(source, profile_root)
      content <- readLines(source, warn = FALSE, encoding = "UTF-8")
      content <- render_agentic_template(content, root, profiles)
      rows[[length(rows) + 1L]] <- list(
        target = target,
        absolute = file.path(root, target),
        content = list(content)
      )
    }
  }
  targets <- vapply(rows, `[[`, character(1), "target")
  if (anyDuplicated(targets)) {
    stop("Profiles define conflicting scaffold targets.", call. = FALSE)
  }
  data.frame(
    target = targets,
    absolute = vapply(rows, `[[`, character(1), "absolute"),
    content = I(lapply(rows, function(x) x$content[[1]])),
    stringsAsFactors = FALSE
  )
}

render_agentic_template <- function(content, root, profiles) {
  repo <- basename(root)
  profile_routes <- if ("r-package" %in% profiles) {
    paste0(
      "- R package API, implementation, documentation, or tests: ",
      "`DESCRIPTION`, `NAMESPACE`, `R/`, `man/`, `tests/testthat/`, and ",
      "`dev/workflows/r-package-development.md`"
    )
  } else {
    "- Repository-type-specific rules: inspect the repository's native configuration and workflows."
  }
  content <- gsub("{{REPOSITORY_NAME}}", repo, content, fixed = TRUE)
  gsub("{{PROFILE_ROUTES}}", profile_routes, content, fixed = TRUE)
}

agentic_manifest_text <- function(expected, profiles) {
  hashes <- vapply(expected$content, hash_text, character(1))
  package_version <- tryCatch(
    as.character(utils::packageVersion("reproducibleai")),
    error = function(e) "development"
  )
  c(
    "schema_version: 1",
    paste0('standard_version: "', agentic_standard_version(), '"'),
    "installed_by: reproducibleai",
    paste0('package_version: "', package_version, '"'),
    "hash_algorithm: md5",
    "profiles:",
    paste0("  - ", profiles),
    "seeded_files:",
    paste0('  "', expected$target, '": "', hashes, '"')
  )
}

parse_agentic_manifest <- function(path) {
  lines <- readLines(path, warn = FALSE)
  standard <- sub(
    '^standard_version:[[:space:]]*"?([^"]+)"?[[:space:]]*$',
    "\\1",
    grep("^standard_version:", lines, value = TRUE)
  )
  profile_start <- match("profiles:", lines)
  file_start <- match("seeded_files:", lines)
  profiles <- character()
  if (!is.na(profile_start) && !is.na(file_start) && file_start > profile_start + 1) {
    block <- lines[(profile_start + 1):(file_start - 1)]
    profiles <- sub("^[[:space:]]*-[[:space:]]*", "", block)
  }
  files <- character()
  if (!is.na(file_start) && length(lines) > file_start) {
    block <- lines[(file_start + 1):length(lines)]
    keys <- sub('^[[:space:]]*"([^"]+)":[[:space:]].*$', "\\1", block)
    values <- sub('^[^:]+:[[:space:]]*"([^"]+)"[[:space:]]*$', "\\1", block)
    files <- stats::setNames(values, keys)
  }
  list(
    standard_version = if (length(standard)) standard[[1]] else NA_character_,
    profiles = profiles,
    files = files
  )
}

hash_text <- function(text) {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  writeLines(text, tmp, useBytes = TRUE)
  unname(tools::md5sum(tmp))
}

identical_file_text <- function(path, text) {
  file.exists(path) &&
    identical(readLines(path, warn = FALSE, encoding = "UTF-8"), text)
}

relative_path <- function(path, root) {
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  sub(paste0("^", escape_regex(root), "/?"), "", path)
}

escape_regex <- function(x) {
  gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
}

new_migration_operations <- function() {
  data.frame(
    action = character(),
    source = character(),
    target = character(),
    status = character(),
    reason = character(),
    source_hash = character(),
    stringsAsFactors = FALSE
  )
}

add_migration_operation <- function(operations, action, source, target,
                                    status, reason, source_hash) {
  rbind(
    operations,
    data.frame(
      action = action, source = source, target = target, status = status,
      reason = reason, source_hash = source_hash, stringsAsFactors = FALSE
    )
  )
}

add_legacy_operation <- function(operations, root, git, action, source, target, reason) {
  absolute <- file.path(root, source)
  tracked <- source %in% git$tracked
  changed <- source %in% git$changed
  status <- if (tracked && !changed) "ready" else "manual_review"
  detail <- if (!tracked) {
    " Source is not recorded in Git."
  } else if (changed) {
    " Source has uncommitted changes."
  } else {
    ""
  }
  add_migration_operation(
    operations, action, source, target, status,
    paste0(reason, detail),
    unname(tools::md5sum(absolute))
  )
}

migration_report_text <- function(plan, copied, removed) {
  operations <- plan$operations[
    plan$operations$action %in% c("move", "remove"),
    ,
    drop = FALSE
  ]
  lines <- c(
    paste0("# Agentic-context migration ", plan$standard_version),
    "",
    paste0("- Applied: ", format(Sys.Date(), "%Y-%m-%d")),
    paste0("- Profiles: ", paste(plan$profiles, collapse = ", ")),
    "- Policy: replacements were created and validated before tracked legacy sources were removed.",
    "",
    "## Adapted artifacts",
    ""
  )
  moves <- operations[operations$action == "move", , drop = FALSE]
  if (nrow(moves)) {
    lines <- c(
      lines,
      paste0("- `", moves$source, "` -> `", moves$target, "`")
    )
  } else {
    lines <- c(lines, "- None.")
  }
  lines <- c(lines, "", "## Removed artifacts", "")
  removals <- operations[operations$action == "remove", , drop = FALSE]
  if (nrow(removals)) {
    lines <- c(
      lines,
      paste0("- `", removals$source, "`: ", removals$reason)
    )
  } else {
    lines <- c(lines, "- None.")
  }
  c(
    lines, "",
    "## Verification", "",
    paste0("- Replacement files copied: ", length(copied)),
    paste0("- Superseded files removed: ", length(removed)),
    "- The standard structure passed validation before removal.",
    "- Git history remains the archive for superseded content."
  )
}

git_inventory <- function(root) {
  tracked <- tryCatch(
    suppressWarnings(system2(
      "git", c("-C", shQuote(root), "ls-files"),
      stdout = TRUE, stderr = FALSE
    )),
    error = function(e) character()
  )
  status <- tryCatch(
    suppressWarnings(system2(
      "git", c("-C", shQuote(root), "status", "--porcelain", "--untracked-files=all"),
      stdout = TRUE, stderr = FALSE
    )),
    error = function(e) character()
  )
  changed <- if (length(status)) {
    trimws(sub("^[ MARCUD?!]{2}[[:space:]]+", "", status))
  } else {
    character()
  }
  list(
    tracked = gsub("\\\\", "/", tracked),
    changed = gsub("\\\\", "/", changed)
  )
}

new_validation_findings <- function() {
  data.frame(
    level = character(), code = character(), path = character(),
    message = character(), stringsAsFactors = FALSE
  )
}

add_validation_finding <- function(findings, level, code, path, message) {
  rbind(
    findings,
    data.frame(
      level = level, code = code, path = path, message = message,
      stringsAsFactors = FALSE
    )
  )
}
