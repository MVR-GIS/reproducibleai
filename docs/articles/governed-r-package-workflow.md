# Governed workflow for an R package

## Overview

This vignette describes a governed AI-assisted workflow for an R package
using the `r_package_governed` recipe from
[reproducibleai](https://mvr-gis.github.io/reproducibleai/).

The goal of this workflow is to:

- install reusable instruction modules into the repository,
- scaffold a standard `dev/` governance structure,
- keep durable project state in repository artifacts rather than only in
  chat transcripts,
- make AI-assisted development more reproducible, reviewable, and
  auditable.

## The governed recipe

The `r_package_governed` recipe composes:

- `chat-manual`
- `goals`
- `r-package`
- `development-governance`

You can inspect the recipe directly:

``` r
library(reproducibleai)

recipes <- instructions_recipes()
recipes$r_package_governed
#> [1] "chat-manual"            "goals"                  "r-package"             
#> [4] "development-governance"
```

## Install the governed workflow

To install the recipe into an R package repository:

``` r
use_instructions(recipes$r_package_governed)
```

By default, this installs instruction modules into:

- `dev/instructions/`

and writes the entrypoint file:

- `dev/instructions/CHAT_INSTRUCTIONS.md`

## What gets scaffolded

Because `development-governance` is a config-aware module, the governed
workflow also scaffolds a standard `dev/` structure.

This includes:

- `dev/05_plan.md`
- `dev/10_design.md`
- `dev/40_schemas.md`
- `dev/decisions/`
- `dev/decisions/README.md`
- `dev/instructions/`
- `dev/sessions/`

These artifacts serve distinct roles.

### `dev/05_plan.md`

The active work plan.

Use it for:

- near-term tasks,
- milestone sequencing,
- concrete next steps,
- definitions of done.

### `dev/10_design.md`

The stable current-state design document.

Use it for:

- architecture,
- design invariants,
- capability boundaries,
- persistent operating assumptions.

### `dev/40_schemas.md`

The structural contract document.

Use it for:

- file schemas,
- structured object contracts,
- required fields and types,
- other interfaces whose shape must remain explicit.

### `dev/decisions/`

The decision record directory.

Use it for:

- durable design decisions,
- rationale,
- alternatives considered,
- supersession history.

### `dev/instructions/`

The installed instruction modules for future sessions.

### `dev/sessions/`

The archive of session transcripts and historical context.

Session transcripts are important for transparency, but they should not
be treated as the canonical source of final project state.

## How the governed workflow is intended to be used

A typical loop looks like this:

1.  install the governed recipe,
2.  begin a chat session using `dev/instructions/CHAT_INSTRUCTIONS.md`,
3.  do implementation or design work,
4.  when the session clarifies durable project state, promote that state
    into:
    - plan,
    - design,
    - schema,
    - decision, as appropriate,
5.  preserve the transcript in `dev/sessions/` when needed.

The key idea is that important outcomes should be promoted into
repository artifacts rather than left only in conversational history.

## Example session prompt

Once the files are installed, a new session can begin by directing the
assistant to the entrypoint:

``` r
# Example prompt content
# Target repo: OWNER/REPO
# Read dev/instructions/CHAT_INSTRUCTIONS.md and follow the listed modules.
```

In practice, `CHAT_INSTRUCTIONS.md` gives the assistant the ordered
module list and the expected reading sequence.

## Why use the governed workflow

This workflow is especially useful when:

- development is iterative and chat-based,
- the team wants durable documentation of design and decisions,
- architecture and schemas evolve over time,
- the repository needs stronger continuity across sessions and
  contributors.

It is a lightweight governance layer rather than a heavy automation
system. The package scaffolds the structure, and the session workflow
helps keep that structure current.

## Related functions

Useful related functions include:

- [`instructions_available()`](https://mvr-gis.github.io/reproducibleai/reference/instructions_available.md)
- [`instructions_recipes()`](https://mvr-gis.github.io/reproducibleai/reference/instructions_recipes.md)
- [`use_instructions()`](https://mvr-gis.github.io/reproducibleai/reference/use_instructions.md)

## Summary

The `r_package_governed` recipe provides a practical starting point for
R packages that want:

- reusable AI instruction modules,
- a standard governance structure,
- durable plan/design/schema/decision artifacts,
- and a more reproducible AI-assisted workflow.
