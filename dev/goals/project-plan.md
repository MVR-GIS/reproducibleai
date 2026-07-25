# Project plan

## Purpose

Develop `{reproducibleai}` as the reusable implementation of durable agentic
context and quantitative evaluation of how effectively agents use that context.

## Current objective

Implement the first usable agentic-routing evaluation slice:

- versioned competency-question fixtures;
- isolated repeated Codex execution;
- structured event and response capture;
- transparent deterministic scoring;
- quantitative health summaries and durable reports; and
- tests that do not require credentials or live model calls.

Status: implemented on `feat/agentic-routing-evaluation`; awaiting review.

## Verification record

- 96 package tests pass with no failures, warnings, or skips.
- A clean source package build includes all three vignettes.
- `R CMD check --no-manual --no-build-vignettes` completes with status OK.
- The pkgdown site builds with the new article and API reference pages.
- No authenticated model calls or paid usage occurred during implementation.
- A live pilot remains the next step because the locally packaged Codex
  executable was not accessible as a standalone CLI from this environment.

## Acceptance criteria

- Gold fixtures and raw runs remain outside the evaluated repository.
- Every repetition starts a fresh ephemeral read-only Codex session.
- Repeated model execution requires explicit approval.
- Final responses conform to a versioned JSON Schema.
- Routing and answer scoring is literal, transparent, and independently
  testable.
- JSONL usage and tool metrics are retained when Codex emits them.
- Failed runs remain observable and receive a zero combined score.
- Health reports summarize repeated runs and omit private or sensitive detail.
- Tests exercise the execution boundary through an injected fake runner.
- Public documentation distinguishes deterministic harness behavior from
  stochastic model behavior.

## Standard 0.1 rollout status

- `{reproducibleai}` self-adoption: complete.
- `{ohwm2}` migration: complete and merged.
- `{fluvgeo}` migration: complete and merged.
- `FG-architecture`: available as the design reference.

These repositories form the initial evaluation cohort. Remaining repositories
are a later adoption and external-validation cohort.

## Next evaluation phases

1. Establish baseline competency questions for the initial cohort.
2. Run a small authenticated pilot and inspect raw scoring evidence.
3. Refine rubrics before increasing repetitions.
4. Compare one routing-specification factor at a time in fixed worktrees.
5. Validate recommendations on held-out questions or repositories.

## Deferred work

- comparative experiment orchestration across worktrees
- automated sensitivity grids
- prompt or specification tuning
- semantic or model-judge scoring
- multi-turn SDK execution
- monetary cost estimation
- automatic application of recommendations
- automatic semantic migration
- nested `AGENTS.md` generation
- automatic three-way standard upgrades
