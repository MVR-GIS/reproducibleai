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
3. @dev/05_plan.md with the realization that this plan needs to be updated based local-ai-workstation POC findings
4. @dev/15_local_ai_architecture.md for the active local/hybrid AI architecture proposal
5. @dev/decisions/adr-0004-hybrid-ai-methodology-and-mcp-aware-integration.md for the proposed architectural decision

After reading these base documents, then consider this conclusion:
- I've discovered that I've made sereral architectural mistakes. 
    1. For performance, bare metal architecture should be used instead of containers. Additionally, container networking is too complex on secure gov workstations. 
    2. Open WebUI should be removed from design. To build a local-only, bare-metal, open source, vibe-coding, ai workstation, Open WebUI is not compatible/needed with this design: Positron + Continue + Ollama + MCP server array + large -instruct model
- These docs describe how I went down the wrong direction with Open WebUI. Please read: 
    - @dev/16_ai-workstation-spec.md 
    - @dev/sessions/checkpoint-local-ai-workstation.md. 
    - @dev/decisions/adr-0005-local-agentic-dev
- The objective of this chat is to:
    - rewind the previous Open WebUI implementation
    - Implement the design: Positron + Continue + Ollama + MCP server array + large -instruct model
    - complete the proof of concept for configuring an array of MCP servers for a local open-source vibe-coding ai workstation.

Only then propose a plan, followed by concrete edits or code changes.
"


## Update AI Chat Artifacts
reproducibleai::extract_copilot_chat(file.path(
  Sys.getenv("USERPROFILE"), "Downloads", "copilot_export.zip")
)


## Update docs
devtools::install()
pkgdown::build_site()

