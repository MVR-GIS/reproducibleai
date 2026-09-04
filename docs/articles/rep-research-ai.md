# Reproducible Research in the Age of AI Agents

### The reproducibility problem did not begin with AI

Reproducible research has transformed scientific computing. Modern
analytical projects can preserve source data, code, computational
environments, parameters, tests, and derived results. Version control
records how implementations change. Automated testing verifies expected
behavior. Literate programming systems allow narrative, computation, and
results to coexist. Yet an important part of scientific work has
remained stubbornly difficult to reproduce:

**Why did the analyst build the system this way?**

Consider the questions that arise when inheriting a mature scientific or
engineering project:

- Why was this particular analytical method selected?
- What does this variable mean in the domain, rather than merely in the
  database?
- Which alternatives were considered and rejected?
- Which assumptions are scientific requirements and which are
  implementation conveniences?
- Why is responsibility divided among these software components?
- Which behavior represents an authoritative requirement?
- Which ideas are provisional?
- What problem was the previous developer actually trying to solve?
- What remains unresolved?

The answers frequently exist only partially in issue trackers, commit
messages, meeting notes, source-code comments, documentation, email,
or—most commonly—in the memory of experienced practitioners. The
computational result may therefore be reproducible while much of the
**reasoning that produced the system is not**.

This is particularly consequential in applied science and engineering
organizations. Analytical systems can persist for decades. Personnel
move between projects and organizations. Scientific terminology is
specialized. Software evolves. Data systems are modernized. New
platforms replace old ones while the underlying engineering knowledge
must survive.

The cost of documenting all of this reasoning manually has historically
been high enough that much of it simply was not captured. AI-assisted
development creates an opportunity to change that.

### AI changes the economics of documentation

Large language models are often discussed primarily as mechanisms for
generating code, answering questions, or accelerating individual tasks.
Those capabilities are useful, but they may not represent their most
consequential contribution to reproducible scientific practice. During
an AI-assisted analytical or development session, practitioners
routinely explain things that were previously left undocumented:

> This feature represents an observation, not a permanent physical
> entity.

> This calculation belongs in the scientific library rather than the
> user interface.

> We considered storing the intermediate raster but rejected it because
> the authoritative product can be reproduced from the source terrain
> and processing parameters.

> These two systems use the same term differently.

> This requirement exists because downstream engineering decisions
> depend on the distinction.

These statements contain **analyst intent, domain semantics,
architectural rationale, constraints, and design requirements**.
Historically, recording this material required the analyst to stop doing
the work and become a documentation author.

With an AI agent already participating in the work, much of the raw
material has been expressed naturally as part of the analytical process.
This suggests a different use for AI:

> **Let the practitioner concentrate on scientific and engineering
> reasoning while the AI helps curate that reasoning into durable,
> structured project knowledge.**

The objective is not to preserve every conversation. The objective is to
preserve what matters after the conversation ends.

## From reproducible computation to reproducible intent

A conventional reproducibility model might emphasize a chain such as:

**data → code → environment → parameters → results**

AI-assisted workflows make it practical to preserve a richer chain:

**intent → evidence → decisions → requirements → implementation →
verification → results**

The second model does not replace the first. It extends it. Code still
matters. Tests still matter. Data provenance still matters.
Computational environments still matter. But the analytical system can
now preserve substantially more information about **why those artifacts
exist and what they are intended to mean**. This is the problem that
`reproducibleai` is intended to address.

## The repository, not the conversation, is the record

A tempting response to AI-assisted work is to preserve prompts and
transcripts. `reproducibleai` takes a different approach. AI
conversations are working environments. They contain exploration,
abandoned ideas, misunderstandings, repetition, intermediate reasoning,
and information that may later be superseded. A transcript can provide
useful historical evidence, but it is a poor substitute for curated
project documentation.

The durable record should instead consist of maintained project
artifacts appropriate to the information being preserved. Depending on
the project, these might include:

- project goals
- architectural descriptions
- architecture decision records
- scientific or engineering requirements
- data and interface contracts
- schemas
- controlled terminology
- feature specifications
- workflows
- provenance requirements
- tests
- implementation status
- checkpoints describing unfinished work

The AI agent helps continuously route consequential information from the
working interaction into these artifacts. This leads to a simple
principle:

> **The repository owns project memory. AI sessions consume and
> contribute to that memory, but they do not replace it.**

This distinction is essential for reproducibility. A project should not
require access to a particular person’s AI conversation history in order
to understand how the project works.

## Govern the record, not the agent’s thought process

AI governance could easily become counterproductive. Modern coding
agents can already inspect repositories, search history, trace
dependencies, run tests, compare implementations, and revise their
approach as evidence emerges. Attempting to prescribe every step of this
process can suppress capabilities that make agentic tools useful in the
first place.

`reproducibleai` therefore favors lightweight governance. The objective
is not to dictate exactly how an agent investigates a problem. Instead,
governance concentrates on what must survive the session:

- consequential analyst intent
- authoritative requirements
- important assumptions
- scientific and engineering decisions
- architectural decisions
- evidence supporting those decisions
- unresolved questions
- provenance
- verification

The distinction is important. An organization should govern **authority,
evidence, and durable outputs** without attempting to govern every
intermediate action an AI system performs.

This resembles good professional practice more generally. Expert
scientists and engineers should never be given scripts prescribing every
cognitive step they must take. They work within requirements concerning
authoritative evidence, accepted methods, quality assurance, review,
documentation, and accountable outputs. Our institutions depend on their
critical thinking and professional judgement. AI-assisted scientific
work should adopt a similar model.

## Human authority remains essential

Capturing more reasoning does not transfer scientific authority to an AI
system. AI-generated code, analysis, documentation, tests, and
recommendations are contributions to an analytical process. They are
not, by themselves, authoritative scientific evidence.

Domain-significant assumptions, methods, interpretations, definitions,
thresholds, transformations, and acceptance criteria must remain
traceable to authoritative evidence or accountable human judgment.

At the same time, requiring human approval for every implementation
detail would eliminate much of the value of agentic development. The
useful boundary is therefore not:

**human work versus AI work**

but rather:

**delegated implementation versus consequential judgment**

An agent can often autonomously determine how to implement an
already-established requirement. It should not silently redefine the
requirement merely because doing so makes implementation easier. The
practitioner retains responsibility for the meaning of the work.

## Durable context as an interface between AI platforms

This approach also changes how different AI tools can work together.
We’ve learned that a conversational reasoning system and a
repository-aware coding agent do not need elaborate platform-to-platform
integration. They can interact asynchronously through the same durable
project record.

For example, a practitioner might use a conversational AI environment to
explore an architectural idea, investigate an external standard, or
challenge a scientific assumption. Once a consequential conclusion is
accepted, it is recorded in the appropriate project artifact. A
repository-aware coding agent can subsequently discover that artifact
and implement against it without needing the original conversation.

Likewise, discoveries made during implementation can become durable
architecture, requirements, decisions, tests, or unresolved issues that
another AI environment can later inspect. The repository becomes the
integration layer:

**human + AI platform A → durable context ← AI platform B + human**

This architecture has an important practical advantage: the scientific
record is not tightly coupled to a particular AI vendor, model,
conversation, or user interface. Why is this critical? AI platforms will
change. The project record should survive them.

## A fresh session is a reproducibility test

This leads to a useful empirical test of documentation quality: Start a
new AI session. Give it access to the repository, but not the previous
conversation. Can it determine:

- what the project is trying to accomplish
- what the current architecture is
- why important design choices were made
- what is implemented
- what is merely proposed
- which requirements are authoritative
- which decisions remain unresolved
- where relevant evidence can be found
- what work is currently incomplete
- what constraints must be preserved?

If it cannot, the immediate response should not necessarily be to
provide a larger prompt.

- The failure may indicate a problem in the durable project context.
- Perhaps important knowledge was never recorded.
- Perhaps it was recorded in the wrong place.
- Perhaps the repository does not route agents toward it.
- Perhaps two documents provide contradictory answers.
- Perhaps obsolete information still appears authoritative.

Are these documentation and knowledge-management defects? If so, they
can be corrected.

`reproducibleai` treats **session-to-session recoverability** as an
observable property of the project. A concise routing file can tell a
new agent where authoritative information lives. Structured project
artifacts provide the actual knowledge. Independent agent sessions can
then test whether that organization works.

The question becomes not:

> Did we write enough documentation?

but:

> Can an independent capable agent reliably recover the intended project
> state from the documentation we maintain?

That is a much more useful criterion.

## Beyond context stuffing

Much contemporary discussion of generative AI focuses on prompts:
finding the ideal prompt, constructing large context windows, or
supplying enough text to induce the desired response.

These techniques can be useful for individual interactions, but they do
not solve the institutional problem.

Repeatedly stuffing project knowledge into prompts creates another form
of ephemeral context. Every session must reconstruct the project again,
and the authoritative source of a statement can become difficult to
distinguish from instructions supplied for convenience. A
durable-context approach asks a different question:

> **What should this project know about itself before the next AI
> session begins?**

That moves the engineering problem away from prompt craftsmanship and
toward familiar disciplines:

- information architecture;
- provenance;
- software architecture;
- knowledge representation;
- controlled vocabulary;
- testing;
- version control;
- scientific documentation.

For rigorous scientific organizations, these are much stronger
foundations than dependence on increasingly elaborate prompts.

## Machine-readable domain knowledge

The same reasoning extends beyond software documentation. Scientific and
engineering organizations depend on specialized terminology whose
meaning may be obvious to experienced practitioners but ambiguous to
general-purpose AI systems. Controlled vocabularies, formal schemas,
linked data, knowledge graphs, and ontologies offer mechanisms for
making those meanings increasingly explicit and machine-readable.

This is not necessary for every project artifact, nor should formal
semantic modeling become a prerequisite for ordinary analytical work.
But as organizations begin using agents across increasingly complex data
and software systems, machine-readable domain semantics become valuable
infrastructure.

An agent that can determine not merely that two databases contain a
field named `reach`, but what a Reach means within an authoritative
engineering model, can reason much more reliably across systems. In this
sense, durable agentic context exists on a continuum:

**narrative intent → structured requirements → schemas and contracts →
controlled vocabulary → formal semantics**

The appropriate degree of formalization depends on the problem. The
underlying goal remains the same: reduce the amount of critical domain
knowledge that exists only implicitly in the minds of individual
experts.

## Why this matters for institutional knowledge

This problem is especially important in long-lived public scientific and
engineering organizations. Institutional knowledge accumulates over
decades. Experienced practitioners understand why systems evolved as
they did, which datasets can be trusted for particular purposes, how
specialized terminology is used, which seemingly arbitrary constraints
resulted from earlier failures, and where formal policy leaves room for
professional judgment.

Personnel eventually change roles or leave the organization. Software
platforms are replaced. Databases migrate. Cloud architectures replace
desktop or on-premises systems. Contracts change.

Without deliberate knowledge capture, each transition risks losing part
of the reasoning that made the previous system authoritative and useful.
AI-assisted workflows provide an opportunity to capture considerably
more of that knowledge as a routine byproduct of doing the work. The
long-term opportunity is therefore larger than code generation.

It is the possibility of routinely capturing **institutional knowledge
as a reproducible research artifact**.

## What `reproducibleai` is trying to provide

`reproducibleai` is an experimental R package for turning these
principles into practical development infrastructure. Its role is
intentionally modest:

- It does not prescribe a universal AI workflow.
- It does not require one AI vendor.
- It does not attempt to preserve every AI interaction.
- It does not attempt to replace scientific judgment.

Instead, the package explores tooling for making durable agentic context
easier to create, maintain, validate, and test. The emerging strategy
is:

1.  **Provide a predictable repository structure for durable context.**
    Important project knowledge should have an identifiable home.

2.  **Give AI agents concise routing instructions.** Agents should be
    able to discover authoritative context without receiving the entire
    project history in a prompt.

3.  **Make documentation part of normal agent-assisted work.** When
    consequential intent, decisions, requirements, or constraints
    emerge, agents should help curate them into durable artifacts.

4.  **Keep ephemeral reasoning distinct from authoritative knowledge.**
    Conversations and exploratory outputs should not silently become
    project truth.

5.  **Preserve human authority over consequential scientific
    decisions.** Automation should reduce clerical burden rather than
    obscure accountability.

6.  **Test recoverability empirically.** Fresh AI sessions can be used
    to evaluate whether project context actually communicates what its
    authors intended.

7.  **Automate only practices that prove useful.** Real projects should
    inform governance patterns before those patterns are generalized
    into tooling.

## An applied experiment

These ideas are being developed through practical scientific software
and data-engineering work rather than as a purely theoretical
AI-governance exercise. A useful development cycle has proven to be:

**real project need → AI-assisted work → durable context → fresh-session
recovery → observed failure → improved context → reusable tooling**

- The project consuming the tooling acts as a proving ground.
- If a new AI session cannot understand an important design decision,
  that is evidence.
- If an agent repeatedly searches the wrong artifact, that is evidence.
- If governance adds ceremony without improving recoverability, that is
  evidence too.
- Practices that survive this process can then be generalized for other
  projects.

This empirical approach is important because agent capabilities are
changing rapidly. Governance designed around assumptions about what an
AI system cannot do may become obsolete quickly—or may actively
interfere with capabilities the system already possesses. A more
worthwile objective is to make the **scientific record itself better**.

## Showing our work

For generations of analysts, “always show your work” has been a
foundational principle. In computational science, we have progressively
expanded what that means. First, preserve the result. Then preserve the
code. Then preserve the data, dependencies, parameters, environments,
and provenance required to reproduce the computation.

AI-assisted workflows make another expansion possible. We can
increasingly preserve:

**what we intended, what we considered, what we decided, why we decided
it, what requirement resulted, how it was implemented, and how we
verified it.**

The practitioner should not have to become a full-time historian of
their own analytical process to achieve this. If the AI systems are
increasingly already participating in the work, they should help carry
the documentation burden. That is the opportunity `reproducibleai` is
exploring:

> **Use AI not only to accelerate scientific work, but to leave behind a
> better scientific record of how and why the work was done.**

If successful, the result is not merely more productive analysts. It is
analytical work that is easier to reproduce, easier to review, easier to
transfer, easier to maintain, and easier for both humans and future AI
systems to understand.
