param(
    [ValidateSet("auto", "cl", "gcc")]
    [string]$Compiler = "auto",
    [string[]]$CompilerArgs = @(),
    [string[]]$ProgramArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$runScriptPath = Join-Path $PSScriptRoot "run.ps1"
& $runScriptPath -Compiler $Compiler -CompilerArgs $CompilerArgs -ProgramArgs $ProgramArgs
exit $LASTEXITCODE
