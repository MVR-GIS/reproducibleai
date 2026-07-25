# Evaluate agentic routing

Agentic-context validation confirms that a repository has the expected
structure. Routing evaluation asks a different question: when Codex
receives a task, does it find the right maintained evidence and produce
the expected answer efficiently?

The harness is deterministic, but model responses are stochastic.
Interpret results as repeated-run distributions rather than
byte-identical tests.

## Define private competency questions

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
  questions = questions,
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

The durable report contains only aggregate metrics and recommendations.
Inspect external raw runs before changing instructions, and validate
proposed improvements on held-out questions or repositories.
