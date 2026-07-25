# Run repeated agentic-routing evaluations

Runs each competency question in a fresh, ephemeral, read-only
`codex exec` session and captures JSONL events plus schema-constrained
final responses. Gold rubrics are never included in model prompts.

## Usage

``` r
run_agentic_routing_evaluation(
  path = ".",
  questions,
  repetitions = 3L,
  approved = FALSE,
  output_dir = NULL,
  codex = NULL,
  model = NULL,
  timeout = 900,
  runner = NULL,
  quiet = FALSE
)
```

## Arguments

- path:

  Git repository to evaluate.

- questions:

  One question or a list of questions created by
  [`new_agentic_routing_question()`](https://mvr-gis.github.io/reproducibleai/reference/new_agentic_routing_question.md).

- repetitions:

  Positive number of independent runs per question.

- approved:

  Must be `TRUE`. Repeated model execution can consume paid usage and is
  never started implicitly.

- output_dir:

  Directory for raw event and response files. It must be outside `path`.

- codex:

  `NULL` to discover a standalone Codex CLI automatically, or a CLI
  command or absolute executable path. Live evaluation requires this
  optional external program and existing CLI authentication. Use
  [`check_agentic_routing_prerequisites()`](https://mvr-gis.github.io/reproducibleai/reference/check_agentic_routing_prerequisites.md)
  before the first run.

- model:

  Optional model override. `NULL` uses the configured default.

- timeout:

  Maximum seconds for each run.

- runner:

  Optional process runner for testing or custom execution. It receives
  `command`, `args`, `wd`, `stdout`, `stderr`, and `timeout`.

- quiet:

  Suppress progress messages.

## Value

An object of class `agentic_routing_evaluation`.

## Details

Raw output defaults to a temporary directory outside the target
repository. This prevents earlier results from contaminating later
repetitions. Live execution also requires a clean Git repository and
verifies that its commit and worktree remain unchanged across the run.
