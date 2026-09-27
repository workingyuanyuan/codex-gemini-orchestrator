# Model selection

Read when task fit is unclear, a worker leaves a capability gap, or routing is being reviewed. Routine defaults and dispatch settings are in [SKILL.md](../SKILL.md). Exact scores and provenance are in [benchmarks.md](benchmarks.md).

## Tool and scope fit

Gemini is the preferred worker when a self-contained handoff and Antigravity's tools can complete the assignment. Choose native Codex workers when they need a Codex tool, essential context that cannot be transferred effectively, or capabilities suited to an observed shortfall.

For native work, use Luna for a narrow deliverable with clear boundaries. Choose Sol when completion requires coordinating several steps, tracing interactions across modules, or maintaining a larger working context. Luna max and Sol medium serve different task shapes; their effort labels do not establish a shared capability scale.

The main agent retains requirements, architecture, integration, and final acceptance at the user's selected model and effort. Astra measurements provide reference context. Routine selection uses the task's requirements without inspecting the main agent's model or calculating a score gap.

## Effort selection

### Gemini: medium by default, high for depth

Medium suits self-contained research, organization, implementation, and review with a clear deliverable. Select high when substantial uncertainty, deeper reasoning, or knowledge synthesis is central to completion.

On the shared nine benchmarks, medium leads high on AA-LCR and Frontier Code 1.1, ties AutomationBench, and trails on six others. Frontier Code is 41.2 versus 38.0, while SciCode is 55.1 versus 56.6. These mixed results do not establish a general coding advantage for medium. High leads by 6.0 on CritPt and 5.7 on Humanity's Last Exam. Medium's Cost is 35.8% lower.

### Luna: high by default, max for demanding narrow work

High suits native search, extraction, code mapping, and local modifications with clear acceptance criteria. Select max when the assignment remains narrow but requires substantial inference or verification. Move to Sol when scope and coordination become the main difficulty.

Within Luna's separate effort dataset, high has 35.8% lower Cost than max, with 22.0% lower Reasoning and 15.1% lower Agentic scores. These are measured score changes within Luna's dataset, not predicted task failure rates.

### Sol: medium by default, high for complex logic

Medium suits native multi-step work with a clear implementation or investigation path. Select high for complex debugging, cross-module tracing, checking assumptions, or working through edge cases.

High exceeds medium on all nine shared benchmarks for about 7.9% higher Cost. The largest point increases are AA-Briefcase (+8.6) and AutomationBench (+4.3). This supports choosing high directly for demanding tasks while keeping medium as the routine entry.

## Cross-model tradeoffs

Two comparisons help resolve common routing questions on the shared nine-benchmark set:

- **Gemini medium and Luna high:** both have Cost 18.1. Gemini scores higher on eight benchmarks; Luna scores higher on CritPt (15.4 versus 12.3). Tool access and scope explain Luna's native role.
- **Gemini high and Sol high:** Gemini leads on AA-Briefcase, AA-Omniscience, GDPval-AA, Humanity's Last Exam, and SciCode. Sol leads on AA-LCR, AutomationBench, CritPt, and Frontier Code 1.1. Sol's leads on CritPt and Frontier Code are 7.1 and 9.7 points. Neither profile leads on every benchmark.

These observations inform task-fit judgments; benchmark counts do not establish overall task quality. Consider the unmet requirement and available tools before changing model or effort after an incomplete result. Missing context, authentication, or an unavailable tool needs its own correction.

## Evidence coverage

| Evidence in [benchmarks.md](benchmarks.md) | Use |
| --- | --- |
| Shared 9 benchmarks, all 12 profiles | Direct cross-model and cross-effort comparison on those nine benchmarks |
| Shared 25 benchmarks, four baseline profiles | Broader comparison at Astra max, Sol max, Gemini high, and Luna max |
| Separate within-model effort datasets | Effort tradeoffs within each model only |
| Common Cost scale | Relative cost across supplied profiles; lower is better |

The nine benchmarks are a subset of the 25; their overlapping results are not independent evidence. Different models' separate effort datasets use different benchmark coverage. Do not compare those aggregates across models or apply their retention ratios to the shared tables. Cost uses the user's conversion and does not directly measure Codex allowance or total workflow expenditure.

## Official guidance

[OpenAI's subagent guidance](https://learn.chatgpt.com/docs/agent-configuration/subagents#choosing-models-and-reasoning) describes Sol for demanding multi-step work and Luna for narrow, repeatable work, with medium and high as their respective starting efforts. It recommends higher effort for complex logic, assumptions, and edge cases. [Astra's guide](https://developers.openai.com/api/docs/guides/latest-model) covers difficult end-to-end work.

The routing choices here combine that guidance with the user's supplied evidence and the available tools. The six enabled configurations are Gemini medium/high, Luna high/max, and Sol medium/high.
