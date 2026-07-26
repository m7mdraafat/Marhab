[CmdletBinding()]
param(
    [string]$SdkHome
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$appDir = Join-Path $root "dist/launcher"
$descriptor = Join-Path $appDir "application.xml"

function Resolve-SdkRoot {
    param([string]$ExplicitSdkHome)

    $candidates = @(
        $ExplicitSdkHome,
        $env:AIR_SDK_HOME,
        $env:AIRSDK_HOME,
        $env:FLEX_HOME,
        $env:AIR_HOME
    ) | Where-Object { $_ }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }

    return $null
}

function Resolve-Tool {
    param(
        [string[]]$Names,
        [string]$SdkRoot
    )

    foreach ($name in $Names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) {
            return $command.Source
        }
    }

    if ($SdkRoot) {
        foreach ($name in $Names) {
            foreach ($extension in ".bat", ".cmd", ".exe", "") {
                $candidate = Join-Path $SdkRoot "bin/$name$extension"
                if (Test-Path -LiteralPath $candidate) {
                    return $candidate
                }
            }
        }
    }

    return $null
}

if (-not (Test-Path -LiteralPath $descriptor)) {
    throw "Launcher is not compiled yet. Run build/compile-launcher.ps1 first."
}

$sdkRoot = Resolve-SdkRoot -ExplicitSdkHome $SdkHome
if (-not $sdkRoot) {
    throw "No AIR SDK found. Pass -SdkHome, set AIR_SDK_HOME, or add adl to PATH."
}

$adl = Resolve-Tool -Names @("adl") -SdkRoot $sdkRoot
if (-not $adl) {
    throw "No AIR Debug Launcher found under '$sdkRoot'. Expected bin/adl."
}

$env:FLEX_HOME = $sdkRoot
$env:AIR_HOME = $sdkRoot
$env:AIR_SDK_HOME = $sdkRoot

Write-Host "ADL:        $adl"
Write-Host "Descriptor: $descriptor"

$previousLocation = Get-Location
Set-Location $appDir
try {
    & $adl $descriptor $appDir
}
finally {
    Set-Location $previousLocation
}