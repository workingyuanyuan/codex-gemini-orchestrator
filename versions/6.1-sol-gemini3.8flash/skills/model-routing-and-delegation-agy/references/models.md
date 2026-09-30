# Model selection

Read when task fit is unclear, a worker leaves a capability gap, or routing is being reviewed. Routine defaults and dispatch settings are in [SKILL.md](../SKILL.md). Exact scores and provenance are in [benchmarks.md](benchmarks.md).

## Tool and scope fit

Prefer Gemini when a self-contained handoff and Antigravity's tools can complete the assignment. Choose native Codex workers for required Codex tools, essential context that cannot be transferred effectively, or capabilities suited to an observed shortfall.

Use Luna for a narrow deliverable. Choose Sol when completion requires coordinating several steps, tracing interactions across modules, or maintaining a larger working context. Luna max and Sol medium serve different task shapes; effort labels do not establish a shared capability scale.

The user selects the main agent's model and effort. The main agent retains requirements, architecture, integration, and final acceptance, and selects workers from the subtask's needs.

## Effort selection

### Gemini: medium for clear deliverables, high for depth

Use medium for self-contained research, organization, implementation, and review with a clear deliverable. Select high when substantial uncertainty, deeper reasoning, or knowledge synthesis is central to completion.

The [shared ten benchmarks](benchmarks.md#shared-10-benchmark-comparison) show mixed coding results between Gemini's efforts: medium leads on Frontier Code, while high leads on SciCode. High's stronger ARC-AGI 2, CritPt, and Humanity's Last Exam results support considering it for deeper work. These measurements inform task fit without establishing a universal coding advantage for either effort.

### Luna: high for readily checked work, max for consequential judgment

High suits evidence gathering and straightforward changes whose correctness is quick to check: locating call sites, extracting configuration, or applying a clear local specification.

Choose max for bounded judgment where subtle mistakes would cause substantial main-agent rework. For example, assess whether one error-handling path misses an exception and return the evidence supporting that conclusion. Weigh review and rework against latency; the user's low concern about Luna's direct cost makes these the more useful selection criteria.

Prefer max when its assignment can run independently of the main agent's next step. If the answer blocks immediate progress, consider narrowing the handoff to evidence gathering with high and keeping the dependent judgment in the main agent. Move to Sol when scope and coordination become the main difficulty.

### Sol: medium for a clear path, high for complex logic, xhigh for sustained reasoning

Medium suits native multi-step work with a clear implementation or investigation path. Select high for complex debugging, cross-module tracing, checking assumptions, or working through edge cases.

Select xhigh for difficult, bounded assignments requiring sustained testing of competing hypotheses or reconciliation of conflicting evidence. File count or step count alone is insufficient to establish that need. Choose the appropriate effort at dispatch.

On the shared ten benchmarks, high improves on medium throughout. Xhigh improves on high on most benchmarks but trails on AA-LCR. This supports a deeper option for demanding assignments while leaving task shape and available tools central to selection.

## Interpreting the evidence

Gemini medium and Luna high have the same supplied cost index; tool access and scope explain Luna's native role. Gemini high and Sol high each lead on different shared benchmarks, supporting task-specific selection.

| Evidence in [benchmarks.md](benchmarks.md) | Use |
| --- | --- |
| Shared 10 benchmarks, 13 profiles | Direct cross-model and cross-effort comparison on those benchmarks |
| Shared 27 benchmarks, four baseline profiles | Broader comparison at Astra max, Sol max, Gemini high, and Luna max |
| Within-model effort datasets | Effort tradeoffs within each model's matched coverage |
| Weighted Cost Index | Relative cost under the same source selection and normalization; lower is better |

The ten benchmarks are a subset of the 27. Within-model datasets have different coverage across models; their aggregates and retention ratios cannot reconstruct comparable shared-set scores. Cost is logarithmically normalized: index point differences do not establish dollar or Codex quota savings. These routing choices combine evidence with workflow judgment, rather than predicting task success from scores.

## Official guidance

[OpenAI's subagent guidance](https://learn.chatgpt.com/docs/agent-configuration/subagents#choosing-models-and-reasoning) recommends Sol for demanding multi-step work and Luna for narrow, repeatable work, starting at medium and high respectively. It associates high with complex logic and xhigh with especially demanding reasoning. The [Astra skills guidance](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) supports concise decision criteria and references loaded as needed.

The seven enabled configurations are Gemini medium/high, Luna high/max, and Sol medium/high/xhigh.
