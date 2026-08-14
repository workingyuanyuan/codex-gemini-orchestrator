#requires -Version 7.0
<#
.SYNOPSIS
Runs one stateless Antigravity CLI task in an existing isolated Git worktree.

.DESCRIPTION
The orchestrating Codex agent owns worktree creation, integration, commits, and cleanup.
This wrapper validates the worktree and UTF-8 task contract, resolves a stable worker
alias against `agy models`, explicitly attaches the resolved worktree, then runs a
single non-interactive Antigravity session with a ten-minute print timeout. Git trust
is added only to this process and its children. The wrapper rejects empty output and
known headless permission-denial output even when Antigravity exits with code zero.
It writes no log files.

Supported aliases resolve to Antigravity slugs as follows:

  gemini-3.7-flash       ->  gemini-3.7-flash-medium
  gemini-3.7-flash-high  ->  gemini-3.7-flash-high
  gemini-3.1-pro         ->  gemini-3.1-pro-high

The Gemini slugs include reasoning effort. Do not pass `--effort` separately.

.EXAMPLE
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" `
  -WorkingDirectory "C:\src\project-agent-task" `
  -Model gemini-3.7-flash `
  -PromptFile "C:\src\contracts\task.md" `
  -AutoApprove
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$WorkingDirectory,

    [Parameter(Mandatory)]
    [ValidateSet('gemini-3.7-flash', 'gemini-3.7-flash-high', 'gemini-3.1-pro')]
    [string]$Model,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$PromptFile,

    [switch]$AutoApprove
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory)][string]$LiteralPath,
        [Parameter(Mandatory)][string]$Label
    )

    try {
        return (Resolve-Path -LiteralPath $LiteralPath -ErrorAction Stop).Path
    }
    catch {
        throw "$Label does not exist or cannot be resolved: $LiteralPath"
    }
}

function Remove-AnsiEscapeSequences {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)
    return [regex]::Replace($Text, "`e\[[0-?]*[ -/]*[@-~]", '')
}

$worktreePath = Resolve-ExistingPath -LiteralPath $WorkingDirectory -Label 'Working directory'
$promptPath = Resolve-ExistingPath -LiteralPath $PromptFile -Label 'Prompt file'

if (-not (Test-Path -LiteralPath $worktreePath -PathType Container)) {
    throw "Working directory is not a directory: $worktreePath"
}
if (-not (Test-Path -LiteralPath $promptPath -PathType Leaf)) {
    throw "Prompt file is not a file: $promptPath"
}

# Git's environment-based configuration is inherited by both these validation
# commands and the Antigravity child process. Append one entry instead of replacing
# caller-provided entries, changing global Git configuration, or trusting every path.
$existingGitConfigCount = 0
if (-not [string]::IsNullOrWhiteSpace($env:GIT_CONFIG_COUNT)) {
    if (-not [int]::TryParse($env:GIT_CONFIG_COUNT, [ref]$existingGitConfigCount) -or $existingGitConfigCount -lt 0) {
        throw "GIT_CONFIG_COUNT must be a non-negative integer when set. Received: $($env:GIT_CONFIG_COUNT)"
    }
}
$gitSafeDirectory = [IO.Path]::GetFullPath($worktreePath).TrimEnd('\', '/') -replace '\\', '/'
Set-Item -LiteralPath "Env:GIT_CONFIG_KEY_$existingGitConfigCount" -Value 'safe.directory'
Set-Item -LiteralPath "Env:GIT_CONFIG_VALUE_$existingGitConfigCount" -Value $gitSafeDirectory
$env:GIT_CONFIG_COUNT = [string]($existingGitConfigCount + 1)

$gitCommand = Get-Command git -ErrorAction Stop | Select-Object -First 1
$insideWorktreeOutput = (& $gitCommand.Source -C $worktreePath rev-parse --is-inside-work-tree 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $insideWorktreeOutput -ne 'true') {
    throw "Working directory is not inside a trusted Git worktree: $worktreePath`n$insideWorktreeOutput"
}

$topLevelRaw = (& $gitCommand.Source -C $worktreePath rev-parse --show-toplevel 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($topLevelRaw)) {
    throw "Unable to determine the Git worktree root for: $worktreePath"
}
$topLevelPath = Resolve-ExistingPath -LiteralPath $topLevelRaw -Label 'Git worktree root'

$normalizedWorktree = [IO.Path]::GetFullPath($worktreePath).TrimEnd('\', '/')
$normalizedTopLevel = [IO.Path]::GetFullPath($topLevelPath).TrimEnd('\', '/')
if (-not $normalizedWorktree.Equals($normalizedTopLevel, [StringComparison]::OrdinalIgnoreCase)) {
    throw "WorkingDirectory must be the Git worktree root. Resolved root: $normalizedTopLevel"
}

try {
    $strictUtf8 = [Text.UTF8Encoding]::new($false, $true)
    $prompt = [IO.File]::ReadAllText($promptPath, $strictUtf8)
}
catch {
    throw "Prompt file must be valid UTF-8: $promptPath. $($_.Exception.Message)"
}
if ([string]::IsNullOrWhiteSpace($prompt)) {
    throw "Prompt file is empty: $promptPath"
}

$agyCommand = Get-Command agy -ErrorAction Stop | Select-Object -First 1
$modelsOutput = (& $agyCommand.Source models 2>&1 | Out-String)
$modelsExitCode = $LASTEXITCODE
if ($modelsExitCode -ne 0) {
    throw "`agy models` failed with exit code $modelsExitCode.`n$modelsOutput"
}

$cleanModelsOutput = Remove-AnsiEscapeSequences -Text $modelsOutput
$modelSlug = switch ($Model) {
    'gemini-3.7-flash'      { 'gemini-3.7-flash-medium' }
    'gemini-3.7-flash-high' { 'gemini-3.7-flash-high' }
    'gemini-3.1-pro'        { 'gemini-3.1-pro-high' }
    default { throw "Unsupported model alias: $Model" }
}

# agy 1.1.4 emits model slugs rather than display names. Match the exact slug as
# a standalone token, then pass that slug unchanged to `agy --model`.
$modelPattern = '(?<![A-Za-z0-9._-])' + [regex]::Escape($modelSlug) + '(?![A-Za-z0-9._-])'
$resolvedModels = @(
    [regex]::Matches(
        $cleanModelsOutput,
        $modelPattern,
        [Text.RegularExpressions.RegexOptions]::IgnoreCase
    ) |
        ForEach-Object { $_.Value.ToLowerInvariant() } |
        Sort-Object -Unique
)

if ($resolvedModels.Count -ne 1) {
    throw "Model alias '$Model' did not resolve uniquely to slug '$modelSlug'. Found $($resolvedModels.Count) match(es). Available model output:`n$cleanModelsOutput"
}
$resolvedModel = $modelSlug

$agyArguments = @(
    '--add-dir', $worktreePath,
    '--print-timeout', '10m',
    '--model', $resolvedModel,
    '-p', $prompt
)
if ($AutoApprove) {
    $agyArguments = @('--dangerously-skip-permissions') + $agyArguments
}

$exitCode = 1
$agyOutput = @()
Push-Location -LiteralPath $worktreePath
try {
    $agyOutput = @(& $agyCommand.Source @agyArguments 2>&1)
    $exitCode = if ($null -eq $LASTEXITCODE) { 1 } else { [int]$LASTEXITCODE }
}
finally {
    Pop-Location
}

$agyOutput | ForEach-Object { Write-Output $_ }

if ($exitCode -eq 0) {
    $cleanAgyOutput = Remove-AnsiEscapeSequences -Text ($agyOutput | Out-String)
    $headlessPermissionFailure =
        $cleanAgyOutput -match '(?im)^\s*jetski:\s*no output produced\b' -or
        $cleanAgyOutput -match '(?i)\ba tool required the ["'']command["''] permission\b'

    if ([string]::IsNullOrWhiteSpace($cleanAgyOutput) -or $headlessPermissionFailure) {
        [Console]::Error.WriteLine('Antigravity produced no usable agent result. Treating the exit-0 response as a failure.')
        exit 1
    }
}

exit $exitCode
