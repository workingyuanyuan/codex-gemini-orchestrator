---
name: model-routing-and-delegation-agy
description: Route bounded execution work from a Codex orchestrator to native GPT-5.6 Luna Max or authenticated Antigravity CLI workers (Gemini 3.6 Flash, Gemini 3.5 Flash, Gemini 3.1 Pro, and Claude Opus 4.6). Use when work is separable, bounded, objectively verifiable, parallelizable, context-heavy, or explicitly requested for a worker, subagent, Gemini, Opus, Luna, or Antigravity. Covers model selection, task contracts, Git worktree isolation, invocation, validation, and capability-directed escalation.
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
| Opus 4.6         | Worker              | 60        | 74           | 88        | 78     | 43      | 89   | 70   | 83       | 63          |
| Gemini 3.1 Pro   | Worker              | 86        | 77           | 84        | 76     | 28      | 91   | 78   | 85       | 79          |
| Gemini 3.5 Flash | Worker              | 87        | 75           | 82        | 78     | 43      | 88   | 65   | 85       | 75          |
| Gemini 3.6 Flash | Worker — default    | 88        | 74           | 85        | 78     | 46      | 86   | 63   | 84       | 75          |

## Default routes

- **Gemini 3.6 Flash:** default for bounded, objectively verifiable execution.
- **GPT-5.6 Luna Max:** complex bounded execution requiring exploration, cross-file edits, or iterative build-test-fix loops.
- **Gemini 3.5 Flash:** well-bounded, objectively verifiable TypeScript and Python work; prefer Gemini 3.6 Flash or Luna Max for DeepSWE-shaped work.
- **Gemini 3.1 Pro:** dense specifications, strict instruction following, language precision, difficult math, and data work.
- **Opus 4.6:** intricate debugging, subtle invariants, complex causal analysis, and large cross-file comprehension.

## Worker entry points

Use the native Codex agent `gpt_5_6_luna_max` for GPT-5.6 Luna Max. Its TOML profile fixes reasoning effort at `max`.

Use the official Antigravity CLI through the authenticated subscription session for external workers; never request or use an API key.

- `gemini-3.6-flash` → `gemini-3.6-flash-high`
- `gemini-3.5-flash` → `gemini-3.5-flash-high`
- `gemini-3.1-pro` → `gemini-3.1-pro-high`
- `claude-opus-4-6` → `claude-opus-4-6-thinking`

The Gemini slugs include effort; Opus 4.6 is available only in thinking mode. Do not pass a separate effort option. Never substitute another model when an alias is missing or ambiguous.

Before invoking Antigravity, emit exactly one progress line: `Delegating to <model alias>: <brief task>`.

```powershell
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" -WorkingDirectory $worktree -Model gemini-3.6-flash -PromptFile $contract -AutoApprove
```

Use `-AutoApprove` only when the contract authorizes the required local writes. Give the wrapper an outer timeout longer than its ten-minute internal print timeout.

## Delegation rules

- Give each worker one stateless, self-contained task. Workers must not delegate further.
- State the objective and deliverable, repository context, allowed paths, constraints and exclusions, acceptance criteria, validation commands, and required return fields (`summary`, `changed_files`, `validation`, `risks`, `unresolved`).
- Keep temporary contracts outside the repository unless they are intended deliverables.
- Parallelize independent read-heavy tasks. Allow parallel writes only with disjoint file ownership. Serialize shared contracts, schemas, public interfaces, dependency manifests, global configuration, and architectural decisions.
- For Antigravity writes, use a runtime-provided isolated worktree or create one detached from `HEAD`; do not create a branch. Use one worktree per task. For read-only tasks, use the repository root and omit `-AutoApprove`.
- Workers must not commit, merge, rebase, push, release, or deploy. Review the complete diff, integrate accepted changes, validate proportionately, and remove temporary worktrees.
- Gather or define essential context and acceptance criteria before delegation.

Wait for every requested worker, synthesize distilled results rather than raw logs, and finish when the acceptance bar is met.
