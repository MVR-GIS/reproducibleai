# Local AI Architecture

Last updated: 2026-06-13

## Purpose
This document defines the proposed architecture direction for how `reproducibleai` should support AI-assisted development workflows across both frontier-model and local-model environments.

`reproducibleai` is an opinionated package intended to help standardize emerging best practice for a USACE data science team. It should therefore do more than install instruction files. It should help teams adopt governed, reviewable, reproducible AI workflows that are realistic about the strengths and limits of different AI platforms.

This document establishes the current architecture proposal for that work.

It is stronger than exploratory notes, but not yet the final canonical statement of stable package architecture. Stable conclusions from this document may later be promoted into:
- `dev/10_design.md`
- `dev/05_plan.md`
- `dev/decisions/`
- `dev/instructions/`

## Relationship to existing governance artifacts

### `dev/10_design.md`
Use `dev/10_design.md` for stable current-state package architecture and accepted operating assumptions.

This document is the design-stage architecture proposal that will feed future updates to `dev/10_design.md` once the proposed local and hybrid workflow model has been validated.

### `dev/05_plan.md`
Use `dev/05_plan.md` for concrete implementation work created by this architecture proposal.

### `dev/decisions/`
Use `dev/decisions/` when a durable architecture or methodology choice from this document has been accepted and should be preserved with explicit rationale and alternatives.

### `dev/instructions/`
Use `dev/instructions/` for reusable chat and developer instruction modules after this architecture has clarified how frontier-oriented instructions, local-adapted runtime rules, and client-specific rule artifacts should relate to one another.

## Problem statement
`reproducibleai` was initially developed around modular instruction workflows that performed well with hosted frontier-model platforms such as GitHub Copilot.

Subsequent experimentation with a local stack using:
- Podman
- Ollama
- Continue
- local rules
- local repository context

demonstrated that a local system should not be treated as a drop-in one-model replacement for a hosted frontier platform.

The design problem is not merely how to run a local model.

The real design problem is how to help teams build a governed AI workbench that:
- supports both frontier and local workflows
- preserves the strengths of modular instruction systems
- improves local context awareness and repository grounding
- supports IT-managed and no-cloud environments where needed
- remains reviewable, reproducible, and governable
- guides users toward the right tool or workflow mode for the task

## Package position
`reproducibleai` should explicitly support both frontier-model and local-model workflows as first-class methodology targets.

The package should not define success as replacing hosted assistants with one local model.

Instead, it should define success as helping teams build a governed hybrid AI workflow in which:
- frontier systems are used where they are the best fit
- local systems are used where they are the best fit
- repository-specific instructions and governed artifacts remain central
- evaluation is explicit rather than anecdotal
- architecture and workflow choices are reviewable and reproducible

This package should therefore standardize methodology, structure, and evaluation more than it standardizes allegiance to any one runtime.

## Why this document is needed
The package already provides strong support for:
- modular instructions
- recipe-based composition
- reviewed static instruction text
- governed repository scaffolding

However, those strengths were established primarily in a frontier-model context.

The package does not yet fully define how the same instruction-first and governance-first philosophy should operate when:
- local models have different reasoning and context limits
- client-specific runtime rule systems are introduced
- users need to switch intentionally between hosted and local modes
- evaluation must distinguish between raw model quality and system-design quality

This document exists to close that gap by making the local and hybrid architecture explicit.

## Architecture position
The package should be designed around the assumption that hosted frontier platforms behave like integrated AI systems rather than like single interchangeable models.

Their apparent performance is shaped not only by model quality, but also by:
- retrieval and ranking
- tool orchestration
- context management
- editor integration
- workflow tuning
- hidden platform behavior

A local system should therefore not be modeled as:
- one model
- one editor integration
- one instruction set
- one universal workflow

A local system should instead be modeled as a governed workbench with explicit architecture for:
- model roles
- context selection
- rule activation
- workflow modes
- evaluation
- governance

## Industry gut-check

The current architecture direction is aligned with emerging industry practice in several important ways.

First, modern AI development workflows increasingly behave as multi-layer systems rather than as single-model experiences. In practice, workflow quality depends not only on model quality, but also on retrieval, tool access, context selection, workflow shaping, evaluation, and client integration.

Second, workspace-local runtime rules are now a standard pattern in at least some major AI coding clients. This supports the package direction of separating canonical human-readable instruction sources from client-facing runtime rule artifacts.

Third, explicit integration standards such as MCP increasingly provide a better solution to structured context and tool access than trying to encode all project knowledge directly into prompt text.

Fourth, evaluation is becoming a first-class concern. Teams increasingly need repeatable workflow checks rather than relying only on anecdotal impressions of whether one AI setup “feels better” than another.

These signals support the current direction of `reproducibleai` as a methodology, governance, derivation, deployment, and evaluation layer rather than as a new AI runtime.

This also clarifies an important boundary:

`reproducibleai` should adopt and integrate best-of-breed external tooling where appropriate instead of attempting to replace mature clients, tool protocols, or context delivery mechanisms.

## Non-goals

To keep the package architecture focused, `reproducibleai` should not attempt to become:

- a general-purpose AI runtime
- a code editor or IDE client
- a generic model serving framework
- a generic retrieval platform
- a generic agent runtime
- a generic MCP platform

Instead, the package should focus on:

- governed instruction architecture
- hybrid workflow methodology
- client-facing runtime rule derivation and deployment
- repository-governed AI context conventions
- evaluation and competency-question design
- integration patterns for external tools and protocols

## MCP in the proposed architecture

MCP should be treated as a preferred integration standard in the package architecture.

This is important because the design problem faced by `reproducibleai` is not limited to prompt wording or model selection. The package also needs a way to expose governed repository artifacts, reusable workflows, and structured actions to compatible AI clients in a standard, inspectable form.

In this architecture, MCP is not the model, and it is not the client.

It is the integration boundary through which AI clients can access governed capabilities.

For `reproducibleai`, the most relevant MCP roles are:

- **resources**
  - governed repository artifacts and structured context sources
- **tools**
  - callable actions related to repository inspection, instruction handling, validation, or derivation workflows
- **prompts**
  - reusable workflow entrypoints and task templates aligned with package methodology

This makes MCP a strong fit for:

- multi-repository R package ecosystems
- governed design and schema artifacts
- cross-repo API understanding
- reusable workflow patterns
- structured local context delivery

The package should therefore be designed so that its methodology, artifact structure, and future deployment helpers can support MCP-compatible exposure of governed capabilities.

This does not mean that `reproducibleai` should become a generic MCP platform.

It means the package should explicitly design for MCP-aware integration and should avoid architecture choices that would make MCP support difficult later.

## External tools to leverage rather than replace

The package should explicitly leverage existing best-of-breed tools where they fit the architecture.

Initial examples include:

- **Continue**
  - as a client integration target for workspace-local rules, local and hybrid model use, and MCP-aware workflows
- **MCP**
  - as an integration standard for exposing governed resources, tools, and prompts
- **existing package tests and linters**
  - for machine-checkable concerns that should not be enforced only through prompt instructions
- **existing local model runtimes**
  - such as Ollama, rather than custom model-serving logic inside the package

This architecture should prefer integration and specialization over reinvention.

## Observed design shift
The earlier working assumption was that a local stack could reproduce the apparent behavior of a hosted assistant by combining:
- one model
- one editor integration
- one rule system

That assumption is now rejected as the core design target.

The design target for `reproducibleai` should be a hybrid AI methodology that helps teams:
- choose the right workflow mode for the task
- deploy repository-governed instructions across different AI clients
- adapt frontier-oriented instruction systems into local-runtime rule systems
- evaluate AI workflow quality using explicit competency questions
- preserve durable development governance regardless of runtime choice

## Shortcomings matrix

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

## Architecture conclusions
The shortcomings matrix supports the following architecture conclusions.

### 1. `reproducibleai` should standardize a hybrid AI methodology
The package should support both:
- frontier-model workflows
- local-model workflows

It should also support intentional switching between them.

The package should not assume:
- hosted-only methodology
- local-only methodology
- one-model parity as the primary goal

Instead, it should standardize a hybrid methodology that helps teams choose the best-bet workflow for the task while preserving governance and reproducibility.

### 2. `reproducibleai` should treat local systems as governed workbenches
Local workflows should not be framed as one-model replacements for hosted assistants.

They should be framed as governed workbenches with explicit design for:
- model roles
- context strategy
- rule tiers
- workflow modes
- evaluation

### 3. `reproducibleai` should treat local context awareness as a major design opportunity
Local workflows are unlikely to consistently outperform frontier systems at general reasoning quality.

They may, however, outperform frontier systems in:
- governed repository grounding
- explicit use of local design artifacts
- repeatable workflow compliance
- transparent configuration
- private and infrastructure-constrained environments

For this package, local context awareness should therefore be treated as a primary optimization target rather than a secondary convenience.

### 4. `reproducibleai` should distinguish raw model capability from workflow architecture quality
When a local workflow performs poorly, the cause may be:
- model limitations
- rule overload
- weak context selection
- poor task framing
- wrong tool choice

The package should help users evaluate and improve system design rather than treating all failures as prompt problems.

### 5. `reproducibleai` should optimize for selective superiority rather than universal parity
The package should not promise that local workflows will match frontier platforms in every dimension.

Instead, it should help teams build workflows that are selectively better in areas such as:
- governance
- privacy
- reviewability
- explicit repository grounding
- controlled and reproducible workflow behavior

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

## Implications for instruction architecture

### Current package strength
`reproducibleai` already provides a strong foundation through:
- modular instruction text
- reviewed static canonical modules
- recipe composition
- governed installation into target repositories

### Required extension
To support local and hybrid workflows well, the package should extend that foundation to include:
- rule-tier classification
- local-runtime rule variants derived from canonical instruction sources
- client-specific workspace rule deployment
- workflow-mode guidance
- competency-question-based evaluation support

### Canonical source principle
The package should preserve one canonical human-readable instruction source wherever possible.

Frontier-ready instructions should remain the reviewed source of truth for developers and reviewers.

Local-runtime rule variants should be derived from those canonical sources rather than maintained as unrelated parallel documents.

This is necessary to preserve:
- governance
- readability
- reviewability
- semantic alignment across workflow modes

### Local-adapted derivation principle
The package should treat local-rule adaptation as a governed transformation problem.

The core design question is not whether local-adapted rules should exist. They should.

The remaining design question is how to derive them while preserving quality and reviewer confidence.

The package should therefore assume:
- derivation from canonical human-readable instructions is the desired model
- fully automatic derivation may not be sufficient in all cases
- human review and iterative refinement are likely to remain necessary
- any future automation should preserve transparent traceability to the canonical instruction source

## Implications for repository deployment

The package should standardize a three-part deployment distinction.

### 1. User-level AI client configuration
This layer should hold:
- endpoint definitions
- model declarations
- client-wide defaults
- behavior intended to apply across repositories

This layer should remain minimal and should not carry the full burden of repository-specific workflow governance.

### 2. Repository-level runtime rules
This layer should hold:
- workspace-specific runtime rules
- version-controlled local client artifacts
- repository-governed behavior tied to the local project

The first supported target for this layer should be Continue.

The architecture should remain extensible to additional clients later.

### 3. Repository-level human instruction sources
This layer should hold:
- richer reviewed source instructions
- architecture and workflow rationale
- governance-aligned human-readable materials that should not always be injected directly into runtime prompt context

This layer should be treated as the durable source material from which runtime rule artifacts may be derived or maintained.

## Proposed package direction

Based on the current analysis, `reproducibleai` should move toward the following package direction:

- support both frontier and local workflows as first-class methodology targets
- document hybrid best-bet task routing rather than requiring one universal runtime
- preserve canonical human-readable instruction sources
- support derived local-runtime rule variants
- scaffold workspace-local runtime rules beginning with Continue
- formalize rule tiers as part of package methodology
- formalize workflow modes as part of package methodology
- formalize competency-question-based evaluation as part of package methodology
- support MCP-aware integration as part of package methodology
- expose governed capabilities through external-tool-friendly architecture rather than prompt text alone

## First MCP-aware package architecture sketch

This section sketches the first concrete package architecture direction for incorporating MCP-aware integration into `reproducibleai`.

The goal is not to turn the package into a generic MCP platform.

The goal is to define the package concepts, boundaries, and first implementation slice needed to support governed AI workflows in a multi-repository R package ecosystem.

## Package responsibility boundary

`reproducibleai` should define and scaffold governed capabilities for AI-assisted development workflows.

It should not attempt to own all surrounding infrastructure.

In particular, the package should aim to:

- define canonical human-readable instruction sources
- derive or support derivation of client-facing runtime rule artifacts
- define governed repository context conventions
- define reusable workflow prompts and methodology patterns
- define evaluation structures for competency-question-based workflow testing
- support client- and protocol-aware deployment patterns where needed

It should not attempt to become:

- a generic MCP runtime host
- a general-purpose MCP server framework
- a code editor client
- a model-serving framework
- a generic retrieval engine
- a general agent orchestration platform

## Core MCP-aware package concepts

The package architecture should distinguish at least five core concepts.

### 1. Canonical instruction sources
These are the reviewed human-readable source materials that define team workflow expectations.

Current examples include:
- `inst/instructions/*.md`

These sources should remain:
- readable by humans
- reviewable in Git
- versioned with the package
- the semantic source of truth for derived workflow artifacts

### 2. Runtime rule artifacts
These are client-facing artifacts intended for direct AI runtime use.

Examples may include:
- Continue workspace rule files
- future client-specific runtime rule bundles

These artifacts should:
- be optimized for runtime behavior rather than long-form readability
- preserve traceability to canonical instruction sources
- support client-specific deployment without fragmenting the human-reviewed source of truth

### 3. Governed repository resources
These are repository artifacts that should be treated as governed context inputs for AI workflows.

Candidate examples include:
- `dev/05_plan.md`
- `dev/10_design.md`
- `dev/40_schemas.md`
- `dev/decisions/`
- `dev/instructions/`
- package metadata
- package API summaries derived from repository contents

These resources should be classified explicitly rather than discovered only through ad hoc prompt behavior.

### 4. Governed tools
These are bounded, inspectable actions aligned with package methodology.

Candidate examples include:
- list governed repository artifacts
- summarize current design state
- resolve instruction recipes
- compare canonical instructions with deployed runtime rules
- generate or validate client-facing rule artifacts
- derive package or cross-repo API summaries

These are methodology-aware capabilities rather than generic AI actions.

### 5. Workflow prompts and templates
These are reusable workflow entrypoints aligned with package methodology.

Candidate examples include:
- analyze repository design
- draft governed design updates
- prepare local runtime rules from canonical instructions
- evaluate hosted vs local task fit
- review repository context before proposing changes

These prompts and templates should be treated as reusable workflow assets rather than one-off chat phrasing.

## Mapping to MCP roles

These package concepts align naturally with MCP.

### MCP resources
The following package concepts are natural candidates for MCP resources:
- governed repository resources
- package-generated summaries of architecture, schema, or API state
- selected canonical instruction sources when they are useful as structured context

### MCP tools
The following package concepts are natural candidates for MCP tools:
- governed tools
- validation helpers
- derivation helpers
- repository analysis helpers
- cross-repo API inspection helpers

### MCP prompts
The following package concepts are natural candidates for MCP prompts:
- workflow prompts and templates
- standardized task entrypoints for governed repository work
- hybrid workflow routing prompts

This mapping suggests that MCP is not an incidental add-on. It is a strong fit for how `reproducibleai` should expose governed capabilities to compatible clients.

## Recommended package abstractions

The package likely needs a small abstraction layer beyond the current instruction-handler model.

Candidate abstraction families include:

### 1. Source abstractions
Purpose:
- represent canonical instruction modules and recipes as governed source assets

Possible responsibilities:
- source discovery
- provenance tracking
- recipe membership
- source-to-derived-artifact traceability

### 2. Runtime artifact abstractions
Purpose:
- represent client-facing runtime artifacts as derived deployment targets

Possible responsibilities:
- target client type
- derivation metadata
- deployment location
- overwrite/preservation behavior
- source linkage

### 3. Governed resource abstractions
Purpose:
- classify repository artifacts that should be treated as governed AI context

Possible responsibilities:
- artifact type classification
- inclusion rules
- context packaging rules
- future MCP resource exposure

### 4. Capability abstractions
Purpose:
- represent reusable methodology-aware actions and prompts

Possible responsibilities:
- capability type
- required repo inputs
- allowed outputs
- deployment target
- evaluation hooks

### 5. Integration adapter abstractions
Purpose:
- isolate client- and protocol-specific deployment behavior from core package logic

Candidate early adapters:
- Continue runtime rule adapter
- MCP-aware integration adapter

This abstraction should help prevent Continue-specific or MCP-specific details from leaking across the whole package design.

## Recommended first implementation slice

The package should begin with a narrow, high-value implementation slice rather than trying to implement the full architecture at once.

Recommended first slice:

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

even if the first iteration is only documented or scaffolded rather than fully deployed by the package.

### 4. Competency-question evaluation
Define at least one evaluation path that tests whether:
- governed resources are usable as intended
- runtime rules reflect the intended instruction source
- the workflow improves local context awareness in a measurable way

This first slice should prioritize architecture clarity and methodological value over breadth.

## Recommended near-term deployment stance

In the near term, `reproducibleai` should assume:

- local and hybrid AI workflows are real package targets
- Continue is the first supported runtime-rule client target
- MCP is the preferred protocol-level integration direction
- local deployment patterns are feasible and worth supporting
- the package should scaffold and document integration patterns before attempting to generalize them too aggressively

## Design risks to manage

The package should explicitly manage the following risks:

### 1. Overbuilding abstractions too early
The package should not create a heavy internal framework before the first deployment patterns are validated.

### 2. Duplicating mature external tooling
The package should prefer integration with existing clients, runtimes, and protocols over reimplementation.

### 3. Losing traceability between reviewed source instructions and deployed runtime artifacts
This would undermine governance and reviewer confidence.

### 4. Treating MCP as equivalent to runtime rules
MCP and runtime rules solve different problems and should remain conceptually distinct.

### 5. Letting client-specific details dominate the package core
Continue and MCP are important, but the package should retain a methodology-centered core rather than becoming client-bound.

## Architecture implication

This sketch implies that `reproducibleai` may need to evolve from an instruction-handler package into a broader governed AI workflow package with support for:

- canonical instruction sources
- derived runtime rule artifacts
- governed repository resource definitions
- reusable methodology-aware capabilities
- integration adapters
- competency-question evaluation structures

This is a meaningful expansion of scope, but it remains coherent with the package’s existing governance-first and instruction-first design principles.


## Remaining implementation questions

The major architecture direction is now clear enough to state strongly.

The remaining open questions are primarily implementation and packaging questions rather than core direction questions.

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


## Promotion targets

If subsequent experimentation supports this architecture direction, the following promotions should occur:

- update `dev/10_design.md` to include stable local and hybrid AI capability boundaries
- update `dev/05_plan.md` with a formal local-AI methodology milestone
- create a new ADR recording the decision to support hybrid frontier/local methodology with governed local runtime rule deployment
- update `dev/instructions/` and `inst/instructions/` to reflect rule-tier and derivation-aware architecture

## Immediate follow-up work

The next design and implementation work should likely include:

- refining the shortcomings matrix into a more explicit task-routing framework
- defining the first formal rule-tier taxonomy
- defining the first Continue-specific workspace rule deployment pattern
- designing the first competency-question evaluation structure
- identifying which existing instruction modules need local-adapted variants first

## Current proposal status

This document now serves as the package’s working architecture proposal for local and hybrid AI methodology.

It should be treated as the governing design draft for this topic until its stable conclusions are promoted into:
- `dev/10_design.md`
- `dev/05_plan.md`
- `dev/decisions/`
