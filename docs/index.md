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

``` r

question <- new_agentic_routing_question(
  id = "current-priority",
  prompt = "What is the current development priority?",
  required_paths = "dev/goals/project-plan.md",
  allowed_paths = "AGENTS.md",
  expected_terms = "current objective"
)

evaluation <- run_agentic_routing_evaluation(
  path = ".",
  questions = question,
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
Model responses remain stochastic; health reports summarize repeated
observations rather than claiming deterministic model behavior.

## Bug reports

Please open an issue at
<https://github.com/MVR-GIS/reproducibleai/issues>.
