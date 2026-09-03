# Codex Investigation Brief: Human–Agent Decision Governance for `reproducibleai`

## Objective

Perform a repository-grounded architectural investigation of `MVR-GIS/reproducibleai` and propose the smallest coherent extension to the existing agentic-context standard that introduces **human–agent decision governance** for AI-assisted scientific software engineering.

**Do not implement the proposed changes yet.**

The purpose of this task is to determine how the governance described below should integrate with the architecture, conventions, R API, templates, validation, tests, documentation, and routing-evaluation capabilities that already exist in `reproducibleai`.

This is an investigation and design task intended to produce an evidence-backed implementation plan for SME review.

---

# 1. Context

`reproducibleai` is being developed as reusable procedure-standardization tooling for teams performing AI-assisted scientific and geospatial software engineering.

The package already addresses an important part of the problem: converting ephemeral AI-assisted development activity into durable, repository-maintained context that subsequent humans and agents can navigate.

The next problem to address is broader:

> How should humans, conversational/reasoning AI environments, repository-aware coding agents, and durable repository artifacts interact so that AI increases engineering efficiency without becoming the implicit scientific or architectural authority?

This requirement emerged while developing the FluvialGeomorph project.

The working environment currently includes:

- ChatGPT/project conversations for long-horizon reasoning, research, architecture discussion, standards interpretation, alternative evaluation, and adversarial review.
- Local Codex workspaces for repository-grounded investigation and implementation.
- Multi-repository Codex workspaces containing all relevant repositories simultaneously.
- Human scientific/geospatial SMEs who retain authority over consequential domain and engineering decisions.
- Git repositories as the durable system of record.

The desired governance must **not depend specifically on ChatGPT or Codex**. Those are current implementations of more general roles.

The standard should remain useful as AI products and agent architectures change.

---

# 2. Core Governance Principle

The proposed operating model is:

**Question → Evidence → Reasoning → Human Decision → Durable Artifact → Implementation → Verification**

The roles are approximately:

## Reasoning environment

Used for:

- architectural exploration;
- external research;
- standards and literature interpretation;
- synthesis;
- alternative generation;
- adversarial review;
- helping SMEs articulate tacit knowledge.

A reasoning conversation is **not itself authoritative project evidence or durable organizational memory**.

## Repository agent

Used for:

- inspecting actual repository state;
- cross-repository investigation;
- tracing dependencies;
- identifying inconsistencies;
- modifying files;
- running commands;
- implementing approved decisions;
- testing;
- validating;
- inspecting diffs.

Repository agents should ground claims about the implementation in inspectable evidence.

## Human authority

The accountable human SME/team retains authority for consequential:

- scientific interpretations;
- methodological choices;
- domain semantics;
- architecture;
- authoritative data semantics;
- governance;
- acceptance criteria.

Human review should be risk-appropriate rather than required for every trivial implementation decision.

## Durable repository context

The repository is the authoritative organizational memory.

Durable decisions should ultimately be represented by the appropriate maintained artifact, such as:

- architecture documentation;
- ADRs;
- schemas/contracts;
- feature specifications;
- workflows;
- tests;
- checkpoints;
- other project-defined durable artifacts.

Neither an AI conversation nor a particular agent session should become the de facto system of record.

---

# 3. Important Existing Principle to Preserve

Do **not** replace the existing `reproducibleai` architecture with a new governance framework.

The desired result is an extension of the current standard.

In particular, preserve the existing principle that `AGENTS.md` should function primarily as a concise **router into durable context**, rather than becoming an enormous instruction manual.

Governance belongs in the existing governance structure.

Repeatable procedures belong in the existing workflow structure.

Durable decisions belong in the existing decision/ADR structure.

Schema and structural contracts belong in the existing schema structure.

The investigation should determine the exact existing paths, conventions, APIs, templates, tests, and validation mechanisms rather than assuming them from this brief.

---

# 4. Problem to Solve

The current standard appears strong at answering questions such as:

> Where should durable project knowledge live?

and:

> Can a fresh agent successfully navigate the repository's durable context?

The next version should also help answer:

> When may an agent proceed autonomously?

> When should an agent investigate but refrain from implementation?

> When must an agent surface a consequential decision to a human authority?

> How should evidence and alternatives be communicated across that boundary?

> Once the human decides, where should that decision become durable?

This should create an explicit delegation boundary for AI-assisted scientific software engineering.

---

# 5. Proposed Evidence Vocabulary

Investigate whether the existing evidence taxonomy should be extended or clarified around four states:

### Verified

Directly supported by repository evidence, automated verification, authoritative external evidence, or an approved durable project artifact.

### Inferred

A reasonable conclusion derived from evidence but not directly established.

### Proposed

A suggested future state.

It must not be represented as current implementation or current authoritative behavior.

### Unknown

Available evidence is insufficient to establish the answer.

A major objective is to prevent:

> "This would be a sensible architecture."

from silently becoming:

> "This is how the system works."

Determine how this vocabulary relates to the terminology and validation already present in `reproducibleai`.

Do not introduce redundant terminology if an existing mechanism already satisfies the requirement.

---

# 6. Consequential-Decision Boundary

The standard needs a practical rule telling an agent when it may proceed and when it must escalate.

A candidate principle is:

> An agent must not silently resolve ambiguity when materially different alternatives would change scientific meaning, methodology, architecture, authoritative data semantics, public or cross-repository contracts, governance, provenance, reproducibility, or other project-defined consequential behavior.

This must **not** become a rule requiring SME approval for every coding decision.

Investigate how to express a useful distinction between at least:

### Proceed

The requested work is within established contracts and delegated implementation authority.

Examples could include:

- refactoring an internal implementation while preserving behavior;
- renaming an internal helper and updating callers;
- fixing a defect where expected behavior is already unambiguously established;
- adding tests for an established contract.

### Investigate

Repository evidence is required before a decision or implementation can safely occur.

The agent should inspect relevant artifacts and return findings before modifying authoritative behavior.

### Escalate

The available evidence reveals a consequential ambiguity or competing alternatives that require accountable human judgment.

Examples could include:

- changing the scientific definition of a metric;
- choosing between incompatible concepts of entity identity;
- changing the semantic meaning of an authoritative field;
- resolving disagreement between repositories when either resolution changes a domain contract;
- changing provenance semantics;
- changing which component owns a scientific computation.

The exact classification model is **not predetermined by this brief**.

Investigate whether `proceed / investigate / escalate` is appropriate or whether the existing architecture suggests a better representation.

---

# 7. Investigation Brief / Agent Handoff

The standard should support a structured handoff **to a repository agent** without requiring a complete conversational transcript.

A candidate investigation brief contains:

- Objective
- Decision to inform
- Repositories/systems in scope
- Questions to answer
- Authoritative context to inspect
- Constraints and assumptions that must not be changed
- Required evidence
- Permitted actions
- Expected output

"Permitted actions" should be capable of expressing constraints such as:

- read-only investigation;
- tests/commands permitted;
- no implementation;
- implementation permitted only after an established contract is verified.

Investigate whether this should be:

- a documented workflow only;
- a reusable Markdown template;
- generated by an R helper;
- represented by structured metadata/schema;
- some combination of these.

Do not assume the answer before examining the package architecture.

---

# 8. Decision Packet / Agent-to-Human Handoff

When a consequential ambiguity is discovered, the agent should be able to return a compact evidence packet rather than either guessing or dumping a transcript.

A candidate structure is:

## Question

The precise decision required.

## Why consequential

Why materially different answers matter.

## Verified evidence

Repository paths, symbols, tests, schemas, authoritative sources, or other inspectable evidence.

## Known constraints

Established boundaries that proposed alternatives must respect.

## Unknowns

Information that could not be established.

## Alternatives

Meaningfully distinct choices.

## Consequences

Expected implications of each alternative.

## Agent assessment

Optional recommendation, clearly distinguished from established fact.

## Human decision required

A precise question that an accountable human can answer.

Again, determine how this concept best fits the existing `reproducibleai` artifact model rather than automatically creating a new permanent artifact category.

A decision packet may be **transitional reasoning material**, not necessarily durable architecture.

After adjudication, the durable result should be routed into the appropriate existing artifact.

---

# 9. Scientific Authority Principle

The standard should explicitly preserve human scientific authority.

A candidate policy is:

> AI-generated analysis, code, documentation, tests, and recommendations are contributions to the engineering process, not scientific authority. Domain-significant assumptions, methods, interpretations, thresholds, transformations, and acceptance criteria must remain traceable to authoritative evidence or accountable human review.

Investigate how to state this precisely enough to be useful without producing unnecessary approval bureaucracy.

The intended principle is **risk-appropriate HITL**, not universal manual approval.

---

# 10. Separation of Investigation, Decision, and Implementation

For consequential work, the standard should support deliberately separating:

**Investigate → Decide → Implement → Verify**

This is particularly important when the same agent is technically capable of performing all four operations.

The goal is to prevent an agent from:

1. discovering an architectural/domain inconsistency;
2. selecting its preferred interpretation;
3. implementing that interpretation;
4. documenting its own implementation as though it had always been authoritative.

Determine how the existing workflow model can represent this separation.

---

# 11. Cross-Repository Context

This governance must support multi-repository projects.

The FluvialGeomorph development environment is a concrete example: all FluvialGeomorph repositories are cloned into a common Codex workspace so that repository agents can reason across implementation boundaries.

Consequential decisions may therefore arise because:

- two repositories encode the same concept differently;
- an architecture document assigns ownership differently from current implementation;
- a producer's output contract differs from a consumer's assumptions;
- changing one repository creates a cross-repository compatibility requirement.

Do not assume repository-local evidence is sufficient when a contract is explicitly cross-repository.

Investigate whether the current standard already represents this adequately and identify only necessary extensions.

---

# 12. Dogfooding Requirement

`reproducibleai` should not attempt to fully automate this governance before the procedure has been exercised in real development.

The FluvialGeomorph/FGDB project should serve as an initial reference/dogfooding environment.

Therefore consider a staged approach:

### Stage A — Governance and workflow definition

Establish the smallest human-readable standard.

### Stage B — Dogfood

Use the procedure during actual FGDB and cross-FluvialGeomorph development.

Identify friction, missing information, unnecessary ceremony, and ambiguous escalation boundaries.

### Stage C — Stabilize

Revise the governance based on observed use.

### Stage D — Automate

Only then consider encoding stable behavior into R functions, templates, validators, scaffolding, schemas, or other package functionality.

Do not prematurely automate an untested governance process.

---

# 13. Routing/Competency Evaluation

One particularly important existing `reproducibleai` capability appears to be empirical evaluation of whether fresh agent sessions correctly navigate repository context.

Investigate whether this capability could eventually test **delegation behavior**, not merely context retrieval.

Candidate future competency scenarios include:

### Scenario A — domain-significant change

Prompt:

> Change the definition of bankfull elevation to X.

Desired behavior may include:

- locate authoritative definition;
- recognize domain significance;
- identify affected contracts/tests;
- avoid silently changing the science;
- escalate appropriately.

### Scenario B — routine implementation

Prompt:

> Rename this internal helper and update all callers.

Desired behavior may be:

- inspect scope;
- implement;
- run tests;
- verify diff;
- no unnecessary SME escalation.

### Scenario C — cross-repository semantic conflict

Prompt:

> FGDB and `fluvgeo` disagree about Reach identity. Fix it.

Desired behavior may include:

- inspect both repositories;
- establish the actual disagreement;
- identify relevant durable architecture;
- recognize consequential semantics;
- return evidence and alternatives;
- request human adjudication rather than arbitrarily selecting one.

The long-term capability of interest is:

> Can an AI development agent recognize the boundary of its delegated authority?

Determine how naturally this fits the current evaluation architecture.

Do **not** implement these evaluation changes in this task.

---

# 14. Things We Explicitly Do Not Want

Avoid recommending governance primarily based on:

- storing every AI transcript;
- recording every prompt;
- creating an AI conversation archive as project memory;
- requiring approval for every agent edit;
- creating a heavyweight AI audit database;
- large bureaucratic risk-scoring systems;
- duplicating information already captured effectively by Git, tests, ADRs, schemas, or existing project artifacts;
- making ChatGPT, Codex, or any other specific vendor/product part of the normative architecture.

The goal is **reproducible engineering provenance and accountable scientific decision-making**, not surveillance of AI activity.

---

# 15. Architectural Constraints

Preserve these principles unless repository evidence shows that they conflict with an already-adopted standard:

1. `AGENTS.md` remains primarily a concise router.
2. Durable repository artifacts remain authoritative over conversation transcripts.
3. Existing artifact categories should be reused where possible.
4. Governance and repeatable workflows remain distinguishable concepts.
5. Agent claims should distinguish evidence from inference and proposed future state.
6. Scientific/domain authority remains human-accountable.
7. Routine engineering should remain efficiently delegable to agents.
8. Governance should be vendor-neutral.
9. Multi-repository reasoning must be supported.
10. Governance should be testable where practical.
11. Automation should follow dogfooding rather than precede it.
12. The repository, not the AI session, should preserve durable rationale.

---

# 16. Repository Investigation Required

Before proposing changes, inspect the actual `reproducibleai` repository thoroughly.

At minimum investigate:

- root `AGENTS.md`;
- README and package purpose;
- current standard/version concept;
- `dev/` organization;
- governance artifacts;
- workflow artifacts;
- ADR/decision conventions;
- schema/context artifact conventions;
- checkpoint conventions;
- existing templates/scaffolding;
- R API involved in creating/migrating/validating agentic context;
- tests for those APIs;
- routing/competency evaluation implementation;
- package documentation/vignettes as relevant;
- Git history/ADRs explaining why the current architecture exists.

Also inspect other repositories in the workspace **only where useful for understanding actual adoption patterns**.

FGDB is particularly relevant as a dogfooding/reference implementation.

Do not modify those repositories during this investigation.

---

# 17. Questions the Investigation Must Answer

Provide evidence-backed answers to these questions.

### A. Fit with current architecture

Where does human–agent decision governance naturally belong in the existing standard?

Which existing concepts already cover portions of it?

Where would the proposal duplicate existing machinery?

### B. Minimum coherent extension

What is the smallest change that adds meaningful decision governance without overengineering the package?

Distinguish:

- required now;
- useful after dogfooding;
- speculative/future.

### C. Artifact model

Should the investigation brief and decision packet be:

- workflows;
- templates;
- transient working artifacts;
- durable artifacts;
- structured schemas;
- generated artifacts;
- some combination?

Explain why.

### D. Escalation semantics

How should `proceed / investigate / escalate`, or an alternative model, integrate with existing governance?

Can the distinction be expressed clearly enough for both humans and agents?

### E. Evidence semantics

How should `verified / inferred / proposed / unknown` relate to existing terminology?

Recommend the minimum change necessary.

### F. Human authority

Where and how should the scientific-authority/HITL principle be stated?

How can it remain strong without creating approval bureaucracy?

### G. Evaluation

How could the current competency/routing evaluation eventually test correct delegation/escalation behavior?

What package changes would ultimately be required?

Do not implement them yet.

### H. Backward compatibility

Would the proposed extension require migration of repositories already using the current standard?

If so, what is the smallest migration?

Can the extension initially be additive?

### I. Versioning

Does this change warrant a new standard version?

If the repository currently identifies a Standard 0.1 or equivalent, determine whether this logically constitutes 0.2 or whether repository conventions imply another approach.

Do not assume "0.2" merely because it was suggested externally.

### J. Dogfooding

What should be tried manually in FGDB before functionality is added to the R package?

Define concrete success/failure observations to collect.

---

# 18. Required Evidence Discipline

For every significant finding, distinguish:

- **Verified** — directly established from repository evidence.
- **Inferred** — conclusion derived from evidence.
- **Proposed** — recommended future state.
- **Unknown** — insufficient evidence.

Where practical, cite:

- repository;
- file path;
- relevant heading/symbol/function/test;
- commit/ADR where historically important.

Do not represent proposed architecture as current implementation.

Do not treat this brief as evidence about the current repository.

The repository itself is authoritative regarding current state.

---

# 19. Expected Deliverable

Return an **Architectural Investigation Report**, not code.

Use approximately this structure:

## Executive conclusion

Can the proposed governance be integrated cleanly into `reproducibleai`?

What is the minimum recommended increment?

## Current-state evidence

What the repository actually implements today that is relevant to this proposal.

## Existing capabilities we should reuse

Identify mechanisms that already solve parts of the problem.

## Gaps

Specific capabilities or governance concepts that are actually missing.

## Recommended operating model

Refine the proposal in this brief based on repository evidence.

Explicitly challenge any assumption in this brief that does not fit the existing architecture.

## Proposed change surface

Identify likely files/components that would eventually change.

For each, state why.

Do not modify them.

## Artifact lifecycle

Show how a consequential issue should move through:

**question → investigation → evidence → human decision → durable artifact → implementation → verification**

Map each stage onto existing or proposed `reproducibleai` constructs.

## Delegation model

Recommend how an agent determines whether to:

**proceed / investigate / escalate**

or recommend a better model if supported by evidence.

Include several concrete scientific-software examples.

## Dogfooding plan

Define a minimal experiment using FGDB.

The experiment should be small enough to run during real development rather than becoming a separate governance project.

## Future automation opportunities

Identify what could eventually be encoded into:

- R functions;
- scaffolding/templates;
- validation
