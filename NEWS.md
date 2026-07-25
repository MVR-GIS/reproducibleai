# reproducibleai 2026.07.25.9000

### Agentic-routing evaluation

* Added versioned competency-question fixtures with private routing and answer
  rubrics.
* Added deterministic competency derivation from maintained `dev/` sections,
  mandatory human review, provenance hashes, and externally frozen benchmarks.
* Added canonical-answer token precision, recall, and F1 for generated
  retrieval and grounding questions.
* Added explicitly approved, repeated, ephemeral, read-only `codex exec`
  evaluation with JSONL event capture and schema-constrained responses.
* Added transparent routing, answer, completion, usage, and variability metrics.
* Added aggregate Markdown health reports that omit raw prompts, rubrics, and
  traces from the evaluated repository.
* Added contamination controls that keep gold fixtures and raw runs outside the
  repository under evaluation.
* Added no-usage prerequisite diagnostics and robust discovery of the
  user-local standalone Codex CLI on Windows.
* Clarified that deterministic package capabilities require neither Codex nor a
  cloud account, while live evaluation remains optional and subject to local
  application, identity, and network policy.

# reproducibleai 2026.07.24.9000

### Agentic-context standard 0.1

* Replaced instruction modules, recipes, `CHAT_INSTRUCTIONS.md`, and session
  transcript tooling with a durable `AGENTS.md`-routed repository standard.
* Added deterministic base and R-package scaffolds with a version manifest and
  seed hashes.
* Added read-only profile detection and migration planning.
* Added explicitly approved migration application that validates replacements
  before removing tracked, unchanged legacy files.
* Added structured validation suitable for interactive use, tests, and CI.
* Allowed `use_sbom()` to run non-interactively so its deterministic scaffold
  can be exercised in tests and automation.
* Removed the superseded `use_instructions()`, `instructions_available()`,
  `instructions_recipes()`, `extract_copilot_chat()`, and
  `cleanup_session_backups()` interfaces without compatibility wrappers.
