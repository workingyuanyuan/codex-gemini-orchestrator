# Contributing

Thank you for helping improve `codex-gemini-orchestrator`.

## Ground rules

- Never add credentials, API keys, tokens, cookies, private task content, machine-specific absolute paths, or personal data.
- Do not require a Gemini API key. Antigravity integration must continue to use the user's existing authenticated subscription session.
- Keep PowerShell compatible with PowerShell 7. PowerShell 5.1 is not supported.
- Preserve orchestrator ownership of architecture, security, integration, Git state, and final acceptance.
- Keep delegated Gemini tasks single-shot, stateless, contract-driven, and isolated in Git worktrees.

## Versioned changes

Directories under `versions/` identify supported GPT generations, not project release versions. Apply bug fixes, security hardening, documentation corrections, and compatibility repairs inside the existing generation directory. Create a new directory—such as `versions/6.0/`—when adding GPT-6.0 and its corresponding routing table; do not create a new directory merely for a project bug fix.

The model scores and routing policy are deliberate inputs. A pull request that changes them must explain the evidence and compatibility impact. Do not average the capability dimensions into a new composite or trade away the task-specific quality threshold for cost.

## Development workflow

1. Create a short-lived branch from `main`.
2. Keep the change focused and avoid unrelated cleanup.
3. Update documentation and `CHANGELOG.md` when behavior or compatibility changes.
4. Validate every TOML file with a TOML 1.0 parser.
5. Parse every `.ps1` file with PowerShell 7 and run `pwsh -NoProfile -File .\tests\Invoke-AntigravityAgent.Tests.ps1`.
6. Confirm README parameter names, paths, and examples match the scripts.
7. Review the complete diff for secrets and machine-specific data.
8. Open a pull request that includes the commands run and their results.

Useful PowerShell syntax check:

```powershell
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  (Resolve-Path .\install.ps1),
  [ref]$tokens,
  [ref]$errors
) | Out-Null
$errors
```

If a PowerShell script is digitally signed, any modification invalidates that signature. Re-sign the final file after all edits and before distribution.

## Pull requests

Include:

- The objective and affected version line.
- Files changed and files intentionally left unchanged.
- Validation evidence for TOML, PowerShell, installer behavior, and documentation examples.
- Security or compatibility risks.
- Migration guidance when users must select a new version.

By contributing, you agree that your contribution is licensed under the MIT License.
