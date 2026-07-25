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
