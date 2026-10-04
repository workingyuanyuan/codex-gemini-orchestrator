# Antigravity operations

Read before Gemini dispatch for setup, invocation and recovery. Requires Windows 11, PowerShell 7, Git, and the official `agy.exe` on PATH. The implementation targets the headless JSON interface documented for CLI 1.2.11.

Before dispatch, tell the user the Gemini model, effort, and task in one sentence. Include the outcome or blocker in the next necessary update, distinguishing returned work from accepted work. Combine notices for a batch of tasks.

## Setup and workspace

Install and authenticate using [Google's instructions](https://antigravity.google/docs/cli/install/). Start `agy` interactively once to establish the subscription session. `agy models` lists available model IDs; select `gemini-3.8-flash-medium` or `gemini-3.8-flash-high`. The runner passes the selected ID directly. Confirm availability for the current account if a model is rejected.

Create or reuse an idle, dedicated linked Git worktree through the runtime's worktree tools. Supply the intended source revision and include relevant uncommitted source changes in a clean snapshot when needed. For environments without worktree tools, `git worktree add --detach <path> <ref>` creates a linked worktree. The runner requires its root and a clean initial status. The prompt must be a nonempty, strictly valid UTF-8 file outside it.

The contract specifies outcome, required context, permitted edits and validation. Specify native Antigravity tools as the permitted tool scope. Verify unfamiliar capabilities with a small operation at the start of the assignment. Have the worker return a capability gap when completion requires tools beyond that scope. Keep contracts and runtime logs out of the repository. An isolated worktree separates file changes; it does not restrict filesystem or network access. `-AutoApprove` enables non-interactive tool execution, so assign only authorized work. For read-only work, prohibit writes in the contract and verify a clean worktree with `git status --short` afterward. Retain the worktree and logs until acceptance; retire managed worktrees with the runtime's archive tool.

## Parameters

Resolve `../../scripts/Invoke-AntigravityAgent.ps1` relative to the skill directory and verify that the packaged runner exists. The installer places it in the Codex installation's `scripts` directory. Explicitly select an enabled model:

```powershell
& $runner -WorkingDirectory $worktree -PromptFile $contract -Model gemini-3.8-flash-medium -AutoApprove
```

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

For authentication failure, restore the interactive session. Inspect partial work before retrying; the runner requires a clean starting workspace. For context or environment defects, correct the cause and normally retry once. If the same failure recurs, choose a suitable worker or finish in the main agent. Further retries need new evidence of a correctable cause and must fit the task's time budget. Treat inadequate capability as a reason to select another route.

Full logs remain local until deleted by the caller. For scripts downloaded as ZIP files, Windows may attach `Zone.Identifier`. After inspecting and trusting the downloaded script, use `Unblock-File -LiteralPath <script-path>` if `RemoteSigned` blocks execution.

See [headless mode](https://antigravity.google/docs/cli/headless/) for the upstream JSON envelope, status semantics and permission behavior.

## Supervise Browser and Boost

Use direct CLI streaming for these built-in workflows so the caller can capture the conversation ID while work is running and resume that exact conversation for cleanup. Apply the setup, authorization and clean linked-worktree requirements above. Read the relevant [task contract](gemini-capabilities.md) before dispatch.

Save a UTF-8 contract beginning with `/browser` or `/boost` outside the worktree. Include the permitted built-in child workflow, total time budget, artifacts and cleanup requirement. Reserve cleanup time within the total deadline; for a 600-second assignment, allow up to 510 seconds for work and 90 seconds for cleanup. Set `$seconds` to the remaining work allowance, `$contract` to the task file and `$model` to an enabled Gemini ID.

Launch each invocation through the calling shell tool in a dedicated PowerShell 7 process with the worktree as its working directory. Create `$events`, `$diagnostics` and `$supervisor` paths in a unique output directory outside the worktree. Record that dedicated shell's process ID and start time before launching the CLI:

```powershell
$agy = (Get-Command agy.exe -CommandType Application).Source
$prompt = [IO.File]::ReadAllText($contract, [Text.UTF8Encoding]::new($false, $true))
[pscustomobject]@{ pid = $PID; started = (Get-Process -Id $PID).StartTime.ToUniversalTime().ToString('o') } |
    ConvertTo-Json -Compress | Set-Content -LiteralPath $supervisor -Encoding utf8
$agyArgs = @('--dangerously-skip-permissions', '--add-dir', $worktree,
    '--model', $model, '--print-timeout', "${seconds}s",
    '--output-format', 'stream-json', '-p', $prompt)
& $agy @agyArgs 1> $events 2> $diagnostics
$agyExitCode = $LASTEXITCODE
[pscustomobject]@{ exit_code = $agyExitCode; events = $events; diagnostics = $diagnostics } | ConvertTo-Json -Compress
```

Allow the calling shell tool to yield while the process runs. Inspect complete NDJSON lines from `$events`: save the top-level `conversation_id` from the `init` event as `$conversationId`, track child IDs and log locations from `step_update.subagent_info`, and inspect tool results and the final `result.status`. Record returned usage with its conversation scope. Use the [headless protocol](https://antigravity.google/docs/cli/headless/) for the event schema and `--conversation` resumption.

Require actual browser operations or Boost child events to establish that the requested workflow started. Maintain the task deadline across follow-ups. Collect child tool results and verification artifacts from the returned log locations; keep the main response focused on the deliverable. Check the CLI exit code together with the final result and the worktree.

At completion, failure, cancellation or the work deadline, save available artifacts and dispose of the assignment's child tree. If the invocation overruns, load `$supervisor`, verify the recorded PID and start time against the live process, and terminate that dedicated shell's process tree with `System.Diagnostics.Process.Kill(true)`. Once it has exited, resume its recorded conversation with a cleanup-only prompt whenever cleanup still needs verification.

Recover a missing conversation ID from this run's persisted `init` or terminal `result` event. If both are missing, preserve the logs and report the unresolved conversation identity. Cleanup requires an exact root conversation ID. In a fresh dedicated shell, resolve `$agy` again and supply `$worktree`, `$model`, `$conversationId`, fresh output paths and `$cleanupSeconds` from the remaining cleanup allowance:

```powershell
$agy = (Get-Command agy.exe -CommandType Application).Source
if ([string]::IsNullOrWhiteSpace($conversationId)) { throw 'Cleanup requires the original conversation ID.' }
[pscustomobject]@{ pid = $PID; started = (Get-Process -Id $PID).StartTime.ToUniversalTime().ToString('o') } |
    ConvertTo-Json -Compress | Set-Content -LiteralPath $cleanupSupervisor -Encoding utf8
$cleanup = 'Stop this assignment. Use manage_subagents Action=list. Kill the listed assignment children with Action=kill and their ConversationIds, including their descendants. List again and return the final inventory and tool evidence.'
$cleanupArgs = @('--dangerously-skip-permissions', '--add-dir', $worktree,
    '--model', $model, '--conversation', $conversationId,
    '--print-timeout', "${cleanupSeconds}s", '--output-format', 'stream-json', '-p', $cleanup)
& $agy @cleanupArgs 1> $cleanupEvents 2> $cleanupDiagnostics
$cleanupExitCode = $LASTEXITCODE
[pscustomobject]@{ exit_code = $cleanupExitCode; events = $cleanupEvents; diagnostics = $cleanupDiagnostics } | ConvertTo-Json -Compress
```

The calling agent invokes `manage_subagents` through the resumed Antigravity worker. Verify its actual list/kill/list tool results, with an empty final inventory, before releasing the worktree. If cleanup fails, retain the conversation ID, worktree and logs and report the unresolved lifecycle state. A CLI timeout requires this same service-side cleanup. The tool operations are documented in [Antigravity tool schemas](https://antigravity.google/docs/hooks/).
