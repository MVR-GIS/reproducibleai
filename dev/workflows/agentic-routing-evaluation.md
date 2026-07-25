# Agentic-routing evaluation workflow

## Prepare

1. Run `check_agentic_routing_prerequisites(path = target)`.
2. Validate the target repository's agentic context.
3. Use a clean, fixed Git commit or a dedicated worktree for each specification
   variant.
4. Derive deterministic candidates from maintained `dev/` context or author
   questions manually.
5. Human-review every derived prompt, source, and canonical answer; explicitly
   approve or reject each candidate.
6. Freeze the reviewed benchmark outside the target repository.
7. Separate baseline questions from held-out validation questions.
8. Decide repetitions, model override, timeout, and raw external output path.

Do not proceed if the target can inspect its rubrics or previous raw runs.

The preflight discovers the standalone CLI from `PATH` and supported user-local
locations, checks saved authentication, and checks the target context and Git
state. It makes no model request. A ready result does not test outbound network,
service entitlement, or enterprise execution policy.

On managed, disconnected, or no-admin equipment, stop at offline preparation
when policy prohibits the CLI or Codex service. Do not request elevated rights
or bypass application and network controls. The package's deterministic
scaffolding, validation, fixture, scoring, and reporting capabilities remain
available.

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

Live execution is a maintainer-initiated local development diagnostic. Do not
run it automatically during package installation, package builds, tests, or CI.

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

Commit the aggregate report so maintainers can troubleshoot context changes and
end-users can inspect current process-quality evidence. The report identifies
the evaluated Git SHA and therefore normally lags the commit that adds or
updates the report.

## Compare and tune

Change one experimental factor at a time. Use the same questions and runtime
settings for specification comparisons. Validate any recommended change on
held-out questions or repositories before adoption. Do not automatically apply
instruction recommendations.
