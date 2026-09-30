#requires -Version 7.0
<#
.SYNOPSIS
Runs a single Gemini 3.8 Flash task in a clean linked Git worktree on Windows.
.DESCRIPTION
Uses authenticated agy.exe, literal process arguments and separate output streams.
Returns compact JSON; full artifacts are saved in a unique directory per invocation.
.PARAMETER OutputDirectory
Parent directory for per-run artifacts. Defaults to the system temporary directory.
.PARAMETER AgyExecutablePath
Optional explicit agy.exe location. Defaults to the application on PATH.
.PARAMETER Model
Gemini 3.8 Flash medium (default) or high. The requested model is passed without fallback.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$WorkingDirectory,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$PromptFile,
    [switch]$AutoApprove,
    [ValidateRange(1, 3600)][int]$TimeoutSeconds = 600,
    [ValidateRange(256, 100000)][int]$MaxResultChars = 6000,
    [string]$OutputDirectory,
    [ValidateSet('gemini-3.8-flash-medium', 'gemini-3.8-flash-high')][string]$Model = 'gemini-3.8-flash-medium',
    [string]$AgyExecutablePath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = [Text.UTF8Encoding]::new($false, $true)
$childEnvironment = @{}

function Get-FullPath([string]$Path) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}
function Test-Within([string]$Path, [string]$Root) {
    $rootPath = $Root.TrimEnd('\', '/')
    $Path.Equals($rootPath, [StringComparison]::OrdinalIgnoreCase) -or
        $Path.StartsWith($rootPath + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)
}
function Limit-Text([string]$Value, [int]$Length) {
    if ($Value.Length -le $Length) { return $Value }
    # Avoid splitting a UTF-16 surrogate pair at the result boundary.
    if ([char]::IsHighSurrogate($Value[$Length - 1])) { $Length-- }
    $Value.Substring(0, $Length)
}
function Invoke-Native([string]$Executable, [string[]]$Arguments, [string]$Directory, [int]$WaitSeconds) {
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $Executable
    $startInfo.WorkingDirectory = $Directory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.StandardOutputEncoding = [Text.UTF8Encoding]::new($false)
    $startInfo.StandardErrorEncoding = [Text.UTF8Encoding]::new($false)
    foreach ($argument in $Arguments) { $startInfo.ArgumentList.Add($argument) }
    foreach ($key in $childEnvironment.Keys) { $startInfo.Environment[$key] = $childEnvironment[$key] }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    try {
        $null = $process.Start()
        $process.StandardInput.Close()
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $timedOut = -not $process.WaitForExit($WaitSeconds * 1000)
        if ($timedOut) {
            $process.Kill($true)
            if (-not $process.WaitForExit(5000)) { throw 'Timed-out process could not be stopped.' }
        }
        $drained = [Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($stdoutTask, $stderrTask), 5000)
        [pscustomobject]@{
            ExitCode = $process.ExitCode
            TimedOut = $timedOut
            Drained = $drained
            Stdout = if ($stdoutTask.IsCompletedSuccessfully) { $stdoutTask.Result } else { '' }
            Stderr = if ($stderrTask.IsCompletedSuccessfully) { $stderrTask.Result } else { '' }
        }
    }
    finally { $process.Dispose() }
}
function Invoke-Git([string[]]$Arguments) {
    $gitResult = Invoke-Native $gitExecutable (@('-C', $worktreePath) + $Arguments) $worktreePath 30
    if ($gitResult.TimedOut -or -not $gitResult.Drained -or $gitResult.ExitCode -ne 0) {
        throw "Git preflight failed: $(Limit-Text $gitResult.Stderr.Trim() 1000)"
    }
    $gitResult.Stdout.Trim()
}

$exitCode = 1
$rawStdout = ''
$rawStderr = ''
$fullResult = ''
$runDirectory = $null
$envelope = [ordered]@{ status = 'error'; model = $Model; result = ''; truncated = $false; error = $null; artifacts = $null }
try {
    if (-not $IsWindows) { throw 'This runner requires Windows and PowerShell 7.' }
    $outputParent = if ($OutputDirectory) { Get-FullPath $OutputDirectory } else { [IO.Path]::GetTempPath() }
    $worktreePath = (Resolve-Path -LiteralPath $WorkingDirectory).Path.TrimEnd('\', '/')
    if (-not (Test-Path -LiteralPath $worktreePath -PathType Container)) { throw 'WorkingDirectory must be a directory.' }
    if (Test-Within $outputParent $worktreePath) { throw 'OutputDirectory must be outside the worktree.' }
    $runDirectory = Join-Path $outputParent "antigravity-run-$([guid]::NewGuid().ToString('N'))"
    $null = [IO.Directory]::CreateDirectory($runDirectory)
    $envelope.artifacts = [ordered]@{
        stdout = Join-Path $runDirectory 'stdout.json'
        stderr = Join-Path $runDirectory 'stderr.log'
        result = Join-Path $runDirectory 'result.txt'
    }
    if (-not $AutoApprove) { throw 'AutoApprove is required for headless tool execution.' }
    $promptPath = (Resolve-Path -LiteralPath $PromptFile).Path
    if (-not (Test-Path -LiteralPath $promptPath -PathType Leaf)) { throw 'PromptFile must be a file.' }
    if (Test-Within $promptPath $worktreePath) { throw 'Prompt file contract must be outside the worktree.' }
    try {
        # Decode bytes explicitly; ReadAllText would auto-detect and accept UTF-16 BOMs.
        $prompt = $utf8.GetString([IO.File]::ReadAllBytes($promptPath)).TrimStart([char]0xFEFF)
    }
    catch { throw 'Prompt file must be valid UTF-8.' }
    if ([string]::IsNullOrWhiteSpace($prompt)) { throw 'Prompt file is empty.' }

    # Add Git trust only to each child process, retaining caller-provided config entries.
    $configCount = 0
    if ($env:GIT_CONFIG_COUNT -and (-not [int]::TryParse($env:GIT_CONFIG_COUNT, [ref]$configCount) -or $configCount -lt 0)) {
        throw 'GIT_CONFIG_COUNT must be a non-negative integer.'
    }
    $childEnvironment['GIT_CONFIG_COUNT'] = [string]($configCount + 1)
    $childEnvironment["GIT_CONFIG_KEY_$configCount"] = 'safe.directory'
    $childEnvironment["GIT_CONFIG_VALUE_$configCount"] = $worktreePath.Replace('\', '/')
    $gitExecutable = (Get-Command git.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $topLevel = Invoke-Git @('rev-parse', '--show-toplevel')
    if (-not $worktreePath.Equals([IO.Path]::GetFullPath($topLevel).TrimEnd('\', '/'), [StringComparison]::OrdinalIgnoreCase)) {
        throw 'WorkingDirectory must be the Git worktree root.'
    }
    $gitDirectory = Invoke-Git @('rev-parse', '--path-format=absolute', '--git-dir')
    $commonDirectory = Invoke-Git @('rev-parse', '--path-format=absolute', '--git-common-dir')
    if ($gitDirectory.Equals($commonDirectory, [StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath (Join-Path $worktreePath '.git') -PathType Leaf)) {
        throw 'WorkingDirectory is a primary Git checkout or is not a linked worktree.'
    }
    if (Invoke-Git @('status', '--porcelain', '--untracked-files=all')) { throw 'Working directory is dirty; use a clean dedicated worktree.' }

    $agyExecutable = if ($AgyExecutablePath) {
        (Resolve-Path -LiteralPath $AgyExecutablePath).Path
    } else {
        (Get-Command agy.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    }
    if (-not $agyExecutable.EndsWith('.exe', [StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $agyExecutable -PathType Leaf)) { throw 'Antigravity requires an application .exe.' }
    $agyArguments = @('--dangerously-skip-permissions', '--add-dir', $worktreePath,
        '--print-timeout', "${TimeoutSeconds}s", '--model', $Model, '--output-format', 'json', '-p', $prompt)
    $graceSeconds = [Math]::Min(15, [Math]::Max(2, [int]($TimeoutSeconds * 0.05)))
    $execution = Invoke-Native $agyExecutable $agyArguments $worktreePath ($TimeoutSeconds + $graceSeconds)
    $rawStdout = $execution.Stdout
    $rawStderr = $execution.Stderr
    if ($execution.TimedOut) {
        $exitCode = 124
        $envelope.status = 'timeout'
        throw "Execution timed out after $TimeoutSeconds seconds plus shutdown grace."
    }
    if ($execution.ExitCode -ne 0) {
        $exitCode = $execution.ExitCode
        throw "Antigravity exited with code $exitCode. Inspect the stdout and stderr artifacts."
    }
    if (-not $execution.Drained) { throw 'Antigravity output streams did not close; capture is incomplete.' }
    try { $payload = ConvertFrom-Json -InputObject $rawStdout -AsHashtable -ErrorAction Stop }
    catch { throw 'Antigravity emitted malformed JSON or empty output.' }
    if ($payload -isnot [Collections.IDictionary] -or -not $payload.Contains('status')) { throw 'Antigravity emitted a malformed JSON envelope.' }
    if ($payload['conversation_id'] -is [string]) { $envelope['conversation_id'] = $payload['conversation_id'] }
    if ($payload['status'] -cne 'SUCCESS') {
        $detail = if ($payload['error'] -is [string]) { $payload['error'] } else { [string]$payload['status'] }
        throw "Antigravity reported failure: $detail"
    }
    if ($payload['response'] -isnot [string] -or [string]::IsNullOrWhiteSpace($payload['response'])) {
        throw 'Antigravity produced a non-string, empty or blank response.'
    }
    $fullResult = $payload['response']
    $permissionPattern = '(?i)\ba tool required the ["'']command["''] permission\b'
    if ($fullResult -match '(?im)^\s*jetski:\s*no output produced\b' -or
        $fullResult -match "(?i)^\s*$permissionPattern" -or
        $rawStderr -match $permissionPattern -or $rawStderr -match '(?im)^\s*jetski:\s*no output produced\b') {
        throw 'Headless false-success detected; inspect permission diagnostics.'
    }
    $envelope.status = 'success'
    $envelope.result = Limit-Text $fullResult $MaxResultChars
    $envelope.truncated = $fullResult.Length -gt $envelope.result.Length
    $exitCode = 0
}
catch { $envelope.error = Limit-Text $_.Exception.Message 2000 }

# Artifact persistence is part of success: truncated output must remain recoverable.
if ($runDirectory -and $envelope.artifacts) {
    try {
        [IO.File]::WriteAllText($envelope.artifacts.stdout, $rawStdout, $utf8)
        [IO.File]::WriteAllText($envelope.artifacts.stderr, $rawStderr, $utf8)
        [IO.File]::WriteAllText($envelope.artifacts.result, $fullResult, $utf8)
    }
    catch {
        if ($exitCode -eq 0) { $exitCode = 1 }
        if ($envelope.status -eq 'success') { $envelope.status = 'error' }
        $envelope.error = Limit-Text ("$($envelope.error) Artifact write failed: $($_.Exception.Message)").Trim() 2000
    }
}
$envelope | ConvertTo-Json -Depth 5 -Compress
exit $exitCode
