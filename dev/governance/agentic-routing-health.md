# Agentic routing health

- Repository: `reproducibleai`
- Git SHA: `202172f1296f26c536c0f73a4c0cf9ef7ae358be`
- Model: `configured-default`
- Codex CLI: `codex-cli 0.145.0`
- Evaluated: 2026-07-25T18:27:51Z
- Questions: 11
- Runs: 11
- Completion rate: 100.0%
- Weighted health score: 80.0/100
- Mean required-evidence recall: 100.0%
- Mean relevant-evidence precision: 90.9%
- Mean answer score: 39.4%
- Mean input tokens: 53106
- Mean cached input tokens: 36631
- Mean output tokens: 632
- Mean tool calls: 2.2
- Mean elapsed seconds: 23.87

The score summarizes repeated stochastic runs; it is not a deterministic proof of correctness.
Private rubrics and raw traces are intentionally stored outside the evaluated repository.
This pilot has one observation per question and cannot estimate run-to-run stability.
Token and timing metrics are descriptive until compared with a maintained baseline or threshold.

## Question results

| Question | Runs | Complete | Score | SD | Recall | Precision | Answer | Input | Cached | Output | Tools | Seconds |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `auto-architecture-ai-workstation-spec-purpose` | 1 | 100.0% | 63.8% | NA | 100.0% | 50.0% | 12.5% | 82600 | 62464 | 991 | 4.0 | 38.48 |
| `auto-architecture-design-system-boundary` | 1 | 100.0% | 77.4% | NA | 100.0% | 100.0% | 24.6% | 64624 | 38400 | 683 | 2.0 | 21.85 |
| `auto-architecture-local-ai-architecture-purpose` | 1 | 100.0% | 68.1% | NA | 100.0% | 50.0% | 26.8% | 97489 | 71680 | 997 | 4.0 | 35.20 |
| `auto-decision-adr-0001-development-governance-decision` | 1 | 100.0% | 88.2% | NA | 100.0% | 100.0% | 60.7% | 46135 | 29184 | 512 | 2.0 | 23.02 |
| `auto-decision-adr-0002-parameterized-help-decision` | 1 | 100.0% | 87.5% | NA | 100.0% | 100.0% | 58.4% | 46180 | 41216 | 511 | 2.0 | 18.41 |
| `auto-decision-adr-0003-handler-based-instruction-installations-decision` | 1 | 100.0% | 85.3% | NA | 100.0% | 100.0% | 51.0% | 46495 | 29184 | 562 | 2.0 | 20.69 |
| `auto-feature-agentic-context-standard-user-outcome` | 1 | 100.0% | 76.9% | NA | 100.0% | 100.0% | 23.0% | 46020 | 29184 | 522 | 2.0 | 21.25 |
| `auto-feature-agentic-routing-evaluation-user-outcome` | 1 | 100.0% | 75.9% | NA | 100.0% | 100.0% | 19.6% | 31102 | 14080 | 613 | 1.0 | 19.49 |
| `auto-goal-project-plan-current-objective` | 1 | 100.0% | 80.1% | NA | 100.0% | 100.0% | 33.8% | 46595 | 43264 | 734 | 2.0 | 24.03 |
| `auto-workflow-complete-development-task-procedure` | 1 | 100.0% | 89.5% | NA | 100.0% | 100.0% | 65.0% | 46481 | 30208 | 416 | 2.0 | 16.86 |
| `auto-workflow-r-package-development-procedure` | 1 | 100.0% | 87.2% | NA | 100.0% | 100.0% | 57.5% | 30443 | 14080 | 414 | 1.0 | 23.35 |

## Recommendations

- `auto-architecture-ai-workstation-spec-purpose`: narrow the route or remove distracting context.
- `auto-architecture-ai-workstation-spec-purpose`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-architecture-design-system-boundary`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-architecture-local-ai-architecture-purpose`: narrow the route or remove distracting context.
- `auto-architecture-local-ai-architecture-purpose`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-decision-adr-0001-development-governance-decision`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-decision-adr-0002-parameterized-help-decision`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-decision-adr-0003-handler-based-instruction-installations-decision`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-feature-agentic-context-standard-user-outcome`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-feature-agentic-routing-evaluation-user-outcome`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-goal-project-plan-current-objective`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-workflow-complete-development-task-procedure`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.
- `auto-workflow-r-package-development-procedure`: inspect prompt-to-criterion alignment and response breadth; low literal grounding can reflect paraphrase, excess context, or unclear durable evidence.

## Scoring contract

- 40% required evidence recall
- 20% relevant evidence precision
- 30% canonical-answer token F1 for generated questions, or expected-term recall for authored questions
- 10% successful execution and structured response
- The combined score is multiplied by one minus the forbidden-term rate.

Review recommendations against the underlying runs before changing repository instructions.
