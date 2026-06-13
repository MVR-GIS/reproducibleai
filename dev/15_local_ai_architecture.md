# Local AI Architecture

Last updated: 2026-06-13

## Purpose
This document is a working design-analysis artifact for the local AI system architecture used in repositories supported by `reproducibleai`.

Its purpose is to capture:
- shortcomings observed in frontier-model development workflows
- the opportunities and limits of local AI systems
- architectural implications for `reproducibleai`
- candidate design directions that require iteration before promotion into stable design documents or decision records

This document is intentionally exploratory.

It is not yet the canonical statement of stable package architecture. Stable conclusions from this document may later be promoted into:
- `dev/10_design.md`
- `dev/05_plan.md`
- `dev/decisions/`
- `dev/instructions/`

## Relationship to existing governance artifacts

### `dev/10_design.md`
Use `dev/10_design.md` for stable current-state package architecture and accepted operating assumptions.

This file should hold exploratory analysis and evolving architecture concepts until they are stable enough to promote.

### `dev/05_plan.md`
Use `dev/05_plan.md` for concrete follow-up work created by this design analysis.

### `dev/decisions/`
Use `dev/decisions/` when a durable design choice has been made and the rationale, alternatives, and supersession history should be preserved.

### `dev/instructions/`
Use `dev/instructions/` for reusable chat/developer instruction modules after the architecture for local and frontier workflows is clearer.

## Problem statement
`reproducibleai` was initially developed around modular instruction workflows that worked well with hosted frontier-model platforms such as GitHub Copilot.

Early experimentation with a local stack using:
- Podman
- Ollama
- Continue
- local rules
- local repository context

showed that a local system cannot be treated as a drop-in one-model replacement for a frontier-model platform.

The key design problem is not merely how to run a local model.

The deeper design problem is how to help teams build a reproducible, private, repo-aware AI development system that:
- preserves the strengths of modular instruction workflows
- improves local context awareness and repo grounding
- supports IT-managed and no-cloud environments
- remains reviewable and governable
- sets correct expectations about where local systems outperform or underperform hosted frontier-model systems

## Current design hypothesis
The correct target is not:

- one local model that “does it all” like a hosted assistant appears to do

The correct target is:

- a modular local AI system with explicit architecture for:
  - model roles
  - context selection
  - rule activation
  - workflow modes
  - evaluation
  - governance

## Why this document is needed
The package currently provides strong support for:
- modular instructions
- recipe-based composition
- reviewable static instruction text
- governed repository scaffolding

However, it does not yet provide a complete architecture for helping teams adapt frontier-model workflows into local-model workflows.

This gap matters because:
- local AI use is a realistic operational need in some environments
- hosted-model workflows and local-model workflows have materially different capability profiles
- instructions written for frontier systems may not transfer directly to smaller or local models
- teams need guidance on where local systems should be optimized, constrained, or combined with other tools

## Observed design shift
The initial working assumption was that a local stack could reproduce the apparent behavior of a hosted assistant by combining:
- one model
- one editor integration
- one rule system

This assumption is now considered too simplistic.

The emerging design view is that hosted systems behave like integrated platforms rather than single models. Their performance likely depends on:
- multiple model classes
- optimized retrieval and ranking
- product-layer orchestration
- context management
- strong editor/tool integration
- platform-specific tuning

A local system should therefore be designed as a workbench rather than a single assistant.

## Shortcomings matrix

| Frontier workflow strength or shortcoming | Why it matters | Can a local system address it? | Likely local response | Primary `reproducibleai` implication |
|---|---|---|---|---|
| Frontier systems often feel like one assistant that can handle many tasks | This creates unrealistic expectations that one local model should perform equally well across planning, explanation, editing, and repo analysis | Partially | Reset expectations and design for multiple roles rather than one universal model | Add methodology guidance that local systems are modular, role-based systems |
| Frontier systems often provide stronger default reasoning and better ambiguity handling | Teams may perceive local systems as weak or unreliable when comparing raw chat quality directly | Only partially | Do not optimize local systems around “general brilliance”; optimize around governed, repeatable, repo-aware workflows | Explicitly define local success criteria and capability boundaries |
| Hosted tools can be weak at durable repo-specific workflow compliance | Important instructions may be inconsistently followed across sessions or repos | Yes | Use reviewed static instruction modules and repo-local rules | Extend instruction architecture for local-rule deployment and activation |
| Hosted tools may be less transparent about why behavior changed | This weakens auditability and reproducibility | Yes | Favor explicit rules, explicit context, and explicit architecture layers | Strengthen package guidance on traceable configuration and evaluated workflows |
| Cloud dependence can conflict with data governance or no-cloud requirements | Some teams need local/private workflows even if they are less polished | Yes | Treat local workflows as first-class supported patterns, with realistic boundaries | Add local-first methodology and setup guidance |
| Frontier workflows may not fully exploit local repo conventions and governed artifacts | Teams want AI behavior grounded in local files, repo rules, and design docs | Yes, if designed carefully | Emphasize workspace-local rules, file-aware workflows, and explicit context selection | Add patterns for mapping governed repo artifacts into AI-usable context |
| Long modular instructions developed for frontier systems may overload smaller local models | Local quality may degrade if prompt/rule mass is too large | Yes | Create compressed local-model-adapted rule variants and rule tiers | Add rule taxonomy and adaptation strategy |
| One global always-on instruction set can reduce local-model performance | Too much active instruction competes with task context | Yes | Use small core always-on rules plus conditional task-specific overlays | Add architecture for rule tiers and activation strategy |
| Broad workspace context can reduce answer quality if irrelevant files dominate the prompt | Repo awareness is useful only when the right context is selected | Yes | Prefer narrow, curated context windows and explicit task-mode prompts | Add context-strategy guidance and evaluation criteria |
| Repo-scale edits, targeted refactors, and explanation tasks may need different tools or model modes | One chat interface is not the same as one optimal workflow | Yes | Design workflows that separate chat, editing, refactoring, and evaluation tasks | Position `reproducibleai` as a methodology layer over multiple AI workflow modes |

## Preliminary conclusions from the matrix

### 1. A local system should not be evaluated as a direct one-model substitute for hosted assistants
The comparison target should be:
- governed, reproducible, repo-aware productivity
not:
- general chat parity with frontier systems

### 2. `reproducibleai` should support local AI as a methodology problem
The package should likely help teams design:
- rule structure
- context strategy
- workflow modes
- evaluation methods
- governance artifacts

rather than merely installing instruction files.

### 3. Instruction portability is not automatic
Frontier-oriented instruction modules may need:
- compression
- decomposition
- reclassification
- local-model-specific adaptations

before they work well in local systems.

### 4. Rule architecture may matter more than model substitution
Early evidence suggests that local-model quality may be more sensitive to:
- rule overload
- irrelevant context
- weak task framing

than to model identity alone.

### 5. The design goal should be selective superiority, not universal parity
Local systems may be able to outperform hosted tools in:
- privacy
- repo-specific governance
- repeatability
- explicit workflow control
- durable local context

while still underperforming in:
- general reasoning quality
- ambiguity handling
- polished “one assistant” behavior

## Candidate architecture layers

### 1. Model layer
Questions:
- Which model is used for which task?
- Should chat, edit, autocomplete, and summarization be treated as separate roles?
- Which tasks are acceptable for smaller local models and which are not?

Candidate direction:
- do not assume one model should handle all tasks equally well
- design for model-role separation where supported by the client platform

### 2. Context layer
Questions:
- What file, selection, or repo context should be active for each task type?
- How much context is too much for local models?

Candidate direction:
- favor narrow, highly relevant context
- standardize context patterns such as:
  - current file only
  - selected text plus current file
  - current file plus one or two related files
  - governed repo artifact plus working file

### 3. Rule layer
Questions:
- Which instructions should always apply?
- Which should be conditional?
- Which should remain human-oriented source material rather than active model prompt content?

Candidate direction:
- define a small always-on core
- define conditional task overlays
- distinguish human source instructions from local-model runtime rules

### 4. Workflow layer
Questions:
- Which workflows should be treated as distinct operating modes?
- What prompt conventions produce reliable results?

Candidate direction:
- define standard workflow modes such as:
  - explain
  - compare options
  - review before edit
  - draft replacement text
  - repo design analysis
  - governed documentation update

### 5. Evaluation layer
Questions:
- How will teams know whether local workflow quality is improving?
- What tasks should be used for repeated comparison?

Candidate direction:
- define a repeatable task suite
- compare configurations against the same representative tasks
- score:
  - instruction compliance
  - repo grounding
  - usefulness
  - hallucination rate
  - formatting compliance
  - reviewability

## Implications for instruction architecture

### Current strength
`reproducibleai` already supports:
- modular instruction text
- reviewed static canonical modules
- recipe composition
- governed installation

### Likely gap
The package may need a second layer of support for:
- local-model-adapted rule variants
- rule compression
- rule tier classification
- workspace rule deployment conventions such as `.continue/rules`
- evaluation-oriented workflow recipes

### Working taxonomy proposal
Candidate categories:

- **Core rules**
  - short, always-on, cross-cutting constraints
- **Task overlays**
  - domain- or workflow-specific rules applied only when relevant
- **Source instructions**
  - richer human-readable documents that should not necessarily be injected directly into model context
- **Local-adapted variants**
  - compressed or operationalized versions of frontier-oriented instruction modules for smaller local models

## Implications for repository deployment

Candidate deployment distinction:

- user-level AI client configuration
  - shared across workspaces
  - endpoint definitions
  - model declarations
  - minimal base behavior

- repo-level runtime rules
  - workspace-specific
  - version controlled
  - aligned to governed repository state

- repo-level human instruction sources
  - richer design and workflow documentation
  - used as canonical reviewed source material for generating or maintaining runtime rules

## Open questions

### Capability and scope
- Should `reproducibleai` explicitly support both frontier and local workflows as first-class methodology targets?
- Should it define separate recipe families for frontier-optimized and local-optimized instruction systems?

### Rule adaptation
- Should local-model-adapted rules be maintained manually or generated from canonical source instructions?
- If generated, what transformations are acceptable without violating the static canonical instruction principle?

### Deployment
- Should the package scaffold workspace-local rules for Continue or other clients?
- If so, should that be modeled as a new config-aware capability?

### Evaluation
- What minimum benchmark task suite should be used to evaluate local workflow quality?
- How should evaluation artifacts be stored and compared across repos?

### Tool boundaries
- Which tasks should remain in hosted platforms even in a local-first methodology?
- How should the package document hybrid workflows without weakening local-first governance goals?


## Provisional design directions

This section records the current working direction from active design analysis.

These are not yet final package decisions, but they are stronger than open questions and should guide subsequent experimentation and design refinement.

### 1. Capability and scope
The package should support both frontier-model and local-model workflows.

The working goal is not to replace frontier platforms outright, nor to assume that local-first is a universal requirement.

Instead, `reproducibleai` should support a hybrid methodology in which:
- frontier and local systems are both recognized as useful
- each is used for the tasks it performs best
- users can switch between them intentionally
- workflows remain governed, reviewable, and reproducible across both modes

The architecture should therefore avoid assuming a single universal AI runtime.

Instead, it should help users configure and operate multiple AI workflow modes with explicit guidance on when each mode is the better fit.

### 2. Rule adaptation
The preferred design is to maintain a single human-readable canonical instruction source that is suitable for review by developers and non-programmers.

Local-model-adapted rule variants should be derived from these more verbose frontier-ready instructions rather than authored independently from scratch.

This preserves:
- one reviewed starting point
- clearer governance
- easier diff review
- lower risk of semantic drift between frontier and local workflows

The main unresolved design question is not whether derivation should occur, but how it should occur.

Current candidate approaches include:
- deterministic manual compression maintained by package authors
- LLM-assisted derivation followed by human review and editing
- partially automated derivation with structured post-processing and manual approval

The architecture should assume that fully automatic derivation may not be sufficient for high-quality local-model rules, especially when local models have materially different context and reasoning limits.

### 3. Deployment
The package should scaffold workspace-local runtime rules.

The first supported client target should be Continue.

The design should remain extensible so that additional local or hybrid AI clients can be supported later without redesigning the core instruction architecture.

This implies that `reproducibleai` may need to distinguish between:
- canonical reviewed instruction sources
- client-specific runtime rule artifacts
- client-specific configuration scaffolding

### 4. Evaluation
Evaluation should be a first-class part of the package design.

Evaluation artifacts and tests should be maintained inside `reproducibleai` using standard R package testing infrastructure where practical.

The preferred evaluation pattern is to organize tests as competency questions.

These competency questions should assess whether a configured workflow can perform targeted behaviors reliably and reviewably.

High-value evaluation targets should emphasize local-system strengths, especially:
- local context awareness
- governed use of repository artifacts
- instruction compliance
- stable task framing
- useful distinctions between hosted and local task fit

This reflects the working view that local context awareness is a major opportunity area where local workflows may outperform hosted frontier systems if designed well.

### 5. Tool boundaries
The package should not assume a strict local-first ideology.

In this team context, local workflows were introduced to address shortcomings of hosted frontier systems rather than to prohibit hosted usage.

The preferred methodology is therefore hybrid.

`reproducibleai` should help teams categorize tasks into best-bet recommendations such as:
- tasks better suited to hosted frontier systems
- tasks better suited to local systems
- tasks where either is acceptable
- tasks where a staged or hybrid workflow is recommended

This implies that part of the package methodology may need to include explicit task-routing guidance rather than only instruction installation.

## Implications of the provisional directions

The current design work now suggests the following likely package responsibilities:

- support both frontier and local methodology patterns
- preserve one canonical human-readable instruction source where possible
- support derivation or maintenance of local-runtime rule variants
- scaffold client-specific workspace rule deployments beginning with Continue
- add competency-question-based evaluation support
- document hybrid best-bet task routing rather than assuming one universal AI workflow

These implications are still subject to refinement through experimentation and implementation review.


## Promotion candidates

The following topics may later be promoted into stable design or decisions if validated:

- local systems should be treated as modular workbenches rather than one-model assistants
- instruction modules may require local-model-adapted variants
- rule tiering should be a formal part of the package methodology
- evaluation should be an explicit package-supported workflow
- workspace-local runtime rules may deserve first-class package support

## Immediate follow-up candidates
This document suggests likely next work in:

- `dev/05_plan.md`
  - add a local-AI methodology milestone
- `dev/10_design.md`
  - later add a stable section on local-vs-frontier capability boundaries
- `dev/decisions/`
  - later record a decision if local-AI architecture becomes a formal supported package direction
- `dev/instructions/`
  - later develop rule-tier and local-adaptation guidance once the architecture is tested
