# Score one agentic-routing response

Scores evidence routing, expected answer content, forbidden content, and
completion using a fixed transparent rubric. This function supports
offline scoring without invoking Codex.

## Usage

``` r
score_agentic_routing_run(question, response, completed = TRUE)
```

## Arguments

- question:

  A question created by
  [`new_agentic_routing_question()`](https://mvr-gis.github.io/reproducibleai/reference/new_agentic_routing_question.md).

- response:

  A list with `answer`, `evidence_paths`, `route_summary`, and
  `confidence`.

- completed:

  Whether execution and structured-response parsing succeeded.

## Value

A named list of component metrics and the combined score.
