# Evaluate agentic routing

Agentic-context validation confirms that a repository has the expected
structure. Routing evaluation asks a different question: when Codex
receives a task, does it find the right maintained evidence and produce
the expected answer efficiently?

The harness is deterministic, but model responses are stochastic.
Interpret results as repeated-run distributions rather than
byte-identical tests.

## Capability and environment preflight

Most [reproducibleai](https://mvr-gis.github.io/reproducibleai/)
functionality is available without Codex, a cloud account, or
administrator rights. Live routing evaluation is different: it starts
authenticated model runs and therefore requires a separately installed
Codex CLI, connectivity, account entitlement, and organizational
permission.

On Windows, the standalone installer uses a user-local installation and
does not require npm:

``` powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

Restart the R IDE after installing. Then perform a no-usage preflight:

``` r

library(reproducibleai)

check_agentic_routing_prerequisites(
  path = "C:/workspace/FluvialGeomorph/fluvgeo"
)
```

Automatic discovery checks `PATH` and the standard user-local Windows
installation. Supply `codex = "C:/path/to/codex.exe"` only for a
nonstandard installation. The diagnostic checks the executable, saved
authentication, agentic context, and Git state without contacting a
model. Network and enterprise execution policy remain untested until a
live run begins.

On managed government-furnished, disconnected, or no-admin equipment,
package installation and offline capabilities remain useful even if
application allow-listing, identity policy, or network controls prohibit
live Codex evaluation. Do not bypass those controls. Prepare or inspect
fixtures and reports offline, and perform live evaluation only in an
approved environment.

## Define private competency questions

The preferred first pass derives candidates deterministically from
maintained `dev/` sections. The generator does not inspect `AGENTS.md`,
and no model is used to create either the question or its canonical
answer:

``` r

benchmark <- derive_agentic_routing_questions(
  "C:/workspace/FluvialGeomorph/fluvgeo"
)

review_dir <- "C:/workspace/agentic-reviews/fluvgeo-baseline"
write_agentic_routing_review(benchmark, review_dir)

# Edit questions.csv, inspect exclusions.csv, then import the decisions.
benchmark <- apply_agentic_routing_review(
  benchmark,
  review_dir
)

fixture <- file.path(tempdir(), "fluvgeo-routing-benchmark.json")
write_agentic_routing_benchmark(benchmark, fixture)
benchmark <- read_agentic_routing_benchmark(fixture)
```

All generated candidates begin as pending. Evaluation refuses a
benchmark until every item has been explicitly approved or rejected. The
[benchmark-review
article](https://mvr-gis.github.io/reproducibleai/articles/review-agentic-routing-benchmarks.md)
describes the CSV columns, QA checklist, exclusions review, staged
review, and artifact lifecycle. Freeze the reviewed benchmark outside
the target repository before comparing routing specifications. Source
and rules hashes make changes auditable.

Questions that require synthesis, judgment, or facts not expressed in a
supported maintained section should still be authored manually:

``` r

library(reproducibleai)

questions <- list(
  new_agentic_routing_question(
    id = "current-priority",
    prompt = "What is the current development priority and its exit criteria?",
    required_paths = "dev/goals/project-plan.md",
    allowed_paths = c("AGENTS.md", "dev/architecture/design.md"),
    expected_terms = c("current objective", "exit criteria"),
    forbidden_terms = "session transcript"
  ),
  new_agentic_routing_question(
    id = "architecture-boundary",
    prompt = "Which repository owns this behavior and what evidence supports that?",
    required_paths = c(
      "AGENTS.md",
      "dev/architecture/backend-ecosystem.md"
    ),
    allowed_paths = "dev/workflows/backend-change-assessment.md",
    expected_terms = c("ownership", "downstream")
  )
)

fixture <- file.path(tempdir(), "fluvgeo-routing-questions.json")
write_agentic_routing_questions(questions, fixture)
questions <- read_agentic_routing_questions(fixture)
```

Keep the fixture outside the repository under evaluation. Otherwise
Codex can inspect the private rubric.

## Run repeated isolated sessions

``` r

evaluation <- run_agentic_routing_evaluation(
  path = "C:/workspace/FluvialGeomorph/fluvgeo",
  questions = benchmark,
  repetitions = 5,
  approved = TRUE,
  model = NULL
)
```

Each repetition uses a fresh `codex exec` session with:

- `--ephemeral`;
- `--sandbox read-only`;
- `--ask-for-approval never`;
- `--ignore-user-config`;
- `--json`; and
- `--output-schema`.

The function uses existing Codex authentication. It does not accept or
record API keys. Raw JSONL, responses, and stderr remain in an external
temporary directory unless another external directory is supplied.

`codex exec` and structured output are documented in OpenAI’s
[non-interactive
mode](https://learn.chatgpt.com/docs/non-interactive-mode) and [CLI
reference](https://learn.chatgpt.com/docs/developer-commands?surface=cli#cli-codex-exec).

## Summarize and report

``` r

health <- summarize_agentic_routing(evaluation)
health$health_score
health$by_question

write_agentic_routing_report(
  health,
  path = file.path(
    "C:/workspace/FluvialGeomorph/fluvgeo",
    "dev",
    "governance",
    "agentic-routing-health.md"
  )
)
```

Generated questions score answer grounding with deterministic multiset
token precision, recall, and F1 against the frozen canonical answer.
Manually authored questions retain expected-term recall. The durable
report contains only aggregate metrics and recommendations. Inspect
external raw runs before changing instructions, and validate proposed
improvements on held-out questions or repositories.

Run this workflow deliberately during local development when agentic
context changes. Do not place live evaluation in package builds or CI.
Commit the aggregate report as a transparent quality and troubleshooting
artifact; never commit the private fixtures or raw traces.
