#requires -Version 7.0

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-SequenceEqual {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][AllowEmptyCollection()][string[]]$Expected,
        [Parameter(Mandatory)][AllowEmptyString()][AllowEmptyCollection()][string[]]$Actual
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
$wrapperPath = Join-Path $repositoryRoot 'versions\6-sol-gemini3.8flash\scripts\Invoke-AntigravityAgent.ps1'
if (-not (Test-Path -LiteralPath $wrapperPath -PathType Leaf)) {
    throw "Wrapper under test not found at: $wrapperPath"
}

$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$testRoot = [System.IO.Path]::GetFullPath((Join-Path $tempBase "antigravity-regression-test-$([System.Guid]::NewGuid().ToString('N'))"))

if (-not $testRoot.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Unsafe temporary test path: $testRoot"
}

$null = New-Item -ItemType Directory -Path $testRoot
$fakeBin = Join-Path $testRoot 'bin'
$null = New-Item -ItemType Directory -Path $fakeBin
$argumentsFile = Join-Path $testRoot 'agy-arguments.txt'
$mockCsPath = Join-Path $testRoot 'MockAgy.cs'
$fakeAgyExe = Join-Path $fakeBin 'agy.exe'

# Locate local C# compiler for completely offline mock compilation
$cscPath = $null
$possibleCscPaths = @(
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'),
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe')
)
foreach ($cand in $possibleCscPaths) {
    if (Test-Path -LiteralPath $cand -PathType Leaf) {
        $cscPath = $cand
        break
    }
}
if (-not $cscPath) {
    $cscCmd = Get-Command csc.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cscCmd) { $cscPath = $cscCmd.Source }
}
if (-not $cscPath) {
    throw "No C# compiler (csc.exe) found to build offline mock agy executable."
}

# Compile offline C# mock executable
$mockSource = @'
using System;
using System.IO;
using System.Text;
using System.Threading;

class MockAgy
{
    static int Main(string[] args)
    {
        Console.OutputEncoding = Encoding.UTF8;
        try {
            Console.SetError(new StreamWriter(Console.OpenStandardError(), Encoding.UTF8) { AutoFlush = true });
        } catch {}

        string argFile = Environment.GetEnvironmentVariable("AGY_ARGUMENTS_FILE");
        if (!string.IsNullOrEmpty(argFile))
        {
            using (StreamWriter sw = new StreamWriter(argFile, false, Encoding.UTF8))
            {
                foreach (string arg in args)
                {
                    sw.WriteLine(Convert.ToBase64String(Encoding.UTF8.GetBytes(arg)));
                }
            }
        }

        string mode = Environment.GetEnvironmentVariable("AGY_TEST_MODE") ?? "success";
        string envFile = Environment.GetEnvironmentVariable("AGY_ENV_FILE");
        if (!string.IsNullOrEmpty(envFile)) File.WriteAllLines(envFile, new string[] {
            Environment.GetEnvironmentVariable("GIT_CONFIG_COUNT") ?? "",
            Environment.GetEnvironmentVariable("GIT_CONFIG_KEY_0") ?? "",
            Environment.GetEnvironmentVariable("GIT_CONFIG_VALUE_0") ?? "",
            Environment.GetEnvironmentVariable("GIT_CONFIG_KEY_1") ?? ""
        });
        if (mode == "missing-status") { Console.WriteLine("{\"response\":\"unusable\"}"); return 0; }
        if (mode == "numeric-response") { Console.WriteLine("{\"status\":\"SUCCESS\",\"response\":42}"); return 0; }
        if (mode == "artifact-failure") {
            string root = Environment.GetEnvironmentVariable("AGY_ARTIFACT_ROOT");
            foreach (string dir in Directory.GetDirectories(root, "antigravity-run-*")) {
                if (Directory.GetFileSystemEntries(dir).Length == 0) {
                    Directory.Delete(dir);
                    File.WriteAllText(dir, "block artifact persistence");
                }
            }
        }
        if (mode == "large-stderr") Console.Error.WriteLine(new string('D', 131072));
        string sleepMsStr = Environment.GetEnvironmentVariable("AGY_SLEEP_MS");
        if (!string.IsNullOrEmpty(sleepMsStr))
        {
            int sleepMs;
            if (int.TryParse(sleepMsStr, out sleepMs) && sleepMs > 0)
            {
                Thread.Sleep(sleepMs);
            }
        }

        if (mode == "timeout")
        {
            Thread.Sleep(30000);
            return 0;
        }

        if (mode == "nonzero")
        {
            Console.Error.WriteLine("simulated Antigravity failure on stderr");
            return 23;
        }

        if (mode == "stderr-separation")
        {
            Console.Error.WriteLine("diagnostic trace line 1");
            Console.Error.WriteLine("diagnostic trace line 2");
            Console.WriteLine("{\"conversation_id\":\"conv-sep-123\",\"status\":\"SUCCESS\",\"response\":\"clean-stdout-response\",\"error\":null,\"duration_seconds\":0.5,\"num_turns\":1,\"usage\":{}}");
            return 0;
        }

        if (mode == "malformed-json")
        {
            Console.WriteLine("This is not valid JSON text!");
            return 0;
        }

        if (mode == "non-success-status")
        {
            Console.WriteLine("{\"conversation_id\":\"conv-err\",\"status\":\"FAILED\",\"response\":\"\",\"error\":\"Model quota exceeded\",\"duration_seconds\":0.1,\"num_turns\":0,\"usage\":{}}");
            return 0;
        }

        if (mode == "empty-response")
        {
            Console.WriteLine("{\"conversation_id\":\"conv-empty\",\"status\":\"SUCCESS\",\"response\":\"   \",\"error\":null,\"duration_seconds\":0.1,\"num_turns\":1,\"usage\":{}}");
            return 0;
        }

        if (mode == "headless-permission")
        {
            Console.WriteLine("{\"conversation_id\":\"conv-perm\",\"status\":\"SUCCESS\",\"response\":\"jetski: no output produced — a tool required the \\\"command\\\" permission.\",\"error\":null,\"duration_seconds\":0.1,\"num_turns\":1,\"usage\":{}}");
            return 0;
        }

        if (mode == "large-response")
        {
            string resp = new string('X', 10000);
            Console.WriteLine("{\"conversation_id\":\"conv-large\",\"status\":\"SUCCESS\",\"response\":\"" + resp + "\",\"error\":null,\"duration_seconds\":1.0,\"num_turns\":1,\"usage\":{}}");
            return 0;
        }

        // Default: echo prompt safely in json
        string promptArg = "";
        for (int i = 0; i < args.Length - 1; i++)
        {
            if (args[i] == "-p")
            {
                promptArg = args[i + 1];
                break;
            }
        }

        string safePrompt = promptArg.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r").Replace("\n", "\\n");
        Console.WriteLine("{\"conversation_id\":\"conv-echo-456\",\"status\":\"SUCCESS\",\"response\":\"Echo: " + safePrompt + "\",\"error\":null,\"duration_seconds\":0.2,\"num_turns\":1,\"usage\":{}}");
        return 0;
    }
}
'@

Set-Content -LiteralPath $mockCsPath -Value $mockSource -Encoding utf8NoBOM
& $cscPath /nologo /out:$fakeAgyExe $mockCsPath
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $fakeAgyExe -PathType Leaf)) {
    throw "Failed to compile offline mock agy executable using csc.exe."
}

# Set up isolated temporary test Git repo and linked worktree
$primaryRepo = Join-Path $testRoot 'primary-repo'
$linkedWorktree = Join-Path $testRoot 'linked-worktree'
$contractsDir = Join-Path $testRoot 'contracts'
$customArtifactsDir = Join-Path $testRoot 'custom-artifacts'

$null = New-Item -ItemType Directory -Path $primaryRepo
$null = New-Item -ItemType Directory -Path $contractsDir
$null = New-Item -ItemType Directory -Path $customArtifactsDir

& git -C $primaryRepo init
& git -C $primaryRepo config user.email "test@example.com"
& git -C $primaryRepo config user.name "Test Worker"
Set-Content -LiteralPath (Join-Path $primaryRepo 'README.md') -Value 'Initial Repository' -Encoding utf8NoBOM
& git -C $primaryRepo add .
& git -C $primaryRepo commit -m "Initial commit"

& git -C $primaryRepo worktree add $linkedWorktree -b linked-branch

# Define prompt with Unicode, newlines, quotes, and shell metacharacters
$complexPromptPath = Join-Path $contractsDir 'complex-prompt.txt'
$complexPromptContent = @"
First line with "double quotes" and 'single quotes'
Second line with metacharacters: & | < > ^ %PATH% `$env:PATH `` ~ () [] {} ; * ?
Third line with Unicode: 🚀 Hello 世界 Über café ñoño € 100%
"@
Set-Content -LiteralPath $complexPromptPath -Value $complexPromptContent -Encoding utf8NoBOM
$expectedPromptContent = [System.IO.File]::ReadAllText($complexPromptPath, [System.Text.UTF8Encoding]::new($false))

function Invoke-Runner {
    param(
        [string]$WorkDir = $linkedWorktree,
        [string]$Prompt = $complexPromptPath,
        [switch]$NoAutoApprove,
        [int]$Timeout = 600,
        [int]$MaxChars = 6000,
        [string]$OutDir = $customArtifactsDir,
        [string]$ModelSlug,
        [string]$ExePath = ''
    )

    $cmdArgs = @(
        '-NoProfile',
        '-File', $wrapperPath,
        '-WorkingDirectory', $WorkDir,
        '-PromptFile', $Prompt
    )
    if (-not $NoAutoApprove) {
        $cmdArgs += '-AutoApprove'
    }
    if ($Timeout -ne 600) {
        $cmdArgs += @('-TimeoutSeconds', $Timeout)
    }
    if ($MaxChars -ne 6000) {
        $cmdArgs += @('-MaxResultChars', $MaxChars)
    }
    if (-not [string]::IsNullOrEmpty($OutDir)) {
        $cmdArgs += @('-OutputDirectory', $OutDir)
    }
    if ($PSBoundParameters.ContainsKey('ModelSlug')) {
        $cmdArgs += @('-Model', $ModelSlug)
    }
    if (-not [string]::IsNullOrEmpty($ExePath)) {
        $cmdArgs += @('-AgyExecutablePath', $ExePath)
    }

    $raw = & pwsh @cmdArgs 2>&1
    $code = $LASTEXITCODE
    $text = ($raw | Out-String).Trim()

    $parsed = $null
    try {
        $parsed = $text | ConvertFrom-Json -ErrorAction Stop
    }
    catch {}

    return [pscustomobject]@{
        ExitCode  = $code
        RawOutput = $text
        Json      = $parsed
    }
}

$previousPath = $env:PATH
$previousArgumentsFile = $env:AGY_ARGUMENTS_FILE
$previousTestMode = $env:AGY_TEST_MODE
$previousSleepMs = $env:AGY_SLEEP_MS
$previousAssumeDifferentOwner = $env:GIT_TEST_ASSUME_DIFFERENT_OWNER
$previousTestEnvironment = @{}
foreach ($key in @('GIT_CONFIG_COUNT', 'GIT_CONFIG_KEY_0', 'GIT_CONFIG_VALUE_0', 'AGY_ENV_FILE', 'AGY_ARTIFACT_ROOT')) {
    $previousTestEnvironment[$key] = [Environment]::GetEnvironmentVariable($key)
}

try {
    # Put fakeBin first on PATH and enable test environment
    $env:PATH = "$fakeBin;$previousPath"
    $env:AGY_ARGUMENTS_FILE = $argumentsFile
    $env:AGY_TEST_MODE = 'success'
    $env:GIT_TEST_ASSUME_DIFFERENT_OWNER = '1'

    # Test 1: Complex prompt roundtrip, exact argument pinning, no shell evaluation, compact JSON success
    Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
    $res1 = Invoke-Runner
    if ($res1.ExitCode -ne 0) {
        throw "Test 1 failed with exit code $($res1.ExitCode): $($res1.RawOutput)"
    }
    if ($null -eq $res1.Json) {
        throw "Test 1 output did not parse as compact JSON: $($res1.RawOutput)"
    }
    if ($res1.Json.status -cne 'success' -or $res1.Json.model -cne 'gemini-3.8-flash-medium' -or $res1.Json.truncated -ne $false) {
        throw "Test 1 JSON envelope fields mismatch: $($res1.RawOutput)"
    }
    if ($res1.Json.conversation_id -cne 'conv-echo-456' -or $null -ne $res1.Json.error) {
        throw "Test 1 conversation_id or error mismatch: $($res1.RawOutput)"
    }
    if (-not (Test-Path -LiteralPath $argumentsFile -PathType Leaf)) {
        throw "Test 1 did not record argument invocation."
    }

    $actualArgs = @(Get-Content -LiteralPath $argumentsFile | ForEach-Object {
        if (-not [string]::IsNullOrWhiteSpace($_)) {
            [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))
        }
    })
    $expectedArgs = @(
        '--dangerously-skip-permissions',
        '--add-dir',
        [System.IO.Path]::GetFullPath($linkedWorktree).TrimEnd('\', '/'),
        '--print-timeout',
        '600s',
        '--model',
        'gemini-3.8-flash-medium',
        '--output-format',
        'json',
        '-p',
        $expectedPromptContent
    )
    Assert-SequenceEqual -Expected $expectedArgs -Actual $actualArgs

    # Explicit choices must pass the exact selected model and preserve the complete argv.
    foreach ($modelSlug in @('gemini-3.8-flash-medium', 'gemini-3.8-flash-high')) {
        Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
        $selected = Invoke-Runner -ModelSlug $modelSlug
        if ($selected.ExitCode -ne 0 -or $null -eq $selected.Json -or
            $selected.Json.status -cne 'success' -or $selected.Json.model -cne $modelSlug) {
            throw "Explicit model selection failed for ${modelSlug}: $($selected.RawOutput)"
        }
        if (-not (Test-Path -LiteralPath $argumentsFile -PathType Leaf)) {
            throw "Explicit model selection did not invoke agy: $modelSlug"
        }
        $selectedArgs = @(Get-Content -LiteralPath $argumentsFile | ForEach-Object {
            [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))
        })
        $selectedExpectedArgs = $expectedArgs.Clone()
        $selectedExpectedArgs[6] = $modelSlug
        Assert-SequenceEqual -Expected $selectedExpectedArgs -Actual $selectedArgs
    }

    # Verify no shell evaluation: %PATH% and $env:PATH stayed literal
    if ($actualArgs[10] -notlike '*%PATH%*' -or $actualArgs[10] -notlike '*$env:PATH*') {
        throw 'Test 1 prompt arguments were modified or evaluated through shell.'
    }

    # Verify artifacts exist on disk and match
    $artifacts = $res1.Json.artifacts
    if (-not (Test-Path -LiteralPath $artifacts.stdout -PathType Leaf) -or
        -not (Test-Path -LiteralPath $artifacts.stderr -PathType Leaf) -or
        -not (Test-Path -LiteralPath $artifacts.result -PathType Leaf)) {
        throw "Test 1 artifacts missing on disk: $($artifacts | ConvertTo-Json -Compress)"
    }
    $persistedResult = [System.IO.File]::ReadAllText($artifacts.result, [System.Text.UTF8Encoding]::new($false))
    if ($persistedResult -notlike '*Echo:*') {
        throw "Test 1 persisted result file content mismatch: $persistedResult"
    }

    # Test 2: Custom OutputDirectory parameter
    $res2 = Invoke-Runner -OutDir $customArtifactsDir
    if ($res2.ExitCode -ne 0) {
        throw "Test 2 failed with exit code $($res2.ExitCode): $($res2.RawOutput)"
    }
    $normCustomArtifacts = [System.IO.Path]::GetFullPath($customArtifactsDir).TrimEnd('\', '/')
    $normOutStdout = [System.IO.Path]::GetFullPath($res2.Json.artifacts.stdout)
    if (-not $normOutStdout.StartsWith($normCustomArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Test 2 did not respect custom OutputDirectory: $($res2.Json.artifacts.stdout)"
    }

    # Test 3: Stderr separation (diagnostics on stderr must not mix into stdout or result)
    $env:AGY_TEST_MODE = 'stderr-separation'
    $res3 = Invoke-Runner
    if ($res3.ExitCode -ne 0) {
        throw "Test 3 failed: $($res3.RawOutput)"
    }
    if ($res3.Json.status -cne 'success' -or $res3.Json.result -cne 'clean-stdout-response') {
        throw "Test 3 stdout result mismatch: $($res3.RawOutput)"
    }
    if ($res3.RawOutput -like '*diagnostic trace*') {
        throw 'Test 3 diagnostics leaked into runner stdout envelope!'
    }
    $stderrText = [System.IO.File]::ReadAllText($res3.Json.artifacts.stderr, [System.Text.UTF8Encoding]::new($false))
    if ($stderrText -notlike '*diagnostic trace line 1*') {
        throw "Test 3 stderr artifact missing diagnostic lines: $stderrText"
    }
    $stdoutText = [System.IO.File]::ReadAllText($res3.Json.artifacts.stdout, [System.Text.UTF8Encoding]::new($false))
    if ($stdoutText -like '*diagnostic trace*') {
        throw "Test 3 stdout artifact was polluted with stderr data: $stdoutText"
    }

    # Test 4: Truncation + full file persistence
    $env:AGY_TEST_MODE = 'large-response'
    $res4 = Invoke-Runner -MaxChars 500
    if ($res4.ExitCode -ne 0) {
        throw "Test 4 failed: $($res4.RawOutput)"
    }
    if ($res4.Json.truncated -ne $true -or $res4.Json.result.Length -ne 500) {
        throw "Test 4 result was not correctly truncated to 500 chars (len=$($res4.Json.result.Length), truncated=$($res4.Json.truncated))."
    }
    $fullResultText = [System.IO.File]::ReadAllText($res4.Json.artifacts.result, [System.Text.UTF8Encoding]::new($false))
    if ($fullResultText.Length -ne 10000) {
        throw "Test 4 full result file was truncated prematurely (length $($fullResultText.Length), expected 10000)."
    }

    # Test 5: Nonzero exit code propagation
    $env:AGY_TEST_MODE = 'nonzero'
    $res5 = Invoke-Runner
    if ($res5.ExitCode -ne 23) {
        throw "Test 5 did not propagate native exit code 23 (got $($res5.ExitCode)). Output: $($res5.RawOutput)"
    }
    if ($res5.Json.status -cne 'error' -or $res5.Json.error -notlike '*code 23*') {
        throw "Test 5 error envelope mismatch: $($res5.RawOutput)"
    }
    if ($res5.Json.result -ne '') {
        throw "Test 5 expected empty result on error."
    }

    # Test 6: Timeout enforcement (exit 124, timeout status)
    $env:AGY_TEST_MODE = 'timeout'
    $res6 = Invoke-Runner -Timeout 1
    if ($res6.ExitCode -ne 124) {
        throw "Test 6 expected exit code 124 on timeout (got $($res6.ExitCode)). Output: $($res6.RawOutput)"
    }
    if ($res6.Json.status -cne 'timeout' -or $res6.Json.error -notlike '*timed out*') {
        throw "Test 6 expected timeout status envelope: $($res6.RawOutput)"
    }

    # Test 7: Malformed JSON output handling (exit 1, error status)
    $env:AGY_TEST_MODE = 'malformed-json'
    $res7 = Invoke-Runner
    if ($res7.ExitCode -ne 1) {
        throw "Test 7 expected exit code 1 for malformed output (got $($res7.ExitCode)). Output: $($res7.RawOutput)"
    }
    if ($res7.Json.status -cne 'error' -or $res7.Json.error -notlike '*malformed*') {
        throw "Test 7 envelope mismatch: $($res7.RawOutput)"
    }

    # Test 8: Non-SUCCESS status in envelope (exit 1, error status, bounded error preserved)
    $env:AGY_TEST_MODE = 'non-success-status'
    $res8 = Invoke-Runner
    if ($res8.ExitCode -ne 1) {
        throw "Test 8 expected exit code 1 for non-SUCCESS status (got $($res8.ExitCode)). Output: $($res8.RawOutput)"
    }
    if ($res8.Json.status -cne 'error' -or $res8.Json.error -notlike '*Model quota exceeded*') {
        throw "Test 8 envelope mismatch: $($res8.RawOutput)"
    }
    if ($res8.Json.conversation_id -cne 'conv-err') {
        throw "Test 8 did not preserve conversation_id: $($res8.RawOutput)"
    }

    # Test 9: Empty response string failure (exit 1, error status)
    $env:AGY_TEST_MODE = 'empty-response'
    $res9 = Invoke-Runner
    if ($res9.ExitCode -ne 1) {
        throw "Test 9 expected exit code 1 for empty response (got $($res9.ExitCode)). Output: $($res9.RawOutput)"
    }
    if ($res9.Json.status -cne 'error' -or $res9.Json.error -notlike '*empty or blank*') {
        throw "Test 9 envelope mismatch: $($res9.RawOutput)"
    }

    # Test 10: Headless permission failure (jetski false-success detection)
    $env:AGY_TEST_MODE = 'headless-permission'
    $res10 = Invoke-Runner
    if ($res10.ExitCode -ne 1) {
        throw "Test 10 expected exit code 1 for headless permission false-success (got $($res10.ExitCode)). Output: $($res10.RawOutput)"
    }
    if ($res10.Json.status -cne 'error' -or $res10.Json.error -notlike '*false-success*') {
        throw "Test 10 envelope mismatch: $($res10.RawOutput)"
    }

    # Reset test mode for preflight tests
    $env:AGY_TEST_MODE = 'success'

    # Test 11: Reject primary checkout without agy invocation
    Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
    $res11 = Invoke-Runner -WorkDir $primaryRepo
    if ($res11.ExitCode -ne 1) {
        throw "Test 11 expected exit code 1 for primary checkout (got $($res11.ExitCode)). Output: $($res11.RawOutput)"
    }
    if ($res11.Json.status -cne 'error' -or $res11.Json.error -notlike '*primary Git checkout*') {
        throw "Test 11 expected primary checkout rejection: $($res11.RawOutput)"
    }
    if (Test-Path -LiteralPath $argumentsFile) {
        throw 'Test 11 agy was invoked despite primary checkout rejection!'
    }

    # Test 12: Reject dirty worktree without agy invocation
    $dirtyFilePath = Join-Path $linkedWorktree 'dirty-untracked.txt'
    Set-Content -LiteralPath $dirtyFilePath -Value 'dirty content'
    try {
        Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
        $res12 = Invoke-Runner
        if ($res12.ExitCode -ne 1) {
            throw "Test 12 expected exit code 1 for dirty worktree (got $($res12.ExitCode)). Output: $($res12.RawOutput)"
        }
        if ($res12.Json.status -cne 'error' -or $res12.Json.error -notlike '*dirty*') {
            throw "Test 12 expected dirty worktree error: $($res12.RawOutput)"
        }
        if (Test-Path -LiteralPath $argumentsFile) {
            throw 'Test 12 agy was invoked despite dirty worktree rejection!'
        }
    }
    finally {
        Remove-Item -LiteralPath $dirtyFilePath -Force -ErrorAction SilentlyContinue
    }

    # Test 13: Reject prompt contract located inside worktree without agy invocation
    $insidePromptPath = Join-Path $linkedWorktree 'inside-contract.md'
    Set-Content -LiteralPath $insidePromptPath -Value 'contract inside worktree' -Encoding utf8NoBOM
    try {
        Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
        $res13 = Invoke-Runner -Prompt $insidePromptPath
        if ($res13.ExitCode -ne 1) {
            throw "Test 13 expected exit code 1 for contract inside worktree (got $($res13.ExitCode)). Output: $($res13.RawOutput)"
        }
        if ($res13.Json.status -cne 'error' -or $res13.Json.error -notlike '*outside*') {
            throw "Test 13 expected contract outside worktree error: $($res13.RawOutput)"
        }
        if (Test-Path -LiteralPath $argumentsFile) {
            throw 'Test 13 agy was invoked despite contract-inside rejection!'
        }
    }
    finally {
        Remove-Item -LiteralPath $insidePromptPath -Force -ErrorAction SilentlyContinue
    }

    # Test 14: Strict UTF-8 and empty prompt rejection
    $invalidUtf8Path = Join-Path $contractsDir 'invalid-utf8.bin'
    [System.IO.File]::WriteAllBytes($invalidUtf8Path, [byte[]]@(0xC0, 0xAF))
    Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
    $res14a = Invoke-Runner -Prompt $invalidUtf8Path
    if ($res14a.ExitCode -ne 1) {
        throw "Test 14a expected exit code 1 for invalid UTF-8 (got $($res14a.ExitCode)). Output: $($res14a.RawOutput)"
    }
    if ($res14a.Json.status -cne 'error' -or $res14a.Json.error -notlike '*valid UTF-8*') {
        throw "Test 14a expected valid UTF-8 error: $($res14a.RawOutput)"
    }
    if (Test-Path -LiteralPath $argumentsFile) {
        throw 'Test 14a agy was invoked despite invalid UTF-8 rejection!'
    }

    $emptyPromptPath = Join-Path $contractsDir 'empty-prompt.txt'
    [System.IO.File]::WriteAllBytes($emptyPromptPath, [byte[]]@())
    Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
    $res14b = Invoke-Runner -Prompt $emptyPromptPath
    if ($res14b.ExitCode -ne 1) {
        throw "Test 14b expected exit code 1 for empty prompt (got $($res14b.ExitCode)). Output: $($res14b.RawOutput)"
    }
    if ($res14b.Json.status -cne 'error' -or $res14b.Json.error -notlike '*empty*') {
        throw "Test 14b expected empty prompt error: $($res14b.RawOutput)"
    }
    if (Test-Path -LiteralPath $argumentsFile) {
        throw 'Test 14b agy was invoked despite empty prompt rejection!'
    }

    # Test 15: Require AutoApprove switch for headless execution
    Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
    $res15 = Invoke-Runner -NoAutoApprove
    if ($res15.ExitCode -ne 1) {
        throw "Test 15 expected exit code 1 when AutoApprove is omitted (got $($res15.ExitCode)). Output: $($res15.RawOutput)"
    }
    if ($res15.Json.status -cne 'error' -or $res15.Json.error -notlike '*AutoApprove*') {
        throw "Test 15 expected AutoApprove error: $($res15.RawOutput)"
    }
    if (Test-Path -LiteralPath $argumentsFile) {
        throw 'Test 15 agy was invoked despite missing AutoApprove!'
    }

    # Test 16: Scoped child Git config preservation & global config leak avoidance
    $globalSafeBefore = @(& git config --global --get-all safe.directory 2>$null)
    $env:GIT_CONFIG_COUNT = '1'
    $env:GIT_CONFIG_KEY_0 = 'test.preserved'
    $env:GIT_CONFIG_VALUE_0 = 'preserved-val'
    $env:AGY_ENV_FILE = Join-Path $testRoot 'child-environment.txt'

    Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
    $res16 = Invoke-Runner
    if ($res16.ExitCode -ne 0) {
        throw "Test 16 failed with exit code $($res16.ExitCode): $($res16.RawOutput)"
    }

    if ($env:GIT_CONFIG_COUNT -ne '1' -or
        $env:GIT_CONFIG_KEY_0 -ne 'test.preserved' -or
        $env:GIT_CONFIG_VALUE_0 -ne 'preserved-val') {
        throw "Test 16 pre-existing GIT_CONFIG entries were corrupted! GIT_CONFIG_COUNT=$($env:GIT_CONFIG_COUNT)"
    }
    if (Test-Path -LiteralPath 'Env:GIT_CONFIG_KEY_1') {
        throw 'Test 16 GIT_CONFIG_KEY_1 leaked into caller environment!'
    }
    $childValues = @(Get-Content -LiteralPath $env:AGY_ENV_FILE)
    Assert-SequenceEqual -Expected @('2', 'test.preserved', 'preserved-val', 'safe.directory') -Actual $childValues

    $globalSafeAfter = @(& git config --global --get-all safe.directory 2>$null)
    if (($globalSafeBefore -join "`0") -cne ($globalSafeAfter -join "`0")) {
        throw 'Test 16 global safe.directory was modified!'
    }

    # Test 17: Unsupported models fail parameter validation before agy starts.
    foreach ($invalidModel in @('gemini-3.7-flash-high', 'gemini-3.8-flash-low', 'gemini-3.8-flash-medum')) {
        Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
        $res17 = Invoke-Runner -ModelSlug $invalidModel
        if ($res17.ExitCode -eq 0 -or $res17.RawOutput -notmatch 'ValidateSet|validation|validate') {
            throw "Test 17 expected model validation failure for ${invalidModel}: $($res17.RawOutput)"
        }
        if (Test-Path -LiteralPath $argumentsFile) {
            throw "Test 17 agy was invoked despite unsupported model: $invalidModel"
        }
    }

    # Test 18: Script-level executable override parameter
    Remove-Item -LiteralPath $argumentsFile -ErrorAction SilentlyContinue
    $res18 = Invoke-Runner -ExePath $fakeAgyExe
    if ($res18.ExitCode -ne 0) {
        throw "Test 18 failed with explicit AgyExecutablePath: $($res18.RawOutput)"
    }
    if (-not (Test-Path -LiteralPath $argumentsFile)) {
        throw 'Test 18 agy was not invoked when passing explicit AgyExecutablePath.'
    }

    foreach ($mode in @('missing-status', 'numeric-response')) {
        $env:AGY_TEST_MODE = $mode
        $res = Invoke-Runner
        if ($res.ExitCode -ne 1 -or $res.Json.status -ne 'error') { throw "Invalid envelope accepted: $mode" }
        if (-not (Test-Path $res.Json.artifacts.stdout)) { throw "Raw evidence lost: $mode" }
    }
    $env:AGY_TEST_MODE = 'large-stderr'
    $res = Invoke-Runner
    if ($res.ExitCode -ne 0 -or (Get-Item $res.Json.artifacts.stderr).Length -lt 131072) { throw 'Concurrent stream capture failed.' }
    $env:AGY_TEST_MODE = 'success'
    $runA = Invoke-Runner
    $runB = Invoke-Runner
    if ($runA.Json.artifacts.stdout -eq $runB.Json.artifacts.stdout -or -not (Test-Path $runA.Json.artifacts.stdout)) {
        throw 'Repeated OutputDirectory overwrote previous artifacts.'
    }
    $utf16Path = Join-Path $contractsDir 'utf16.txt'
    [IO.File]::WriteAllText($utf16Path, 'must reject UTF-16', [Text.Encoding]::Unicode)
    $res = Invoke-Runner -Prompt $utf16Path
    if ($res.ExitCode -ne 1 -or $res.Json.error -notlike '*UTF-8*') { throw 'UTF-16 was accepted as UTF-8.' }
    $res = Invoke-Runner -OutDir (Join-Path $linkedWorktree 'logs')
    if ($res.ExitCode -ne 1 -or $res.Json.error -notlike '*outside*') { throw 'Artifacts allowed inside worktree.' }
    $env:AGY_TEST_MODE = 'artifact-failure'
    $env:AGY_ARTIFACT_ROOT = $customArtifactsDir
    $res = Invoke-Runner
    if ($res.ExitCode -ne 1 -or $res.Json.status -ne 'error' -or $res.Json.error -notlike '*Artifact write failed*') {
        throw 'Artifact write failure reported success.'
    }

    Write-Host 'PASS: deterministic execution, argument pinning, stream separation, timeout, worktree preflight, and isolation.'
}
finally {
    $env:PATH = $previousPath
    $env:AGY_ARGUMENTS_FILE = $previousArgumentsFile
    $env:AGY_TEST_MODE = $previousTestMode
    $env:AGY_SLEEP_MS = $previousSleepMs
    $env:GIT_TEST_ASSUME_DIFFERENT_OWNER = $previousAssumeDifferentOwner
    foreach ($key in $previousTestEnvironment.Keys) { [Environment]::SetEnvironmentVariable($key, $previousTestEnvironment[$key]) }

    if (Test-Path -LiteralPath $testRoot) {
        $resolvedCleanup = [System.IO.Path]::GetFullPath($testRoot)
        if ($resolvedCleanup.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedCleanup -Recurse -Force
        }
    }
}
