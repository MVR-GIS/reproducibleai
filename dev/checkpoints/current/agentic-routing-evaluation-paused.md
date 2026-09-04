# Checkpoint: Agentic-routing evaluation paused after baseline

- Updated: 2026-07-25
- Status: paused by maintainer

## Objective

Preserve the completed `{reproducibleai}` agentic-context evaluation feature,
self-review benchmark, pilot evidence, and next experimental question so a
later session can resume without reconstructing this development history.

## Current state

- The feature was merged to remote `main` by PR #3 at merge commit `6a0fc26`.
- The current checkout is `feat/agentic-routing-evaluation` at `b25472a`; that
  commit is an ancestor of `origin/main`.
- The reviewed baseline evaluates target commit `202172f`.
- No further evaluation development or live model runs are authorized while
  this checkpoint is paused.
- The next possible research task is a controlled architecture-routing
  specificity experiment, not an unfinished implementation requirement.

## Completed

- Agentic-context standard 0.1 scaffolding, migration, and validation.
- Deterministic competency derivation independent of `AGENTS.md`.
- External CSV review bundle with human QA, exclusions, locked provenance, and
  frozen benchmark JSON.
- Read-only repeated `codex exec` evaluation with explicit approval, CLI
  discovery, authentication checks, interface compatibility preflight, canary
  guidance, and supported structured output.
- Transparent routing, literal answer, completion, token, cache, tool, timing,
  variability, and aggregate health metrics.
- Durable self-evaluation report at
  `dev/governance/agentic-routing-health.md`.
- Connected user documentation:
  1. `vignettes/review-agentic-routing-benchmarks.Rmd`
  2. `vignettes/agentic-routing-evaluation.Rmd`
  3. `vignettes/interpret-agentic-routing-health.Rmd`
- First authenticated pilot: 11 completed sessions, 100% required-evidence
  recall, 90.9% relevant-evidence precision, 39.4% literal answer score, and
  80.0/100 weighted health.

## Remaining

Nothing is required to complete the current feature. Optional work after an
explicit resume:

1. Inspect the two low-precision architecture questions and their private raw
   evidence.
2. State one architecture-routing specificity or stopping-behavior hypothesis.
3. Pin an explicit model identifier; the pilot used `configured-default`.
4. Compare baseline and one variant in clean worktrees using the unchanged
   frozen benchmark and three to five repetitions on selected sentinel
   questions.
5. Validate any selected formulation on held-out questions or repositories.

Do not interpret the pilot's 53,106 mean input tokens as an established
pass/fail threshold. Do not interpret low literal token F1 as proof of a
substantively incorrect answer without inspecting private evidence.

## Evidence and verification

- `dev/governance/agentic-routing-health.md` is the durable public aggregate.
- `dev/goals/project-plan.md` records the paused state and optional on-resume
  phases.
- `dev/decisions/adr-0007-agentic-routing-evaluation.md` and
  `dev/decisions/adr-0008-deterministic-competency-derivation.md` record the
  durable design decisions.
- `dev/schemas/project-schemas.md` records benchmark, review, response, run, and
  report contracts.
- 155 package expectations passed with no failures, warnings, or skips.
- A source build containing five vignettes completed.
- `R CMD check --no-manual --no-build-vignettes` completed with status OK.
- The pkgdown site built with the numbered review-run-interpret workflow.

Private artifacts outside the evaluated repository:

- Review bundle:
  `C:/workspace/agentic-reviews/reproducibleai-baseline/`
- Frozen benchmark:
  `C:/workspace/agentic-reviews/reproducibleai-baseline.json`
- Combined serialized pilot and private report:
  `C:/workspace/agentic-reviews/reproducibleai-pilot-20260725-final/`
- Successful raw runs:
  `C:/workspace/agentic-reviews/reproducibleai-pilot-20260725-canary/raw/`
  and
  `C:/workspace/agentic-reviews/reproducibleai-pilot-20260725-remainder/raw/`
- Detached clean baseline worktree:
  `C:/workspace/agentic-reviews/pilot-worktree/reproducibleai`
- The directories `reproducibleai-pilot-20260725/` and
  `reproducibleai-pilot-20260725-retry/` contain only invalid launch
  diagnostics from the obsolete CLI option and unsupported schema keyword;
  they are not routing-health observations.

## Next safe action

Do nothing until the maintainer explicitly resumes this research. On resume:

1. start from an up-to-date `main`;
2. read `AGENTS.md`, this checkpoint, `dev/goals/project-plan.md`, the durable
   health report, and the three numbered workflow articles;
3. verify that the external benchmark and raw evidence still exist;
4. inspect current Git and Codex CLI/model evidence; and
5. obtain explicit approval before any new live model execution.

Archive or remove this checkpoint only after the resumed task has established a
new durable objective or superseding baseline.

## Blockers or decisions

- No active blocker.
- Future comparisons must pin an explicit model rather than
  `configured-default`.
- One pilot repetition per question cannot estimate stochastic stability.
- Gold criteria and private raw traces must remain outside the evaluated
  repository.
- Automatic instruction rewriting remains out of scope; recommendations require
  controlled and held-out validation.
