# Write a competency-review sheet

Writes a pending or partially reviewed benchmark as an external review
directory containing `questions.csv`, `exclusions.csv`, and `REVIEW.md`.
This is the artifact bundle a human opens, reviews, edits, and saves
before applying the decisions back to the benchmark.

## Usage

``` r
write_agentic_routing_review(benchmark, path, overwrite = FALSE)
```

## Arguments

- benchmark:

  A generated `agentic_routing_benchmark`.

- path:

  Destination directory outside the evaluated repository.

- overwrite:

  Replace known files in an existing review directory.

## Value

The normalized review-sheet path, invisibly.
