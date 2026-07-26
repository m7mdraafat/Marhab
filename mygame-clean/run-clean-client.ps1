[CmdletBinding()]
param(
    [string]$SdkHome = "$HOME\OneDrive - Microsoft\Desktop\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1",
    [switch]$StopExisting
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$sourceDist = Join-Path $repoRoot "client\launcher\dist"
$cleanDist = Join-Path $repoRoot "client\launcher\dist-clean"
$runtimeSource = Join-Path $repoRoot "client\runtime"
$runtimeTarget = Join-Path $cleanDist "runtime"
$cleanSwf = Join-Path $runtimeSource "snl.780.swf.original"
$cleanLoader = Join-Path $runtimeSource "ml.21.9"
$descriptor = Join-Path $cleanDist "application.xml"
$adl = Join-Path $SdkHome "bin\adl.exe"

if ($StopExisting) {
    Get-Process -Name adl,adl64 -ErrorAction SilentlyContinue | Stop-Process -Force
}

if (-not (Test-Path -LiteralPath $adl)) {
    throw "ADL not found: $adl"
}
if (-not (Test-Path -LiteralPath $sourceDist)) {
    throw "Launcher dist not found: $sourceDist"
}
if (-not (Test-Path -LiteralPath $cleanSwf)) {
    throw "Clean SWF not found: $cleanSwf"
}
if (-not (Test-Path -LiteralPath $cleanLoader)) {
    throw "Clean loader not found: $cleanLoader"
}

if (Test-Path -LiteralPath $cleanDist) {
    Remove-Item -LiteralPath $cleanDist -Recurse -Force
}

Copy-Item -LiteralPath $sourceDist -Destination $cleanDist -Recurse -Force
if (Test-Path -LiteralPath $runtimeTarget) {
    Remove-Item -LiteralPath $runtimeTarget -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $runtimeTarget | Out-Null
Copy-Item -Path (Join-Path $runtimeSource "*") -Destination $runtimeTarget -Recurse -Force
Copy-Item -LiteralPath $cleanSwf -Destination (Join-Path $runtimeTarget "snl.780.swf") -Force

$cleanConfig = [ordered]@{
    loader = "app:/runtime/ml.21.9"
    core = "app:/runtime/snl.780.swf"
    background = "app:/runtime/loader-bg.jpg"
    serverName = "marhab"
    protocol = "http://"
    policyFile = "http://127.0.0.1:8080/crossdomain.xml"
    versionData = @(
        [ordered]@{ platform = "windows"; version = "1.0.1.2"; url = "" },
        [ordered]@{ platform = "mac"; version = "1.0.1.1"; url = "" }
    )
}
$cleanConfig | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $runtimeTarget "c.local.json") -Encoding UTF8

Write-Host "ADL:       $adl"
Write-Host "App:       $cleanDist"
Write-Host "Loader:    $cleanLoader"
Write-Host "Clean SWF: $cleanSwf"
Write-Host "Hash:      $((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $runtimeTarget "snl.780.swf")).Hash)"

$previousLocation = Get-Location
Set-Location $cleanDist
try {
    & $adl $descriptor $cleanDist
}
finally {
    Set-Location $previousLocation
}