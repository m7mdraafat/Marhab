[CmdletBinding()]
param(
    [string]$HostName = "127.0.0.1",
    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$probeRoot = Join-Path $repoRoot "server\probe"
$logRoot = Join-Path $repoRoot "server\logs"

if (-not (Test-Path $probeRoot)) {
    throw "Probe folder not found: $probeRoot"
}

New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

$env:PROBE_HOST = $HostName
$env:PROBE_PORT = [string]$Port

Write-Host "Starting protocol probe on ${HostName}:${Port}"
Write-Host "Logs: $logRoot"

Push-Location $probeRoot
try {
    node .\src\index.js
}
finally {
    Pop-Location
}