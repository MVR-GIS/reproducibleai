# Create a flat competency-review table

Converts a generated benchmark into the human-review surface used by
[`write_agentic_routing_review()`](https://mvr-gis.github.io/reproducibleai/reference/write_agentic_routing_review.md).
Reviewers may edit `review_status`, `review_note`, `prompt`, and
`canonical_answer`. All other columns are locked provenance and are
verified when the review is applied.

## Usage

``` r
as_agentic_routing_review(benchmark)
```

## Arguments

- benchmark:

  A generated `agentic_routing_benchmark`.

## Value

A base R data frame with one row per competency question.
