[CmdletBinding()]
param(
    [string]$SdkHome,
    [string]$JavaHome = "C:/Program Files/Microsoft/jdk-17.0.18.8-hotspot",
    [string]$Output = "dist/game/snl.rebuilt.swf",
    [string]$MainClass = "Sanalika"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$preprocessScript = Join-Path $PSScriptRoot "preprocess-game.ps1"
$sourceRoot = Join-Path $root "obj/game-src"
$mainFile = Join-Path $sourceRoot "$MainClass.as"
$outputPath = Join-Path $root $Output
$outputDir = Split-Path $outputPath -Parent
$assetDir = Join-Path $sourceRoot "_assets"
$assetBundle = Join-Path $assetDir "assets.swf"
$runtimeSwf = Join-Path $root "runtime/snl.780.swf"

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

if (-not (Test-Path -LiteralPath $preprocessScript)) {
    throw "Preprocess script not found: $preprocessScript"
}

if (-not (Test-Path -LiteralPath $runtimeSwf)) {
    throw "Runtime SWF not found: $runtimeSwf"
}

& $preprocessScript

if (-not (Test-Path -LiteralPath $mainFile)) {
    throw "Main class file not found after preprocessing: $mainFile"
}

$sdkRoot = Resolve-SdkRoot -ExplicitSdkHome $SdkHome
if (-not $sdkRoot) {
    throw "No AIR/Flex SDK found. Pass -SdkHome, set AIR_SDK_HOME/FLEX_HOME, or add mxmlc to PATH."
}

$compiler = Resolve-Tool -Names @("amxmlc", "mxmlc") -SdkRoot $sdkRoot
if (-not $compiler) {
    throw "No ActionScript compiler found under '$sdkRoot'. Expected bin/mxmlc or bin/amxmlc."
}

$java = $null
if ($JavaHome) {
    $javaCandidate = Join-Path $JavaHome "bin/java.exe"
    if (Test-Path -LiteralPath $javaCandidate) {
        $java = $javaCandidate
    }
}
if (-not $java) {
    $javaCommand = Get-Command java -ErrorAction SilentlyContinue
    if ($javaCommand) {
        $java = $javaCommand.Source
    }
}
if (-not $java) {
    throw "No Java runtime found. Pass -JavaHome or add java to PATH."
}

$compilerJar = Join-Path $sdkRoot "lib/mxmlc.jar"
if (-not (Test-Path -LiteralPath $compilerJar)) {
    throw "Flex compiler jar not found: $compilerJar"
}

$env:FLEX_HOME = $sdkRoot
$env:AIR_HOME = $sdkRoot
$env:AIR_SDK_HOME = $sdkRoot

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
New-Item -ItemType Directory -Force -Path $assetDir | Out-Null
Copy-Item -LiteralPath $runtimeSwf -Destination $assetBundle -Force

$args = @(
    "-source-path+=$sourceRoot",
    "-debug=true",
    "-warnings=false",
    "-strict=false",
    "-compiler.verbose-stacktraces=true",
    "-static-link-runtime-shared-libraries=true",
    "-output=$outputPath",
    $mainFile
)

Write-Host "SDK:      $sdkRoot"
Write-Host "Compiler: $compilerJar"
Write-Host "Java:     $java"
Write-Host "Main:     $mainFile"
Write-Host "Assets:   $assetBundle"
Write-Host "Output:   $outputPath"

$previousLocation = Get-Location
Set-Location $sourceRoot
try {
    $javaArgs = @(
        "-Xmx1024m",
        "-Dsun.io.useCanonCaches=false",
        "-Djava.util.Arrays.useLegacyMergeSort=true",
        "-jar",
        $compilerJar,
        "+configname=air",
        "+flexlib=$sdkRoot/frameworks"
    ) + $args
    & $java @javaArgs
}
finally {
    Set-Location $previousLocation
}

if ($LASTEXITCODE -ne 0) {
    throw "Compiler failed with exit code $LASTEXITCODE."
}

Write-Host "Compiled game SWF: $outputPath"