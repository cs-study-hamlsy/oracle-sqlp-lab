param(
    [ValidateSet("auto", "cl", "gcc")]
    [string]$Compiler = "auto",
    [string[]]$CompilerArgs = @(),
    [string[]]$ProgramArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$proCRunnerPath = Join-Path $repoRoot "common\scripts\Invoke-ProCRun.ps1"

& $proCRunnerPath `
    -SourcePath (Join-Path $PSScriptRoot "pro-c\hint_plan_test.pc") `
    -BuildDirectory (Join-Path $PSScriptRoot "build") `
    -Compiler $Compiler `
    -CompilerArgs $CompilerArgs `
    -ProgramArgs $ProgramArgs
