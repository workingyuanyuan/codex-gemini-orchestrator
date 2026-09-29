---
name: model-routing-and-delegation-agy
description: Delegate independent, verifiable work through Gemini or native Codex subagents.
---

# Delegation

Keep requirements, architectural decisions, integration, and final acceptance with the main agent. Delegate bounded work when its useful output justifies the handoff and review; continue independent work while it runs.

## Select a worker

Prefer Gemini for self-contained research, analysis, implementation, and review that Antigravity can complete with its tools. Choose a native worker when the task needs Codex tools or context, or an observed capability gap makes that worker a better fit.

| Worker | Default effort and task fit | Choose higher effort when |
| --- | --- | --- |
| Gemini 3.8 Flash | `medium`: self-contained work with a clear deliverable | `high`: deeper reasoning, knowledge synthesis, or substantial uncertainty |
| GPT-6 Luna | `high`: native evidence gathering and straightforward changes whose correctness is quick to check | `max`: bounded judgment where subtle mistakes would cause substantial rework |
| GPT-6 Sol | `medium`: native multi-step work with a clear path | `high`: complex debugging, cross-module tracing, assumptions, or edge cases; `xhigh`: difficult bounded assignments requiring sustained testing of competing hypotheses or reconciliation of conflicting evidence |

Choose the appropriate effort at dispatch; higher effort does not require a failed default attempt. Prefer Luna max for work that can run independently of the main agent's next step. Distinguish Luna max from Sol medium by scope and coordination needs. Read [model selection evidence](references/models.md) only when task fit is unclear or routing is being reviewed.

For native workers, explicitly set `model` (`gpt-6-luna` or `gpt-6-sol`) and `reasoning_effort` from the table. With `collaboration.spawn_agent`, use `fork_turns: "none"` and a self-contained handoff; include limited history only when necessary and supported. Avoid custom agent configurations that override the selected model or effort. Honor the runtime's available models and controls; if a route is unavailable, report it and choose a suitable available worker or the main agent. Keep the main agent's model and effort.

## Handoff and acceptance

Provide the objective, essential context or file locations, allowed changes, and observable acceptance criteria. Request a concise result with artifact/file references, validation evidence, and unresolved issues. Keep exploration logs with the worker. Give write tasks separate workspaces or disjoint ownership; serialize shared-interface changes. Tell workers to complete their assignment without further delegation and leave Git publication, releases, and deployment to the main agent.

Review the relevant artifacts and evidence before integrating. Check consequential changes directly without repeating the worker's investigation. Diagnose incomplete results before retrying: correct missing context or environment defects, or select a worker suited to the unmet requirement. Retry a corrected context or environment failure once; if it repeats, use a suitable alternative or complete the task in the main agent.

## Run Gemini

Before dispatch, tell the user the Gemini model, effort, and task in one sentence. After it returns, include the outcome or blocker in the next necessary update, distinguishing returned work from accepted work. Combine notices for a batch of tasks.

Use an authenticated Antigravity subscription session and a dedicated, clean linked Git worktree. Save the task as a UTF-8 file outside it. Include relevant uncommitted source changes in the worker's clean snapshot when needed. The worktree separates changes but is not a filesystem sandbox. For read-only work, prohibit writes in the task and verify a clean worktree afterward.

Resolve `../../scripts/Invoke-AntigravityAgent.ps1` relative to this skill directory. Explicitly pass `-Model gemini-3.8-flash-medium` or `-Model gemini-3.8-flash-high`:

```powershell
& $runner -WorkingDirectory $worktree -PromptFile $contract -Model gemini-3.8-flash-medium -AutoApprove
```

The runner returns compact JSON with status, result, and paths to full output. Check its exit code and status, then evaluate the result and artifacts. Read full output when the result is truncated or evidence is missing. Retain artifacts until acceptance. For setup, parameters, permissions, or failures, read [Antigravity operations](references/antigravity.md).
