# Local AI Architecture

Last updated: 2026-06-13

## Purpose
This document records the working architecture proposal for how `reproducibleai` should support governed AI-assisted development workflows across frontier-model and local-model environments.

It is the primary design-stage architecture document for Milestone G work on local and hybrid AI methodology.

This document is not the stable statement of current implemented package architecture. That role remains with `dev/10_design.md`.

Instead, this document captures the proposed direction, rationale, architecture layers, MCP-aware integration concepts, and implementation questions that may later be promoted into:
- `dev/10_design.md`
- `dev/decisions/`
- `dev/instructions/`
- package helpers and handlers in `R/`


## Quick orientation
The current working direction is:

- `reproducibleai` should support both frontier-model and local-model workflows
- the package should standardize a hybrid methodology rather than assume one universal runtime
- local workflows should be treated as governed workbenches rather than one-model replacements for hosted assistants
- canonical human-readable instructions should remain the semantic source of truth
- client-facing runtime artifacts should be derived from canonical instruction sources
- MCP should be treated as a preferred integration direction for governed resources, tools, and prompts

The current design work does not yet settle:

- exact rule derivation mechanics
- exact client adapter structure
- exact MCP deployment mechanics
- exact competency-question harness structure

For implementation work, the immediate priorities are:

- governed resource classification
- Continue runtime rule deployment
- first MCP-oriented capability design
- first competency-question evaluation path


## Relationship to governance artifacts

### `dev/10_design.md`
Use `dev/10_design.md` for the stable current-state architecture of the implemented package.

Use this document for the active architecture extension that is still being refined and validated.

### `dev/05_plan.md`
Use `dev/05_plan.md` for concrete follow-up work created by this architecture proposal, especially Milestone G.

### `dev/decisions/`
Use `dev/decisions/` for durable accepted choices about package scope, boundaries, and architecture direction.

ADR-0004 records the current proposed decision direction for this work:
- `dev/decisions/adr-0004-hybrid-ai-methodology-and-mcp-aware-integration.md`

### `dev/instructions/`
Use `dev/instructions/` for reusable instruction modules after this architecture has clarified how canonical source instructions, local runtime rules, and MCP-aware capabilities should relate to one another.

## Problem statement
`reproducibleai` was initially developed around governed, instruction-first workflows that performed well with hosted frontier-model platforms such as GitHub Copilot.

Subsequent experimentation with local tooling showed that the design problem is not merely how to run a local model.

The real design problem is how to help teams build a governed hybrid AI workbench that:
- supports both frontier and local workflows
- preserves repository-specific instructions and governed development artifacts
- improves local context awareness in a multi-repository R package ecosystem
- supports reusable workflow patterns across different clients and runtimes
- remains reviewable, reproducible, and governable

## Architecture position

### Hybrid methodology
`reproducibleai` should explicitly support both frontier-model and local-model workflows as first-class methodology targets.

The package should not define success as replacing hosted assistants with one local model.

Instead, it should define success as helping teams build governed hybrid workflows in which:
- frontier systems are used where they are the best fit
- local systems are used where they are the best fit
- repository-specific instructions and governed artifacts remain central
- evaluation is explicit rather than anecdotal
- workflow choices are reviewable and reproducible

### Local workflows as governed workbenches
The package should treat local workflows as governed workbenches rather than as one-model replacements for hosted assistants.

This means the architecture should explicitly account for:
- model roles
- context selection
- runtime rule design
- workflow modes
- evaluation
- integration

Hosted frontier platforms should be understood as integrated systems whose quality depends not only on model quality, but also on:
- retrieval and ranking
- tool access
- context management
- workflow shaping
- editor integration
- hidden platform behavior

For that reason, one-model parity is the wrong design target for local workflow architecture.

### Non-goals
`reproducibleai` should not attempt to become:
- a general-purpose AI runtime
- a code editor or IDE client
- a generic model serving framework
- a generic retrieval platform
- a generic agent runtime
- a generic MCP platform

Instead, it should focus on:
- governed instruction architecture
- hybrid workflow methodology
- client-facing runtime rule derivation and deployment
- repository-governed AI context conventions
- evaluation and competency-question design
- integration patterns for external tools and protocols

## Why this direction

### Industry alignment
The current architecture direction is aligned with emerging industry practice in several important ways.

Modern AI development workflows increasingly behave as multi-layer systems rather than as single-model experiences. Workflow quality depends not only on model quality, but also on retrieval, tool access, context selection, workflow shaping, evaluation, and client integration.

Workspace-local runtime rules are now a standard pattern in at least some major AI coding clients. This supports separating canonical human-readable instruction sources from client-facing runtime rule artifacts.

Explicit integration standards such as MCP provide a better solution to structured context and tool access than trying to encode all project knowledge directly into prompt text alone.

Evaluation is also becoming a first-class concern. Teams increasingly need repeatable workflow checks rather than relying only on anecdotal impressions of whether one AI setup “feels better” than another.

These signals support the current direction of `reproducibleai` as a methodology, governance, derivation, deployment, and evaluation layer rather than as a new AI runtime.

### Shortcomings matrix

| Frontier workflow strength or shortcoming | Why it matters | Can a local or hybrid system address it? | Required response from `reproducibleai` |
|---|---|---|---|
| Frontier systems often feel like one assistant that can handle many tasks | This creates the false expectation that one local model should perform equally well across planning, explanation, editing, and repository analysis | Only partially | Explicitly teach that AI workflows are multi-layer systems, not single-model substitutes |
| Frontier systems often provide stronger default reasoning and better ambiguity handling | Teams may misdiagnose local-system weaknesses as “bad prompting” when the issue is actually capability mismatch or poor system design | Only partially | Define realistic success criteria for local workflows and separate architecture quality from raw model quality |
| Hosted tools can be weak at durable repository-specific workflow compliance | Important team instructions and governed repo artifacts may not be followed consistently | Yes | Standardize repository-governed instruction systems and workspace runtime rules |
| Hosted tools may be less transparent about why behavior changed | This weakens reproducibility, auditability, and reviewer confidence | Yes | Favor explicit architecture layers, explicit rules, and explicit evaluation |
| Cloud dependence can conflict with governance, security, or infrastructure constraints | Teams may need local/private workflows even when hosted tools are stronger in general reasoning | Yes | Support local and hybrid workflows as first-class package targets |
| Hosted workflows may not exploit local repository design artifacts as effectively as a tuned local system could | Teams want better use of local files, rules, schemas, plans, and design docs | Yes | Treat local context awareness as a core design target and evaluation objective |
| Long modular instructions written for frontier systems may overload smaller local models | Local performance can degrade when instruction mass competes with task context | Yes | Introduce rule-tier architecture and local-adapted runtime rule variants |
| Large always-on instruction sets can reduce local-model usefulness | Local systems often need smaller active prompts and more deliberate task scoping | Yes | Standardize a small core rule layer plus conditional overlays |
| Broad workspace context can reduce answer quality when irrelevant files dominate the prompt | Context awareness is useful only when relevant context is selected well | Yes | Standardize task-specific context strategies and competency-based evaluation |
| Explanation, editing, planning, and refactoring are not the same task | One interface should not imply one optimal model, rule set, or workflow mode | Yes | Define workflow modes and best-bet task routing rather than pretending one workflow fits all cases |

### Key architecture conclusions
The current design work supports the following conclusions:

1. `reproducibleai` should standardize a hybrid AI methodology rather than assume hosted-only, local-only, or one-model-parity workflows.
2. Local workflows should be treated as governed workbenches with explicit design for model roles, context strategy, rule tiers, workflow modes, evaluation, and integration.
3. Local context awareness is a major package opportunity and should be treated as a primary optimization target.
4. The package should distinguish raw model capability from workflow architecture quality.
5. The package should optimize for selective superiority in governance, privacy, reviewability, and repository grounding rather than universal parity with hosted frontier systems.

## Proposed architecture layers

`reproducibleai` should standardize local and hybrid AI methodology across six architecture layers.

### 1. Model layer
The architecture should distinguish between different model roles rather than assuming one model should do everything.

The package methodology should assume that tasks such as:
- explanation
- planning
- editing
- autocomplete
- summarization
- repository analysis

may be better served by different model roles, runtime settings, or clients.

The package does not need to hard-code one universal model strategy, but it should explicitly teach model-role separation as a best practice.

### 2. Context layer
The architecture should standardize deliberate context selection.

The package should teach that better context is often more important than more context, especially for local models.

Recommended context patterns should include:
- current file only
- selected text plus current file
- current file plus one or two directly related files
- working file plus governed repository artifact such as:
  - `dev/10_design.md`
  - `dev/05_plan.md`
  - `dev/40_schemas.md`
  - relevant instruction or rule files

The package should discourage indiscriminate broad workspace injection as a default workflow.

### First-pass governed AI context resource classification
The architecture now needs a stable first-pass classification for repository artifacts that should be treated as governed AI context.

This classification is intended to support:
- context selection guidance for local and hybrid workflows
- later runtime-artifact derivation work
- future MCP resource exposure
- competency-question-based evaluation of whether workflows are using the right repository context

The first-pass governed resource set is:

| Artifact | Primary role | Typical use in AI workflows | Default context posture |
|---|---|---|---|
| `dev/05_plan.md` | active planning and next-step control | identify current priorities, determine smallest useful next step, align work with active milestone scope | task-conditional but frequently relevant |
| `dev/10_design.md` | stable current architecture and package boundaries | answer questions about implemented architecture, invariants, and current supported package behavior | high-priority governance context for architecture and implementation tasks |
| `dev/40_schemas.md` | structural contracts and explicit data or object expectations | validate assumptions about package structures, result objects, file conventions, and other maintained schemas | high-priority when touching structured package behavior |
| `dev/decisions/` | durable decision provenance and scope boundaries | confirm accepted or proposed architectural direction, non-goals, and rationale before extending package behavior | task-conditional but high-value for architectural changes |
| `dev/instructions/` | active repository-specific behavioral guidance | govern chat behavior, development workflow expectations, and module-specific instruction constraints | high-priority session-governance context |

This classification distinguishes several context roles that should remain conceptually separate:

- **behavioral governance context**
  - instructions that shape how the AI assistant should behave in the repository
  - currently centered on `dev/instructions/`
- **stable architectural context**
  - documents that describe implemented architecture and package boundaries
  - currently centered on `dev/10_design.md`
- **planning context**
  - documents that define active priorities and work sequencing
  - currently centered on `dev/05_plan.md`
- **structural contract context**
  - documents that define explicit schemas, result shapes, and maintained structural assumptions
  - currently centered on `dev/40_schemas.md`
- **decision provenance context**
  - documents that explain why specific architectural directions were chosen or proposed
  - currently centered on `dev/decisions/`

This classification also implies a basic selection rule for local and hybrid workflows:

- do not inject all governed artifacts into every task by default
- always prefer the smallest context set that preserves correctness and governance fidelity
- include `dev/instructions/` when behavioral constraints matter
- include `dev/10_design.md` when the task touches current implemented architecture
- include `dev/05_plan.md` when the task requires prioritization or milestone alignment
- include `dev/40_schemas.md` when the task depends on structural correctness or schema assumptions
- include `dev/decisions/` when the task depends on rationale, scope boundaries, or proposed architectural direction

The distinction between governed repository resources and client-facing runtime artifacts should remain explicit.

Governed repository resources are durable source context assets. Runtime artifacts are derived deployment outputs intended for direct use by AI clients. A repository document such as `dev/10_design.md` is not itself a runtime rule, even if it later informs one.

### 3. Rule layer
The architecture should standardize rule tiers.

The package should distinguish between:
- **core rules**
  - short, always-on, cross-cutting constraints
- **task overlays**
  - domain- or workflow-specific runtime rules used only when relevant
- **source instructions**
  - canonical human-readable reviewed instructions that serve as the source of truth
- **local-adapted runtime rules**
  - compressed or operationalized variants derived from canonical source instructions for use in local client rule systems

This distinction should become a formal part of package methodology rather than an ad hoc practice.

### 4. Workflow layer
The architecture should standardize workflow modes instead of assuming one generic chat protocol is sufficient.

Candidate workflow modes should include:
- explain current file
- compare options before editing
- review before drafting
- draft replacement text
- analyze repository design
- prepare governed documentation updates
- evaluate task fit for hosted vs local execution

The package should help teams define and reuse these modes consistently.

### 5. Evaluation layer
The architecture should make evaluation a first-class concern.

AI workflow quality should be evaluated with repeatable competency questions rather than anecdotal impressions alone.

Evaluation should focus on questions such as:
- does the workflow use the intended repository context correctly?
- does it follow the applicable rules reliably?
- does it produce useful and reviewable outputs?
- does it choose an appropriate workflow mode for the task?
- where does local outperform hosted, and where does it not?

This evaluation model should become part of the package’s methodology and testing approach.

### 6. Integration layer
The architecture should explicitly define how governed repository capabilities are exposed to AI clients and external workflow components.

This layer should include:
- client-specific runtime rule deployment
- MCP-aware exposure of resources, tools, and prompts
- integration boundaries between package-governed artifacts and external AI systems
- trust and deployment assumptions for local and hybrid integrations

The integration layer is where `reproducibleai` should connect its governed internal artifacts to external AI tooling without becoming a generic AI platform itself.

## MCP-aware package architecture

### Role of MCP
MCP should be treated as a preferred integration standard in the package architecture.

In this architecture, MCP is not the model, and it is not the client.

It is the integration boundary through which AI clients can access governed capabilities.

For `reproducibleai`, the most relevant MCP roles are:
- **resources**
  - governed repository artifacts and structured context sources
- **tools**
  - callable actions related to repository inspection, instruction handling, validation, derivation, and package-ecosystem workflows
- **prompts**
  - reusable workflow entrypoints and task templates aligned with package methodology

MCP is a strong fit for:
- multi-repository R package ecosystems
- governed design and schema artifacts
- cross-repo API understanding
- reusable workflow patterns
- structured local context delivery

### External tools to leverage
`reproducibleai` should explicitly leverage existing best-of-breed tools where they fit the architecture.

Initial examples include:
- **Continue**
  - as a client integration target for workspace-local rules, local and hybrid model use, and MCP-aware workflows
- **MCP**
  - as an integration standard for exposing governed resources, tools, and prompts
- **existing package tests and linters**
  - for machine-checkable concerns that should not be enforced only through prompt instructions
- **existing local model runtimes**
  - such as Ollama, rather than custom model-serving logic inside the package

The package should prefer integration and specialization over reinvention.

### Core package concepts
The package architecture should distinguish at least five MCP-aware concepts:

1. **Canonical instruction sources**
   - reviewed human-readable source materials that define team workflow expectations
   - currently centered on `inst/instructions/*.md`

2. **Runtime rule artifacts**
   - client-facing artifacts intended for direct AI runtime use
   - for example Continue workspace rule files or future client-specific runtime rule bundles

3. **Governed repository resources**
   - repository artifacts treated as governed context inputs for AI workflows
   - including plan, design, schema, decisions, instructions, package metadata, and package/API summaries

4. **Governed tools**
   - bounded, inspectable actions aligned with package methodology
   - for example listing governed artifacts, resolving instruction recipes, validating runtime artifacts, or summarizing API relationships

5. **Workflow prompts and templates**
   - reusable workflow entrypoints aligned with package methodology
   - for example design analysis, governed update drafting, rule preparation, and task-fit evaluation

### Mapping to MCP roles
These package concepts align naturally with MCP.

#### MCP resources
Natural candidates include:  
- governed repository resources
- package-generated summaries of architecture, schema, or API state
- selected canonical instruction sources when they are useful as structured context

#### MCP tools
Natural candidates include:  
- governed tools
- validation helpers
- derivation helpers
- repository analysis helpers
- cross-repo API inspection helpers

#### MCP prompts
Natural candidates include:  
- workflow prompts and templates
- standardized task entrypoints for governed repository work
- hybrid workflow routing prompts

This mapping suggests that MCP is a strong fit for how `reproducibleai` should expose governed capabilities to compatible clients.

### Recommended package abstractions
The package likely needs a small abstraction layer beyond the current instruction-handler model.

Candidate abstraction families include:

1. **Source abstractions**
   - represent canonical instruction modules and recipes as governed source assets
   - responsibilities may include source discovery, provenance tracking, recipe membership, and source-to-derived-artifact traceability

2. **Runtime artifact abstractions**
   - represent client-facing runtime artifacts as derived deployment targets
   - responsibilities may include target client type, derivation metadata, deployment location, overwrite behavior, and source linkage

3. **Governed resource abstractions**
   - classify repository artifacts that should be treated as governed AI context
   - responsibilities may include artifact type classification, inclusion rules, context packaging rules, and future MCP resource exposure

4. **Capability abstractions**
   - represent reusable methodology-aware actions and prompts
   - responsibilities may include capability type, required inputs, allowed outputs, deployment target, and evaluation hooks

5. **Integration adapter abstractions**
   - isolate client- and protocol-specific deployment behavior from core package logic
   - early candidates include a Continue runtime rule adapter and an MCP-aware integration adapter

These abstractions should prevent Continue-specific or MCP-specific details from leaking across the whole package design.

## First implementation slice
The following items are the intended first implementation targets. They translate the current architecture direction into an initial practical work sequence without attempting to build the full system at once.

### 1. Governed resource classification
Define the first explicit package convention for which repository artifacts count as governed AI context.

This should likely start with:  
- `dev/05_plan.md`
- `dev/10_design.md`
- `dev/40_schemas.md`
- `dev/decisions/`
- `dev/instructions/`

### 2. Continue runtime rule deployment
Define the first formal package support for deploying workspace-local Continue runtime rules derived from canonical instruction sources.

### 3. MCP-oriented capability design
Define the first conceptual set of:  
- MCP resources
- MCP tools
- MCP prompts

The first iteration may be documented or scaffolded before it is fully package-deployed.

### 4. Competency-question evaluation
Define at least one evaluation path that tests whether:  
- governed resources are usable as intended
- runtime rules reflect the intended instruction source
- the workflow improves local context awareness in a measurable way

This first implementation slice should prioritize architecture clarity and methodological value over breadth.

## Remaining implementation questions

### 1. Rule derivation mechanics
Open implementation questions:  
- which parts of local-rule derivation can be automated safely
- which parts require mandatory human editing or approval
- how derivation lineage should be recorded

### 2. Client support sequence
Open implementation questions:  
- what the first Continue-specific scaffolding should include
- how client-specific runtime artifacts should be abstracted so later clients can be supported without redesign

### 3. MCP deployment pattern
Open implementation questions:  
- which governed resources should be exposed first through MCP
- which tools should be exposed first through MCP
- which prompts or workflow templates belong in MCP versus static instruction modules
- whether MCP helpers should be generated by the package, documented by the package, or both

### 4. Evaluation harness design
Open implementation questions:  
- how competency questions should be represented in package tests
- what fixtures and scoring conventions should be used
- how local-context-aware behavior should be tested consistently
- how MCP-enabled workflows should be evaluated alongside non-MCP workflows

### 5. Recipe and deployment structure
Open implementation questions:  
- whether frontier-oriented and local-oriented workflows should be represented as separate recipe families
- how hybrid workflow guidance should be exposed to users
- how much deployment logic belongs in handlers versus supporting helpers
- whether MCP-aware capabilities should be treated as a separate config-aware package capability

These questions should be resolved incrementally through Milestone G work rather than by expanding the architecture spec prematurely.

## Risks and constraints
The package should explicitly manage the following risks:

1. **Overbuilding abstractions too early**
   - The package should not create a heavy internal framework before the first deployment patterns are validated.

2. **Duplicating mature external tooling**
   - The package should prefer integration with existing clients, runtimes, and protocols over reimplementation.

3. **Losing traceability between reviewed source instructions and deployed runtime artifacts**
   - This would undermine governance and reviewer confidence.

4. **Treating MCP as equivalent to runtime rules**
   - MCP and runtime rules solve different problems and should remain conceptually distinct.

5. **Letting client-specific details dominate the package core**
   - Continue and MCP are important, but the package should retain a methodology-centered core rather than becoming client-bound.

## Current status and promotion path
The current proposed package direction is:
- support for both frontier and local workflows as first-class methodology targets
- hybrid best-bet task routing rather than one universal runtime
- canonical human-readable instruction sources as the semantic source of truth
- derived local-runtime rule artifacts
- workspace-local runtime rule deployment beginning with Continue
- formal rule tiers
- formal workflow modes
- competency-question-based evaluation
- MCP-aware integration for governed resources, tools, and prompts

This direction is now reflected in:
- `dev/15_local_ai_architecture.md` as the working architecture proposal
- `dev/05_plan.md` Milestone G as the active work plan
- `dev/decisions/adr-0004-hybrid-ai-methodology-and-mcp-aware-integration.md` as the proposed architectural decision

The following items are still considered implementation-stage questions rather than settled architecture:
- rule derivation mechanics
- client adapter structure
- MCP deployment mechanics
- competency-question harness structure
- recipe and deployment structure

Stable outcomes from the Milestone G work may later require promotion into:
- `dev/10_design.md`
- accepted ADR updates in `dev/decisions/`
- updated instruction modules in `inst/instructions/` and `dev/instructions/`
- package helpers and handlers in `R/`

Until that promotion occurs, this document should be treated as the main context document for continuing local and hybrid AI architecture implementation work.
