#requires -Version 7.0

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$installerPath = Join-Path $repositoryRoot 'install.ps1'
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$testRoot = [IO.Path]::GetFullPath((Join-Path $tempBase "codex-gemini-orchestrator-install-test-$([guid]::NewGuid())"))

if (-not $testRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Unsafe temporary test path: $testRoot"
}

$null = New-Item -ItemType Directory -Path $testRoot
$testDestination = Join-Path $testRoot '.codex'
try {

    & $installerPath -DestinationRoot $testDestination

    $expectedFiles = @(
        '.codex\AGENTS.md'
        '.codex\scripts\Invoke-AntigravityAgent.ps1'
        '.codex\skills\model-routing-and-delegation-agy\SKILL.md'
        '.codex\skills\model-routing-and-delegation-agy\agents\openai.yaml'
    )

    foreach ($relativePath in $expectedFiles) {
        $installedPath = Join-Path $testRoot $relativePath
        if (-not (Test-Path -LiteralPath $installedPath -PathType Leaf)) {
            throw "Expected installed file is missing: $installedPath"
        }
        $sourcePath = Join-Path $repositoryRoot ('versions\6-gemini3.8flash\' + $relativePath.Substring('.codex\'.Length))
        if ((Get-FileHash -LiteralPath $sourcePath).Hash -cne (Get-FileHash -LiteralPath $installedPath).Hash) {
            throw "Installed file does not match the current snapshot: $relativePath"
        }
    }

    $installedRules = Join-Path $testDestination 'AGENTS.md'
    Set-Content -LiteralPath $installedRules -Value 'local customization'
    $unrelatedFile = Join-Path $testDestination 'unrelated.txt'
    Set-Content -LiteralPath $unrelatedFile -Value 'keep'
    $collisionDetected = $false
    try {
        & $installerPath -DestinationRoot $testDestination -Version '6-gemini3.8flash'
    }
    catch {
        $collisionDetected = $_.Exception.Message -like 'Installation would overwrite existing files*'
    }
    if (-not $collisionDetected) {
        throw 'Installer did not reject existing destination files without -Force.'
    }

    & $installerPath -DestinationRoot $testDestination -Version '6-gemini3.8flash' -Force
    if (Test-Path -LiteralPath (Join-Path $testDestination 'agents')) { throw 'Current snapshot installed native agent profiles.' }
    if ((Get-FileHash $installedRules).Hash -ne (Get-FileHash (Join-Path $repositoryRoot 'versions/6-gemini3.8flash/AGENTS.md')).Hash) { throw 'Force did not restore snapshot.' }
    if ((Get-Content $unrelatedFile) -ne 'keep') { throw 'Unrelated file was changed.' }
    $legacyDestination = Join-Path $testRoot 'legacy'
    & $installerPath -DestinationRoot $legacyDestination -Version '5.6-gemini3.8flash'
    if (-not (Test-Path (Join-Path $legacyDestination 'agents/gpt-5-6-luna-max.toml'))) { throw 'Legacy agent profile was not installed.' }
    Write-Host 'PASS: High-only and legacy installation, collision handling, Force, and unrelated-file preservation.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
