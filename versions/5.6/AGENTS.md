# MODEL ROUTING FOR WORKFLOWS AND DELEGATED AGENTS

**Ranks:** higher is better. **Cost Efficiency** reflects the user's actual paid cost and subscription allowance, not list price. **Intelligence** is a composite reference score; it must not replace task-specific capability scores.

| Model | Entry point | Reasoning effort | Cost Efficiency | Intelligence | Reasoning | Coding | Agentic | Math | Data Analysis | Language | Instruction Following |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| GPT-5.6-Sol | Codex | High | 3.0 | 8.0 | 9.0 | 8.2 | 5.5 | 9.6 | 8.0 | 8.5 | 7.0 |
| GPT-5.6-Terra | Codex | High | 6.0 | 7.5 | 8.5 | 7.5 | 5.2 | 9.0 | 8.0 | 7.6 | 6.0 |
| GPT-5.6-Luna | Codex | High | 7.5 | 7.0 | 8.5 | 7.5 | 5.0 | 8.7 | 7.5 | 7.0 | 5.9 |
| Gemini 3.1 Pro | Antigravity | High | 8.7 | 7.7 | 8.5 | 7.6 | 4.5 | 9.1 | 7.8 | 8.5 | 7.9 |
| Gemini 3.5 Flash | Antigravity | High | 8.8 | 7.5 | 8.2 | 7.8 | 4.9 | 8.8 | 6.5 | 8.5 | 7.5 |

## How to apply

- These are defaults, not limits. The agent currently receiving the user's request in Codex is the **orchestrating agent**. The user chooses that model; this file does not define a permanent main model.
- Select models in this order: **task-specific capability threshold → Intelligence → Cost Efficiency**. Do not average all dimensions into a single routing score.
- Cost is only a tie-breaker after the required capability threshold is met. Do not trade away critical quality, correctness, or safety for a cheaper run.
- If a cheaper model's output does not meet the required standard, rerun or redo the work with a better-suited model without asking. Outputs are judged by result quality, not price tags. Escalating cost is cheaper than shipping mediocre work.
- Escalate dynamically according to the failed capability. Do not treat Sol, Terra, Luna, or any model family as a fixed linear hierarchy.
- If failure was caused by an ambiguous task contract, missing repository context, a broken environment, or invalid acceptance criteria, fix that cause before changing models.

## Default routing

- **Bulk or mechanical work**—clear-spec implementation, repetitive edits, data analysis, migrations, and other easily verified work: default to **Gemini 3.5 Flash**.
- **User-facing work**—frontend, UI, copy, API design, and presentation-sensitive output: default to **Gemini 3.5 Flash**.
- **Core architecture, critical logic, security, integration, and final acceptance:** retain ownership in the orchestrating Codex agent. When delegation requires the strongest available reasoning profile, use **GPT-5.6-Sol**.
- For specialized work, compare only the capabilities that materially determine success. Examples: `Math + Reasoning` for difficult quantitative work; `Coding + Reasoning` for complex debugging; `Instruction Following + Language` for dense specifications and exact prose.
- The orchestrating agent reviews delegated results itself. A second model review is optional, not mandatory.

## Codex worker agents

Use Codex native subagents for the following configured agents:

- `gpt_5_6_sol_high` → `gpt-5.6-sol`, high reasoning effort
- `gpt_5_6_terra_high` → `gpt-5.6-terra`, high reasoning effort
- `gpt_5_6_luna_high` → `gpt-5.6-luna`, high reasoning effort

The corresponding TOML files live under `$HOME\.codex\agents\`. Their descriptions are intentionally neutral; routing decisions come from this file.

## Gemini delegation mechanics

Gemini is invoked through the official Antigravity CLI using the user's existing authenticated subscription session. Do not request or use an API key for this workflow.

Stable aliases:

- `gemini-3.5-flash` → the uniquely available `Gemini 3.5 Flash (High)` model
- `gemini-3.1-pro` → the uniquely available `Gemini 3.1 Pro (High)` model

Call:

```powershell
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" `
  -WorkingDirectory "C:\path\to\isolated-worktree" `
  -Model gemini-3.5-flash `
  -PromptFile "C:\path\to\task-contract.md" `
  -AutoApprove
```

Omit `-AutoApprove` when Antigravity's configured permission flow should remain in effect. Never silently substitute another model when the requested alias cannot be resolved uniquely.

The wrapper attaches the resolved worktree with Antigravity's `--add-dir` option and uses a ten-minute print timeout. Any process supervising the wrapper must use an outer timeout longer than ten minutes so Antigravity can return its own exit code.

## Delegation contract and isolation

- Every delegation is a **single, stateless, self-contained task**. Do not depend on a previous Antigravity conversation.
- The orchestrating agent creates and owns a temporary Git branch and worktree for each Gemini task. The wrapper script does not create, commit, merge, or delete Git state.
- One delegated task maps to one isolated worktree. Gemini may modify only that worktree.
- Parallel tasks must have non-overlapping file ownership and must not modify the same shared contract, schema, public interface, dependency manifest, global configuration, or architectural decision. Serialize dependent or overlapping work.
- Actual concurrency is controlled by Codex configuration; this file does not impose an additional numeric limit.
- Gemini must not commit, merge, rebase, push, release, or deploy. It returns worktree changes and execution results for the orchestrating agent to review.
- The orchestrating agent reviews the complete diff, chooses validation proportionate to the task and risk, integrates accepted changes, and cleans up the temporary worktree.

A task contract may be compact for simple work, but it must contain enough information to execute safely and verify objectively. Include, as applicable:

1. Objective and expected deliverable.
2. Repository context and working directory.
3. Allowed scope and files or directories that may change.
4. Constraints, dependencies, and explicit out-of-scope items.
5. Acceptance criteria and relevant validation commands.
6. Required return format: summary, changed files, validation evidence, risks, and unresolved issues.

Do not delegate when essential contract fields are missing.
