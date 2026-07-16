# codex-gemini-orchestrator

Versioned configuration and tooling for routing Codex work to GPT-5.6 subagents and making one-shot Gemini calls through the official Antigravity CLI. Gemini uses the user's existing authenticated Antigravity subscription session—no Gemini API key is requested or used.

## What this project provides

- An `AGENTS.md` policy that routes work by task-specific capability, intelligence, and cost efficiency.
- Native Codex subagent definitions for GPT-5.6-Sol, GPT-5.6-Terra, and GPT-5.6-Luna at high reasoning effort.
- A PowerShell 7 wrapper that resolves stable Gemini aliases and runs exactly one stateless Antigravity task.
- A collision-safe installer that copies the configuration for a selected GPT generation into `$HOME\.codex`.

The orchestrating Codex agent remains responsible for shared architecture, critical logic, security, integration, final acceptance, Git state, worktree lifecycle, commits, and cleanup. Delegated agents work from explicit, self-contained task contracts.

## Repository layout

```text
codex-gemini-orchestrator/
├─ README.md
├─ CHANGELOG.md
├─ LICENSE
├─ CONTRIBUTING.md
├─ SECURITY.md
├─ .gitignore
├─ install.ps1
├─ tests/
│  └─ Invoke-AntigravityAgent.Tests.ps1
└─ versions/
   └─ 5.6/
      ├─ AGENTS.md
      ├─ agents/
      │  ├─ gpt-5-6-sol-high.toml
      │  ├─ gpt-5-6-terra-high.toml
      │  └─ gpt-5-6-luna-high.toml
      └─ scripts/
         └─ Invoke-AntigravityAgent.ps1
```

## Version policy

The directory version identifies the supported GPT generation, not the project release version. `versions/5.6/` means that the routing configuration supports the GPT-5.6 family; it also supports Gemini 3.5 Flash while retaining the Gemini 3.1 Pro alias present in the routing baseline.

Bug fixes, security hardening, documentation corrections, and wrapper compatibility repairs are applied within the existing GPT-generation directory. A new GPT generation and its corresponding routing-table update must be added as a new directory, such as `versions/6.0/` for GPT-6.0. Do not create a new version directory merely to release a project bug fix.

## Model routing

The authoritative scores and complete policy are in [`versions/5.6/AGENTS.md`](versions/5.6/AGENTS.md). Routing follows this order:

1. Meet the task-specific capability threshold.
2. Among qualifying models, prefer higher Cost Efficiency.
3. Use Intelligence only when task-specific fit remains unclear.

Bounded, objectively verifiable implementation; repetitive edits; migrations; frontend/UI; documentation and copy; data transformation; and straightforward coding default to Gemini 3.5 Flash. Dense specifications, instruction- or language-heavy work, and difficult quantitative work suitable for an external worker default to Gemini 3.1 Pro. Native Codex worker selection follows each custom agent's TOML `description`: Sol handles high-risk and cross-cutting work, Terra handles read-heavy analysis and bounded moderate-complexity changes, and Luna handles low-risk fully specified implementation and mechanical edits.

The orchestrator retains shared architectural decisions and final acceptance. If a worker fails acceptance, correct an incomplete contract, missing repository context, broken environment, or invalid acceptance criteria before making one targeted repair attempt or escalating to a model stronger in the failed capability.

## Isolation and delegation

Every Gemini delegation is single-shot, stateless, and self-contained. For write tasks, the orchestrator uses a runtime-provided isolated worktree or creates a detached worktree from the current `HEAD`; no temporary branch is created. It supplies a UTF-8 task contract, reviews the complete diff and validation evidence, integrates only accepted changes, and removes the worktree.

The wrapper does not create, commit, merge, rebase, push, release, or deploy. Gemini may modify only its assigned worktree and must not use a previous Antigravity conversation as hidden state. Parallel work is safe only when file ownership and public contracts do not overlap.

## Prerequisites

- Windows 10 or Windows 11.
- PowerShell 7 (`pwsh`). PowerShell 5.1 is not supported.
- Git.
- Codex CLI with support for native subagent definitions under `$HOME\.codex\agents`.
- The official Antigravity CLI, including the `agy` command.
- An authenticated Antigravity subscription session that can list the configured Gemini models.

No Gemini API key is needed. Do not add one to this repository or to task contracts.

## Installation

Clone the repository and run the installer from its root in PowerShell 7:

```powershell
git clone https://github.com/workingyuanyuan/codex-gemini-orchestrator.git
Set-Location .\codex-gemini-orchestrator
pwsh -NoProfile -File .\install.ps1 -Version 5.6
```

The installer copies:

| Source | Destination |
| --- | --- |
| `versions/5.6/AGENTS.md` | `$HOME\.codex\AGENTS.md` |
| `versions/5.6/agents/*.toml` | `$HOME\.codex\agents\` |
| `versions/5.6/scripts/*.ps1` | `$HOME\.codex\scripts\` |

The default is fail-safe: if any destination file already exists, installation stops before copying anything. Review the collision list first. Only an explicit `-Force` permits those managed files to be replaced:

```powershell
pwsh -NoProfile -File .\install.ps1 -Version 5.6 -Force
```

`-Force` does not delete unrelated files.

If local execution policy or a downloaded-file mark blocks the installed wrapper, run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
Unblock-File "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1"
```

The installer does not change execution policy and does not run installed code. If you digitally sign either PowerShell script, every subsequent modification invalidates the signature and the modified script must be signed again.

## One-shot Gemini usage

Codex should first obtain an isolated worktree, or create a detached worktree from the current `HEAD`, and prepare a complete UTF-8 task contract outside the repository. It can then call:

```powershell
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" `
  -WorkingDirectory "C:\path\to\isolated-worktree" `
  -Model gemini-3.5-flash `
  -PromptFile "C:\path\to\task-contract.md" `
  -AutoApprove
```

Supported stable aliases in version 5.6 are `gemini-3.5-flash` and `gemini-3.1-pro`. The wrapper requires exactly one matching High model from `agy models`; it never silently substitutes a different model.

The wrapper passes the resolved worktree through Antigravity's `--add-dir` option and sets `--print-timeout 10m`. If another process supervises the wrapper, its outer timeout must be longer than ten minutes so Antigravity can return its own exit code.

Omit `-AutoApprove` to keep Antigravity's configured permission flow. With `-AutoApprove`, the wrapper passes Antigravity's permission-skipping flag, so use it only inside a disposable, correctly scoped worktree after reviewing the task contract.

## Security

Never place credentials, API keys, tokens, cookies, secrets, or private data in routing files, task contracts, prompts, logs, commits, or issue reports. See [`SECURITY.md`](SECURITY.md) for vulnerability reporting and supported-version information.

## Contributing and license

See [`CONTRIBUTING.md`](CONTRIBUTING.md) before proposing routing or version changes. This project is available under the [MIT License](LICENSE).

Run the wrapper regression test with:

```powershell
pwsh -NoProfile -File .\tests\Invoke-AntigravityAgent.Tests.ps1
```
