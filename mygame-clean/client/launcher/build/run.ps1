[CmdletBinding()]
param(
    [string]$SdkHome
)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../../..")
$appDir = Join-Path $repoRoot "client/launcher/dist"
$descriptor = Join-Path $appDir "application.xml"
$runtimeSource = Join-Path $repoRoot "client/runtime"
$runtimeTarget = Join-Path $appDir "runtime"

function Resolve-SdkRoot {
    param([string]$ExplicitSdkHome)
    $candidates = @($ExplicitSdkHome, $env:AIR_SDK_HOME, $env:AIRSDK_HOME, $env:FLEX_HOME, $env:AIR_HOME) | Where-Object { $_ }
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) { return (Resolve-Path $candidate).Path }
    }
    return $null
}

function Resolve-Tool {
    param([string[]]$Names, [string]$SdkRoot)
    foreach ($name in $Names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    if ($SdkRoot) {
        foreach ($name in $Names) {
            foreach ($extension in ".bat", ".cmd", ".exe", "") {
                $candidate = Join-Path $SdkRoot "bin/$name$extension"
                if (Test-Path -LiteralPath $candidate) { return $candidate }
            }
        }
    }
    return $null
}

if (-not (Test-Path -LiteralPath $descriptor)) { throw "Launcher is not compiled yet. Run client/launcher/build/compile.ps1 first." }
if (-not (Test-Path -LiteralPath $runtimeSource)) { throw "Runtime folder not found: $runtimeSource" }

$sdkRoot = Resolve-SdkRoot -ExplicitSdkHome $SdkHome
if (-not $sdkRoot) { throw "No AIR SDK found. Pass -SdkHome or set AIR_SDK_HOME." }

$adl = Resolve-Tool -Names @("adl") -SdkRoot $sdkRoot
if (-not $adl) { throw "No AIR Debug Launcher found under '$sdkRoot'." }

$env:FLEX_HOME = $sdkRoot
$env:AIR_HOME = $sdkRoot
$env:AIR_SDK_HOME = $sdkRoot

New-Item -ItemType Directory -Force -Path $runtimeTarget | Out-Null
Copy-Item -Path (Join-Path $runtimeSource "*") -Destination $runtimeTarget -Recurse -Force

Write-Host "ADL:        $adl"
Write-Host "Descriptor: $descriptor"
Write-Host "Runtime:    $runtimeTarget"

$previousLocation = Get-Location
Set-Location $appDir
try { & $adl $descriptor $appDir }
finally { Set-Location $previousLocation }