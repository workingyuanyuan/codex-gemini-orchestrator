# Model Routing and Delegation

## Objective

The current Codex agent is the orchestrator. It owns task decomposition, shared contracts, integration, and final acceptance. Route bounded work to the lowest-cost worker likely to meet the required quality; delegation must improve model fit, parallelism, or context isolation enough to justify its overhead.

## Routing policy

1. Identify the capabilities, risk, and acceptance bar that determine success.
2. Exclude models unlikely to meet that bar; among qualified models, prefer higher Cost Efficiency. Use Intelligence only when task-specific fit is unclear.
3. Keep trivial, tightly coupled, or coordination-heavy work in the orchestrator.
4. Validate delegated output. Fix an incomplete contract, missing context, or environment failure before changing models. If the worker still fails, make one targeted repair attempt or escalate to a model stronger in the failed capability.
5. Do not use a second-model review unless risk or unresolved uncertainty justifies it. Stop when acceptance criteria are met.

All listed profiles use high reasoning effort. Scores are routing estimates; higher is better. Cost Efficiency reflects the user's subscription-adjusted cost, and Intelligence is only a secondary composite signal.

| Model            | Cost Eff. | Intelligence | Reasoning | Coding | Agentic | Math | Data | Language | Instruction |
| ---------------- | --------- | ------------ | --------- | ------ | ------- | ---- | ---- | -------- | ----------- |
| GPT-5.6-Sol      | 3.0       | 8.0          | 9.0       | 8.2    | 5.5     | 9.6  | 8.0  | 8.5      | 7.0         |
| GPT-5.6-Terra    | 6.0       | 7.5          | 8.5       | 7.5    | 5.2     | 9.0  | 8.0  | 7.6      | 6.0         |
| GPT-5.6-Luna     | 7.5       | 7.0          | 8.5       | 7.5    | 5.0     | 8.7  | 7.5  | 7.0      | 5.9         |
| Gemini 3.1 Pro   | 8.7       | 7.7          | 8.5       | 7.6    | 4.5     | 9.1  | 7.8  | 8.5      | 7.9         |
| Gemini 3.5 Flash | 8.8       | 7.5          | 8.2       | 7.8    | 4.9     | 8.8  | 6.5  | 8.5      | 7.5         |

## Default routes

* **Gemini 3.5 Flash:** default for bounded, objectively verifiable implementation; repetitive edits; migrations; frontend/UI; documentation and copy; data transformation; and straightforward coding.
* **Gemini 3.1 Pro:** dense specifications, instruction- or language-heavy work, and difficult quantitative work suitable for an external worker.
* For native Codex workers, use each custom agent's TOML `description` as the source of truth for task fit. Apply the capability, risk, cost, validation, and escalation policies in this file when multiple workers qualify.

The orchestrator retains shared architectural decisions and final acceptance. If it is already the best-fit model, delegate only when parallelism or context isolation adds material value.

## Worker entry points

Native Codex workers:

* `gpt_5_6_sol_high`
* `gpt_5_6_terra_high`
* `gpt_5_6_luna_high`

Their TOML files are under `$HOME\.codex\agents\`.

Gemini workers use the official Antigravity CLI through the authenticated subscription session; never request or use an API key.

* `gemini-3.5-flash` → `Gemini 3.5 Flash (High)`
* `gemini-3.1-pro` → `Gemini 3.1 Pro (High)`

```powershell
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" -WorkingDirectory $worktree -Model gemini-3.5-flash -PromptFile $contract -AutoApprove
```

Use `-AutoApprove` only when the task contract authorizes the required local writes. Never substitute another model when an alias is missing or ambiguous. Wait for the wrapper to finish; its internal print timeout is ten minutes, so any outer timeout must be longer.

## Delegation rules

* Give each worker one stateless, self-contained task. Workers must not delegate further.
* The contract must state: objective and deliverable; repository context; allowed paths; constraints and out-of-scope work; acceptance criteria and validation commands; required return fields (`summary`, `changed_files`, `validation`, `risks`, `unresolved`).
* Store temporary contract files outside the repository unless they are intended deliverables.
* Parallelize independent read-heavy tasks. Parallel writes require disjoint file ownership. Serialize work affecting shared contracts, schemas, public interfaces, dependency manifests, global configuration, or architectural decisions.
* For Gemini write tasks, use a runtime-provided isolated worktree or a detached worktree created from the current `HEAD`; do not create a branch. Use one worktree per task and restrict changes to the allowed paths.
* Gemini must not commit, merge, rebase, push, release, or deploy. The orchestrator reviews the complete diff, integrates accepted changes, runs proportionate validation, and removes temporary worktrees.
* If essential context or acceptance criteria are missing, gather or define them before delegation.

Wait for all requested workers, synthesize their distilled results rather than raw logs, and finish once the user's acceptance bar is satisfied.
