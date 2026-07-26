[CmdletBinding()]
param(
    [string]$SdkHome,
    [string]$Output = "dist/launcher/bin/MyGame.swf",
    [string]$MainClass = "boot_338d"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$sourceRoot = Join-Path $root "launcher/src"
$mainFile = Join-Path $sourceRoot "$MainClass.as"
$outputPath = Join-Path $root $Output
$outputDir = Split-Path $outputPath -Parent
$appDir = Split-Path $outputDir -Parent
$descriptorSource = Join-Path $PSScriptRoot "application.xml"
$descriptorTarget = Join-Path $appDir "application.xml"
$runtimeSource = Join-Path $root "runtime"
$runtimeTarget = Join-Path $appDir "runtime"

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

if (-not (Test-Path -LiteralPath $mainFile)) {
    throw "Main class file not found: $mainFile"
}

$sdkRoot = Resolve-SdkRoot -ExplicitSdkHome $SdkHome
if (-not $sdkRoot) {
    throw "No AIR/Flex SDK found. Pass -SdkHome, set AIR_SDK_HOME/FLEX_HOME, or add amxmlc/mxmlc to PATH. Current AIR_SDK_HOME='$env:AIR_SDK_HOME'."
}

$compiler = Resolve-Tool -Names @("amxmlc", "mxmlc") -SdkRoot $sdkRoot
if (-not $compiler) {
    throw "No ActionScript compiler found under '$sdkRoot'. Expected bin/amxmlc or bin/mxmlc."
}

$env:FLEX_HOME = $sdkRoot
$env:AIR_HOME = $sdkRoot
$env:AIR_SDK_HOME = $sdkRoot

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
New-Item -ItemType Directory -Force -Path $runtimeTarget | Out-Null
Copy-Item -LiteralPath $descriptorSource -Destination $descriptorTarget -Force
Copy-Item -Path (Join-Path $runtimeSource "*") -Destination $runtimeTarget -Recurse -Force

$forceInclude = @("swf.SWFLibrary")
$forceInclude += Get-ChildItem -LiteralPath $sourceRoot -File -Filter "__ASSET__*.as" |
    ForEach-Object { $_.BaseName }

$args = @(
    "-source-path+=$sourceRoot",
    "-debug=true",
    "-warnings=true",
    "-strict=false",
    "-static-link-runtime-shared-libraries=true",
    "-output=$outputPath"
)

foreach ($className in $forceInclude) {
    $args += "-includes+=$className"
}

$args += $mainFile

Write-Host "SDK:      $sdkRoot"
Write-Host "Compiler: $compiler"
Write-Host "Main:     $mainFile"
Write-Host "Output:   $outputPath"
Write-Host "Includes: $($forceInclude.Count) force-linked classes"

$previousLocation = Get-Location
Set-Location $sourceRoot
try {
    & $compiler @args
}
finally {
    Set-Location $previousLocation
}

if ($LASTEXITCODE -ne 0) {
    throw "Compiler failed with exit code $LASTEXITCODE."
}

Write-Host "Compiled launcher: $outputPath"
Write-Host "AIR descriptor:     $descriptorTarget"