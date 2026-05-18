param(
    [string]$EnvFilePath = (Join-Path $PSScriptRoot "..\oracle.env")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $EnvFilePath)) {
    throw "Oracle env file not found: $EnvFilePath"
}

$resolvedEnvFilePath = (Resolve-Path -LiteralPath $EnvFilePath).Path

Get-Content -LiteralPath $resolvedEnvFilePath | ForEach-Object {
    $line = $_.Trim()

    if ($line.Length -eq 0 -or $line.StartsWith("#")) {
        return
    }

    $separatorIndex = $line.IndexOf("=")

    if ($separatorIndex -lt 1) {
        throw "Invalid env line in ${resolvedEnvFilePath}: $line"
    }

    $name = $line.Substring(0, $separatorIndex).Trim()
    $value = $line.Substring($separatorIndex + 1).Trim()

    [Environment]::SetEnvironmentVariable($name, $value, "Process")
}

[pscustomobject]@{
    EnvFilePath = $resolvedEnvFilePath
    ORACLE_USER = $env:ORACLE_USER
    ORACLE_PASSWORD = $env:ORACLE_PASSWORD
    ORACLE_CONNECT_STRING = $env:ORACLE_CONNECT_STRING
}
