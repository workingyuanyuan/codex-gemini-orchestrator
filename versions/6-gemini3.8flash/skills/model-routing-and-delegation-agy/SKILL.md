---
name: model-routing-and-delegation-agy
description: Delegate bounded work exclusively to Gemini 3.8 Flash High through authenticated Antigravity CLI. Use for independent parallel tasks or explicit delegation requests.
---

# Delegation through Antigravity

## Execution

Gemini 3.8 Flash High is the only permitted worker, including retries; do not use native Codex agents or other models. Use the authenticated Antigravity subscription session without API keys.

The orchestrator owns architecture, decomposition, shared contracts, integration, review, and final acceptance. Delegate independent, objectively verifiable work when parallelism could save time or improve quality; handle trivial or tightly coupled work directly. Continue useful independent work while workers run.

## Task contract and isolation

- Give each worker one self-contained task with objective, deliverable, essential context, allowed paths, constraints, acceptance criteria, validation commands, and return fields: `summary`, `changed_files`, `validation`, `risks`, `unresolved`.
- Workers must not delegate, commit, merge, rebase, push, release, or deploy.
- Keep temporary contracts outside the repository. Use a dedicated runtime-provided worktree or create one detached from `HEAD` for each task.
- Parallel writes require disjoint file ownership. Serialize changes to shared contracts, schemas, public interfaces, dependency manifests, and global configuration.
- Headless execution requires `-AutoApprove`, including for read-only tasks. Use it only in the isolated worktree. For read-only work, forbid modifications in the contract and verify empty `git status --short` afterward.

## Invocation

Before invoking, emit: `Delegating to gemini-3.8-flash-high: <brief task>`.

```powershell
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" -WorkingDirectory $worktree -Model gemini-3.8-flash-high -PromptFile $contract -AutoApprove
```

The alias resolves to the exact `gemini-3.8-flash-high` slug. Do not pass a separate effort option or substitute a model if unavailable. Set the outer timeout longer than the wrapper's ten-minute internal print timeout.

## Acceptance and recovery

Wait for workers, review their complete diffs and validation evidence, integrate accepted changes, and remove temporary worktrees. Synthesize the results and stop when acceptance criteria are met.

Treat a nonzero wrapper exit or unusable result as failure. Correct contract, context, or environment defects and retry once with the same model. If the retry fails or capability is insufficient, return the task to the orchestrator.
