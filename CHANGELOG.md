# Changelog

All notable changes to this project are documented in this file.

The version directory identifies the supported GPT generation, not the project release version. In-generation bug fixes are applied in place; a new GPT generation receives a new directory.

## [Unreleased]

### Added

- Added the `5.6-gemini3.6flash` snapshot with Gemini 3.6 Flash and Gemini 3.1 Pro routing through the authenticated Antigravity CLI session.
- Documented how to detect and remove the PowerShell `Zone.Identifier` download-origin mark after downloading or copying the wrapper.

### Changed

- Marked `5.6-gemini3.5flash` as an archived, deprecated snapshot retained for version history.
- Refined native Codex worker descriptions and instructions so Sol, Terra, and Luna advertise distinct risk- and task-based routing roles.
- Updated routing to prefer Cost Efficiency among models that meet the task-specific capability threshold, with Intelligence as a secondary signal.
- Replaced temporary-branch creation for Gemini write tasks with runtime-provided or detached isolated worktrees.
- Required temporary delegation contracts to remain outside the repository unless they are intended deliverables.

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
