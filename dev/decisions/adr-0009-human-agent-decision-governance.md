# ADR-0009: Adopt human-agent decision governance for manual dogfooding

- Status: accepted
- Date: 2026-09-03

## Context

Agentic-context Standard 0.1 establishes durable repository context, artifact
authority, concise routing, and structural validation. The routing-evaluation
feature measures whether fresh read-only sessions find expected evidence.
Neither capability defines when an agent may implement, when it should only
investigate, or when a consequential ambiguity requires accountable human
judgment.

FluvialGeomorph organization and FGDB governance already demonstrate useful
authority boundaries, evidence classification, cross-repository review, and
explicit limits on AI scientific authority. Those practices should inform a
generic extension without making project-specific roles or vendors normative.

The procedure has not yet been exercised broadly enough to justify stable R
functions, schemas, scaffold requirements, or automated delegation scoring.

## Decision

`{reproducibleai}` adopts a vendor-neutral human-agent decision-governance
policy and an investigate-decide-implement-verify workflow for manual use and
dogfooding.

The policy:

- preserves accountable human authority for consequential scientific and
  engineering decisions;
- distinguishes verified, inferred, proposed, and unknown claims;
- permits routine implementation under established contracts and delegated
  scope;
- requires investigation when evidence is insufficient;
- requires escalation when materially different defensible alternatives would
  change consequential behavior;
- treats investigation briefs and decision packets as transitional working
  material rather than new permanent artifact categories;
- promotes adjudicated outcomes into existing durable artifact categories; and
- separates investigation, decision, implementation, and verification for
  consequential work.

This decision does not modify Standard 0.1, add a profile, change scaffolding or
validation, or add an R API. FGDB will be the initial manual dogfooding
environment. Any standardized scaffold or automation requires a later reviewed
decision based on observed use.

## Consequences

- Agents receive a practical authority boundary without requiring approval for
  every coding choice.
- Human reviewers receive compact evidence and alternatives instead of full
  transcripts.
- Existing ADR, schema, architecture, workflow, feature, and checkpoint roles
  remain unchanged.
- Standard 0.1 repositories require no migration during manual dogfooding.
- The process depends initially on human and agent compliance rather than
  machine validation.
- Dogfooding must measure missed escalation, unnecessary escalation, decision
  clarity, review effort, durable promotion, and transcript independence.
- If the policy later becomes required scaffold behavior, a new standard
  version and a customization-preserving upgrade path will be necessary.
