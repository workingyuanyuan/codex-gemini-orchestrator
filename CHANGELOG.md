# Changelog

All notable changes to this project are documented in this file.

The version directory identifies the supported GPT generation, not the project release version. In-generation bug fixes are applied in place; a new GPT generation receives a new directory.

## [Unreleased]

### Added

- Added a native `gpt_5_6_terra_max` worker profile to the current `5.6-gemini3.7flash` snapshot.

### Changed

- Replaced the routing table with the new Cost Efficiency, Reasoning, Knowledge, Coding, Agentic, and Language dimensions and scores.
- Retained Gemini 3.7 Flash Medium as the default bounded worker and kept High as an explicit reasoning-tier upgrade.
- Removed Gemini 3.1 Pro from the current routing policy and Antigravity wrapper.

### Fixed

- Scoped Git `safe.directory` trust to the wrapper process and its Antigravity child so runtime-owned worktrees pass both preflight and delegated Git commands without changing global configuration.
- Treat empty output and known headless permission-denial output as delegation failure even when Antigravity exits with code zero.
- Added wrapper regressions for dubious ownership, false-success output, and native exit-code propagation.

## [5.6-gemini3.7flash] - 2026-08-14

### Added

- Added the `5.6-gemini3.7flash` snapshot with authenticated Medium and High Gemini 3.7 Flash routes.

### Changed

- Updated the routing capability table to the supplied scores and made Gemini 3.7 Flash the default bounded worker.
- Made Gemini 3.7 Flash Medium the default, with High reserved for Reasoning, Math, Data, Language, or Instruction requirements because Coding and Agentic do not improve at High.
- Removed Opus 4.6 completely from the current snapshot; retained Gemini 3.1 Pro for data-heavy work and removed Gemini 3.5/3.6 Flash aliases.
- Updated `install.ps1`, README examples, and regression tests to target `5.6-gemini3.7flash` by default.
- Marked `5.6-gemini3.6flash` as an archived, deprecated snapshot retained for version history.

## [5.6-gemini3.6flash] - 2026-08-12

### Added

- Added the `model-routing-and-delegation-agy` skill and reduced `AGENTS.md` to the orchestrator boundary and skill trigger.
- Added the native `gpt_5_6_luna_max` worker profile with max reasoning effort for complex bounded execution.
- Expanded authenticated Antigravity routing to Gemini 3.6 Flash, Gemini 3.5 Flash, Gemini 3.1 Pro, and Claude Opus 4.6.
- Updated `install.ps1` to default to `5.6-gemini3.6flash` and install bundled agents, scripts, and skills.
- Documented how to detect and remove the PowerShell `Zone.Identifier` download-origin mark after downloading or copying the wrapper.

### Changed

- Marked `5.6-gemini3.5flash` as an archived, deprecated snapshot retained for version history.
- Clarified that GPT-5.6 Sol Max is an orchestrator comparison baseline and never a delegation target.
- Added capability-specific routes for Luna Max, Gemini 3.5 Flash, Gemini 3.1 Pro, and Opus 4.6 while retaining Gemini 3.6 Flash as the default bounded worker.
- Updated routing to prefer Cost Efficiency among models that meet the task-specific capability threshold, with Intelligence as a secondary signal.
- Replaced temporary-branch creation for Gemini write tasks with runtime-provided or detached isolated worktrees.
- Required temporary delegation contracts to remain outside the repository unless they are intended deliverables.
- Required isolated worktrees and headless command approval for read-only as well as write-capable Antigravity tasks, with a zero-diff check for read-only reviews.

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
