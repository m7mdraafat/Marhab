[CmdletBinding()]
param(
    [string]$SdkHome = "$HOME\OneDrive - Microsoft\Desktop\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1",
    [string]$ServerName = "marhab",
    [switch]$UseLocalProxy,
    [switch]$Build,
    [switch]$StopExisting
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$dist = Join-Path $repoRoot "client\launcher\dist-logged"
$output = "client/launcher/dist-logged/bin/MyGame.swf"
$descriptor = Join-Path $dist "application.xml"
$runtimeSource = Join-Path $repoRoot "client\runtime"
$runtimeTarget = Join-Path $dist "runtime"
$cleanSwf = Join-Path $runtimeSource "snl.780.swf.original"
$cleanLoader = Join-Path $runtimeSource "ml.21.9"
$adl = Join-Path $SdkHome "bin\adl.exe"
$effectiveServerName = if ($UseLocalProxy) { "local" } else { $ServerName }

if ($StopExisting) {
    Get-Process -Name adl,adl64 -ErrorAction SilentlyContinue | Stop-Process -Force
}

if (-not (Test-Path -LiteralPath $adl)) {
    throw "ADL not found: $adl"
}
if (-not (Test-Path -LiteralPath $cleanSwf)) {
    throw "Clean SWF not found: $cleanSwf"
}
if (-not (Test-Path -LiteralPath $cleanLoader)) {
    throw "Clean loader not found: $cleanLoader"
}

if ($Build -or -not (Test-Path -LiteralPath $descriptor) -or -not (Test-Path -LiteralPath (Join-Path $dist "bin\MyGame.swf"))) {
    & (Join-Path $repoRoot "client\launcher\build\compile.ps1") -SdkHome $SdkHome -Output $output
}

if (-not (Test-Path -LiteralPath $descriptor)) {
    throw "Logged launcher descriptor not found: $descriptor"
}

if (Test-Path -LiteralPath $runtimeTarget) {
    Remove-Item -LiteralPath $runtimeTarget -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $runtimeTarget | Out-Null
Copy-Item -Path (Join-Path $runtimeSource "*") -Destination $runtimeTarget -Recurse -Force
Copy-Item -LiteralPath $cleanSwf -Destination (Join-Path $runtimeTarget "snl.780.swf") -Force

$loggedConfig = [ordered]@{
    loader = "app:/runtime/ml.21.9"
    core = "app:/runtime/snl.780.swf"
    background = "app:/runtime/loader-bg.jpg"
    serverName = $effectiveServerName
    protocol = "http://"
    policyFile = "http://127.0.0.1:8080/crossdomain.xml"
    logMode = "logged-clean"
    versionData = @(
        [ordered]@{ platform = "windows"; version = "1.0.1.2"; url = "" },
        [ordered]@{ platform = "mac"; version = "1.0.1.1"; url = "" }
    )
}
$loggedConfig | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $runtimeTarget "c.local.json") -Encoding UTF8

$sessionRoot = Join-Path $env:APPDATA "com.mygame.clean\Local Store\sessions"

Write-Host "ADL:       $adl"
Write-Host "App:       $dist"
Write-Host "Loader:    $cleanLoader"
Write-Host "Clean SWF: $cleanSwf"
Write-Host "Server:    $effectiveServerName"
Write-Host "Hash:      $((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $runtimeTarget "snl.780.swf")).Hash)"
Write-Host "Sessions:  $sessionRoot"

$previousLocation = Get-Location
Set-Location $dist
try {
    & $adl $descriptor $dist
}
finally {
    Set-Location $previousLocation
}
