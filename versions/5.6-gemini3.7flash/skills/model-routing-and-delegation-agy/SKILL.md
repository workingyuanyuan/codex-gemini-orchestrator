---
name: model-routing-and-delegation-agy
description: Route bounded execution work from a Codex orchestrator to native GPT-5.6 Luna Max or authenticated Gemini 3.7 Flash and Gemini 3.1 Pro workers through Antigravity CLI. Use when work is separable, bounded, objectively verifiable, parallelizable, context-heavy, or explicitly requested for a worker, subagent, Gemini, Luna, or Antigravity. Covers model and Gemini 3.7 reasoning-tier selection, task contracts, Git worktree isolation, invocation, validation, and capability-directed escalation.
---

# Model Routing and Delegation

## Objective

Keep architecture, decomposition, shared contracts, integration, review, and final acceptance in the Codex orchestrator. Delegate bounded execution only when model fit, parallelism, token capacity, or context isolation justifies the overhead.

## Routing policy

1. Identify the capabilities, risk, and acceptance bar that determine success.
2. Exclude models that do not meet the bar; among qualified workers, prefer higher Cost Efficiency. Use Intelligence only when task-specific fit is unclear.
3. Keep trivial, tightly coupled, open-ended, or evolving-judgment work in the orchestrator.
4. On failure, fix contract, context, or environment defects and retry once. For a confirmed capability failure, choose a worker stronger in that capability. Return work that is no longer bounded to the orchestrator.
5. Use a second-model review only when risk or unresolved uncertainty warrants it. Stop when acceptance criteria are met.

Scores are routing estimates on a 0–100 scale; higher is better. Cost Efficiency reflects subscription-adjusted cost. GPT-5.6 Sol Max is the usual orchestrator and a comparison baseline, never a delegation target. Max scores do not prescribe a general reasoning-effort policy.

| Model            | Role                | Cost Eff. | Intelligence | Reasoning | Coding | Agentic | Math | Data | Language | Instruction |
| ---------------- | ------------------- | --------- | ------------ | --------- | ------ | ------- | ---- | ---- | -------- | ----------- |
| GPT-5.6 Sol Max  | Orchestrator (self) | 50        | 81           | 91        | 83     | 62      | 96   | 79   | 87       | 71          |
| GPT-5.6 Luna Max | Worker              | 83        | 73           | 85        | 83     | 57      | 87   | 78   | 72       | 60          |
| Gemini 3.1 Pro   | Worker              | 86        | 77           | 84        | 76     | 28      | 91   | 78   | 85       | 79          |
| Gemini 3.7 Flash | Worker — default    | 92        | 78           | 87        | 79     | 61      | 93   | 68   | 85       | 80          |

The Gemini 3.7 Flash row records High reasoning. Medium has the same Coding and Agentic capability scores as High; do not infer unlisted Medium scores for the other dimensions.

## Default routes

- **Gemini 3.7 Flash Medium:** default for bounded, objectively verifiable execution. Use it for coding and agentic work because High does not improve those two capabilities.
- **Gemini 3.7 Flash High:** upgrade from Medium only when the acceptance bar specifically requires stronger Reasoning, Math, Data, Language, or Instruction capability. Do not upgrade for Coding or Agentic requirements alone.
- **GPT-5.6 Luna Max:** complex bounded execution requiring exploration, cross-file edits, or iterative build-test-fix loops.
- **Gemini 3.1 Pro:** data-heavy work where its higher Data score materially matters.

## Worker entry points

Use the native Codex agent `gpt_5_6_luna_max` for GPT-5.6 Luna Max. Its TOML profile fixes reasoning effort at `max`.

Use the official Antigravity CLI through the authenticated subscription session for external workers; never request or use an API key.

- `gemini-3.7-flash` → `gemini-3.7-flash-medium`
- `gemini-3.7-flash-high` → `gemini-3.7-flash-high`
- `gemini-3.1-pro` → `gemini-3.1-pro-high`

The Gemini slugs include effort. Do not pass a separate effort option. Never substitute another model when an alias is missing or ambiguous.

Before invoking Antigravity, emit exactly one progress line: `Delegating to <model alias>: <brief task>`.

```powershell
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" -WorkingDirectory $worktree -Model gemini-3.7-flash -PromptFile $contract -AutoApprove
```

Antigravity print mode is headless: repository inspection through the command tool cannot pause for permission approval. Therefore use `-AutoApprove` for Antigravity only inside a dedicated isolated worktree, including read-only reviews. The task contract remains authoritative: explicitly forbid writes for read-only work and verify that the worktree has no diff afterward. Never use `-AutoApprove` against the user's primary checkout or a shared dirty worktree. Give the wrapper an outer timeout longer than its ten-minute internal print timeout.

The wrapper adds the resolved worktree as `safe.directory` only in its own process environment so both its Git preflight and Antigravity child commands can inspect runtime-owned worktrees. It does not change global Git configuration. Treat any nonzero wrapper exit as delegation failure; the wrapper also converts empty or known headless permission-denial exit-0 responses into failure.

## Delegation rules

- Give each worker one stateless, self-contained task. Workers must not delegate further.
- State the objective and deliverable, repository context, allowed paths, constraints and exclusions, acceptance criteria, validation commands, and required return fields (`summary`, `changed_files`, `validation`, `risks`, `unresolved`).
- Keep temporary contracts outside the repository unless they are intended deliverables.
- Parallelize independent read-heavy tasks. Allow parallel writes only with disjoint file ownership. Serialize shared contracts, schemas, public interfaces, dependency manifests, global configuration, and architectural decisions.
- For every Antigravity task, use a runtime-provided isolated worktree or create one detached from `HEAD`; do not create a branch. Use one worktree per task and pass `-AutoApprove` so headless command access can operate. For read-only tasks, forbid modifications in the contract and require `git status --short` to be empty after the worker returns.
- Workers must not commit, merge, rebase, push, release, or deploy. Review the complete diff, integrate accepted changes, validate proportionately, and remove temporary worktrees.
- Gather or define essential context and acceptance criteria before delegation.

Wait for every requested worker, synthesize distilled results rather than raw logs, and finish when the acceptance bar is met.
