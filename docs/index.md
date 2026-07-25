# reproducibleai

[reproducibleai](https://mvr-gis.github.io/reproducibleai/) creates,
migrates, and validates durable repository context for reproducible
AI-assisted development. Instead of copying chat instructions and
preserving transcripts as working context, it creates a concise root
`AGENTS.md` that routes work into maintained artifacts under `dev/`.

The standard separates standing instructions from goals, architecture,
decisions, governance, workflows, schemas, feature specifications, and
concise checkpoints. Git preserves superseded history. The package can
also measure how effectively Codex follows those routes across repeated
isolated runs.

## Installation

``` r

# install.packages("pak")
pak::pak("MVR-GIS/reproducibleai")
```

The core package is local-first. Scaffolding, migration planning and
application, structural validation, competency-question authoring,
offline scoring, summaries, and report rendering do not require a Codex
installation, cloud SaaS account, or administrator rights.

Live agentic-routing evaluation is an optional connected capability. It
requires:

- a separately installed Codex CLI;
- an authenticated Codex CLI session;
- outbound connectivity to the Codex service; and
- permission under the computer’s application, endpoint, identity, and
  network policies.

On Windows, OpenAI’s standalone installer installs into the user profile
and does not require npm:

``` powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

Restart the R IDE after installation, then run:

``` r

check_agentic_routing_prerequisites(path = ".")
```

The diagnostic also discovers the standard user-local Windows
installation when an IDE has a stale `PATH`. It does not install
software, authenticate, contact a model, or consume model usage. On
managed or disconnected equipment, live execution may remain prohibited
even when package installation succeeds.
[reproducibleai](https://mvr-gis.github.io/reproducibleai/) reports that
limitation and retains its offline functionality; it never attempts to
bypass organizational controls.

## Scaffold a new R package

``` r

library(reproducibleai)

use_agentic_context(
  path = ".",
  profiles = c("base", "r-package")
)

validate_agentic_context(".")
```

Scaffolding is deterministic and idempotent. Existing repository-owned
content is never overwritten.

## Migrate an existing repository

``` r

plan <- plan_agentic_context_migration(".")

# Review the structured operations before changing the repository.
plan$operations

result <- apply_agentic_context_migration(
  plan,
  approved = TRUE
)
```

Planning is read-only: legacy content remains in place. Application
creates and validates replacements before removing superseded files.
Destructive operations are refused when a source is untracked, has
uncommitted changes, or requires manual review.

## Profiles

Standard 0.1 includes:

- `base`, which applies to every repository
- `r-package`, which adds routes and workflow guidance for R package
  development

[`detect_agentic_context_profiles()`](https://mvr-gis.github.io/reproducibleai/reference/detect_agentic_context_profiles.md)
reports evidence for candidate profiles but does not silently select or
apply them.

## Scope

The agentic-routing evaluation API defines private competency questions,
runs fresh read-only `codex exec` sessions, scores evidence routing and
expected answer content, and writes aggregate health reports.

The user workflow is presented as three connected articles:

1.  [Review and freeze the
    benchmark](https://mvr-gis.github.io/reproducibleai/articles/review-agentic-routing-benchmarks.md)
2.  [Run the
    evaluation](https://mvr-gis.github.io/reproducibleai/articles/agentic-routing-evaluation.md)
3.  [Interpret routing
    health](https://mvr-gis.github.io/reproducibleai/articles/interpret-agentic-routing-health.md)

``` r

check_agentic_routing_prerequisites(path = ".")

benchmark <- derive_agentic_routing_questions(".")
print(benchmark) # every generated question begins as pending

review_dir <- file.path(tempdir(), "reproducibleai-routing-review")
write_agentic_routing_review(benchmark, review_dir)

# Edit questions.csv, inspect exclusions.csv, and then:
benchmark <- apply_agentic_routing_review(benchmark, review_dir)
benchmark_path <- file.path(tempdir(), "reproducibleai-benchmark.json")
write_agentic_routing_benchmark(benchmark, benchmark_path)
benchmark <- read_agentic_routing_benchmark(benchmark_path)

evaluation <- run_agentic_routing_evaluation(
  path = ".",
  questions = benchmark,
  repetitions = 5,
  approved = TRUE
)

health <- summarize_agentic_routing(evaluation)
write_agentic_routing_report(
  health,
  "dev/governance/agentic-routing-health.md"
)
```

Keep private fixtures and raw runs outside the evaluated repository.
Freeze reviewed generated benchmarks outside the repository with
[`write_agentic_routing_benchmark()`](https://mvr-gis.github.io/reproducibleai/reference/write_agentic_routing_benchmark.md)
so specification variants use the same criterion. Model responses remain
stochastic; health reports summarize repeated observations rather than
claiming deterministic model behavior. Live evaluation is intended as an
explicitly initiated local development diagnostic, not as an automatic
package-build or CI step. A committed aggregate report can communicate
the observed health of repository context to maintainers and end-users.

## Bug reports

Please open an issue at
<https://github.com/MVR-GIS/reproducibleai/issues>.
