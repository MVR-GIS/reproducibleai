# Agentic-routing evaluation

## User outcome

A repository owner can deterministically derive and human-review competency
questions from maintained development context, run repeated isolated Codex
sessions, quantify whether the expected context routes were used, and write a
durable aggregate health report.

## Supported journey

1. Derive candidates with `derive_agentic_routing_questions()` or author
   questions with `new_agentic_routing_question()`.
2. Write an external review bundle containing instructions, an editable
   question sheet, and generator exclusions.
3. Human-review every generated candidate, inspect coverage gaps, and explicitly
   approve or reject it.
4. Import the review sheet with provenance validation.
5. Freeze the reviewed benchmark outside the target with
   `write_agentic_routing_benchmark()`.
6. Review repetitions, model, target commit, and expected usage.
7. Run `check_agentic_routing_prerequisites()` in the local development
   environment.
8. Run a one-question canary and stop if execution or structured response
   completion fails.
9. Call `run_agentic_routing_evaluation(..., approved = TRUE)`.
10. Inspect raw external runs when a score needs explanation.
11. Call `summarize_agentic_routing()`.
12. Write and commit an aggregate report with
   `write_agentic_routing_report()`.
13. Interpret execution, routing, answer, efficiency, and variability layers in
    that order.
14. Compare instruction formulations only with the same frozen benchmark.

## Capability tiers

### Local deterministic

Available without Codex, a SaaS account, administrator rights, or live network
access: scaffolding, migration, structural validation, fixture authoring,
offline scoring, summarization of saved results, and health-report rendering.

### Local connected agentic

Live evaluation additionally requires a runnable standalone Codex CLI, saved
authentication, outbound service access, account entitlement, and permission
under local application and network policy. It is an explicitly initiated
development diagnostic, not an automatic package-build or CI task.

### Managed or disconnected

Application allow-listing, endpoint security, identity policy, or network
controls may prohibit live execution on no-admin or government-furnished
equipment. The package must preserve deterministic local functionality, explain
the unavailable capability, and never install software, authenticate, or bypass
organizational controls on the user's behalf.

## Measures

Each run records:

- execution and structured-response completion;
- required evidence recall;
- relevant evidence precision;
- canonical-answer token F1 for derived questions, or expected-term recall for
  manually authored questions;
- forbidden-term rate;
- self-reported confidence;
- input, cached-input, and output tokens when emitted by Codex;
- tool-call count;
- elapsed time; and
- a transparent combined score.

Health reports summarize means, minimums, completion rates, and repeated-run
variation by question.

## Experimental controls

- Do not store gold fixtures in the evaluated repository.
- Never derive gold answers from `AGENTS.md` or model output.
- Human-review all generated questions before execution.
- Do not store raw results in the evaluated repository.
- Use fresh ephemeral sessions for every repetition.
- Use read-only sandboxing and no interactive approvals.
- Pin the target commit and model when comparing variants.
- Keep prompts constant when comparing repository specifications.
- Keep repository specifications constant when comparing prompt formulations.
- Reserve held-out questions or repositories for validating recommendations.

## Boundaries

This feature measures literal rubric satisfaction and routing claims. It does
not prove scientific correctness, causal attribution, or universal instruction
quality. The first version does not automatically mutate `AGENTS.md`, search a
prompt space, estimate monetary cost, or orchestrate multi-turn sessions.
Passing local preflight does not prove that network policy or service
entitlement will permit a live run.

## Related authority

- Decision: `dev/decisions/adr-0007-agentic-routing-evaluation.md`
- Schemas: `dev/schemas/project-schemas.md`
- Workflow: `dev/workflows/agentic-routing-evaluation.md`
- Step 1 article: `vignettes/review-agentic-routing-benchmarks.Rmd`
- Step 2 article: `vignettes/agentic-routing-evaluation.Rmd`
- Step 3 article: `vignettes/interpret-agentic-routing-health.Rmd`
