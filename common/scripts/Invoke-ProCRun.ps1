param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,
    [string]$EnvFilePath = (Join-Path $PSScriptRoot "..\oracle.env"),
    [string]$BuildDirectory = "build",
    [string]$ExecutableName,
    [ValidateSet("auto", "cl", "gcc")]
    [string]$Compiler = "auto",
    [string[]]$ProcArgs = @(),
    [string[]]$CompilerArgs = @(),
    [string[]]$ProgramArgs = @(),
    [switch]$SkipRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ToolCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        $command = Get-Command -Name $candidate -ErrorAction SilentlyContinue
        if ($null -ne $command) {
            return $command.Source
        }
    }

    return $null
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandPath,
        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
    )

    & $CommandPath @ArgumentList

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $CommandPath"
    }
}

$loadResult = & (Join-Path $PSScriptRoot "Import-OracleEnv.ps1") -EnvFilePath $EnvFilePath
$resolvedSourcePath = (Resolve-Path -LiteralPath $SourcePath).Path
$sourceDirectory = Split-Path -Parent $resolvedSourcePath
$sourceBaseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedSourcePath)
$generatedCPath = Join-Path $sourceDirectory ($sourceBaseName + ".c")

if ([string]::IsNullOrWhiteSpace($ExecutableName)) {
    $ExecutableName = $sourceBaseName + ".exe"
}

if (-not [System.IO.Path]::IsPathRooted($BuildDirectory)) {
    $BuildDirectory = Join-Path (Get-Location) $BuildDirectory
}

$resolvedBuildDirectory = [System.IO.Path]::GetFullPath($BuildDirectory)
$null = New-Item -ItemType Directory -Path $resolvedBuildDirectory -Force
$resolvedExecutablePath = Join-Path $resolvedBuildDirectory $ExecutableName

$procCommand = Resolve-ToolCommand -Candidates @("proc.exe", "proc")
if ($null -eq $procCommand) {
    throw "Oracle Pro*C command 'proc' was not found in PATH."
}

Write-Host "Loaded Oracle env from $($loadResult.EnvFilePath)"
Write-Host "Using ORACLE_CONNECT_STRING=$($loadResult.ORACLE_CONNECT_STRING)"
Write-Host "Precompiling $resolvedSourcePath"

$procArgumentList = @(
    "iname=$resolvedSourcePath",
    "oname=$generatedCPath"
) + $ProcArgs

Invoke-CheckedCommand -CommandPath $procCommand -ArgumentList $procArgumentList

$selectedCompiler = $Compiler
if ($selectedCompiler -eq "auto") {
    if ($null -ne (Get-Command -Name "cl.exe" -ErrorAction SilentlyContinue) -or
        $null -ne (Get-Command -Name "cl" -ErrorAction SilentlyContinue)) {
        $selectedCompiler = "cl"
    } elseif ($null -ne (Get-Command -Name "gcc.exe" -ErrorAction SilentlyContinue) -or
        $null -ne (Get-Command -Name "gcc" -ErrorAction SilentlyContinue)) {
        $selectedCompiler = "gcc"
    } else {
        throw "No supported C compiler found. Install cl or gcc, or pass -Compiler explicitly."
    }
}

Write-Host "Compiling with $selectedCompiler"

switch ($selectedCompiler) {
    "cl" {
        $compilerCommand = Resolve-ToolCommand -Candidates @("cl.exe", "cl")
        $compilerArgumentList = @(
            "/nologo",
            "/Fe:$resolvedExecutablePath",
            $generatedCPath
        ) + $CompilerArgs
    }
    "gcc" {
        $compilerCommand = Resolve-ToolCommand -Candidates @("gcc.exe", "gcc")
        $compilerArgumentList = @(
            $generatedCPath,
            "-o",
            $resolvedExecutablePath
        ) + $CompilerArgs
    }
    default {
        throw "Unsupported compiler selection: $selectedCompiler"
    }
}

Invoke-CheckedCommand -CommandPath $compilerCommand -ArgumentList $compilerArgumentList

Write-Host "Built executable: $resolvedExecutablePath"

if (-not $SkipRun) {
    Write-Host "Running executable"
    & $resolvedExecutablePath @ProgramArgs

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
