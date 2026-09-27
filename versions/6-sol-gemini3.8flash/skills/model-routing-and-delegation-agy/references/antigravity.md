# Antigravity operations

Use for setup, parameter details or a failed invocation. Requires Windows 11, PowerShell 7, Git, and the official `agy.exe` on PATH. The implementation targets the headless JSON interface documented for CLI 1.2.11.

## Setup and workspace

Install and authenticate using [Google's instructions](https://antigravity.google/docs/cli/install/). Start `agy` interactively once to establish the subscription session. `agy models` lists available model IDs; the installed CLI listed both `gemini-3.8-flash-medium` and `gemini-3.8-flash-high` on 2026-09-27. The runner passes the selected ID directly, without a separate effort flag or silent fallback. Confirm availability for the current account if a model is rejected.

Create or reuse an idle, dedicated linked Git worktree through the runtime's worktree tools. Supply the intended source revision; uncommitted changes in another checkout are not automatically present. For environments without worktree tools, `git worktree add --detach <path> <ref>` creates a linked worktree. The runner requires its root and a clean initial status. The prompt must be a nonempty, strictly valid UTF-8 file outside it.

The contract specifies outcome, required context, permitted edits and validation. Keep contracts and runtime logs out of the repository. An isolated worktree separates file changes; it does not restrict filesystem or network access. `-AutoApprove` enables non-interactive tool execution, so assign only authorized work. For read-only contracts, inspect `git status --short` after execution. Retain the worktree and logs while they are needed for review; retire managed worktrees with the runtime's archive tool.

## Parameters

Resolve `../../scripts/Invoke-AntigravityAgent.ps1` relative to the skill directory.

| Parameter | Meaning |
| --- | --- |
| `WorkingDirectory` | Required clean linked Git worktree root |
| `PromptFile` | Required UTF-8 task file outside that worktree |
| `AutoApprove` | Required acknowledgement of headless tool execution |
| `Model` | Defaults to `gemini-3.8-flash-medium`; accepts that ID or `gemini-3.8-flash-high`. Skill calls specify it explicitly. |
| `TimeoutSeconds` | Default 600; allowed 1–3600 |
| `MaxResultChars` | Default 6000; allowed 256–100000 |
| `OutputDirectory` | Optional parent for per-run output; defaults to temporary storage |
| `AgyExecutablePath` | Optional explicit location of the native `.exe`; otherwise resolves `agy.exe` from PATH |

For High, pass `-Model gemini-3.8-flash-high` to the same runner. Model and effort selection belongs to the calling agent; the runner validates and transports the requested ID.

Allow the calling tool to yield while the process runs; its supervising timeout must exceed the runner's timeout and shutdown grace period. Each invocation is a fresh conversation.

## Result and recovery

The runner emits one compact JSON object. Check both its exit code and `status`. `result` is capped by `MaxResultChars`; `truncated` signals whether to open the full result. `artifacts` contains the raw JSON, diagnostics and full result paths. `conversation_id`, when provided by the CLI, identifies the run. Read diagnostics only as needed; they may include private task content.

Exit 0 means the CLI returned a usable success response. Exit 1 indicates preflight, output or status failure; a nonzero CLI exit is propagated. Exit 124 indicates timeout. Task completion still requires review of the actual files and validation evidence. A permission refusal, unavailable tool or incomplete result can invalidate a worker's claimed success.

For authentication failure, restore the interactive session. For context or environment defects, correct the cause before one retry. For repeated failure or inadequate capability, use the appropriate native route or finish in the main agent. Inspect possible partial work before retrying; the clean-start check will reject a dirty workspace.

Full logs remain local until deleted by the caller. For scripts downloaded as ZIP files, Windows may attach `Zone.Identifier`. After inspecting and trusting the downloaded script, use `Unblock-File -LiteralPath <script-path>` if `RemoteSigned` blocks execution.

See [headless mode](https://antigravity.google/docs/cli/headless/) for the upstream JSON envelope, status semantics and permission behavior.
