# ADR-0004: Hybrid AI methodology and MCP-aware integration

## Status
Proposed

## Date
2026-06-13

## Context

`reproducibleai` was initially developed as an instruction-first package for governed AI-assisted workflows that performed well with hosted frontier-model platforms such as GitHub Copilot.

Through subsequent design work and experimentation, the package scope has broadened. The team now needs the package to address a more general problem:

- how to support governed AI-assisted development across both frontier-model and local-model environments
- how to preserve repository-specific instructions and governed development artifacts across those environments
- how to improve local context awareness in a multi-repository R package ecosystem
- how to support reusable workflow patterns without assuming one model or one client can perform all tasks equally well

The current architecture analysis concludes that local workflows should not be treated as drop-in one-model replacements for hosted assistants.

Instead, local workflows should be treated as governed workbenches whose quality depends on multiple layers such as:
- model role selection
- context selection
- runtime rule design
- workflow mode selection
- evaluation
- external integration

The architecture analysis also concludes that:

- `reproducibleai` should support both frontier and local workflows as first-class methodology targets
- the package should standardize a hybrid methodology rather than require one universal runtime
- repository-governed artifacts should remain central to AI workflow design
- MCP is a strong fit for exposing governed capabilities to compatible clients
- the package should integrate with best-of-breed external tools rather than attempt to replace them

At the same time, the design work also clarified important non-goals.

`reproducibleai` should not become:
- a generic AI runtime
- a code editor client
- a generic model serving framework
- a generic retrieval platform
- a generic MCP platform
- a general agent orchestration platform

The package already has a governance-first design with:
- canonical instruction text in `inst/instructions/`
- handler-based installation into repository `dev/instructions/`
- development-governance scaffolding
- architecture, plan, schema, and decision artifacts in `dev/`

The current design question is whether to formally adopt the broader architecture direction implied by the new local/hybrid and MCP-aware design work.

## Decision

`reproducibleai` will adopt a hybrid AI methodology as part of its package direction.

This means the package will:

- support both frontier-model and local-model workflows as first-class methodology targets
- standardize hybrid best-bet task routing rather than require one universal AI runtime
- treat local workflows as governed workbenches rather than as one-model replacements for hosted assistants
- preserve canonical human-readable instruction sources as the semantic source of truth
- support client-facing runtime rule artifacts derived from canonical instruction sources
- treat MCP as a preferred integration direction for exposing governed resources, tools, and prompts to compatible AI clients
- formalize evaluation of AI workflows through competency-question-oriented methodology
- remain centered on governance, methodology, derivation, deployment, and evaluation rather than on generic runtime ownership

## Scope boundary

Under this decision, `reproducibleai` is positioned as:

- a governed AI workflow package
- an instruction and runtime-artifact derivation package
- a repository-governance and deployment support package
- an evaluation and methodology package
- an MCP-aware integration package

Under this decision, `reproducibleai` is not positioned as:

- a generic AI runtime
- a generic MCP runtime host or server framework
- a code editor client
- a generic retrieval engine
- a generic agent platform

## Rationale

This decision is based on the following conclusions from the local AI architecture design work:

### 1. One-model parity is the wrong target
Hosted frontier platforms behave like integrated systems rather than isolated single-model experiences.

Their apparent quality depends not only on model intelligence, but also on:
- retrieval
- tool access
- context management
- workflow shaping
- editor integration
- hidden platform tuning

A local workflow should therefore be designed as a governed system rather than judged only as a direct model substitute.

### 2. Hybrid workflow support is more realistic than hosted-only or local-only strategy
Frontier systems and local systems each have strengths.

A hybrid methodology allows the team to:
- use frontier systems where general reasoning and convenience are strongest
- use local systems where governance, privacy, and local context awareness are strongest
- preserve one methodology across both modes

### 3. Repository-governed context is a major package opportunity
`reproducibleai` already has strong governance patterns around:
- plans
- design docs
- schemas
- decisions
- instructions

These artifacts can become governed AI context assets rather than remaining only human documentation.

### 4. MCP is a strong fit for the integration problem
The package needs a way to expose governed capabilities to AI clients in a structured and inspectable manner.

MCP provides a promising architecture direction for:
- governed resources
- governed tools
- reusable workflow prompts

without requiring `reproducibleai` to become a generic platform.

### 5. Evaluation needs to become explicit
AI workflow quality should not be judged only by anecdotal impressions.

The package should support a repeatable methodology for competency-question-based evaluation, especially for:
- instruction compliance
- governed context use
- local context awareness
- task-fit comparisons across workflow modes

## Consequences

### Positive consequences
- The package gains a clearer long-term architecture direction.
- The package can evolve beyond frontier-only instruction deployment.
- The package can support Continue-style runtime rule deployment and future client targets.
- The package can incorporate MCP-aware integration without abandoning its instruction-first and governance-first principles.
- The package can develop a clearer evaluation methodology for local and hybrid workflows.

### Costs and risks
- Package scope broadens beyond the original instruction-handler focus.
- New abstractions will likely be needed for runtime artifacts, governed resources, capabilities, and integration adapters.
- There is a risk of overbuilding abstractions too early.
- There is a risk of accidentally duplicating mature external tooling.
- MCP support introduces integration and deployment complexity that must remain carefully bounded.

### Implementation consequences
This ADR does not lock the detailed implementation of:
- rule derivation mechanics
- client adapter structure
- MCP deployment mechanics
- competency-question harness structure
- recipe family structure

Those details remain subject to design and implementation work under:
- `dev/15_local_ai_architecture.md`
- `dev/05_plan.md` Milestone G

## Alternatives considered

### 1. Remain frontier-oriented only
Keep the package focused on workflows optimized for hosted frontier systems and treat local experimentation as out of scope.

Rejected because:
- it does not address the team’s emerging local workflow needs
- it leaves local context-aware methodology underdeveloped
- it would ignore a major new package opportunity

### 2. Adopt strict local-first methodology
Recast the package primarily around local runtimes and local deployment constraints.

Rejected because:
- the team does not require strict local-first operation in all cases
- frontier tools remain useful for some tasks
- a hybrid methodology is a better fit for current team needs

### 3. Keep local workflow work informal and undocumented
Continue experimenting without formalizing package direction.

Rejected because:
- the design implications are already broad enough to affect package scope and architecture
- governance artifacts should capture durable design direction
- the team needs a stable conceptual frame for Milestone G work

### 4. Build a generic AI or MCP platform inside the package
Expand the package into a general runtime, orchestration, or server framework.

Rejected because:
- this would duplicate mature external tooling
- it would blur the package’s core value
- it would expand scope beyond what is justified by current needs

## Follow-up work

Follow-up work should proceed under `dev/05_plan.md` Milestone G, including:

- governed AI context resource classification
- rule-tier and runtime-artifact architecture
- first Continue deployment pattern
- first MCP-aware integration slice
- competency-question evaluation structure

Stable outcomes from that work may later require updates to:
- `dev/10_design.md`
- `inst/instructions/`
- `dev/instructions/`
- package helpers and handlers in `R/`

## Supersession
None.
