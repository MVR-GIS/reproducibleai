# ADR-0008: Derive competency criteria independently from routing instructions

## Status

Accepted

## Context

Hand-authoring every routing question is burdensome, but using the model or the
routing specification to generate gold answers would couple the criterion to
the system under test. That circularity would weaken comparisons between
instruction formulations.

## Decision

`{reproducibleai}` will use a versioned deterministic parser and conservative
heading templates to derive factual competency candidates from maintained
`dev/` artifacts. The generator will not read `AGENTS.md` or call a model.

Every generated item will retain its source path, heading, source hash,
derivation-template identifier, and canonical answer. It begins as pending and
cannot be executed until a human explicitly approves or rejects all candidates.
Human QA will use an external flat review bundle containing instructions,
editable question rows, and derivation exclusions. Import will allow edits only
to decision status, review note, prompt, and canonical answer while validating
all provenance columns. Reviewed benchmarks are then frozen outside the target
repository.

Generated retrieval and grounding answers use literal multiset token F1.
Manually authored questions remain available for synthesis or judgment that
cannot be represented by a maintained factual section.

## Consequences

- The benchmark criterion is auditable and independent of routing instructions.
- Repeated routing variants can use an identical frozen benchmark.
- Human review remains necessary to detect ambiguous, trivial, or obsolete
  questions.
- Reviewers can work in a CSV-capable editor without manipulating nested R
  objects or JSON.
- Version 0.1 favors precision over coverage by excluding code fences, tables,
  oversized sections, unsupported headings, and generated governance reports.
- The framework measures context delivery and grounded recall; it does not
  establish semantic equivalence or scientific correctness.
