#' reproducibleai: Reproducible AI-assisted development workflows
#'
#' `{reproducibleai}` provides tools for building reproducible, reviewable
#' AI-assisted workflows around durable repository context.
#'
#' The agentic-context standard:
#' \itemize{
#'   \item keeps standing rules concise in `AGENTS.md`
#'   \item routes durable detail into purpose-specific artifacts under `dev/`
#'   \item records the installed standard, profiles, and seed hashes
#'   \item separates read-only migration planning from explicitly approved changes
#'   \item validates structure without claiming to judge semantic or scientific quality
#' }
#'
#' Legacy instruction copies and session transcripts are removed during approved
#' migration only after their replacement structure has been created and
#' validated. Git remains the historical record.
#'
#' Most package capabilities are local and deterministic. They do not require a
#' cloud account, Codex CLI, or administrator rights. Live agentic-routing
#' evaluation is an optional capability that requires a separately installed
#' and authenticated Codex CLI plus network and organizational permission.
#' Managed or disconnected computers can still scaffold, migrate, validate,
#' define fixtures, score saved results, summarize evaluations, and render
#' health reports. The package never installs Codex, authenticates an account,
#' or attempts to bypass endpoint or network policy.
#'
#' @keywords internal
"_PACKAGE"
