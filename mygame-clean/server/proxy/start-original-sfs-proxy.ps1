[CmdletBinding()]
param(
    [string]$NodePath = "node",
    [string]$ListenHost = "127.0.0.1",
    [int]$ListenPort = 8080,
    [string]$RemoteHost = "marhab-sfs.rage-world.net",
    [int]$RemotePort = 8080
)

$ErrorActionPreference = "Stop"

$script = Join-Path $PSScriptRoot "src\original-sfs-proxy.js"
if (-not (Test-Path -LiteralPath $script)) {
    throw "Proxy script not found: $script"
}

$env:ORIGINAL_PROXY_HOST = $ListenHost
$env:ORIGINAL_PROXY_PORT = [string]$ListenPort
$env:ORIGINAL_PROXY_REMOTE_HOST = $RemoteHost
$env:ORIGINAL_PROXY_REMOTE_PORT = [string]$RemotePort

Write-Host "Proxy:  $ListenHost`:$ListenPort"
Write-Host "Remote: $RemoteHost`:$RemotePort"
Write-Host "Logs:   server\logs\original-proxy"

& $NodePath $script