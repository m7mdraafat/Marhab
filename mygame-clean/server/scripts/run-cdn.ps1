[CmdletBinding()]
param(
    [string]$HostName = "127.0.0.1",
    [int]$Port = 8081
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$cdnRoot = Join-Path $repoRoot "server\cdn"
$assetRoot = Join-Path $repoRoot "assets\cdn"

if (-not (Test-Path $cdnRoot)) {
    throw "CDN server folder not found: $cdnRoot"
}

New-Item -ItemType Directory -Force -Path $assetRoot | Out-Null

$env:CDN_HOST = $HostName
$env:CDN_PORT = [string]$Port

Write-Host "Starting local CDN on ${HostName}:${Port}"
Write-Host "Asset root: $assetRoot"

Push-Location $cdnRoot
try {
    node .\src\index.js
}
finally {
    Pop-Location
}