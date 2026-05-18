param(
    [string]$EnvFilePath = (Join-Path $PSScriptRoot "..\oracle.env"),
    [Parameter(Mandatory = $true)]
    [string]$ExecutablePath,
    [string[]]$ArgumentList = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$loadResult = & (Join-Path $PSScriptRoot "Import-OracleEnv.ps1") -EnvFilePath $EnvFilePath
Write-Host "Loaded Oracle env from $($loadResult.EnvFilePath)"
Write-Host "Using ORACLE_CONNECT_STRING=$($loadResult.ORACLE_CONNECT_STRING)"

$resolvedExecutablePath = $ExecutablePath

if (
    -not [System.IO.Path]::IsPathRooted($resolvedExecutablePath) -and
    ($resolvedExecutablePath.Contains("\") -or $resolvedExecutablePath.Contains("/"))
) {
    $resolvedExecutablePath = Join-Path (Get-Location) $ExecutablePath
}

& $resolvedExecutablePath @ArgumentList
$exitCode = $LASTEXITCODE

if ($null -ne $exitCode) {
    exit $exitCode
}
