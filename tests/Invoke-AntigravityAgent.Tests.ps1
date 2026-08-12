#requires -Version 7.0

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-SequenceEqual {
    param(
        [Parameter(Mandatory)][string[]]$Expected,
        [Parameter(Mandatory)][string[]]$Actual
    )

    if ($Expected.Count -ne $Actual.Count) {
        throw "Argument count mismatch. Expected $($Expected.Count), received $($Actual.Count).`nActual: $($Actual -join ' | ')"
    }

    for ($index = 0; $index -lt $Expected.Count; $index++) {
        if ($Expected[$index] -cne $Actual[$index]) {
            throw "Argument mismatch at index $index. Expected '$($Expected[$index])', received '$($Actual[$index])'."
        }
    }
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$wrapperPath = Join-Path $repositoryRoot 'versions\5.6-gemini3.6flash\scripts\Invoke-AntigravityAgent.ps1'
$resolvedRepositoryRoot = (Resolve-Path -LiteralPath $repositoryRoot).Path
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$testRoot = [IO.Path]::GetFullPath((Join-Path $tempBase "codex-gemini-orchestrator-wrapper-test-$([guid]::NewGuid())"))

if (-not $testRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Unsafe temporary test path: $testRoot"
}

$null = New-Item -ItemType Directory -Path $testRoot
$fakeBin = Join-Path $testRoot 'bin'
$null = New-Item -ItemType Directory -Path $fakeBin
$argumentsPath = Join-Path $testRoot 'agy-arguments.txt'
$promptPath = Join-Path $testRoot 'prompt.md'
$fakeAgyPath = Join-Path $fakeBin 'agy.cmd'

Set-Content -LiteralPath $promptPath -Value 'wrapper regression smoke test' -Encoding utf8NoBOM
Set-Content -LiteralPath $fakeAgyPath -Encoding ascii -Value @'
@echo off
if "%~1"=="models" goto models
:record
if "%~1"=="" goto done
>>"%AGY_ARGUMENTS_FILE%" echo %~1
shift
goto record
:models
echo gemini-3.6-flash-high
echo gemini-3.5-flash-high
echo gemini-3.1-pro-high
echo claude-opus-4-6-thinking
exit /b 0
:done
exit /b 0
'@

$previousPath = $env:PATH
$previousArgumentsFile = $env:AGY_ARGUMENTS_FILE
try {
    $env:PATH = "$fakeBin;$previousPath"
    $env:AGY_ARGUMENTS_FILE = $argumentsPath

    $modelCases = @(
        @{ Alias = 'gemini-3.6-flash'; Slug = 'gemini-3.6-flash-high' }
        @{ Alias = 'gemini-3.5-flash'; Slug = 'gemini-3.5-flash-high' }
        @{ Alias = 'gemini-3.1-pro'; Slug = 'gemini-3.1-pro-high' }
        @{ Alias = 'claude-opus-4-6'; Slug = 'claude-opus-4-6-thinking' }
    )

    foreach ($modelCase in $modelCases) {
        Remove-Item -LiteralPath $argumentsPath -ErrorAction SilentlyContinue

        $wrapperOutput = & pwsh -NoProfile -File $wrapperPath `
            -WorkingDirectory $resolvedRepositoryRoot `
            -Model $modelCase.Alias `
            -PromptFile $promptPath `
            -AutoApprove 2>&1
        $wrapperExitCode = $LASTEXITCODE

        if ($wrapperExitCode -ne 0) {
            throw "Wrapper exited with code $wrapperExitCode for alias '$($modelCase.Alias)'.`n$($wrapperOutput | Out-String)"
        }
        if (-not (Test-Path -LiteralPath $argumentsPath -PathType Leaf)) {
            throw "The fake agy command did not record an invocation for alias '$($modelCase.Alias)'."
        }

        $actualArguments = @(Get-Content -LiteralPath $argumentsPath)
        $expectedArguments = @(
            '--dangerously-skip-permissions'
            '--add-dir'
            $resolvedRepositoryRoot
            '--print-timeout'
            '10m'
            '--model'
            $modelCase.Slug
            '-p'
            'wrapper regression smoke test'
        )

        Assert-SequenceEqual -Expected $expectedArguments -Actual $actualArguments
    }

    Write-Host 'PASS: all worker aliases bind agy to the resolved worktree with a 10-minute print timeout.'
}
finally {
    $env:PATH = $previousPath
    $env:AGY_ARGUMENTS_FILE = $previousArgumentsFile
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
