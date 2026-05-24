[CmdletBinding()]
param(
    [string]$SdkHome,
    [string]$Output = "bin/MyGame.swf",
    [string]$MainClass = "boot_338d"
)

$ErrorActionPreference = "Stop"

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
            $candidate = Join-Path $SdkRoot "bin/$name.bat"
            if (Test-Path $candidate) {
                return $candidate
            }

            $candidate = Join-Path $SdkRoot "bin/$name.exe"
            if (Test-Path $candidate) {
                return $candidate
            }
        }
    }

    return $null
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sdkRoot = $SdkHome
if (-not $sdkRoot) { $sdkRoot = $env:AIR_SDK_HOME }
if (-not $sdkRoot) { $sdkRoot = $env:AIRSDK_HOME }
if (-not $sdkRoot) { $sdkRoot = $env:FLEX_HOME }
if ($sdkRoot) {
    $sdkRoot = (Resolve-Path $sdkRoot).Path
    $env:FLEX_HOME = $sdkRoot
    $env:AIR_HOME = $sdkRoot
    $env:AIR_SDK_HOME = $sdkRoot
}

$compiler = Resolve-Tool -Names @("amxmlc", "mxmlc") -SdkRoot $sdkRoot
if (-not $compiler) {
    throw "No ActionScript compiler found. Install Harman AIR SDK / Flex SDK, add amxmlc or mxmlc to PATH, or set AIR_SDK_HOME."
}

$sourcePath = Join-Path $repoRoot "scripts"
$mainFile = Join-Path $sourcePath "$MainClass.as"
if (-not (Test-Path $mainFile)) {
    throw "Main class file not found: $mainFile"
}

$outputPath = Join-Path $PSScriptRoot $Output
$outputDir = Split-Path $outputPath -Parent
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

# Classes that are only referenced dynamically (Type.resolveClass / getDefinitionByName)
# must be force-linked or the AVM2 linker strips them and the preloader silently stalls.
# Currently this covers swf.SWFLibrary, MyGameAssetProxy (looked up by the inner
# game SWF), and every generated __ASSET__* asset class.
$forceInclude = @("swf.SWFLibrary", "MyGameAssetProxy")
$forceInclude += Get-ChildItem -Path $sourcePath -File -Filter '__ASSET__*.as' |
    ForEach-Object { $_.BaseName }
Write-Host "Force-include: $($forceInclude.Count) classes"

$args = @(
    "-source-path+=$sourcePath",
    "-debug=true",
    "-warnings=true",
    "-strict=false",
    "-static-link-runtime-shared-libraries=true",
    "-output=$outputPath"
)
foreach ($cls in $forceInclude) {
    $args += "-includes+=$cls"
}
$args += $mainFile

Write-Host "Compiler: $compiler"
Write-Host "Main:     $mainFile"
Write-Host "Output:   $outputPath"
& $compiler @args

if ($LASTEXITCODE -ne 0) {
    throw "Compiler failed with exit code $LASTEXITCODE."
}

Write-Host "Compiled $outputPath"