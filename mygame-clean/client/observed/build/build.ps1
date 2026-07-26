[CmdletBinding()]
param(
    [string]$SdkHome,
    [string]$JavaHome = "C:\Program Files\Eclipse Adoptium\jdk-8.0.492.9-hotspot",
    [string]$MainClass = "Sanalika",
    [string]$AssetSource,
    [switch]$NoPromote
)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../../..")
$observedRoot = Join-Path $repoRoot "client/observed"
$sourceRoot = Join-Path $observedRoot "game-src"
$runtimeRoot = Join-Path $observedRoot "runtime"
$mainFile = Join-Path $sourceRoot "$MainClass.as"
$outputDir = Join-Path $observedRoot "build/out"
$outputSwf = Join-Path $outputDir "snl.780.observed.swf"
$runtimeSwf = Join-Path $runtimeRoot "snl.780.swf"
$assetDir = Join-Path $sourceRoot "_assets"
$assetBundle = Join-Path $assetDir "assets.swf"

function Resolve-SdkRoot {
    param([string]$ExplicitSdkHome)

    $candidates = @($ExplicitSdkHome, $env:AIR_SDK_HOME, $env:AIRSDK_HOME, $env:FLEX_HOME, $env:AIR_HOME) | Where-Object { $_ }
    foreach ($candidate in $candidates) {
        if (-not (Test-Path -LiteralPath $candidate)) { continue }
        $resolved = (Resolve-Path $candidate).Path
        if (Test-Path -LiteralPath (Join-Path $resolved "lib/mxmlc.jar")) { return $resolved }
    }

    return $null
}

if (-not (Test-Path -LiteralPath $mainFile)) { throw "Main class file not found: $mainFile" }
if (-not (Test-Path -LiteralPath $runtimeRoot)) { throw "Observed runtime folder not found: $runtimeRoot" }

if (-not $AssetSource) {
    $localOriginal = Join-Path $runtimeRoot "snl.780.swf.original"
    $repoOriginal = Join-Path $repoRoot "client/runtime/snl.780.swf.original"
    if (Test-Path -LiteralPath $localOriginal) { $AssetSource = $localOriginal }
    elseif (Test-Path -LiteralPath $repoOriginal) { $AssetSource = $repoOriginal }
    else { $AssetSource = $runtimeSwf }
}
if (-not (Test-Path -LiteralPath $AssetSource)) { throw "Asset source SWF not found: $AssetSource" }

$sdkRoot = Resolve-SdkRoot -ExplicitSdkHome $SdkHome
if (-not $sdkRoot) { throw "No AIR/Flex SDK found. Pass -SdkHome or set AIR_SDK_HOME/FLEX_HOME." }

$compilerJar = Join-Path $sdkRoot "lib/mxmlc.jar"
if (-not (Test-Path -LiteralPath $compilerJar)) { throw "Flex compiler jar not found: $compilerJar" }

$java = $null
if ($JavaHome) {
    $javaCandidate = Join-Path $JavaHome "bin/java.exe"
    if (Test-Path -LiteralPath $javaCandidate) { $java = $javaCandidate }
}
if (-not $java) {
    $javaCommand = Get-Command java -ErrorAction SilentlyContinue
    if ($javaCommand) { $java = $javaCommand.Source }
}
if (-not $java) { throw "No Java runtime found. Pass -JavaHome or add java to PATH." }

$env:FLEX_HOME = $sdkRoot
$env:AIR_HOME = $sdkRoot
$env:AIR_SDK_HOME = $sdkRoot

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
New-Item -ItemType Directory -Force -Path $assetDir | Out-Null
Copy-Item -LiteralPath $AssetSource -Destination $assetBundle -Force

$compilerArgs = @(
    "-Xmx1024m",
    "-Dsun.io.useCanonCaches=false",
    "-Djava.util.Arrays.useLegacyMergeSort=true",
    "-jar",
    $compilerJar,
    "+configname=air",
    "+flexlib=$sdkRoot/frameworks",
    "-source-path+=$sourceRoot",
    "-debug=true",
    "-warnings=false",
    "-strict=false",
    "-compiler.verbose-stacktraces=true",
    "-static-link-runtime-shared-libraries=true",
    "-output=$outputSwf",
    $mainFile
)

Write-Host "SDK:      $sdkRoot"
Write-Host "Compiler: $compilerJar"
Write-Host "Java:     $java"
Write-Host "Source:   $sourceRoot"
Write-Host "Assets:   $AssetSource"
Write-Host "Output:   $outputSwf"

$previousLocation = Get-Location
Set-Location $sourceRoot
try { & $java @compilerArgs }
finally { Set-Location $previousLocation }

if ($LASTEXITCODE -ne 0) { throw "Compiler failed with exit code $LASTEXITCODE." }

if (-not $NoPromote) {
    Copy-Item -LiteralPath $outputSwf -Destination $runtimeSwf -Force
    Write-Host "Promoted observed SWF to: $runtimeSwf"
}
else {
    Write-Host "Observed SWF compiled without promotion."
}