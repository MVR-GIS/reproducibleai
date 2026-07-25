# ADR-0007: Evaluate agentic routing with isolated repeated Codex runs

- Status: accepted
- Date: 2026-07-25

## Context

Agentic-context standard 0.1 makes repository instructions compact and
reviewable, but structural validation cannot determine whether Codex follows the
right route, finds the necessary evidence, answers correctly, or does so
efficiently. Anecdotal success is insufficient for comparing alternative
instruction formulations.

Model output is stochastic. A reproducible evaluation therefore requires a
deterministic harness around repeated runs rather than byte-identical responses.
The harness must also avoid leaking gold answers or previous run output into the
repository context being measured.

## Decision

`{reproducibleai}` will evaluate routing with:

- versioned competency-question fixtures containing prompts and private rubrics;
- fresh, ephemeral, read-only `codex exec` sessions;
- explicit approval before repeated model execution;
- `--ignore-user-config` to reduce uncontrolled configuration effects;
- JSONL event capture for completion, usage, and tool metrics;
- a JSON Schema-constrained final response containing the answer, evidence paths,
  route summary, and confidence;
- fixed transparent scoring for required evidence recall, relevant evidence
  precision, expected terms, forbidden terms, and completion;
- repeated-run summaries rather than single-run pass/fail claims; and
- aggregate durable health reports that exclude prompts, rubrics, responses,
  and raw traces;
- optional user-local CLI discovery and a no-usage prerequisite diagnostic; and
- required-option validation against `codex exec --help` before live execution;
- a one-question canary before a larger first-time batch; and
- a strict separation between deterministic offline package capabilities and
  connected agentic execution.

Gold fixtures and raw results must remain outside the evaluated repository.
Reports may be written into the target repository only after the runs complete.
Live evaluation is a maintainer-initiated local development diagnostic, not an
automatic package installation, build, test, or CI action. The package will not
install Codex, request administrative elevation, authenticate an account, or
bypass endpoint or network restrictions.

## Consequences

Routing specifications can be compared quantitatively without treating model
output as deterministic. Tests can exercise the full harness with an injected
fake runner and never require credentials or paid model calls.

Literal path and term scoring is intentionally interpretable but cannot judge
scientific truth or semantic equivalence. Evidence paths are model-reported and
should be treated as auditable claims, not perfect telemetry. Global
instructions, Codex/runtime versions, authentication context, and model-service
changes remain experimental factors and must be recorded or controlled when
comparing formulations.

Automatic instruction rewriting is out of scope for the first version.
Recommendations remain advisory and must be validated on held-out questions or
repositories before adoption.

Computers without administrator rights can still use all deterministic package
capabilities. OpenAI's standalone Windows installer can install the optional
CLI under the user profile, but managed-device application, identity, or
network policy may still prohibit execution. Preflight reports this boundary
without claiming to prove connectivity or entitlement.
