# Investigate, decide, implement, and verify

## Trigger

Use this workflow when a requested change may affect scientific meaning,
methodology, architecture, authoritative data semantics, capability ownership,
provenance, reproducibility, public or cross-repository contracts, governance,
release, or deployment behavior.

## Inputs

- objective and decision to inform;
- repositories or systems in scope;
- constraints and established assumptions;
- permitted actions, including whether implementation is allowed; and
- expected output.

When these are provided in an investigation brief, treat the brief as task
direction rather than evidence of current repository state.

## Procedure

### 1. Establish scope and authority

Read applicable `AGENTS.md` files and routed context. Inspect repository, branch,
working tree, remotes, and relevant history. Name every repository in scope and
do not infer authority to modify another repository from shared workspace access.

### 2. Classify the initial action

- **Proceed** when an established contract unambiguously governs the requested
  result and implementation is authorized.
- **Investigate** when evidence is needed before readiness can be established.
- **Escalate** when available evidence already exposes a consequential choice
  requiring accountable human judgment.

If uncertain, investigate without changing authoritative behavior.

### 3. Build evidence

Inspect the narrowest relevant code, tests, configuration, maintained context,
history, and authoritative external sources. Label significant findings as
verified, inferred, proposed, or unknown. Cite paths, symbols, tests, commits,
or sources where practical.

Treat contradictions as findings. Do not resolve them merely by choosing the
newest, most convenient, or most complete-looking source.

### 4. Determine disposition

Proceed only when evidence establishes the intended contract and the requested
work remains within delegated authority. Otherwise return a decision packet:

#### Question

State the precise decision required.

#### Why consequential

Explain which scientific meaning, contract, owner, consumer, provenance,
reproducibility, release, or deployment behavior differs between alternatives.

#### Verified evidence

Cite inspectable evidence and distinguish current implementation from intended
authority.

#### Known constraints

List accepted boundaries every alternative must preserve.

#### Unknowns

List material facts that could not be established.

#### Alternatives and consequences

Describe only meaningfully different choices and their expected implications.

#### Agent assessment

Optionally recommend an alternative, clearly labeled as an assessment rather
than established fact.

#### Human decision required

Ask one precise question that an accountable human can answer.

### 5. Record the decision durably

After adjudication, route the durable result to the narrowest applicable
artifact:

- goal or scope -> `dev/goals/`;
- capability boundary or system structure -> `dev/architecture/`;
- consequential choice and rationale -> `dev/decisions/`;
- exact contract -> `dev/schemas/`;
- repeatable procedure -> `dev/workflows/`;
- cohesive behavior -> `dev/features/`; or
- user-visible behavior -> the owning repository's user documentation.

Do not preserve the decision packet as competing authority once its outcome is
captured. Use a checkpoint only if meaningful unfinished state remains.

### 6. Implement

Confirm that implementation is authorized, then follow the repository's normal
development workflow. Implement the smallest coherent realization of the
accepted decision while preserving unrelated work.

### 7. Verify

Run checks proportionate to risk. For cross-repository changes, verify the
owning producer contract before consumers and run relevant integration checks.
Review the final status and diff against the authorized scope and durable
decision.

## Completion evidence

Report the disposition, evidence inspected, human decision when required,
durable artifacts updated, implementation boundary, verification performed,
and remaining unknowns or risks.
