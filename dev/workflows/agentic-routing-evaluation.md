# Agentic-routing evaluation workflow

## Prepare

1. Validate the target repository's agentic context.
2. Use a clean, fixed Git commit or a dedicated worktree for each specification
   variant.
3. Define competency questions and private rubrics outside the target.
4. Separate baseline questions from held-out validation questions.
5. Decide repetitions, model override, timeout, and raw external output path.

Do not proceed if the target can inspect its rubrics or previous raw runs.

## Execute

Call `run_agentic_routing_evaluation()` with explicit approval. The default
adapter uses:

- `codex exec`;
- one ephemeral session per question repetition;
- target repository as the working directory;
- read-only sandbox;
- approval policy `never`;
- ignored user configuration;
- JSONL event output; and
- a schema-constrained final response.

Authentication is supplied by the local Codex installation. Never record keys,
access tokens, or credential files in fixtures, events, or reports.

## Review

Inspect failed and low-scoring raw runs before interpreting the aggregate.
Distinguish:

- execution or authentication failure;
- missing or ambiguous route;
- distracting context;
- incomplete durable evidence;
- rubric error;
- stochastic variation; and
- genuine answer failure.

## Report

Summarize repeated runs and write only the aggregate health report into the
target repository. The durable report omits private prompts, rubrics, answers,
raw events, stderr, absolute user paths, and credentials.

## Compare and tune

Change one experimental factor at a time. Use the same questions and runtime
settings for specification comparisons. Validate any recommended change on
held-out questions or repositories before adoption. Do not automatically apply
instruction recommendations.
