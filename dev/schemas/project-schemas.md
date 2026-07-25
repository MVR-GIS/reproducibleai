# Agentic-context schemas

## Standard manifest

Path: `dev/agentic-context.yml`

Required scalar fields:

- `schema_version`: integer, currently `1`
- `standard_version`: string, currently `"0.1"`
- `installed_by`: package identifier
- `package_version`: package version or `"development"`
- `hash_algorithm`: currently `md5`

Required collections:

- `profiles`: ordered, unique profile names; `base` first
- `seeded_files`: relative paths mapped to hashes

The manifest does not contain branch, sprint, prompt, or transcript state.

## Profiles

Supported standard 0.1 profile identifiers:

- `base`
- `r-package`

Input profiles are unique, non-empty strings. Normalization prepends `base` and
preserves the remaining caller order.

## Migration plan

A migration plan contains:

- repository path
- standard version
- selected profiles
- an operations data frame

Every operation contains:

- `action`: `create`, `preserve`, `move`, `remove`, or `manual_review`
- `source`: relative source path when applicable
- `target`: relative destination path when applicable
- `status`: `ready` or `manual_review`
- `reason`: human-readable evidence and rationale
- `source_hash`: pre-application source hash for destructive operations

Application is prohibited while any operation has `manual_review` status.

## Migration ordering

The required mutation order is:

1. revalidate destructive sources
2. create scaffold
3. copy mapped artifacts
4. validate replacement structure
5. remove superseded sources
6. validate final structure
7. write durable migration report

## Validation findings

Every finding contains:

- `level`: `error`, `warning`, or `info`
- `code`: stable machine-readable identifier
- `path`: repository-relative affected path
- `message`: concise human-readable explanation

`valid` is `FALSE` if and only if at least one error exists. Strict validation
raises an R error only after constructing the findings.

## Agentic-routing question fixture

The JSON fixture has:

- `schema_version`: integer, currently `2` (`1` remains readable)
- `questions`: non-empty array of question objects

Every question contains:

- `id`: stable identifier matching `[A-Za-z0-9][A-Za-z0-9._-]*`
- `prompt`: task text sent to Codex
- `required_paths`: non-empty array of repository-relative evidence paths
- `allowed_paths`: array of other relevant evidence paths
- `expected_terms`: array of case-insensitive literal answer terms
- `forbidden_terms`: array of case-insensitive literal superseded/incorrect terms
- `weight`: positive numeric aggregate weight
- optional `canonical_answer`, review status, artifact type, source heading,
  source hash, and derivation-template identifier

A required or allowed path ending in `/` matches descendants. Other paths match
exactly after slash normalization.

## Generated routing benchmark

The frozen benchmark schema is version `1` and records generator version,
repository label, target Git SHA, derivation-rules hash, question objects, and
derivation exclusions. It contains no generation timestamp, so identical
source files and rules serialize deterministically.

Generated questions begin with review status `pending`. Evaluation is
prohibited while any candidate remains pending; rejected items are retained in
the benchmark but omitted from execution. Frozen benchmarks and their canonical
answers must remain outside the repository being evaluated.

## Agentic-routing review bundle

The external review directory contains:

- `REVIEW.md`: generated benchmark identity, QA checklist, editable-column
  contract, and completion instructions
- `questions.csv`: one row per candidate
- `exclusions.csv`: source path, derivation rule, and exclusion reason

Editable question columns are `review_status`, `review_note`, `prompt`, and
`canonical_answer`. All remaining columns are locked provenance and must match
the original in-memory benchmark during import. The question fixture also
retains the optional human `review_note`.

Complete review requires every status to be `approved` or `rejected`. Partial
import is permitted only when explicitly requested. Review bundles contain gold
answers and must remain outside the evaluated repository.

## Agentic-routing prerequisite diagnostic

The local diagnostic contains:

- `ready`: whether local preflight checks passed
- `cli_available`: whether a runnable standalone Codex CLI was found
- `codex_path`: local resolved executable path, never written to a health report
- `codex_version`: reported CLI version
- `authentication`: `authenticated`, `not_authenticated`, or `unavailable`
- optional repository path, context validity, Git SHA, and clean-worktree state
- `network_policy`: currently `not_tested`
- human-readable limitations and local discovery errors

`ready` does not assert network access, service entitlement, or enterprise
policy approval. The diagnostic never starts a model run or installs,
authenticates, or reconfigures software.

## Structured routing response

The Codex final response schema is versioned at
`inst/agentic-routing/1/result-schema.json` and requires:

- `answer`: string
- `evidence_paths`: unique array of repository-relative strings
- `route_summary`: string
- `confidence`: number from zero through one

## Routing run record

Every run records question ID, repetition, weight, completion, exit status,
component and combined scores, confidence, token usage when available, tool-call
count, elapsed seconds, answer, route summary, evidence paths, error text, and
external raw-artifact paths.

The combined score is:

```text
(0.40 * route recall +
 0.20 * route precision +
 0.30 * answer score +
 0.10 * completion)
* (1 - forbidden-term rate)
```

An incomplete run receives a score of zero.
Answer score is canonical-answer multiset token F1 for generated questions and
expected-term recall for manually authored questions.

## Routing health report

The durable Markdown report contains repository name, Git SHA, model and Codex
CLI labels, evaluation timestamp, run and question counts, completion rate,
weighted health score, per-question aggregate metrics, threshold-based
recommendations, and the scoring contract.

It must not contain private prompts, rubrics, raw answers, event streams,
stderr, credentials, or absolute user paths.
