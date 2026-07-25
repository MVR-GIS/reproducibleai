#' Derive competency questions from durable development context
#'
#' Deterministically extracts conservative factual questions and canonical
#' answers from versioned sections under `dev/`. The generator never reads
#' `AGENTS.md`, so its criterion is independent of the routing specification
#' being evaluated. Generated questions remain pending until a human approves
#' or rejects each candidate.
#'
#' @param path Repository containing a valid agentic-context scaffold.
#' @param max_per_type Maximum candidates retained for each artifact type.
#'
#' @return An object of class `agentic_routing_benchmark`.
#' @export
derive_agentic_routing_questions <- function(path = ".", max_per_type = 3L) {
  root <- agentic_context_root(path)
  validate_agentic_context(root, strict = TRUE)
  max_per_type <- routing_positive_integer(max_per_type, "max_per_type")
  rules_path <- routing_derivation_rules_path()
  specification <- jsonlite::read_json(rules_path, simplifyVector = FALSE)
  rules <- specification$rules
  files <- list.files(
    file.path(root, "dev"), pattern = "[.]md$", recursive = TRUE,
    full.names = TRUE
  )
  relative <- normalize_routing_paths(sub(
    paste0("^", routing_regex_escape(normalizePath(
      root, winslash = "/", mustWork = TRUE
    )), "/?"), "", normalizePath(files, winslash = "/", mustWork = TRUE)
  ))
  excluded <- grepl(
    "(^|/)(README|template)[.]md$|^dev/(checkpoints|governance)/",
    relative, ignore.case = TRUE
  ) | grepl("agentic-routing-health", relative, ignore.case = TRUE)
  files <- files[!excluded]
  relative <- relative[!excluded]

  candidates <- list()
  exclusions <- list()
  for (rule in rules) {
    selected <- which(grepl(rule$path_regex, relative, perl = TRUE))
    for (i in selected) {
      result <- routing_derive_one(files[[i]], relative[[i]], rule)
      if (is.null(result$question)) {
        exclusions[[length(exclusions) + 1L]] <- data.frame(
          path = relative[[i]], rule = rule$id, reason = result$reason,
          stringsAsFactors = FALSE
        )
      } else {
        candidates[[length(candidates) + 1L]] <- result$question
      }
    }
  }
  if (!length(candidates)) {
    stop("No eligible competency questions could be derived.", call. = FALSE)
  }
  ordering <- order(
    vapply(candidates, `[[`, character(1), "artifact_type"),
    vapply(candidates, function(x) x$required_paths[[1]], character(1))
  )
  candidates <- candidates[ordering]
  types <- vapply(candidates, `[[`, character(1), "artifact_type")
  retained <- stats::ave(seq_along(types), types, FUN = seq_along) <= max_per_type
  candidates <- candidates[retained]
  answers <- vapply(candidates, `[[`, character(1), "canonical_answer")
  duplicate <- duplicated(tolower(answers))
  if (any(duplicate)) {
    candidates <- candidates[!duplicate]
  }
  benchmark <- structure(
    list(
      schema_version = 1L,
      generator_version = specification$generator_version,
      repository = basename(root),
      git_sha = routing_git_sha(root),
      rules_hash = unname(tools::md5sum(rules_path)),
      questions = candidates,
      exclusions = if (length(exclusions)) {
        do.call(rbind, exclusions)
      } else {
        data.frame(path = character(), rule = character(), reason = character())
      }
    ),
    class = "agentic_routing_benchmark"
  )
  attr(benchmark, "target_path") <- root
  benchmark
}

#' Record human review of generated competency questions
#'
#' @param benchmark A generated `agentic_routing_benchmark`.
#' @param approve Question identifiers to approve.
#' @param reject Question identifiers to reject.
#'
#' @return The updated benchmark.
#' @export
review_agentic_routing_benchmark <- function(benchmark,
                                              approve = character(),
                                              reject = character()) {
  if (!inherits(benchmark, "agentic_routing_benchmark")) {
    stop("`benchmark` must come from `derive_agentic_routing_questions()`.", call. = FALSE)
  }
  approve <- routing_character_vector(approve, "approve", allow_empty = TRUE)
  reject <- routing_character_vector(reject, "reject", allow_empty = TRUE)
  if (length(intersect(approve, reject))) {
    stop("A question cannot be both approved and rejected.", call. = FALSE)
  }
  ids <- vapply(benchmark$questions, `[[`, character(1), "id")
  unknown <- setdiff(c(approve, reject), ids)
  if (length(unknown)) {
    stop("Unknown question identifier: ", paste(unknown, collapse = ", "), call. = FALSE)
  }
  for (i in seq_along(benchmark$questions)) {
    id <- benchmark$questions[[i]]$id
    if (id %in% approve) benchmark$questions[[i]]$review_status <- "approved"
    if (id %in% reject) benchmark$questions[[i]]$review_status <- "rejected"
  }
  benchmark
}

#' Write a frozen generated routing benchmark
#'
#' @param benchmark A generated `agentic_routing_benchmark`.
#' @param path Destination JSON file outside the target repository.
#' @param overwrite Replace an existing file.
#'
#' @return The normalized path, invisibly.
#' @export
write_agentic_routing_benchmark <- function(benchmark, path, overwrite = FALSE) {
  if (!inherits(benchmark, "agentic_routing_benchmark")) {
    stop("`benchmark` must be an agentic-routing benchmark.", call. = FALSE)
  }
  statuses <- vapply(
    benchmark$questions, `[[`, character(1), "review_status"
  )
  if (any(statuses == "pending")) {
    stop(
      "Resolve every pending question before freezing the benchmark.",
      call. = FALSE
    )
  }
  path <- routing_scalar_character(path, "path")
  overwrite <- validate_flag(overwrite, "overwrite")
  target <- attr(benchmark, "target_path", exact = TRUE)
  if (!is.null(target) && path_within(path, target)) {
    stop("Frozen benchmarks must remain outside the repository being evaluated.", call. = FALSE)
  }
  if (file.exists(path) && !overwrite) {
    stop("Routing benchmark already exists: ", path, call. = FALSE)
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  payload <- list(
    schema_version = jsonlite::unbox(benchmark$schema_version),
    generator_version = jsonlite::unbox(benchmark$generator_version),
    repository = jsonlite::unbox(benchmark$repository),
    git_sha = routing_json_scalar(benchmark$git_sha),
    rules_hash = jsonlite::unbox(benchmark$rules_hash),
    questions = lapply(benchmark$questions, routing_question_json),
    exclusions = lapply(seq_len(nrow(benchmark$exclusions)), function(i) {
      lapply(benchmark$exclusions[i, , drop = FALSE], function(x) jsonlite::unbox(x[[1]]))
    })
  )
  jsonlite::write_json(payload, path, pretty = TRUE, auto_unbox = FALSE, null = "null")
  invisible(normalizePath(path, winslash = "/", mustWork = TRUE))
}

#' Read a frozen generated routing benchmark
#'
#' @param path Benchmark JSON written by `write_agentic_routing_benchmark()`.
#'
#' @return An object of class `agentic_routing_benchmark`.
#' @export
read_agentic_routing_benchmark <- function(path) {
  path <- routing_scalar_character(path, "path")
  payload <- jsonlite::read_json(path, simplifyVector = FALSE)
  if (!identical(as.integer(payload$schema_version), 1L)) {
    stop("Unsupported routing benchmark schema version.", call. = FALSE)
  }
  exclusions <- payload$exclusions %||% list()
  exclusions <- if (length(exclusions)) {
    do.call(rbind, lapply(exclusions, function(x) {
      data.frame(path = x$path, rule = x$rule, reason = x$reason, stringsAsFactors = FALSE)
    }))
  } else {
    data.frame(path = character(), rule = character(), reason = character())
  }
  out <- structure(list(
    schema_version = 1L,
    generator_version = payload$generator_version,
    repository = payload$repository,
    git_sha = payload$git_sha %||% NA_character_,
    rules_hash = payload$rules_hash,
    questions = lapply(payload$questions, routing_question_from_json),
    exclusions = exclusions
  ), class = "agentic_routing_benchmark")
  attr(out, "fixture_path") <- normalizePath(path, winslash = "/", mustWork = TRUE)
  out
}

#' @export
print.agentic_routing_benchmark <- function(x, ...) {
  statuses <- table(factor(
    vapply(x$questions, `[[`, character(1), "review_status"),
    levels = c("pending", "approved", "rejected")
  ))
  cat(
    "<agentic_routing_benchmark>\n",
    "Repository: ", x$repository, "\n",
    "Generator: ", x$generator_version, "\n",
    "Questions: ", length(x$questions), " (",
    paste(names(statuses), statuses, sep = "=", collapse = ", "), ")\n",
    sep = ""
  )
  invisible(x)
}

routing_derive_one <- function(path, relative, rule) {
  parsed <- routing_markdown_sections(path)
  matched <- which(vapply(parsed$sections, function(section) {
    any(vapply(rule$heading_patterns, function(pattern) {
      grepl(pattern, section$heading, ignore.case = TRUE, perl = TRUE)
    }, logical(1)))
  }, logical(1)))
  if (!length(matched)) return(list(question = NULL, reason = "required heading absent"))
  section <- parsed$sections[[matched[[1]]]]
  if (section$has_fence) return(list(question = NULL, reason = "section contains code fence"))
  if (any(grepl("^\\s*\\|.*\\|\\s*$", section$lines))) {
    return(list(question = NULL, reason = "section contains Markdown table"))
  }
  answer <- routing_normalize_markdown(section$lines)
  words <- length(strsplit(answer, "\\s+")[[1]])
  if (!nzchar(answer) || words < as.integer(rule$min_words)) {
    return(list(question = NULL, reason = "section is too short"))
  }
  if (words > as.integer(rule$max_words)) {
    return(list(question = NULL, reason = "section is too long"))
  }
  stem <- sub("[.]md$", "", basename(relative), ignore.case = TRUE)
  id <- paste("auto", rule$artifact_type, routing_slug(stem), routing_slug(section$heading), sep = "-")
  title <- if (nzchar(parsed$title)) {
    paste0(" The maintained artifact is titled \"", parsed$title, "\".")
  } else {
    ""
  }
  prompt <- paste0(
    rule$question_template, title,
    " Use the authoritative repository context."
  )
  list(question = new_agentic_routing_question(
    id = id,
    prompt = prompt,
    required_paths = relative,
    canonical_answer = answer,
    review_status = "pending",
    artifact_type = rule$artifact_type,
    source_heading = section$heading,
    source_hash = unname(tools::md5sum(path)),
    derivation_template = rule$id
  ), reason = "")
}

routing_markdown_sections <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  title <- ""
  sections <- list()
  current <- NULL
  in_fence <- FALSE
  for (line in lines) {
    if (grepl("^\\s*(```|~~~)", line)) {
      in_fence <- !in_fence
      if (!is.null(current)) {
        current$lines <- c(current$lines, line)
        current$has_fence <- TRUE
      }
      next
    }
    heading <- if (!in_fence) regmatches(line, regexec("^(#{1,6})\\s+(.+?)\\s*$", line))[[1]] else character()
    if (length(heading)) {
      level <- nchar(heading[[2]])
      text <- trimws(sub("\\s+#+\\s*$", "", heading[[3]]))
      if (level == 1L && !nzchar(title)) title <- text
      if (!is.null(current)) sections[[length(sections) + 1L]] <- current
      current <- list(heading = text, level = level, lines = character(), has_fence = FALSE)
    } else if (!is.null(current)) {
      current$lines <- c(current$lines, line)
    }
  }
  if (!is.null(current)) sections[[length(sections) + 1L]] <- current
  list(title = title, sections = sections)
}

routing_normalize_markdown <- function(lines) {
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  lines <- gsub("^[-*+]\\s+", "", lines)
  lines <- gsub("^\\d+[.)]\\s+", "", lines)
  lines <- gsub("!?\\[([^]]+)\\]\\([^)]+\\)", "\\1", lines, perl = TRUE)
  lines <- gsub("[`*_>#]", "", lines)
  trimws(gsub("\\s+", " ", paste(lines, collapse = " ")))
}

routing_slug <- function(x) {
  x <- tolower(gsub("[^A-Za-z0-9]+", "-", x))
  sub("-+$", "", sub("^-+", "", x))
}

routing_regex_escape <- function(x) {
  gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
}

routing_derivation_rules_path <- function() {
  installed <- system.file(
    "agentic-routing", "1", "derivation-rules.json",
    package = "reproducibleai"
  )
  if (nzchar(installed) && file.exists(installed)) return(installed)
  source <- file.path("inst", "agentic-routing", "1", "derivation-rules.json")
  if (file.exists(source)) {
    return(normalizePath(source, winslash = "/", mustWork = TRUE))
  }
  stop("Agentic-routing derivation rules are unavailable.", call. = FALSE)
}
