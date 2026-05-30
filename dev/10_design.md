## Development-governance capability

### Purpose
`reproducibleai` standardizes a development-governance framework for AI-assisted repositories that use iterative chat sessions as part of normal development work.

The goal is to make important outcomes from chat sessions durable, concise, and reviewable by promoting them into structured repository artifacts rather than leaving them only in archived transcripts.

### Governance model
The package assumes that internal development-state artifacts live in a repository `dev/` directory, while user-facing package documentation is communicated through standard package surfaces such as:
- `README`
- roxygen/man pages
- vignettes/articles
- pkgdown site pages

### Standard internal artifacts
The governance framework centers on these artifacts:

- `dev/05_plan.md` for active work planning
- `dev/10_design.md` for stable current-state architecture and design
- `dev/decisions/` for decision records
- `dev/instructions/` for modular chat/developer guidance
- `dev/sessions/` for archived transcripts

An optional `dev/40_schemas.md` may be used when exact structural contracts need centralized documentation.

### Behavioral enforcement
This capability is enforced primarily through instruction modules rather than through heavy automation.

The intended workflow is:
1. scaffold the governance structure in the repository
2. use instruction modules to condition chat sessions to monitor for governance-update triggers
3. require the chat session to provide paste-ready updates to the relevant `dev/` artifacts when durable project state changes

### Scope boundaries
This governance capability is distinct from domain-specific package functionality.

It governs:
- documentation roles
- document precedence
- session-to-document promotion
- durable design capture

It does not govern:
- package-specific implementation logic
- user-facing instructional content except where governance boundaries must be clarified

### Package responsibilities
`reproducibleai` should support this capability through:
- scaffolding functions that establish the `dev/` governance structure
- instruction modules that define chat behavior for maintaining it
- published package documentation that explains the governance framework to users
