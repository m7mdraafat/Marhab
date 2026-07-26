<#
.SYNOPSIS
    Run the mygame Spring Boot server quickly.

.DESCRIPTION
    Resolves a Java 21 JDK, then launches the server via Gradle `bootRun`.
    Skips tests for fast startup. Pass -Build to compile a jar instead of running.

.EXAMPLE
    ./run.ps1
    Starts the server with bootRun.

.EXAMPLE
    ./run.ps1 -Clean
    Cleans before starting.
#>
[CmdletBinding()]
param(
    [switch]$Clean,
    [switch]$Build,
    [string]$JavaHome
)

$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot
Set-Location $scriptRoot

# Resolve a Java 21 JDK: explicit param > JAVA_HOME > common Adoptium install.
if (-not $JavaHome) {
    if ($env:JAVA_HOME -and (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
        $JavaHome = $env:JAVA_HOME
    }
    else {
        $candidate = Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like 'jdk-21*' } |
            Sort-Object Name -Descending |
            Select-Object -First 1
        if ($candidate) { $JavaHome = $candidate.FullName }
    }
}

if (-not $JavaHome -or -not (Test-Path (Join-Path $JavaHome 'bin\java.exe'))) {
    throw "Could not find a Java 21 JDK. Set JAVA_HOME or pass -JavaHome 'C:\path\to\jdk-21'."
}

$env:JAVA_HOME = $JavaHome
$env:PATH = (Join-Path $JavaHome 'bin') + [IO.Path]::PathSeparator + $env:PATH
Write-Host "Using JAVA_HOME=$JavaHome" -ForegroundColor Cyan

$gradle = Join-Path $scriptRoot 'gradlew.bat'

$tasks = @()
if ($Clean) { $tasks += 'clean' }
if ($Build) { $tasks += @('build', '-x', 'test') }
else        { $tasks += 'bootRun' }

Write-Host "Running: gradlew $($tasks -join ' ')" -ForegroundColor Cyan
& $gradle --no-daemon --console=plain @tasks
exit $LASTEXITCODE
