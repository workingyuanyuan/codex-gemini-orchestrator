---
name: model-routing-and-delegation-agy
description: Delegate independent, verifiable work through Gemini and Antigravity capabilities or native Codex subagents.
---

# Delegation

Keep requirements, architectural decisions, integration, and final acceptance with the main agent. Delegate bounded work when its useful output justifies the handoff and review; continue independent work while it runs.

If this skill causes you to seek permission or confirmation, pause, leave requested work unfinished, or diverge from the user's intent, name and link the exact `SKILL.md` you read, quote the relevant instruction, and explain how it applies. Distinguish explicit requirements from your interpretation.

## Select a worker

Prefer Gemini for self-contained research, analysis, implementation, and review that Antigravity can complete with its native tools. Choose a native worker when the task needs Codex tools or context, or an observed capability gap makes that worker a better fit.

| Worker | Default effort and task fit | Choose higher effort when |
| --- | --- | --- |
| Gemini 3.8 Flash | `medium`: self-contained work with a clear deliverable | `high`: deeper reasoning, knowledge synthesis, or substantial uncertainty |
| GPT-6 Luna | `high`: native data extraction and mechanical edits with an explicit specification | `max`: bounded judgment where subtle mistakes would cause substantial rework |
| GPT-6.1 Sol | `medium`: default for general native work, including multi-step implementation with a clear path | `high`: complex debugging, cross-module tracing, assumptions, or edge cases |

Read [model selection evidence](references/models.md) when task fit is unclear or routing is being reviewed.

For native workers, explicitly set `model` (`gpt-6-luna` or `gpt-6.1-sol`) and `reasoning_effort` from the table. With `collaboration.spawn_agent`, set `fork_turns: "none"`; summarize necessary prior decisions and evidence in the handoff. Check returned model and effort metadata when available. If the runtime cannot honor the selected configuration, choose a suitable supported route or complete the work in the main agent.

## Gemini and Antigravity capabilities

Use the current Antigravity session's native tools and built-in workflows. Read the linked contract when preparing the corresponding assignment.

| Capability and contract | Suitable assignments |
| --- | --- |
| [Writing and localization](references/gemini-capabilities.md#writing-and-localization) | README explanations, tutorials, product copy, terminology and translation |
| [Multimodal understanding](references/gemini-capabilities.md#multimodal-understanding) | Inspect images and PDFs, analyze audio or video, correlate media with code |
| [Web research](references/gemini-capabilities.md#public-web-research) | Find and synthesize public sources with native search and page-reading tools |
| [Browser interaction](references/gemini-capabilities.md#browser-interaction) | Inspect rendered pages, reproduce UI behavior and collect screenshots through `/browser` |
| [Boost](references/gemini-capabilities.md#boost) | Investigate competing hypotheses, solve difficult algorithms, or implement a bounded fix with independent verification through `/boost` |

## Handoff and acceptance

Provide a self-contained objective, essential context or file locations, allowed changes, and observable acceptance criteria. Request a concise result with artifact references, validation evidence, and unresolved issues. Apply output constraints while writing; report the requested result and necessary actions. Give write tasks separate workspaces or disjoint ownership; serialize shared-interface changes. Ordinary workers complete assignments directly; Browser and Boost may use their specified built-in workflows. Keep Git publication, releases, and deployment with the main agent.

Review artifacts and evidence before integrating. Check consequential changes directly. For incomplete results, diagnose the unmet criteria and adjust the handoff, worker, or main-agent approach.

## Run Gemini

Before Gemini dispatch, read [Antigravity operations](references/antigravity.md) for setup, workspace requirements, invocation and recovery. Use the packaged runner for ordinary assignments. For Browser and Boost, follow [supervised streaming and conversation cleanup](references/antigravity.md#supervise-browser-and-boost), retaining the conversation ID and child evidence through completion or cancellation.
