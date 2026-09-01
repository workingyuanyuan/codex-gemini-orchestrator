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
$previousHome = $HOME
try {
    Set-Variable -Name HOME -Value $testRoot -Scope Global -Force

    & $installerPath

    $expectedFiles = @(
        '.codex\AGENTS.md'
        '.codex\agents\gpt-5-6-luna-max.toml'
        '.codex\agents\gpt-5-6-terra-max.toml'
        '.codex\scripts\Invoke-AntigravityAgent.ps1'
        '.codex\skills\model-routing-and-delegation-agy\SKILL.md'
        '.codex\skills\model-routing-and-delegation-agy\agents\openai.yaml'
    )

    foreach ($relativePath in $expectedFiles) {
        $installedPath = Join-Path $testRoot $relativePath
        if (-not (Test-Path -LiteralPath $installedPath -PathType Leaf)) {
            throw "Expected installed file is missing: $installedPath"
        }
    }

    $collisionDetected = $false
    try {
        & $installerPath -Version '5.6-gemini3.7flash'
    }
    catch {
        $collisionDetected = $_.Exception.Message -like 'Installation would overwrite existing files*'
    }
    if (-not $collisionDetected) {
        throw 'Installer did not reject existing destination files without -Force.'
    }

    & $installerPath -Version '5.6-gemini3.7flash' -Force
    Write-Host 'PASS: installer copies agents, scripts, and skills; rejects collisions; and supports -Force.'
}
finally {
    Set-Variable -Name HOME -Value $previousHome -Scope Global -Force
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
