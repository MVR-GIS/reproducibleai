#' Check local prerequisites for live agentic-routing evaluation
#'
#' Diagnoses the optional local capabilities required to start live
#' `codex exec` runs. It does not install software, change configuration,
#' contact a model, or consume model usage. Offline scaffolding, validation,
#' fixture, scoring, summary, and reporting functions do not require these
#' prerequisites.
#'
#' When `codex` is `NULL`, discovery checks the process `PATH` and supported
#' user-local installation locations. On Windows this includes the stable path
#' written by OpenAI's standalone installer, even when an already-running IDE
#' has not refreshed its `PATH`.
#'
#' @param path Optional target repository. When supplied, its agentic context,
#'   Git commit, and clean-worktree status are also checked.
#' @param codex `NULL` for automatic discovery, or a Codex CLI command or
#'   absolute executable path.
#'
#' @return An object of class `agentic_routing_prerequisites`. `ready` means
#'   local preflight checks passed; network access, account entitlement, and
#'   enterprise execution policy can still prohibit a live run.
#' @export
check_agentic_routing_prerequisites <- function(path = NULL, codex = NULL) {
  routing_prerequisite_status(path = path, codex = codex)
}

#' @export
print.agentic_routing_prerequisites <- function(x, ...) {
  cat("<agentic_routing_prerequisites>\n")
  cat("Codex CLI: ", if (x$cli_available) x$codex_version else "unavailable", "\n", sep = "")
  cat("Authentication: ", x$authentication, "\n", sep = "")
  if (!is.null(x$repository)) {
    cat("Repository context: ", if (isTRUE(x$context_valid)) "valid" else "invalid", "\n", sep = "")
    cat("Git worktree: ", if (isTRUE(x$git_clean)) "clean" else "not clean", "\n", sep = "")
  }
  cat("Live evaluation preflight: ", if (x$ready) "ready" else "not ready", "\n", sep = "")
  cat("Network and enterprise policy: not tested\n")
  if (length(x$limitations)) {
    cat("Limitations:\n", paste0("- ", x$limitations, collapse = "\n"), "\n", sep = "")
  }
  invisible(x)
}

routing_prerequisite_status <- function(path = NULL, codex = NULL,
                                        run = routing_command_capture) {
  cli <- routing_resolve_codex(codex = codex, error = FALSE, run = run)
  auth <- if (cli$available) {
    routing_codex_authentication(cli$path, run = run)
  } else {
    list(authenticated = FALSE, status = "unavailable")
  }

  repository <- NULL
  context_valid <- NA
  git_sha <- NA_character_
  git_clean <- NA
  if (!is.null(path)) {
    repository <- tryCatch(
      agentic_context_root(path),
      error = function(e) normalizePath(path, winslash = "/", mustWork = FALSE)
    )
    validation <- tryCatch(
      validate_agentic_context(repository, strict = FALSE),
      error = function(e) NULL
    )
    context_valid <- !is.null(validation) && isTRUE(validation$valid)
    git_sha <- routing_git_sha(repository)
    git_clean <- !is.na(git_sha) && !routing_git_dirty(repository)
  }

  repository_ready <- is.null(path) ||
    (isTRUE(context_valid) && !is.na(git_sha) && isTRUE(git_clean))
  limitations <- character()
  if (!cli$available) {
    limitations <- c(
      limitations,
      "A runnable standalone Codex CLI was not found."
    )
  }
  if (cli$available && !auth$authenticated) {
    limitations <- c(
      limitations,
      "The Codex CLI is not authenticated; run `codex login` where policy permits."
    )
  }
  if (!is.null(path) && !isTRUE(context_valid)) {
    limitations <- c(
      limitations,
      "The target repository does not have valid agentic context."
    )
  }
  if (!is.null(path) && is.na(git_sha)) {
    limitations <- c(
      limitations,
      "The target repository does not have a readable Git HEAD."
    )
  } else if (!is.null(path) && !isTRUE(git_clean)) {
    limitations <- c(
      limitations,
      "The target repository has uncommitted or untracked changes."
    )
  }

  structure(
    list(
      ready = cli$available && auth$authenticated && repository_ready,
      cli_available = cli$available,
      codex_path = if (cli$available) cli$path else NA_character_,
      codex_version = if (cli$available) cli$version else NA_character_,
      authentication = auth$status,
      repository = repository,
      context_valid = context_valid,
      git_sha = git_sha,
      git_clean = git_clean,
      network_policy = "not_tested",
      limitations = unique(limitations),
      discovery_errors = cli$errors
    ),
    class = "agentic_routing_prerequisites"
  )
}

routing_resolve_codex <- function(codex = NULL, error = TRUE,
                                  run = routing_command_capture) {
  if (!is.null(codex)) {
    candidates <- routing_scalar_character(codex, "codex")
  } else {
    candidates <- routing_codex_candidates()
  }
  errors <- character()
  for (candidate in candidates) {
    probe <- routing_probe_codex(candidate, run = run)
    if (probe$available) {
      return(c(probe, list(errors = errors)))
    }
    errors <- c(errors, paste0(candidate, ": ", probe$error))
  }
  result <- list(
    available = FALSE,
    path = NA_character_,
    version = NA_character_,
    error = if (length(errors)) errors[[length(errors)]] else "not found",
    errors = errors
  )
  if (!error) return(result)
  stop(
    "No runnable standalone Codex CLI was found.",
    "\nInstall the optional CLI where local policy permits, restart the R/IDE ",
    "process, or supply its executable with `codex`.",
    "\nRun `check_agentic_routing_prerequisites()` for local diagnostics.",
    call. = FALSE
  )
}

routing_codex_candidates <- function() {
  found <- unname(Sys.which("codex"))
  found <- found[nzchar(found)]
  candidates <- character()
  if (.Platform$OS.type == "windows") {
    local_app_data <- Sys.getenv("LOCALAPPDATA", unset = "")
    stable <- if (nzchar(local_app_data)) {
      file.path(
        local_app_data, "Programs", "OpenAI", "Codex", "bin", "codex.exe"
      )
    } else {
      character()
    }
    app_private <- grepl(
      "/WindowsApps/|\\\\WindowsApps\\\\",
      found,
      ignore.case = TRUE
    )
    candidates <- c(found[!app_private], stable, found[app_private], "codex")
  } else {
    candidates <- c(
      found,
      path.expand("~/.local/bin/codex"),
      "/usr/local/bin/codex",
      "codex"
    )
  }
  unique(candidates[nzchar(candidates)])
}

routing_probe_codex <- function(command, run = routing_command_capture) {
  result <- tryCatch(
    run(command = command, args = "--version", timeout = 10000),
    error = function(e) e
  )
  if (inherits(result, "error") || !identical(as.integer(result$status), 0L)) {
    detail <- if (inherits(result, "error")) {
      conditionMessage(result)
    } else {
      trimws(paste(c(result$stderr, result$stdout), collapse = "\n"))
    }
    return(list(
      available = FALSE,
      path = command,
      version = NA_character_,
      error = if (nzchar(detail)) detail else "executable preflight failed"
    ))
  }
  version <- trimws(paste(result$stdout, collapse = "\n"))
  list(
    available = TRUE,
    path = routing_resolved_command_path(command),
    version = if (nzchar(version)) version else "unknown",
    error = ""
  )
}

routing_codex_authentication <- function(command, run = routing_command_capture) {
  result <- tryCatch(
    run(
      command = command,
      args = c("login", "status"),
      timeout = 10000
    ),
    error = function(e) e
  )
  if (inherits(result, "error")) {
    return(list(authenticated = FALSE, status = "unknown"))
  }
  text <- trimws(paste(c(result$stdout, result$stderr), collapse = "\n"))
  authenticated <- identical(as.integer(result$status), 0L) &&
    !grepl("not logged|not authenticated", text, ignore.case = TRUE)
  list(
    authenticated = authenticated,
    status = if (authenticated) "authenticated" else "not_authenticated"
  )
}

routing_command_capture <- function(command, args, timeout) {
  stdout_path <- tempfile("reproducibleai-codex-stdout-")
  stderr_path <- tempfile("reproducibleai-codex-stderr-")
  on.exit(unlink(c(stdout_path, stderr_path), force = TRUE), add = TRUE)
  status <- suppressWarnings(system2(
    command = command,
    args = vapply(args, shQuote, character(1)),
    stdout = stdout_path,
    stderr = stderr_path,
    timeout = ceiling(timeout / 1000)
  ))
  list(
    status = as.integer(status),
    stdout = if (file.exists(stdout_path)) {
      readLines(stdout_path, warn = FALSE, encoding = "UTF-8")
    } else {
      character()
    },
    stderr = if (file.exists(stderr_path)) {
      readLines(stderr_path, warn = FALSE, encoding = "UTF-8")
    } else {
      character()
    }
  )
}

routing_resolved_command_path <- function(command) {
  if (file.exists(command)) {
    path <- gsub("\\\\", "/", command)
    if (grepl("^[A-Za-z]:/", path) || startsWith(path, "/")) return(path)
    return(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
  found <- unname(Sys.which(command))
  if (length(found) && nzchar(found[[1]])) {
    return(normalizePath(found[[1]], winslash = "/", mustWork = TRUE))
  }
  command
}
