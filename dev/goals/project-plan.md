# Project plan

## Purpose

Develop `{reproducibleai}` as the reusable implementation of durable agentic
context and quantitative evaluation of how effectively agents use that context.

## Current objective

Add an independent, deterministic competency derivation lane:

- extract conservative questions and canonical answers from maintained `dev/`
  sections without reading `AGENTS.md`;
- require explicit human approval or rejection;
- provide an accessible external review bundle and documented QA workflow;
- freeze versioned benchmarks outside the evaluated repository;
- score generated answers with transparent token-overlap metrics; and
- retain manual competency questions for synthesis and judgment tasks.

Status: implemented and verified on `feat/agentic-routing-evaluation`;
awaiting maintainer review.

## Verification record

- 145 package expectations pass with no failures, warnings, or skips.
- A clean source package build includes all four vignettes.
- `R CMD check --no-manual --no-build-vignettes` completes with status OK.
- The pkgdown site builds with the new article and API reference pages.
- Self-derivation produces 11 pending candidates across goals, decisions,
  features, workflows, and architecture; five unsupported sections are
  retained as explicit exclusions for human inspection.
- No authenticated model calls or paid usage occurred during implementation.
- The no-usage preflight discovers Codex CLI 0.145.0 from its stable user-local
  Windows installation and confirms saved ChatGPT authentication despite a
  stale IDE `PATH`.
- A live self-evaluation remains the next step after these changes are committed
  and the maintainer explicitly approves repeated model usage.

## Acceptance criteria

- Gold fixtures and raw runs remain outside the evaluated repository.
- Every repetition starts a fresh ephemeral read-only Codex session.
- Repeated model execution requires explicit approval.
- Package installation and deterministic capabilities do not require Codex,
  cloud authentication, administrator rights, or live network access.
- The package never installs, authenticates, elevates, or bypasses
  organizational endpoint and network controls.
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
