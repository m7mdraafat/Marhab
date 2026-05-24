[CmdletBinding()]
param(
    [string]$SdkHome,
    [string]$Descriptor = "application.xml",
    [string]$ExtDir,
    # When set, runs adl in debug mode (shows AIR error dialogs for uncaught
    # exceptions). Default OFF so the in-game decompile-artifact errors
    # (dya68_, YouTubePlayer BitmapData) don't pop a dialog every frame.
    [switch]$Debug
)

$ErrorActionPreference = "Stop"

function Resolve-Adl {
    param([string]$SdkRoot)

    $command = Get-Command "adl" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    if ($SdkRoot) {
        foreach ($name in @("adl.bat", "adl.exe")) {
            $candidate = Join-Path $SdkRoot "bin/$name"
            if (Test-Path $candidate) {
                return $candidate
            }
        }
    }

    return $null
}

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

$adl = Resolve-Adl -SdkRoot $sdkRoot
if (-not $adl) {
    throw "No AIR runtime launcher found. Install Harman AIR SDK, add adl to PATH, or set AIR_SDK_HOME."
}

$descriptorPath = Join-Path $PSScriptRoot $Descriptor
$swfPath = Join-Path $PSScriptRoot "bin/MyGame.swf"
if (-not (Test-Path $descriptorPath)) {
    throw "AIR descriptor not found: $descriptorPath"
}
if (-not (Test-Path $swfPath)) {
    throw "Compiled SWF not found: $swfPath. Run rebuild/compile.ps1 first."
}

$args = @($descriptorPath, $PSScriptRoot)
if (-not $Debug) {
    # -nodebug runs the AIR runtime in non-debug mode -- no error dialogs.
    $args = @("-nodebug") + $args
}
if ($ExtDir) {
    $resolvedExtDir = Resolve-Path $ExtDir
    $args = @("-extdir", $resolvedExtDir) + $args
}

Write-Host "ADL:        $adl"
Write-Host "Descriptor: $descriptorPath"
Write-Host "Mode:       $(if ($Debug) { 'debug (error dialogs ON)' } else { 'nodebug (error dialogs OFF)' })"
& $adl @args