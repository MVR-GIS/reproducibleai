# Human-agent decision governance

- Status: accepted for manual dogfooding
- Adopted: 2026-09-03
- Governing decision: `dev/decisions/adr-0009-human-agent-decision-governance.md`

## Purpose

Define how humans, reasoning environments, repository agents, and durable
repository artifacts cooperate without making an AI session the implicit
scientific or architectural authority.

The operating sequence is:

```text
question -> evidence -> reasoning -> human decision when required
         -> durable artifact -> implementation -> verification
```

## Authority

- Accountable humans authorize consequential scientific, methodological,
  architectural, data-semantic, governance, release, deployment, and
  cross-repository choices.
- Repository agents may investigate, implement established decisions, run
  permitted checks, and report evidence within their delegated scope.
- Reasoning environments may research, synthesize, challenge assumptions, and
  develop alternatives. Their conversations are not authoritative project
  evidence or durable organizational memory.
- The repository preserves durable rationale through the narrowest applicable
  maintained artifact. Conversations and transient handoffs do not override
  accepted ADRs, schemas, maintained architecture, tests, or current human
  direction.

AI-generated analysis, code, documentation, tests, and recommendations are
contributions to the engineering process, not scientific authority.
Domain-significant assumptions, methods, interpretations, transformations,
thresholds, and acceptance criteria must be traceable to authoritative evidence
or accountable human review.

## Claim posture

Use these labels when the distinction matters:

- **Verified**: directly supported by cited repository evidence, automated
  verification, authoritative external evidence, or an approved durable
  project artifact within its stated authority.
- **Inferred**: a reasonable conclusion derived from evidence but not directly
  established.
- **Proposed**: a candidate future state that is neither current behavior nor
  an accepted decision.
- **Unknown**: available evidence is insufficient.

Claim posture is distinct from artifact lifecycle. For example, an ADR may have
status `proposed` or `accepted`; acceptance makes its decision authoritative but
does not independently verify every empirical statement in its context.

## Consequential-decision boundary

An agent may proceed when the requested outcome is authorized, applicable
contracts establish the intended behavior, no material contradiction remains,
and the work stays within the delegated repository and change scope.

An agent investigates when repository or authoritative external evidence is
needed to establish those conditions. Investigation gathers and reports
evidence; it does not silently alter authoritative behavior.

An agent escalates when investigation reveals materially different defensible
alternatives that would change scientific meaning, methodology, entity
identity, capability ownership, authoritative data semantics, provenance,
reproducibility, a public or cross-repository contract, governance, release, or
deployment behavior.

`Investigate` is normally an intermediate state. After investigation, either
the established evidence permits work to proceed or a precise human decision
is required.

Routine implementation choices remain delegated when they preserve established
behavior and contracts. Risk-appropriate review does not require approval for
every edit.

## Separation of phases

For consequential work, keep these phases explicit even when one agent could
perform all of them:

1. investigate the current state and affected authority;
2. obtain accountable human adjudication when material alternatives remain;
3. promote the decision into the applicable durable artifact;
4. implement only the accepted contract and authorized scope; and
5. verify behavior, artifacts, and the final change boundary.

Do not document an agent-selected interpretation as though it were pre-existing
authority.

## Cross-repository work

Repository-local evidence is insufficient when a contract explicitly spans
repositories. Name every repository in scope, inspect each repository's
instructions and evidence, identify the owner and consumers of the contract,
and obtain authorization before modifying each repository. A shared workspace
improves investigation but does not broaden modification authority.

## Transitional handoffs

Investigation briefs and decision packets are compact working material, not new
permanent artifact categories. Keep them outside authoritative context or mark
them temporary and non-authoritative. After a human decision, promote only the
durable outcome to the applicable goal, architecture, ADR, schema, workflow,
feature, user documentation, test, or code artifact.

Do not retain full transcripts, every prompt, or raw agent traces as project
memory. Create a checkpoint only when useful unfinished state must be resumed.

## Adoption boundary

This policy is accepted for manual use and dogfooding. It does not change
agentic-context Standard 0.1, its scaffold, manifest, validator, or R API.
Standard automation and versioning require evidence from the dogfooding process
and a separate reviewed decision.
