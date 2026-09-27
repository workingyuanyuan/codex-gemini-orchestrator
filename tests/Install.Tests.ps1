#requires -Version 7.0
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $repositoryRoot 'install.ps1'
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$testRoot = [IO.Path]::GetFullPath((Join-Path $tempBase "codex-install-test-$([guid]::NewGuid())"))
if (-not $testRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe test path.' }
$null = New-Item -ItemType Directory -Path $testRoot
$destination = Join-Path $testRoot '.codex'
$previousCodexHome = $env:CODEX_HOME
try {
    & $installer -DestinationRoot $destination
    $snapshot = Join-Path $repositoryRoot 'versions/6-sol-gemini3.8flash'
    $sourceFiles = @(Get-ChildItem (Join-Path $snapshot 'scripts'), (Join-Path $snapshot 'skills') -Recurse -File)
    foreach ($file in $sourceFiles) {
        $relative = [IO.Path]::GetRelativePath($snapshot, $file.FullName)
        $installed = Join-Path $destination $relative
        if (-not (Test-Path -LiteralPath $installed -PathType Leaf)) { throw "Missing installed file: $relative" }
        if ((Get-FileHash $installed).Hash -cne (Get-FileHash $file.FullName).Hash) { throw "File differs: $relative" }
    }
    if (Test-Path (Join-Path $destination 'agents')) { throw 'Unexpected native profiles.' }
    $rules = Join-Path $destination 'AGENTS.md'
    if (Test-Path $rules) { throw 'Trigger must be opt-in.' }
    $custom = "# Personal rules`r`nKeep this exact text. 繁體中文`r`n"
    [IO.File]::WriteAllText($rules, $custom)
    $unrelated = Join-Path $destination 'unrelated.txt'
    Set-Content $unrelated 'keep'
    $beforeHashes = @{}
    Get-ChildItem $destination -Recurse -File | ForEach-Object { $beforeHashes[$_.FullName] = (Get-FileHash $_.FullName).Hash }
    $rejected = $false
    try { & $installer -DestinationRoot $destination -InstallDelegationTrigger }
    catch { $rejected = $_.Exception.Message -like 'Installation would overwrite*' }
    if (-not $rejected) { throw 'Collisions were not rejected.' }
    foreach ($path in $beforeHashes.Keys) {
        if ((Get-FileHash $path).Hash -ne $beforeHashes[$path]) { throw 'Collision rejection modified a file.' }
    }
    & $installer -DestinationRoot $destination -InstallDelegationTrigger -Force
    $merged = [IO.File]::ReadAllText($rules)
    if (-not $merged.StartsWith($custom, [StringComparison]::Ordinal)) { throw 'Personal instructions changed.' }
    if (-not $merged.Contains((Get-Content (Join-Path $snapshot 'AGENTS.md') -Raw).Trim())) { throw 'Missing trigger.' }
    & $installer -DestinationRoot $destination -InstallDelegationTrigger -Force
    if ([IO.File]::ReadAllText($rules) -cne $merged) { throw 'Trigger installation is not idempotent.' }
    # Update only the owned block, preserving text before and after it byte-for-byte.
    $modified = $merged.Replace((Get-Content (Join-Path $snapshot 'AGENTS.md') -Raw).Trim(), 'obsolete trigger') + "`r`n# Tail`r`nPreserve this too."
    [IO.File]::WriteAllText($rules, $modified)
    & $installer -DestinationRoot $destination -InstallDelegationTrigger -Force
    if ([IO.File]::ReadAllText($rules) -cne ($merged + "`r`n# Tail`r`nPreserve this too.")) { throw 'Managed block update changed surrounding content.' }
    # Default installation must not modify existing instructions.
    $expectedRules = [IO.File]::ReadAllText($rules)
    & $installer -DestinationRoot $destination -Force
    if ([IO.File]::ReadAllText($rules) -cne $expectedRules) { throw 'Default installation modified instructions.' }
    if ((Get-Content $unrelated) -ne 'keep') { throw 'Unrelated file changed.' }
    # Malformed markers fail before any packaged file is replaced.
    [IO.File]::WriteAllText($rules, '<!-- codex-gemini-orchestrator:start -->')
    $installedSkill = Join-Path $destination 'skills/model-routing-and-delegation-agy/SKILL.md'
    Set-Content $installedSkill 'local sentinel'
    $rejected = $false
    try { & $installer -DestinationRoot $destination -InstallDelegationTrigger -Force }
    catch { $rejected = $_.Exception.Message -like '*invalid managed block*' }
    if (-not $rejected -or (Get-Content $installedSkill) -ne 'local sentinel') { throw 'Invalid marker preflight failed.' }
    $env:CODEX_HOME = Join-Path $testRoot 'custom-home'
    & $installer
    if (-not (Test-Path (Join-Path $env:CODEX_HOME 'skills/model-routing-and-delegation-agy/SKILL.md'))) { throw 'CODEX_HOME ignored.' }
    $legacy = Join-Path $testRoot 'legacy'
    & $installer -DestinationRoot $legacy -Version '5.6-gemini3.8flash' -InstallDelegationTrigger
    if (-not (Test-Path (Join-Path $legacy 'agents/gpt-5-6-luna-max.toml'))) { throw 'Legacy profile missing.' }
    $rejected = $false
    try { & $installer -DestinationRoot (Join-Path $testRoot 'bad') -Version '../escape' }
    catch { $rejected = $true }
    if (-not $rejected) { throw 'Version traversal accepted.' }
    Write-Host 'PASS: installation, references, opt-in trigger, merge preservation, idempotence, collision preflight, CODEX_HOME, legacy profiles and version validation.'
}
finally {
    $env:CODEX_HOME = $previousCodexHome
    $resolvedTestRoot = [IO.Path]::GetFullPath($testRoot)
    if (-not $resolvedTestRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe cleanup path.' }
    Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
}
