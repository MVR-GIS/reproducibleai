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

- `schema_version`: integer, currently `1`
- `questions`: non-empty array of question objects

Every question contains:

- `id`: stable identifier matching `[A-Za-z0-9][A-Za-z0-9._-]*`
- `prompt`: task text sent to Codex
- `required_paths`: non-empty array of repository-relative evidence paths
- `allowed_paths`: array of other relevant evidence paths
- `expected_terms`: array of case-insensitive literal answer terms
- `forbidden_terms`: array of case-insensitive literal superseded/incorrect terms
- `weight`: positive numeric aggregate weight

A required or allowed path ending in `/` matches descendants. Other paths match
exactly after slash normalization.

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
 0.30 * expected-term recall +
 0.10 * completion)
* (1 - forbidden-term rate)
```

An incomplete run receives a score of zero.

## Routing health report

The durable Markdown report contains repository name, Git SHA, model and Codex
CLI labels, evaluation timestamp, run and question counts, completion rate,
weighted health score, per-question aggregate metrics, threshold-based
recommendations, and the scoring contract.

It must not contain private prompts, rubrics, raw answers, event streams,
stderr, credentials, or absolute user paths.
