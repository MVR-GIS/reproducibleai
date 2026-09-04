# Project plan

## Purpose

Develop `{reproducibleai}` as the reusable implementation of durable agentic
context, human-agent decision governance, and quantitative evaluation of how
effectively agents use that context.

## Current objective

Use the lean human-agent collaboration guidance during normal FGDB development
and observe whether it improves routing and forward progress without weakening
scientific authority.

The stabilized policy and workflow are maintained in
`dev/governance/human-agent-decision-governance.md` and
`dev/workflows/investigate-decide-implement.md`. Agentic-routing sensitivity
experiments remain paused as recorded in
`dev/checkpoints/current/agentic-routing-evaluation-paused.md`.

ADR-0010 records the completed pilot result. The policy prevented unsupported
choices but over-investigated a visual GIS judgment, delayed human
consultation, and omitted the reasoning-environment/repository-agent handoff.
The revised manual guidance addresses those gaps without changing Standard
0.1, scaffolding, validation, or the R API.

## Human-agent collaboration acceptance criteria

- Routine implementation proceeds without unnecessary human escalation.
- Tacit expertise, intent, and visual or professional judgment trigger early,
  focused consultation rather than substitute investigation.
- Reasoning-environment and repository-agent handoffs state the objective,
  established decisions, scope, open questions, permissions, and completion
  criteria without carrying a transcript.
- Investigations stop when the next action is clear or human judgment is the
  remaining input.
- Consequential scientific or architectural choices still stop before
  unauthorized behavior changes.
- Responses lead with conclusions and decision-relevant evidence; full decision
  packets are reserved for genuinely complex choices.
- Adjudicated outcomes are promoted to existing durable artifact categories.
- Further automation is proposed only for a repeated, stable gap not already
  handled by the agent platform or repository instructions.

## Routing baseline verification record (2026-07-25)

- 155 package expectations pass with no failures, warnings, or skips.
- The package now has five connected vignettes, including a numbered
  review-run-interpret workflow.
- `R CMD check --no-manual --no-build-vignettes` completes with status OK.
- The pkgdown site builds with the new article and API reference pages.
- Self-derivation produces 11 pending candidates across goals, decisions,
  features, workflows, and architecture; five unsupported sections are
  retained as explicit exclusions for human inspection.
- Eleven authenticated pilot sessions completed successfully after a canary.
- The baseline has 100% completion, 100% required-evidence recall, 90.9%
  relevant-evidence precision, 39.4% literal answer score, and an 80.0/100
  weighted health score.
- Mean reported input was 53,106 tokens, of which 36,631 were cached; this is a
  baseline observation rather than a pass/fail threshold.
- The no-usage preflight discovers Codex CLI 0.145.0 from its stable user-local
  Windows installation and confirms saved ChatGPT authentication despite a
  stale IDE `PATH`.
- Two zero-usage launch failures exposed a removed CLI option and an unsupported
  JSON Schema keyword; compatibility preflight, schema tests, and canary
  guidance now guard those boundaries.

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

## On-resume evaluation phases

1. Review the two low-precision architecture routes and answer-breadth evidence.
2. Define one routing-specificity hypothesis without changing the benchmark.
3. Compare baseline and variant in fixed worktrees with three to five
   repetitions on selected sentinel questions.
4. Validate the selected formulation on held-out questions or repositories.

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
