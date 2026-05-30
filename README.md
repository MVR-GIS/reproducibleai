<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- rmarkdown::render(input="README.Rmd", output_file="README.md", output_format="md_document") -->

# reproducibleai

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/MVR-GIS/reproducibleai/graph/badge.svg)](https://app.codecov.io/gh/MVR-GIS/reproducibleai)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle)
[![Project Status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![License:
CC0](https://img.shields.io/badge/license-CC0-blue.svg)](http://choosealicense.com/licenses/cc0-1.0/)
<!-- badges: end -->

## Description

{reproducibleai} is an R package of tools to help teams adopt a
reproducible workflow for AI-assisted projects. The package provides
reusable instruction modules, recipe-based composition, and supporting
scaffolds for durable AI-assisted development workflows.

We hold the opinionated view that the ethical use of AI requires data
scientists to make well-informed, conscious decisions throughout the
analysis process. These tools are designed to help teams experiment with
repeatable methods for AI-assisted workflows while keeping those
workflows reviewable and auditable.

**Core ideas:**

-   make chat sessions reproducible by recording the exact instruction
    modules used,
-   keep instruction content reviewable as static markdown,
-   support recipe-based composition of reusable instruction modules,
-   provide lightweight handler-backed installation where some modules
    require supporting repository structure,
-   support an auditable workflow as teams adopt AI tooling.

## Instruction model

`reproducibleai` is instruction-first.

Canonical instruction text is stored as static markdown in
`inst/instructions/`. Public workflows compose instruction modules by
name and install them into a target repository with
`use_instructions()`.

Internally, installation is now handler-backed:

-   every public instruction module has a corresponding handler,
-   simple modules install canonical text only,
-   config-aware modules can also scaffold supporting repository
    structure.

This preserves static, reviewable instruction text while allowing
modules such as development-governance to establish the repository
structure they depend on.

------------------------------------------------------------------------

## Authors

-   [Michael Dougherty](mailto:Michael.P.Dougherty@usace.army.mil),
    Geographer, Rock Island District, U.S. Army Corps of Engineers
    <a itemprop="sameAs" content="https://orcid.org/0000-0002-1465-5927" href="https://0000-0002-1465-5927" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;">
    <img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" alt="ORCID iD icon" style="width:1em;margin-right:.5em;"/>https://orcid.org/0000-0002-1465-5927</a>

------------------------------------------------------------------------

## Installation

You can install the development version from GitHub with:

    # install.packages("pak")
    pak::pak("MVR-GIS/reproducibleai")

## Quick start

### 1) See which instruction modules are available

    library(reproducibleai)
    instructions_available()
    #> [1] "chat-manual"            "development-governance" "goals"                  "parameterized-help"    
    #> [5] "python-package"         "quarto-book"            "r-package"              "shiny-golem"           
    #> [9] "user-manual"
    # returns the public module names you can compose into recipes

### 2) Use a recommended recipe

    recipes <- instructions_recipes()
    recipes$r_package
    #> [1] "chat-manual" "goals"       "r-package"

### 3) Install instructions into your project

    use_instructions(recipes$r_package)
    # installs into dev/instructions/ by default
    # also writes dev/instructions/CHAT_INSTRUCTIONS.md

### 4) Use development-governance when you want repository scaffolding

The `development-governance` module is the first config-aware module. In
addition to installing its instruction text, it scaffolds a standard
development-governance structure under `dev/`, including:

-   `dev/05_plan.md`
-   `dev/10_design.md`
-   `dev/40_schemas.md`
-   `dev/decisions/`
-   `dev/instructions/`
-   `dev/sessions/`

Example:

    use_instructions(c("chat-manual", "development-governance"))

This is useful for repositories that want durable AI-assisted
development artifacts such as plans, design notes, schema contracts,
decision records, reusable instructions, and archived sessions.

## Notes on installation behavior

`use_instructions()` is designed around the repository layout:

-   `dev/instructions/` for installed instruction modules
-   `dev/instructions/CHAT_INSTRUCTIONS.md` as the session entrypoint

Modules are installed through internal handlers. For most modules this
means installing static instruction text. For selected modules, handlers
may also scaffold required supporting files or directories.

The package currently treats canonical instruction markdown as the
authoritative module content; handlers support installation and
scaffolding but do not dynamically rewrite substantive instruction text.

------------------------------------------------------------------------

## Vignettes

    # What vignettes exist for this package?
    vignette(package = "reproducibleai")

## Bug reports

Please open an issue at:
<https://github.com/MVR-GIS/reproducibleai/issues>
