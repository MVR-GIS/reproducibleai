# ADR-0010: Stabilize lean human-agent collaboration after FGDB pilot

- Status: accepted
- Date: 2026-09-03
- Supersedes: ADR-0009

## Context

ADR-0009 introduced a rigorous manual boundary between investigation, human
decision, implementation, and verification. The FGDB pilot showed that this
successfully prevented unsupported scientific and cross-repository choices.

The same pilot also exposed three defects. The workflow encouraged repository
investigation whenever uncertainty remained, consulted the human too late, and
did not specify transitions between a conversational reasoning environment and
a repository agent. In the Flowline example, an experienced GIS analyst could
have established early that smoothing is normally a visual, iterative judgment
with sensible defaults. The agent instead pursued an unnecessarily elaborate
objective-threshold investigation. The result was accurate and rigorous but
verbose, slow, and lower-value than an early consultation.

Normal Codex and repository instructions already provide strong inspection,
change-safety, implementation, and verification behavior. Repeating those
controls in a separate governance system adds ceremony without a distinct
benefit.

## Decision

Human-agent governance becomes a lean collaboration overlay rather than a
comprehensive agent-control framework.

The overlay:

- adds **consult** beside proceed, investigate, and escalate;
- asks for human intent or tacit expertise as soon as it becomes the limiting
  input;
- routes broad reasoning and alternative synthesis to a reasoning environment,
  and repository state, implementation, and verification to a repository
  agent;
- defines compact handoffs in both directions without transcripts;
- requires proportional investigation and treats delay as a cost;
- favors rapid review of reversible defaults and visual workflow choices;
- reserves full decision packets for genuinely complex consequential choices;
  and
- relies on platform and repository-native engineering safeguards rather than
  restating them.

The revised manual guidance is ready for deployment in FGDB. The pilot does not
justify a new agentic-context standard version, R API, schema, template,
validator rule, or automated delegation score.

## Consequences

- Human participation can shape an investigation rather than merely approve
  its result.
- Reasoning-environment and repository-agent responsibilities and handoffs are
  explicit while remaining vendor-neutral.
- Routine and reversible work can move faster without weakening human
  scientific authority.
- FGDB receives one concise local workflow connected to its existing evidence
  and human-review policies.
- The completed pilot is summarized here; its long working brief and transient
  checkpoint need not remain durable context.
- Future automation remains deferred until repeated use reveals a narrow,
  stable capability not already supplied by the agent platform.
