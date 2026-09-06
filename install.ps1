#requires -Version 7.0
<#
.SYNOPSIS
Installs a versioned Codex multi-model orchestration configuration.

.DESCRIPTION
Copies one versioned configuration snapshot into the current user's .codex directory,
including AGENTS.md, native agent profiles, scripts, and bundled skills. Existing
destination files are never overwritten unless -Force is specified.

.PARAMETER Version
Version directory to install from versions/. Defaults to 6-gemini3.8flash.

.PARAMETER DestinationRoot
Installation root. Defaults to the current user Codex directory.

.PARAMETER Force
Allows existing destination files to be overwritten. Unrelated files are untouched.

.EXAMPLE
./install.ps1 -Version 6-gemini3.8flash

.EXAMPLE
./install.ps1 -Version 6-gemini3.8flash -Force
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9.\-]*$')]
    [string]$Version = '6-gemini3.8flash',

    [ValidateNotNullOrEmpty()]
    [string]$DestinationRoot = (Join-Path $HOME '.codex'),

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

$sourceFiles = @(
    [pscustomobject]@{
        Source = Join-Path $sourceRoot.Path 'AGENTS.md'
        DestinationDirectory = $DestinationRoot
        DestinationName = 'AGENTS.md'
    }
)

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

$destinationDirectories = $sourceFiles.DestinationDirectory | Sort-Object -Unique
foreach ($directory in $destinationDirectories) {
    $null = New-Item -ItemType Directory -Path $directory -Force
}

foreach ($file in $sourceFiles) {
    Copy-Item -LiteralPath $file.Source -Destination $file.Destination -Force:$Force
    Write-Verbose "Installed $($file.Destination)"
}

Write-Host "Installed codex-gemini-orchestrator version $Version to $DestinationRoot."
