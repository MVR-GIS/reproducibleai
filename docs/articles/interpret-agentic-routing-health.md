# Agentic routing, Step 3: Interpret routing health

This is Step 3 of the
[reproducibleai](https://mvr-gis.github.io/reproducibleai/)
agentic-routing workflow:

1.  [Review and freeze the competency
    benchmark](https://mvr-gis.github.io/reproducibleai/articles/review-agentic-routing-benchmarks.md).
2.  [Run the routing
    evaluation](https://mvr-gis.github.io/reproducibleai/articles/agentic-routing-evaluation.md).
3.  **Interpret routing health and plan a comparison** (this article).

Step 3 consumes the aggregate report created in Step 2. It separates
execution validity, routing behavior, answer grounding, efficiency, and
stochastic stability before anyone changes repository instructions.

## Read results in the right order

Interpret each layer only when the preceding layer is valid:

| Order | Question | Measures |
|---:|----|----|
| 1 | Did the experiment execute? | completion, exit status, structured response |
| 2 | Did Codex find required evidence? | required-evidence recall |
| 3 | Did Codex avoid unnecessary evidence? | relevant-evidence precision, tool calls |
| 4 | Did the answer resemble the fixed criterion? | canonical-answer token F1 or authored-term recall |
| 5 | How much context and time did it use? | input, cached input, output, elapsed time |
| 6 | Is the behavior stable? | repetitions, minimum score, standard deviation |

If completion is zero, stop at Layer 1. A CLI, authentication, network,
or schema failure is not evidence that `AGENTS.md` routed poorly.

## Understand the component score

The combined score is transparent:

``` text
(0.40 * required-evidence recall +
 0.20 * relevant-evidence precision +
 0.30 * answer score +
 0.10 * completion)
* (1 - forbidden-term rate)
```

For generated questions, answer score is literal multiset token F1
against the reviewed canonical answer. This makes the score repeatable
but intentionally conservative. A low value can mean an incorrect
answer, paraphrase, an answer that is much broader than the criterion,
or a criterion that is too narrow. Inspect private raw evidence before
choosing among those explanations.

Token counts are observations, not universal pass/fail thresholds.
Compare them against a maintained baseline under the same benchmark,
target task, model, and runtime settings.

## Interpret the first `{reproducibleai}` baseline

The first durable report is maintained at
`dev/governance/agentic-routing-health.md`. It evaluates commit
`202172f` with one run for each of 11 reviewed competencies.

| Signal | Baseline | Interpretation |
|----|---:|----|
| Completion | 100.0% | All structured sessions executed |
| Required-evidence recall | 100.0% | Every task found its required source |
| Relevant-evidence precision | 90.9% | Two architecture tasks inspected one extra artifact |
| Answer score | 39.4% | Responses were often broader or differently phrased than concise criteria |
| Weighted health | 80.0/100 | Strong retrieval baseline with answer-breadth sensitivity |
| Mean input tokens | 53,106 | Establishes an efficiency baseline; not yet a threshold |
| Mean cached input tokens | 36,631 | About 69% of reported input was cached |
| Mean tool calls | 2.2 | Most questions required one or two evidence operations |
| Repetitions | 1 per question | Stability cannot yet be estimated |

The defensible conclusion is narrow: the current context framework
reliably delivered required evidence in this pilot. The architecture
route sometimes expanded beyond the minimum source, and answer/token
behavior deserves a controlled follow-up. The pilot does not establish
that 53,106 input tokens is intrinsically too high, nor that low literal
F1 means the substantive answer was wrong.

## Diagnose a low question

For a low-scoring question:

1.  Confirm completion and inspect its external stderr and JSONL.
2.  Compare `evidence_paths` with required and allowed paths.
3.  Compare the private response with the canonical answer.
4.  Classify the issue as missing evidence, extra evidence, incorrect
    content, paraphrase, answer breadth, criterion weakness, or
    stochastic variation.
5.  Record the diagnosis before proposing an instruction change.

Do not put raw answers or canonical criteria into the target repository.
The durable health report intentionally contains only aggregate
evidence.

## Plan the next comparison

Treat tuning as a controlled experiment:

1.  Keep the frozen benchmark, target commit, model, and runtime
    settings fixed.
2.  State one routing-specification hypothesis.
3.  Create a dedicated clean worktree for each specification variant.
4.  Use enough repetitions to estimate variation; three to five per
    selected sentinel question is a practical next sensitivity pass.
5.  Compare routing recall and answer quality together with token and
    time cost.
6.  Prefer changes that improve or preserve quality while reducing
    context cost.
7.  Validate the selected change on held-out questions or repositories.

For this baseline, the first hypothesis should target architecture-task
specificity and stopping behavior because those questions used the most
input, made the most tool calls, and supplied the only imperfect route
precision. That is a testable recommendation, not an automatic edit.

## Continue the cycle

When the benchmark criterion itself changes, return to [Step
1](https://mvr-gis.github.io/reproducibleai/articles/review-agentic-routing-benchmarks.md)
and perform human review again. When only the routing specification
changes, reuse the frozen benchmark and repeat Steps 2 and 3 in clean,
pinned worktrees.
