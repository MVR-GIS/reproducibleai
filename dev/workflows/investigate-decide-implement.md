# Consult, investigate, decide, implement, and verify

## Trigger

Use this workflow when repository work exposes missing human intent, tacit
expertise, or a potentially consequential choice. Routine implementation stays
in `complete-development-task.md`.

## Procedure

### 1. Route the missing work

Identify what is actually missing:

- intent, professional judgment, visual assessment, or broad synthesis:
  **consult the human or use a reasoning environment**;
- current code, history, dependencies, or cross-repository impact:
  **use the repository agent**;
- neither: **proceed with implementation**.

Do not begin a broad investigation merely because the topic is scientific.
Ask a focused human question early when tacit expertise can determine the
direction.

### 2. Inspect proportionately

When repository evidence is needed, inspect the narrowest relevant contracts,
code, tests, history, and external authority. Stop when the next action is
clear, additional evidence is unlikely to change it, or the remaining gap is a
human judgment.

Distinguish verified facts, inferences, proposals, and unknowns when doing so
prevents confusion. The labels are not a required reporting template.

### 3. Choose a disposition

- **Proceed:** implement established behavior within the authorized scope.
- **Consult:** ask one concise question and resume from the answer.
- **Investigate:** gather a bounded missing fact, then classify again.
- **Escalate:** stop before committing a consequential unresolved choice.

Reversible defaults and exploratory settings should normally be proposed and
reviewed quickly. Escalation is for durable consequences, not ordinary
uncertainty.

### 4. Make the handoff

For a repository-agent handoff, provide the objective, established human
decisions, repository scope, open evidence questions, permitted changes, and
completion criteria.

For a human or reasoning-environment handoff, lead with the conclusion or
decision needed, cite only decision-relevant repository facts, identify the
remaining uncertainty, recommend the next action, and ask one precise question.

A full decision packet is optional and should be reserved for complex choices
whose alternatives and consequences cannot be communicated clearly in a short
handoff.

### 5. Record consequential decisions

After adjudication, update the narrowest applicable durable artifact. Do not
store the conversation or transitional packet when the resulting contract,
code, test, or documentation is sufficient.

### 6. Implement and verify

Return to the repository agent when the decision and scope are clear. Implement
the smallest coherent change, run checks proportionate to risk, and report the
outcome and any material remaining uncertainty.

## Completion evidence

Report what changed, what was verified, and whether any human decision became
durable. Avoid reproducing the investigation unless its details are needed for
review or future work.
