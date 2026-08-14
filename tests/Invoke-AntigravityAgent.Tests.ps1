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
$wrapperPath = Join-Path $repositoryRoot 'versions\5.6-gemini3.7flash\scripts\Invoke-AntigravityAgent.ps1'
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
echo gemini-3.7-flash-high
echo gemini-3.7-flash-medium
echo gemini-3.1-pro-high
exit /b 0
:done
if "%AGY_TEST_MODE%"=="empty" exit /b 0
if "%AGY_TEST_MODE%"=="permission" (
  echo jetski: no output produced — a tool required the "command" permission.
  exit /b 0
)
if "%AGY_TEST_MODE%"=="nonzero" (
  echo simulated Antigravity failure
  exit /b 23
)
echo agent-result
exit /b 0
'@

$previousPath = $env:PATH
$previousArgumentsFile = $env:AGY_ARGUMENTS_FILE
$previousTestMode = $env:AGY_TEST_MODE
$previousAssumeDifferentOwner = $env:GIT_TEST_ASSUME_DIFFERENT_OWNER
try {
    $env:PATH = "$fakeBin;$previousPath"
    $env:AGY_ARGUMENTS_FILE = $argumentsPath
    $env:AGY_TEST_MODE = 'success'
    $env:GIT_TEST_ASSUME_DIFFERENT_OWNER = '1'
    $globalSafeDirectoriesBefore = @(& git config --global --get-all safe.directory 2>$null)

    $modelCases = @(
        @{ Alias = 'gemini-3.7-flash'; Slug = 'gemini-3.7-flash-medium' }
        @{ Alias = 'gemini-3.7-flash-high'; Slug = 'gemini-3.7-flash-high' }
        @{ Alias = 'gemini-3.1-pro'; Slug = 'gemini-3.1-pro-high' }
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

    foreach ($retiredAlias in @('gemini-3.6-flash', 'gemini-3.5-flash', 'claude-opus-4-6')) {
        $wrapperOutput = & pwsh -NoProfile -File $wrapperPath `
            -WorkingDirectory $resolvedRepositoryRoot `
            -Model $retiredAlias `
            -PromptFile $promptPath `
            -AutoApprove 2>&1

        if ($LASTEXITCODE -eq 0) {
            throw "Retired alias '$retiredAlias' was unexpectedly accepted.`n$($wrapperOutput | Out-String)"
        }
    }

    $globalSafeDirectoriesAfter = @(& git config --global --get-all safe.directory 2>$null)
    if (($globalSafeDirectoriesBefore -join "`0") -cne ($globalSafeDirectoriesAfter -join "`0")) {
        throw 'The wrapper changed global Git safe.directory configuration.'
    }

    $runtimeCases = @(
        @{ Mode = 'success'; ExpectedExitCode = 0; ExpectedOutput = 'agent-result' }
        @{ Mode = 'empty'; ExpectedExitCode = 1; ExpectedOutput = 'no usable agent result' }
        @{ Mode = 'permission'; ExpectedExitCode = 1; ExpectedOutput = 'no usable agent result' }
        @{ Mode = 'nonzero'; ExpectedExitCode = 23; ExpectedOutput = 'simulated Antigravity failure' }
    )

    foreach ($runtimeCase in $runtimeCases) {
        $env:AGY_TEST_MODE = $runtimeCase.Mode
        $wrapperOutput = & pwsh -NoProfile -File $wrapperPath `
            -WorkingDirectory $resolvedRepositoryRoot `
            -Model 'gemini-3.7-flash' `
            -PromptFile $promptPath `
            -AutoApprove 2>&1
        $wrapperExitCode = $LASTEXITCODE
        $outputText = $wrapperOutput | Out-String

        if ($wrapperExitCode -ne $runtimeCase.ExpectedExitCode) {
            throw "Runtime mode '$($runtimeCase.Mode)' exited with $wrapperExitCode; expected $($runtimeCase.ExpectedExitCode).`n$outputText"
        }
        if ($outputText -notlike "*$($runtimeCase.ExpectedOutput)*") {
            throw "Runtime mode '$($runtimeCase.Mode)' did not emit expected output '$($runtimeCase.ExpectedOutput)'.`n$outputText"
        }
    }

    Write-Host 'PASS: aliases, scoped Git trust, output validation, and exit-code propagation behave as expected.'
}
finally {
    $env:PATH = $previousPath
    $env:AGY_ARGUMENTS_FILE = $previousArgumentsFile
    $env:AGY_TEST_MODE = $previousTestMode
    $env:GIT_TEST_ASSUME_DIFFERENT_OWNER = $previousAssumeDifferentOwner
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
