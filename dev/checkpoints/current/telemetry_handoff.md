CONTEXT HANDOFF: REPRODUCIBLEAI TELEMETRY INFRASTRUCTURE


Project Goals

Extend the experimental {reproducibleai} R package to incorporate local-first, low-overhead resource diagnostics for evaluating conditional context routing. We must rigorously audit token overhead and context isolation inside our GenAI.mil (Gemini API) workflows without text condensation, maintaining 100% verbatim natural language requirements for engineering auditability.

Current State

The package successfully scaffolds a repository, tracks intent via AGENTS.md, and runs repeated isolated competency evaluations (run_agentic_routing_evaluation()) to verify state recovery. However, it lacks the ability to programmatically stress-test routes for logic leakage, context redundancy, or over-reliance on base model weights (hallucinations/guessing when a file is absent).

Target Architecture & Tasks


1. Expanded Competency Question Schema

Implement an R structured object validator (supporting S3 methods or standard tibble metadata blocks) that extends our current question framework to require:
• expected_route: character string naming the strict routing gate defined in AGENTS.md.
• required_context_shards: a character vector of local file paths (under dev/) that must be present to resolve the query.

2. The Three-Tier Ablation Engine

Modify or wrap run_agentic_routing_evaluation() to support a multi-pass evaluation harness:
• Tier A (Happy Path): Execute with full context tracking. Capture the raw API usage_metadata to measure Token Efficiency Ratio (TER):
\(\text{TER}=\frac{\text{candidates\_token\_count}}{\text{prompt\_token\_count}}\)
• Tier B (Boundary Shift / Negative Testing): Execute an out-of-scope competency question against a restricted route. Measure the Context Leakage Metric (CLM): tracking the token volume of shards loaded by the router that are never explicitly cited or processed.
• Tier C (Null-Context Grounding): Programmatically run the evaluation pass while temporarily mocking or masking the paths listed in required_context_shards. Calculate the Gap Sensitivity Score (GSS): verify that the system halts or explicitly reports insufficient context instead of passing the test using base weights.

3. Local Transactional Ledger & Reporting

Write the internal function logic to append all telemetry parameters immediately to a local version-controlled CSV at dev/governance/routing-matrix.csv using only base R data structures or tidyverse primitives (tibble/readr), avoiding heavy external database containers. Ensure it aggregates results into a clean markdown diagnostic matrix for the agentic-routing-health.md workflow file.

Execution Directives

• Language Stack: Pure R targeting local-first Windows/GovCloud developer environments.
• Constraints: No network-based telemetry platforms (e.g., Langfuse/Langsmith). Do not use text-shortening or summarizing routines. Every calculation must be derived locally from the raw token count values returned by the stateless API responses.
To begin this session, would you like to start by generating the unexported internal R helper functions to handle the file-masking sandbox, or should we draft the extended R Markdown/YAML validation schema for the updated competency questions first?
