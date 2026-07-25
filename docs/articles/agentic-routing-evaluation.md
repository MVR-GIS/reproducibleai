# Agentic routing, Step 2: Run the evaluation

This is Step 2 of the
[reproducibleai](https://mvr-gis.github.io/reproducibleai/)
agentic-routing workflow:

1.  [Review and freeze the competency
    benchmark](https://mvr-gis.github.io/reproducibleai/articles/review-agentic-routing-benchmarks.md).
2.  **Run the routing evaluation** (this article).
3.  [Interpret routing health and plan a
    comparison](https://mvr-gis.github.io/reproducibleai/articles/interpret-agentic-routing-health.md).

Step 2 starts with the private, frozen benchmark JSON produced by
Step 1. It runs fresh read-only Codex sessions, retains private
diagnostic evidence outside the target, and writes an aggregate health
report suitable for the target repository.

## Inputs and outputs

| Artifact | Location | Role |
|----|----|----|
| Frozen benchmark JSON | outside target | Private fixed criterion from Step 1 |
| Clean target Git commit | target repository | System under test |
| Raw JSONL, responses, and stderr | outside target | Private troubleshooting evidence |
| Serialized evaluation and health objects | outside target | Reanalysis without rerunning |
| Aggregate Markdown report | inside target | Durable result consumed by Step 3 |

Never place the benchmark, canonical answers, or raw runs inside the
repository being evaluated.

## Load the Step 1 benchmark

``` r

library(reproducibleai)

target <- "C:/workspace/FluvialGeomorph/fluvgeo"
benchmark_path <- "C:/workspace/agentic-reviews/fluvgeo-baseline.json"
benchmark <- read_agentic_routing_benchmark(benchmark_path)
print(benchmark)
```

The benchmark must have no pending questions. Rejected questions remain
in the JSON for auditability but are omitted from execution.

## Run the no-usage preflight

Most [reproducibleai](https://mvr-gis.github.io/reproducibleai/)
capabilities require neither Codex nor a cloud account. Live routing
evaluation requires a separately installed Codex CLI, authentication,
connectivity, account entitlement, and organizational permission.

``` r

status <- check_agentic_routing_prerequisites(target)
print(status)
stopifnot(status$ready)
```

Preflight checks:

- discovery and version of the standalone Codex CLI;
- saved authentication;
- compatibility of the installed `codex exec --help` interface;
- valid agentic context;
- a readable target Git commit; and
- a clean target worktree.

It does not call a model or consume usage. Network and enterprise
execution policy remain untested until the first live session.

On Windows, the standalone user-local installer does not require npm:

``` powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

Restart the R IDE after installation. On managed, disconnected, or
government-furnished equipment, do not bypass application, identity, or
network controls. Stop after offline preparation when live execution is
prohibited.

## Use a canary before a batch

A one-question canary catches runtime, CLI, authentication, and
structured response problems before they invalidate or waste a larger
experiment.

``` r

canary <- benchmark
canary$questions <- benchmark$questions[1]

canary_evaluation <- run_agentic_routing_evaluation(
  path = target,
  questions = canary,
  repetitions = 1,
  approved = TRUE
)

stopifnot(all(canary_evaluation$runs$completed))
```

Do not interpret a zero score when completion is zero as routing
failure. Inspect stderr and JSONL first. An execution or schema failure
means the experiment did not observe routing behavior.

## Run the approved evaluation

After the canary succeeds, run the reviewed benchmark. Start with one
repetition per question to validate coverage; use multiple repetitions
when estimating stochastic stability or comparing specifications.

``` r

evaluation <- run_agentic_routing_evaluation(
  path = target,
  questions = benchmark,
  repetitions = 5,
  approved = TRUE,
  output_dir = "C:/workspace/agentic-reviews/fluvgeo-runs",
  model = NULL
)
```

Every repetition uses a fresh `codex exec` session with:

- `--ephemeral`;
- `--sandbox read-only`;
- `--ignore-user-config`;
- `--json`; and
- `--output-schema`.

Preflight verifies this option contract before the first model call.
Codex CLI 0.145.0 does not expose the interactive `--ask-for-approval`
option on `exec`; read-only sandboxing and non-interactive execution
provide the applicable boundary.

The function uses existing Codex authentication. It does not accept or
record API keys.

## Create the Step 2 output

``` r

health <- summarize_agentic_routing(evaluation)

report_path <- file.path(
  target,
  "dev",
  "governance",
  "agentic-routing-health.md"
)
write_agentic_routing_report(health, report_path)
```

Commit only the aggregate report. Keep serialized R objects, raw
responses, events, stderr, prompts, and gold answers outside the target.

The harness is deterministic, but model responses are stochastic. A
single-repetition pilot validates execution and reveals candidate
signals; it does not estimate run-to-run variation.

**Next:** continue to [Step 3: Interpret routing
health](https://mvr-gis.github.io/reproducibleai/articles/interpret-agentic-routing-health.md)
before changing repository instructions.
