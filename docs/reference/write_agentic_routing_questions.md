# Write agentic-routing competency questions

Writes a versioned JSON fixture containing prompts and private scoring
rubrics. Keep this file outside the repository being evaluated so the
model cannot inspect expected answers.

## Usage

``` r
write_agentic_routing_questions(questions, path, overwrite = FALSE)
```

## Arguments

- questions:

  One question or a list of questions created by
  [`new_agentic_routing_question()`](https://mvr-gis.github.io/reproducibleai/reference/new_agentic_routing_question.md).

- path:

  Destination JSON path.

- overwrite:

  Replace an existing file.

## Value

The normalized destination path, invisibly.
