# Changelog

All notable changes to this project are documented in this file.

The version directory identifies the supported GPT generation, not the project release version. In-generation bug fixes are applied in place; a new GPT generation receives a new directory.

## [5.6] - 2026-07-15

### Added

- GPT-5.6-Sol, GPT-5.6-Terra, and GPT-5.6-Luna Codex subagent profiles at high reasoning effort.
- Capability-first routing policy with explicit quality escalation and cost-efficiency tie-breaking.
- Stable Gemini 3.5 Flash and Gemini 3.1 Pro aliases for one-shot Antigravity CLI delegation.
- Git branch and worktree isolation contract for delegated tasks.
- PowerShell 7 installer with safe collision handling and explicit `-Force` replacement.
- Public documentation, contribution guidance, security policy, and MIT license.

### Fixed

- Bound Antigravity sessions to the resolved Git worktree with `--add-dir`.
- Set an explicit ten-minute Antigravity print timeout so supervising processes can use a longer, coordinated outer timeout.
- Clarified that `5.6` represents GPT-5.6 support and does not prevent in-version project bug fixes.
