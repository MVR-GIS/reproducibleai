# Check local prerequisites for live agentic-routing evaluation

Diagnoses the optional local capabilities required to start live
`codex exec` runs. It does not install software, change configuration,
contact a model, or consume model usage. Offline scaffolding,
validation, fixture, scoring, summary, and reporting functions do not
require these prerequisites.

## Usage

``` r
check_agentic_routing_prerequisites(path = NULL, codex = NULL)
```

## Arguments

- path:

  Optional target repository. When supplied, its agentic context, Git
  commit, and clean-worktree status are also checked.

- codex:

  `NULL` for automatic discovery, or a Codex CLI command or absolute
  executable path.

## Value

An object of class `agentic_routing_prerequisites`. `ready` means local
preflight checks passed; network access, account entitlement, and
enterprise execution policy can still prohibit a live run.

## Details

When `codex` is `NULL`, discovery checks the process `PATH` and
supported user-local installation locations. On Windows this includes
the stable path written by OpenAI's standalone installer, even when an
already-running IDE has not refreshed its `PATH`.
