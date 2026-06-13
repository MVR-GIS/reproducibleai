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
This session is based on MVR-GIS/reproducibleai main. 
Read dev/instructions/CHAT_INSTRUCTIONS.md, then review dev/10_design.md, 
dev/05_plan.md, dev/15_local_ai_architecture.md, 
and ADR-0004 before proposing implementation steps.

## Update AI Chat Artifacts
reproducibleai::extract_copilot_chat(file.path(
  Sys.getenv("USERPROFILE"), "Downloads", "copilot_export.zip")
)


## Update docs
devtools::install()
pkgdown::build_site()

