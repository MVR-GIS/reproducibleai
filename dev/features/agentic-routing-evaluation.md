# Agentic-routing evaluation

## User outcome

A repository owner can define competency questions, run repeated isolated Codex
sessions against a repository, quantify whether the expected context routes were
used, and write a durable aggregate health report.

## Supported journey

1. Define questions with `new_agentic_routing_question()`.
2. Save private fixtures outside the target with
   `write_agentic_routing_questions()`.
3. Review the questions, repetitions, model, target commit, and expected usage.
4. Call `run_agentic_routing_evaluation(..., approved = TRUE)`.
5. Inspect raw external runs when a score needs explanation.
6. Call `summarize_agentic_routing()`.
7. Write an aggregate report with `write_agentic_routing_report()`.
8. Compare instruction formulations only after establishing a stable baseline.

## Measures

Each run records:

- execution and structured-response completion;
- required evidence recall;
- relevant evidence precision;
- expected answer-term recall;
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

## Related authority

- Decision: `dev/decisions/adr-0007-agentic-routing-evaluation.md`
- Schemas: `dev/schemas/project-schemas.md`
- Workflow: `dev/workflows/agentic-routing-evaluation.md`
- User article: `vignettes/agentic-routing-evaluation.Rmd`
