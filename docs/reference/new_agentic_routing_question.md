# Define an agentic-routing competency question

Creates a human-reviewable competency question and its scoring rubric.
The rubric is not included in the prompt sent to Codex.

## Usage

``` r
new_agentic_routing_question(
  id,
  prompt,
  required_paths,
  allowed_paths = character(),
  expected_terms = character(),
  forbidden_terms = character(),
  weight = 1
)
```

## Arguments

- id:

  Stable question identifier.

- prompt:

  Task prompt presented to Codex.

- required_paths:

  Repository-relative evidence paths that a successful response must
  cite. A path ending in `/` matches any descendant.

- allowed_paths:

  Additional relevant evidence paths that may be cited without reducing
  routing precision.

- expected_terms:

  Case-insensitive literal terms expected in the answer.

- forbidden_terms:

  Case-insensitive literal terms that indicate an incorrect or
  superseded answer.

- weight:

  Positive weight used in the aggregate health score.

## Value

An object of class `agentic_routing_question`.
