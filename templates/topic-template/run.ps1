param(
    [string]$ProCSourcePath,
    [string]$ExecutablePath,
    [ValidateSet("auto", "cl", "gcc")]
    [string]$Compiler = "auto",
    [string[]]$CompilerArgs = @(),
    [string[]]$ProgramArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$proCRunnerPath = Join-Path $repoRoot "common\scripts\Invoke-ProCRun.ps1"
$exeRunnerPath = Join-Path $repoRoot "common\scripts\Invoke-WithOracleEnv.ps1"

if (-not [string]::IsNullOrWhiteSpace($ProCSourcePath)) {
    $resolvedProCSourcePath = $ProCSourcePath

    if (-not [System.IO.Path]::IsPathRooted($resolvedProCSourcePath)) {
        $resolvedProCSourcePath = Join-Path $PSScriptRoot $ProCSourcePath
    }

    & $proCRunnerPath `
        -SourcePath $resolvedProCSourcePath `
        -BuildDirectory (Join-Path $PSScriptRoot "build") `
        -Compiler $Compiler `
        -CompilerArgs $CompilerArgs `
        -ProgramArgs $ProgramArgs
    exit $LASTEXITCODE
}

if (-not [string]::IsNullOrWhiteSpace($ExecutablePath)) {
    $resolvedExecutablePath = $ExecutablePath

    if (-not [System.IO.Path]::IsPathRooted($resolvedExecutablePath)) {
        $resolvedExecutablePath = Join-Path $PSScriptRoot $ExecutablePath
    }

    & $exeRunnerPath -ExecutablePath $resolvedExecutablePath -ArgumentList $ProgramArgs
    exit $LASTEXITCODE
}

Write-Host "Use this script in one of these ways:"
Write-Host '.\run.ps1 -ProCSourcePath .\pro-c\example.pc'
Write-Host '.\run.ps1 -ExecutablePath .\build\example.exe'
Write-Host "Optional compiler selection: -Compiler cl or -Compiler gcc"
Write-Host "Optional extra compiler flags: -CompilerArgs @('arg1', 'arg2')"
Write-Host "Optional runtime arguments: -ProgramArgs @('arg1', 'arg2')"
exit 0
