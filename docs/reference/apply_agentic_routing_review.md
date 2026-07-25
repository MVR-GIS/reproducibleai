# Apply a completed competency-review sheet

Imports the four editable review columns while rejecting changes to
question identifiers, source evidence, or benchmark provenance.

## Usage

``` r
apply_agentic_routing_review(benchmark, path, require_complete = TRUE)
```

## Arguments

- benchmark:

  The original generated `agentic_routing_benchmark`.

- path:

  Review directory written by
  [`write_agentic_routing_review()`](https://mvr-gis.github.io/reproducibleai/reference/write_agentic_routing_review.md),
  or its edited `questions.csv`.

- require_complete:

  Require every row to be approved or rejected.

## Value

The reviewed benchmark, ready to freeze when review is complete.
