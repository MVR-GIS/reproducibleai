# Human-agent collaboration and decision governance

- Status: accepted for lean manual deployment
- Updated: 2026-09-03
- Governing decision: `dev/decisions/adr-0010-lean-human-agent-collaboration.md`

## Purpose

Add only the collaboration rules that normal repository-agent behavior does
not already provide: where work should happen, when a human should be
consulted, what crosses an AI-system boundary, and who decides
domain-significant questions.

This policy does not repeat ordinary expectations to inspect repositories,
preserve unrelated work, test changes, or review diffs. Repository instructions
and the agent platform already govern those practices.

## Roles and routing

- A **reasoning environment** helps a human clarify objectives, articulate
  tacit knowledge, research, challenge assumptions, and compare approaches.
- A **repository agent** establishes actual state across relevant repositories,
  makes authorized changes, and verifies them.
- An **accountable human** supplies intent and professional judgment and accepts
  consequential scientific, semantic, architectural, release, or deployment
  choices.
- The **repository** preserves the resulting durable decisions and contracts;
  conversations remain working context.

Use the participant with the missing capability. Move toward human discussion
or a reasoning environment for intent, tacit knowledge, visual judgment, or
broad synthesis. Move toward a repository agent for code, history,
dependencies, multi-repository state, implementation, or verification.

## Four dispositions

- **Proceed** when the outcome is authorized and established behavior governs
  the work.
- **Consult** when a short human interaction can supply missing intent,
  expertise, preference, or professional judgment. Consult as soon as that is
  the limiting input.
- **Investigate** when inspectable evidence can resolve a material uncertainty.
  Inspect the smallest useful evidence set.
- **Escalate** before committing materially different scientific, semantic,
  architectural, provenance, public-contract, release, or deployment choices.

Consultation and investigation are not ordered stages. Either can come first,
and a brief consultation may eliminate the need for investigation.

## Proportionality

The cost of delay matters. Stop investigating when more evidence is unlikely
to change the next action or human expertise can answer more directly.

Treat reversible defaults, exploratory settings, and visual workflow choices
as candidates for rapid proposal and review unless the project has explicitly
made them scientific invariants. Do not turn every parameter into a universal-
method study.

Lead with conclusions and decision-relevant facts. Reserve full decision
packets and durable supporting detail for choices complex enough to need them.

## Handoffs and durable outcomes

Handoffs carry objectives, established decisions, scope, open questions,
permissions, and completion criteria—not transcripts. The operational formats
are defined in `../workflows/investigate-decide-implement.md`.

Record accepted consequential outcomes in the narrowest existing goal, ADR,
architecture, schema, workflow, feature, documentation, test, or code artifact.
Do not retain routine packets or investigation exhaust as durable context.

## Authority and evidence

AI-generated work contributes to engineering but does not establish scientific
authority. Human review should occur early enough to shape the work, not only
approve it afterward.

When the distinction affects a decision, identify facts as **verified**,
conclusions as **inferred**, future choices as **proposed**, and unestablished
matters as **unknown**. These labels are clarity aids, not a mandatory response
format.

## Adoption boundary

This lean manual layer does not change agentic-context Standard 0.1,
scaffolding, manifests, validation, or the R API. Standardization or automation
requires repeated evidence of a stable gap not already handled by the platform.
