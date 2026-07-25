# Review agentic-routing competency benchmarks

Derivation creates candidate questions and private canonical answers. It
does not make those candidates scientifically valid by itself. A human
reviewer must confirm that each question represents a useful competency
and that its answer is supported by maintained repository evidence.

The review workflow uses an external, flat artifact bundle. Reviewers do
not need to edit the nested R benchmark object or raw JSON.

## Artifact lifecycle

| Stage | Artifact | Location | Purpose |
|----|----|----|----|
| Derive | `agentic_routing_benchmark` R object | R session | Deterministic candidates and provenance |
| Review | directory with `REVIEW.md`, `questions.csv`, and `exclusions.csv` | outside target repository | Human QA and recorded decisions |
| Freeze | versioned benchmark JSON | outside target repository | Fixed private criterion for repeated experiments |
| Execute | raw events and responses | outside target repository | Troubleshooting evidence |
| Report | aggregate Markdown health report | inside target repository | Durable public process record |

The review bundle and frozen benchmark contain gold answers. Do not put
them inside the repository being evaluated, where Codex could inspect
them.

## Create the review bundle

``` r

library(reproducibleai)

target <- "C:/workspace/FluvialGeomorph/reproducibleai"
benchmark <- derive_agentic_routing_questions(target)

review_dir <- "C:/workspace/agentic-reviews/reproducibleai-baseline"
write_agentic_routing_review(benchmark, review_dir)
```

The directory contains:

- `REVIEW.md`: a generated checklist and benchmark identifiers;
- `questions.csv`: the editable decision sheet; and
- `exclusions.csv`: maintained files that did not yield a candidate and
  the reason each was excluded.

Open `questions.csv` in RStudio’s data viewer, a text editor, or
spreadsheet software. Long prompts and answers may wrap across visual
lines but remain one CSV row.

``` r

review <- read.csv(
  file.path(review_dir, "questions.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
View(review)
```

## Review each candidate

For every question:

1.  Open `source_path` in the target repository and locate
    `source_heading`.
2.  Decide whether the prompt tests a useful, realistic repository
    competency.
3.  Confirm that the prompt is unambiguous without revealing its
    evidence path or canonical answer.
4.  Confirm that `canonical_answer` is correct, current, minimally
    sufficient, and fully supported by the maintained source.
5.  Edit the prompt or canonical answer if human clarification is
    needed.
6.  Change `review_status` from `pending` to `approved` or `rejected`.
7.  Use `review_note` to explain substantive edits, rejection, or
    uncertainty.

Only these columns are editable:

- `review_status`;
- `review_note`;
- `prompt`; and
- `canonical_answer`.

Identifiers, source evidence, hashes, generator version, and rules hash
are locked provenance. Import fails if those columns change.

The reviewer records the valid expected answer in `canonical_answer`.
They do not answer as if they were Codex and should not paraphrase
merely for style. The answer should remain a concise criterion grounded
in the cited maintained section.

## Review exclusions and coverage

`exclusions.csv` is part of QA, not an error log to ignore. For each
exclusion, ask whether:

- the repository does not need that competency;
- another approved question already covers it;
- the maintained source needs a clearer supported heading; or
- a manually authored competency question is needed.

The deterministic generator intentionally favors precise questions over
broad coverage. Human review supplies the coverage judgment.

## Apply decisions

After saving `questions.csv`, import it:

``` r

reviewed <- apply_agentic_routing_review(benchmark, review_dir)
print(reviewed)
```

By default, import fails while any question remains pending. For a
staged review, preserve partial decisions in R with:

``` r

partially_reviewed <- apply_agentic_routing_review(
  benchmark,
  review_dir,
  require_complete = FALSE
)
```

Continue editing the same CSV. Use the original benchmark or the
partially reviewed object when importing again; the CSV remains the
review record.

## Freeze the criterion

Once every candidate is approved or rejected, write the private
benchmark:

``` r

benchmark_path <- "C:/workspace/agentic-reviews/reproducibleai-baseline.json"
write_agentic_routing_benchmark(reviewed, benchmark_path)

frozen <- read_agentic_routing_benchmark(benchmark_path)
```

Rejected questions remain in the JSON for auditability but are not
executed. Approved questions form the fixed criterion used across
repeated runs and routing-specification variants.

If source hashes, the target commit, or derivation rules change, derive
a new benchmark and review bundle. Do not silently carry approval
forward: the old frozen JSON remains the record for the old criterion.

## Run only after review

``` r

evaluation <- run_agentic_routing_evaluation(
  path = target,
  questions = frozen,
  repetitions = 5,
  approved = TRUE
)
```

This explicit separation makes the roles clear: maintained `dev/`
context supplies the candidate criterion, a human validates it, the
frozen JSON fixes it, Codex supplies stochastic responses, and the
health report summarizes the observed performance.
