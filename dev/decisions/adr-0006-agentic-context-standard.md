# ADR-0006: Replace session instruction modules with durable agentic context

- Status: accepted
- Date: 2026-07-24
- Standard version: 0.1

## Context

The package previously copied instruction modules into `dev/instructions/`,
generated `CHAT_INSTRUCTIONS.md`, and treated archived session transcripts as a
reproducibility mechanism. That model duplicated context, required bootstrap
prompts, consumed attention with historical conversation, and allowed durable
project knowledge to remain dispersed.

`FG-architecture` established a more efficient pattern: concise standing rules
in `AGENTS.md` route tasks to purpose-specific maintained artifacts. Git records
superseded history, while checkpoints preserve only useful resumable state.

The package is young, has one user, and has no compatibility requirement.

## Decision

`{reproducibleai}` will provide versioned, deterministic scaffolding for durable
agentic context:

- root `AGENTS.md` contains concise rules and conditional routes;
- durable detail lives in plural-purpose directories under `dev/`;
- profiles are declarative overlays on a required base profile;
- a manifest records the standard version, selected profiles, and seed hashes;
- scaffolding never overwrites repository-owned content;
- migration planning is read-only;
- applying a migration requires explicit approval, creates and validates
  replacements first, and removes superseded tracked sources last;
- untracked, modified, or unresolved legacy content blocks removal; and
- transcript capture, instruction recipes, copied modules, and compatibility
  wrappers are removed.

Standard 0.1 implements the `base` and `r-package` profiles. It does not invoke a
model or evaluate routing effectiveness.

## Consequences

Repositories receive compact, automatically discoverable standing context and
durable routed documentation. Local edits remain repository-owned and appear as
upgrade warnings rather than being overwritten.

Existing users must migrate directly to the new API. `fluvgeo` and `ohwm2`
contain known calls to the removed instruction interface and require explicit
migration.

Routing evaluation, repeated Codex runs, competency questions, health reports,
and prompt tuning remain a separate later feature after target repositories
adopt this standard.

ADR-0003 is superseded by this decision. ADR-0001 remains historical evidence of
the earlier governance model.
