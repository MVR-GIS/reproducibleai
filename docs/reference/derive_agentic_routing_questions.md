# Derive competency questions from durable development context

Deterministically extracts conservative factual questions and canonical
answers from versioned sections under `dev/`. The generator never reads
`AGENTS.md`, so its criterion is independent of the routing
specification being evaluated. Generated questions remain pending until
a human approves or rejects each candidate.

## Usage

``` r
derive_agentic_routing_questions(path = ".", max_per_type = 3L)
```

## Arguments

- path:

  Repository containing a valid agentic-context scaffold.

- max_per_type:

  Maximum candidates retained for each artifact type.

## Value

An object of class `agentic_routing_benchmark`.
