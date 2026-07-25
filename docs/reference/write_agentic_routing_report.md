# Write an agentic-routing health report

Writes an aggregate Markdown report suitable for a durable `dev/`
artifact. Raw prompts, private rubrics, answers, and event traces are
intentionally omitted.

## Usage

``` r
write_agentic_routing_report(health, path, overwrite = FALSE)
```

## Arguments

- health:

  Result from
  [`summarize_agentic_routing()`](https://mvr-gis.github.io/reproducibleai/reference/summarize_agentic_routing.md).

- path:

  Destination Markdown path.

- overwrite:

  Replace an existing report.

## Value

The normalized report path, invisibly.
