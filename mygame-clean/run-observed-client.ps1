[CmdletBinding()]
param(
    [switch]$Build,
    [switch]$StopExisting,
    [string]$SdkHome,
    [string]$JavaHome = "C:\Program Files\Eclipse Adoptium\jdk-8.0.492.9-hotspot"
)

$ErrorActionPreference = "Stop"
$repoRoot = $PSScriptRoot

if (-not $SdkHome) {
    $defaultSdk = Join-Path $HOME "OneDrive - Microsoft\Desktop\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1"
    if (Test-Path -LiteralPath $defaultSdk) {
        $SdkHome = $defaultSdk
    }
}

if (-not $SdkHome) {
    throw "No AIR/Flex SDK path found. Pass -SdkHome."
}

if ($StopExisting -or $Build) {
    Get-Process -Name adl,adl64 -ErrorAction SilentlyContinue | Stop-Process -Force
}

if ($Build) {
    & (Join-Path $repoRoot "client/observed/build/build.ps1") -SdkHome $SdkHome -JavaHome $JavaHome
}

& (Join-Path $repoRoot "client/observed/build/run.ps1") -SdkHome $SdkHome