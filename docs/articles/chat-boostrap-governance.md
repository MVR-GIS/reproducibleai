# Starting a new AI chat session with a governed bootstrap prompt

This vignette describes a best-practice workflow for starting a new AI
chat session in a repository that uses the development-governance
framework supported by `reproducibleai`.

The goal is to avoid losing momentum between sessions by giving the next
chat a small, structured bootstrap prompt that points it to the right
repository artifacts in the right order.

## Why a chat bootstrap prompt helps

In a governed AI workflow, important project state should already be
captured in repository artifacts such as:

- `dev/10_design.md`
- `dev/05_plan.md`
- `dev/decisions/`
- `dev/instructions/`
- `dev/sessions/`

That means a new chat session should not need an informal “memory file”
to recover context.

However, a short session-start prompt is still useful because it can:

- anchor the chat to the correct repository and branch
- identify the authoritative files to read first
- clarify the role of each artifact
- require a short synthesis before proposing changes

This vignette refers to that pattern as a **chat bootstrap prompt**.

## The chat bootstrap formula

A strong chat bootstrap prompt usually has four parts:

1.  **Anchor the session**
    - identify the repository and branch
2.  **Name the authoritative artifacts**
    - tell the next session exactly what to read
3.  **Clarify document roles**
    - distinguish stable architecture, active plan, working proposal,
      and decision records
4.  **Require synthesis before action**
    - ask for a short summary and the next smallest useful step before
      proposing edits

This works especially well in repositories that use `reproducibleai`
governance artifacts because the repository already contains a
structured context model.

## Recommended document roles

When using the development-governance workflow, the next chat session
should usually distinguish these roles:

- `dev/instructions/CHAT_INSTRUCTIONS.md`
  - repository instruction entrypoint
- `dev/10_design.md`
  - stable current implemented architecture
- `dev/05_plan.md`
  - active work plan
- design-stage architecture documents such as
  `dev/15_local_ai_architecture.md`
  - active architecture extension or working proposal
- ADRs in `dev/decisions/`
  - durable accepted or proposed decision records

This separation helps the next session understand which files
describe: - current implementation - active work - proposed extension -
and formal decisions

## A recommended bootstrap prompt

For repositories using the governance structure above, a good default
prompt is:

``` text
This session is based on @MVR-GIS/reproducibleai on main.

First read:
1. @dev/instructions/CHAT_INSTRUCTIONS.md
2. @dev/10_design.md for the stable current implemented architecture
3. @dev/05_plan.md with attention to the current milestone
4. @dev/15_local_ai_architecture.md for the active local/hybrid AI architecture proposal
5. @dev/decisions/adr-0004-hybrid-ai-methodology-and-mcp-aware-integration.md for the proposed architectural decision

After reading:
- briefly summarize the current architecture state,
- identify the next smallest useful implementation or design step,
- and only then propose concrete edits or code changes.
```

This is only a wild-caught example that was used while developing this
package. In another repository, the exact files will differ.

## Why this format works

This prompt format helps in several ways.

### It reduces ambiguity

The next session does not need to guess: - which design document is
current - which plan is active - which architecture proposal matters -
or which ADR is relevant

### It improves continuity

The bootstrap prompt makes it easier to resume work after: - a new day -
a new browser session - an editor restart - switching AI clients

### It reinforces governance

Instead of relying on an undocumented mental model, the next session is
guided back to: - governed instructions - governed plans - governed
design docs - governed decisions

### It encourages smaller next steps

Asking for the “next smallest useful step” helps reduce wasted motion
and keeps the session oriented toward incremental progress.

## Recommended project conventions

For repositories using `reproducibleai`, the following conventions are
recommended.

### 1. Keep repository instructions persistent

Use `dev/instructions/CHAT_INSTRUCTIONS.md` and related instruction
modules for durable repo-wide guidance.

### 2. Keep restart prompts short

A chat bootstrap prompt should point to authoritative artifacts, not
restate their contents in detail.

### 3. Avoid creating duplicate “memory” files unless truly needed

If: - design state is already in `dev/10_design.md` - active work is
already in `dev/05_plan.md` - decisions are already in
`dev/decisions/` - and working architecture proposals are already
captured in `dev/` design documents

then a separate freeform memory document will often create duplication
and drift.

### 4. Tell the next session what kind of response is wanted first

A good first response is usually: - a brief state summary - the next
recommended step - and only then concrete proposed changes

### 5. Use file references that fit the AI client

If your AI client supports `@` file references, they can make the
bootstrap prompt more explicit and actionable.

## Example adaptation for another repository

Here is a more generic template:

``` text
This session is based on @<owner/repo> on <branch>.

First read:
1. @<instruction entrypoint>
2. @<stable design doc> for the stable current implemented architecture
3. @<active plan> with attention to the current milestone
4. @<working architecture proposal>
5. @<relevant ADR>

After reading:
- briefly summarize the current state,
- identify the next smallest useful step,
- and only then propose concrete edits or code changes.
```

This template can be adapted to many governed repositories, not just
`reproducibleai` itself.

## When a separate memory file may still help

A separate “active memory” document may still be useful when:

- a repository does not yet have a stable governance structure
- important design state has not been promoted into plan/design/ADR
  artifacts
- the active work depends on fragile transient context that has not yet
  been documented elsewhere

In a well-governed repository, however, the preferred pattern is
usually:

- authoritative state in governed artifacts
- lightweight session bootstrap prompt for restart efficiency

not a second layer of semi-authoritative memory.

## Troubleshooting

Common issues:

- **The next session ignores key documents**: make the bootstrap prompt
  more explicit about read order and document roles.
- **The next session proposes changes too early**: ask for a summary and
  next-step recommendation before edits.
- **The next session reads the wrong design file**: explicitly
  distinguish stable design from working proposal.
- **Prompt text becomes too long**: shorten the prompt and rely more on
  governed repository artifacts.
- **Different AI clients behave differently**: keep the bootstrap
  formula stable, but adapt the file reference syntax if needed.

## Summary

A governed repository should not rely on undocumented session memory to
maintain momentum across AI chats.

Instead, the recommended pattern is:

- capture durable state in governed repository artifacts
- use a short bootstrap prompt to point the next chat to those artifacts
- ask for summary before action
- keep the workflow incremental and reviewable

For teams adopting `reproducibleai`, this is a practical best practice
for improving continuity, auditability, and development velocity across
AI-assisted sessions.
