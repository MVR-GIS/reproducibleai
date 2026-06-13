# `renv``

## Configure `renv`
install.packages("renv")
update.packages()
renv::init()
file.exists("renv.lock")

## Workflow to update `renv`
update.packages()
renv::snapshot()
renv::status()

# SBOM

## Configure SBOM
use_sbom()
pak::pak("MVR-GIS/reproducibleai")


## Specify Chat Instructions
reproducibleai::use_instructions(c("chat-manual", "goals", "r-package"))

## Start new chat prompt text:
"
This session is based on MVR-GIS/reproducibleai on main.

First read:
1. @dev/instructions/CHAT_INSTRUCTIONS.md
2. @dev/10_design.md for the stable current implemented architecture
3. @dev/05_plan.md with attention to Milestone G
4. @dev/15_local_ai_architecture.md for the active local/hybrid AI architecture proposal
5. @dev/decisions/adr-0004-hybrid-ai-methodology-and-mcp-aware-integration.md for the proposed architectural decision

After reading, briefly summarize:
- the current stable package architecture,
- the active local/hybrid architecture extension,
- the current Milestone G priorities,
- and the next smallest useful step to maintain momentum.

Only then propose concrete edits or code changes.
"

## Update AI Chat Artifacts
reproducibleai::extract_copilot_chat(file.path(
  Sys.getenv("USERPROFILE"), "Downloads", "copilot_export.zip")
)


## Update docs
devtools::install()
pkgdown::build_site()

