# Security Policy

## Supported versions

Security fixes are evaluated for the current documented compatibility line. Versioned snapshots remain immutable so users can audit exactly what they installed; a correction that changes versioned behavior is published as a new version directory with migration notes.

| Version | Supported |
| --- | --- |
| 5.6 | Yes |
| Earlier or unofficial copies | No |

## Reporting a vulnerability

Use GitHub's private vulnerability reporting feature from the repository's **Security** tab when available. If private reporting is unavailable, contact the maintainers through a private channel listed on the repository profile. Do not open a public issue for an unpatched vulnerability.

Include:

- The affected file and version directory.
- Reproduction steps or a minimal proof of concept.
- Expected impact and required preconditions.
- Any suggested mitigation, if known.

Do not include real credentials, API keys, tokens, cookies, private prompts, or personal data. Use clearly fake placeholders and redact command output.

## Scope

Security-sensitive areas include:

- Installer path validation, collision handling, and overwrite behavior.
- Antigravity model resolution and permission-mode arguments.
- Task-contract and Git worktree boundaries.
- Accidental secret disclosure in prompts, logs, documentation, or commits.
- Instructions that could cause delegated agents to modify Git state or files outside their assigned worktree.

The project never requires a Gemini API key. Requests to add, transmit, or store one for this workflow should be treated as suspicious.

## Response expectations

Maintainers will acknowledge a complete report, assess severity and supported versions, coordinate a fix, and publish disclosure details after users have a reasonable opportunity to update. Exact timing depends on impact and reproducibility.
