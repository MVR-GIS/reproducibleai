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
  weight = 1,
  canonical_answer = NULL,
  review_status = "approved",
  artifact_type = NULL,
  source_heading = NULL,
  source_hash = NULL,
  derivation_template = NULL
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

- canonical_answer:

  Optional maintained answer text used for deterministic token-level
  grounding scores.

- review_status:

  Whether the question is `"approved"`, `"pending"`, or `"rejected"` by
  human review.

- artifact_type:

  Optional generated artifact classification.

- source_heading:

  Optional generated source-section heading.

- source_hash:

  Optional hash of the source file used for derivation.

- derivation_template:

  Optional identifier of the deterministic template that generated the
  question.

## Value

An object of class `agentic_routing_question`.
