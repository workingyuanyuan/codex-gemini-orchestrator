#requires -Version 7.0
<#
.SYNOPSIS
Installs a versioned Codex multi-model orchestration configuration.

.DESCRIPTION
Copies scripts, bundled skills, and any native agent profiles into the Codex directory.
Optionally merges the snapshot's AGENTS.md into a managed block, preserving other instructions.
Existing destination files are never overwritten unless -Force is specified.

.PARAMETER Version
Version directory to install from versions/. Defaults to 6.1-sol-gemini3.8flash.

.PARAMETER DestinationRoot
Installation root. Defaults to the current user Codex directory.

.PARAMETER Force
Allows packaged files and the managed AGENTS.md block to be replaced.

.PARAMETER InstallDelegationTrigger
Adds the snapshot's instructions to a managed block in AGENTS.md.

.EXAMPLE
./install.ps1 -InstallDelegationTrigger

.EXAMPLE
./install.ps1 -InstallDelegationTrigger -Force
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9.\-]*$')]
    [string]$Version = '6.1-sol-gemini3.8flash',

    [ValidateNotNullOrEmpty()]
    [string]$DestinationRoot = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }),

    [switch]$InstallDelegationTrigger,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$DestinationRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DestinationRoot)

$versionsRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'versions') -ErrorAction Stop
$sourceCandidate = Join-Path $versionsRoot.Path $Version

if (-not (Test-Path -LiteralPath $sourceCandidate -PathType Container)) {
    throw "Version '$Version' was not found under: $($versionsRoot.Path)"
}

$sourceRoot = Resolve-Path -LiteralPath $sourceCandidate -ErrorAction Stop
$sourceParent = Split-Path -Parent $sourceRoot.Path
if (-not $sourceParent.Equals($versionsRoot.Path, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Version '$Version' does not resolve to a direct child of the versions directory."
}

$agentSourceDirectory = Join-Path $sourceRoot.Path 'agents'
$scriptSourceDirectory = Join-Path $sourceRoot.Path 'scripts'

if (-not (Test-Path -LiteralPath $scriptSourceDirectory -PathType Container)) {
    throw "Version '$Version' is incomplete; scripts directory is missing."
}

$agentFiles = @(
    if (Test-Path -LiteralPath $agentSourceDirectory -PathType Container) {
        Get-ChildItem -LiteralPath $agentSourceDirectory -File -Filter '*.toml' | Sort-Object Name
    }
)
$scriptFiles = @(Get-ChildItem -LiteralPath $scriptSourceDirectory -File -Filter '*.ps1' | Sort-Object Name)

if ($scriptFiles.Count -eq 0) {
    throw "Version '$Version' contains no PowerShell scripts."
}

$skillSourceDirectory = Join-Path $sourceRoot.Path 'skills'
$skillFiles = @()
if (Test-Path -LiteralPath $skillSourceDirectory -PathType Container) {
    $skillFiles = @(
        Get-ChildItem -LiteralPath $skillSourceDirectory -File -Recurse |
            Sort-Object FullName
    )
}

$sourceFiles = @()

foreach ($sourceFile in $agentFiles) {
    $sourceFiles += [pscustomobject]@{
        Source = $sourceFile.FullName
        DestinationDirectory = Join-Path $DestinationRoot 'agents'
        DestinationName = $sourceFile.Name
    }
}

foreach ($sourceFile in $scriptFiles) {
    $sourceFiles += [pscustomobject]@{
        Source = $sourceFile.FullName
        DestinationDirectory = Join-Path $DestinationRoot 'scripts'
        DestinationName = $sourceFile.Name
    }
}

$skillsRoot = Join-Path $DestinationRoot 'skills'
foreach ($sourceFile in $skillFiles) {
    $relativePath = [IO.Path]::GetRelativePath($skillSourceDirectory, $sourceFile.FullName)
    $relativeDirectory = Split-Path -Parent $relativePath
    $destinationDirectory = if ([string]::IsNullOrEmpty($relativeDirectory)) {
        $skillsRoot
    }
    else {
        Join-Path $skillsRoot $relativeDirectory
    }

    $sourceFiles += [pscustomobject]@{
        Source = $sourceFile.FullName
        DestinationDirectory = $destinationDirectory
        DestinationName = $sourceFile.Name
    }
}

foreach ($file in $sourceFiles) {
    if (-not (Test-Path -LiteralPath $file.Source -PathType Leaf)) {
        throw "Version '$Version' is incomplete; required file is missing: $($file.Source)"
    }
    $file | Add-Member -NotePropertyName Destination -NotePropertyValue (
        Join-Path $file.DestinationDirectory $file.DestinationName
    )
}

$collisions = @($sourceFiles | Where-Object { Test-Path -LiteralPath $_.Destination })
if ($collisions.Count -gt 0 -and -not $Force) {
    $collisionList = ($collisions.Destination | Sort-Object) -join [Environment]::NewLine
    throw "Installation would overwrite existing files. No files were copied. Re-run with -Force to replace only these files:$([Environment]::NewLine)$collisionList"
}

# Prepare the optional block before copying anything, so malformed instructions fail early.
$instructionsPath = Join-Path $DestinationRoot 'AGENTS.md'
$instructionsText = $null
if ($InstallDelegationTrigger) {
    $startMarker = '<!-- codex-gemini-orchestrator:start -->'
    $endMarker = '<!-- codex-gemini-orchestrator:end -->'
    $sourceInstructions = Get-Content -LiteralPath (Join-Path $sourceRoot.Path 'AGENTS.md') -Raw
    $block = "$startMarker`n$($sourceInstructions.Trim())`n$endMarker"
    $existing = if (Test-Path -LiteralPath $instructionsPath) { [IO.File]::ReadAllText($instructionsPath) } else { '' }
    $starts = [regex]::Matches($existing, [regex]::Escape($startMarker))
    $ends = [regex]::Matches($existing, [regex]::Escape($endMarker))
    if ($starts.Count -ne $ends.Count -or $starts.Count -gt 1 -or
        ($starts.Count -eq 1 -and $starts[0].Index -ge $ends[0].Index)) {
        throw 'AGENTS.md contains an invalid managed block; repair its markers before installation.'
    }
    if ($starts.Count -eq 1) {
        $offset = $starts[0].Index
        $length = $ends[0].Index + $endMarker.Length - $offset
        if (-not $Force -and $existing.Substring($offset, $length) -cne $block) {
            throw 'Replacing the managed AGENTS.md block requires -Force.'
        }
        $instructionsText = $existing.Substring(0, $offset) + $block + $existing.Substring($offset + $length)
    }
    else {
        $separator = if ($existing.Length -gt 0) { "`n`n" } else { '' }
        $instructionsText = $existing + $separator + $block + "`n"
    }
}

$destinationDirectories = $sourceFiles.DestinationDirectory | Sort-Object -Unique
foreach ($directory in $destinationDirectories) {
    $null = New-Item -ItemType Directory -Path $directory -Force
}

foreach ($file in $sourceFiles) {
    Copy-Item -LiteralPath $file.Source -Destination $file.Destination -Force:$Force
    Write-Verbose "Installed $($file.Destination)"
}

if ($InstallDelegationTrigger) {
    [IO.File]::WriteAllText($instructionsPath, $instructionsText, [Text.UTF8Encoding]::new($false))
}

Write-Host "Installed codex-gemini-orchestrator version $Version to $DestinationRoot."
