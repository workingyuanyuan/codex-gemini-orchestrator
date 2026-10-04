# Model selection

Read when task fit is unclear, a worker leaves a capability gap, or routing is being reviewed. Routine defaults and dispatch settings are in [SKILL.md](../SKILL.md). Exact scores and provenance are in [benchmarks.md](benchmarks.md).

## Tool and scope fit

Prefer Gemini when a self-contained handoff and Antigravity's native tools can complete the assignment. Choose native Codex workers for required Codex tools, essential context that cannot be transferred effectively, or capabilities suited to an observed shortfall.

Use Luna high for data extraction and mechanical edits with an explicit specification, and Luna max for narrow judgment tasks. Use GPT-6.1 Sol medium as the default for general native work, especially when completion requires coordinating several steps, tracing interactions across modules, or maintaining a larger working context. Compare Luna max and Sol medium by task fit and measured performance.

The user selects the main agent's model and effort. The main agent retains requirements, architecture, integration, and final acceptance, and selects workers from the subtask's needs.

## Effort selection

### Gemini: medium for clear deliverables, high for depth

Use medium for self-contained research, organization, implementation, and review with a clear deliverable. Select high when substantial uncertainty, deeper reasoning, or knowledge synthesis is central to completion.

Gemini's Language score is 84.6 on the shared 30-benchmark set, supporting consideration for writing and localization. Its native media access and Antigravity's Browser and Boost workflows also provide concrete task fits. Use the [capability contracts](gemini-capabilities.md) to select inputs, invocation and acceptance evidence.

On the [shared 11 benchmarks](benchmarks.md#shared-11-benchmark-comparison), Gemini high gains 6.1 Reasoning and 3.6 Knowledge points over medium, while Coding gains 0.3 and Comprehension falls 1.8. These aggregates support considering high for deeper reasoning and knowledge synthesis.

### Luna: high for extraction and mechanical edits, max for bounded judgment

High suits data extraction and mechanical changes with an explicit specification: locating call sites, extracting configuration, or applying a prescribed local substitution. Use max or Sol when the assignment requires substantive judgment. On the shared 11 benchmarks, Luna max gains 16.0 Reasoning and 5.5 Coding points over high.

Choose max for bounded judgment where subtle mistakes would cause substantial main-agent rework. For example, assess whether one error-handling path misses an exception and return the evidence supporting that conclusion. Weigh review effort, rework, and latency when selecting the worker.

Use independence to decide whether the handoff is worthwhile. Select the model and effort by difficulty, scope, required tools, and review overhead. Move to Sol when scope and coordination become the main difficulty.

### GPT-6.1 Sol: medium for a clear path, high for complex logic

Medium is the default for general native delegation, including multi-step work with a clear implementation or investigation path. Select high for complex debugging, cross-module tracing, checking assumptions, or working through edge cases. Choose the appropriate effort at dispatch.

On the shared 11 benchmarks, high exceeds medium in all supplied capability aggregates, including Overall (+2.1), Reasoning (+3.6), and Coding (+0.9), at a cost-index increase of 4.3. Use medium/high for GPT-6.1 Sol delegation.

## Interpreting the evidence

Gemini medium and Luna high have the same supplied cost index, as do Gemini high and Luna max. Tool access and scope explain Luna's native role. GPT-6.1 Sol medium exceeds Gemini high in all supplied capability aggregates on the shared 11-benchmark set, at a higher cost index. Task fit and workflow overhead remain routing considerations.

| Evidence in [benchmarks.md](benchmarks.md) | Use |
| --- | --- |
| Shared 11 benchmarks, 12 profiles | Cross-model and cross-effort comparison of supplied aggregates |
| Shared 30 benchmarks, four baseline profiles | Broader comparison at Astra max, GPT-6.1 Sol max, Gemini high, and Luna max |
| Cost | Relative cost index; lower is better |

Compare aggregates within the same dataset. Interpret Cost as a relative index. Combine the benchmark evidence with task fit and workflow overhead.

The six enabled configurations are Gemini medium/high, Luna high/max, and GPT-6.1 Sol medium/high.
