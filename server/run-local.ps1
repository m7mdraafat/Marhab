# run-local.ps1 -- deploy MyGameExtension.jar into a local SFS install and
# (re)start the SmartFoxServer 2X service so the new extension is picked up.
#
# Requires SFS_HOME env var or -SfsHome arg pointing to your SFS2X directory.
[CmdletBinding()]
param(
    [string]$SfsHome = $env:SFS_HOME,
    [string]$ExtensionName = 'MyGameExtension'
)
$ErrorActionPreference = 'Stop'

if (-not $SfsHome -or -not (Test-Path $SfsHome)) {
    throw "SFS install not found. Pass -SfsHome 'C:\path\to\SFS2X' or set SFS_HOME."
}

$here = $PSScriptRoot
$jar = Join-Path $here 'dist\MyGameExtension.jar'
if (-not (Test-Path $jar)) {
    Write-Host "no jar found; running build first..." -ForegroundColor Cyan
    & (Join-Path $here 'build.ps1')
}

$extDir = Join-Path $SfsHome "extensions\$ExtensionName"
New-Item -ItemType Directory -Force -Path $extDir | Out-Null
Copy-Item $jar $extDir -Force
Write-Host "Deployed jar to: $extDir" -ForegroundColor Green

# Restart SFS service. SFS Windows installer typically registers a service
# named "SmartFoxServer 2X" but the exact display name can vary.
$svc = Get-Service | Where-Object { $_.DisplayName -like 'SmartFoxServer*' } | Select-Object -First 1
if ($svc) {
    Write-Host "Restarting service '$($svc.Name)' ..." -ForegroundColor Cyan
    Restart-Service -Name $svc.Name -Force
    Write-Host "Restarted. Admin UI: http://localhost:8080/admin (user: sfsadmin)" -ForegroundColor Green
} else {
    Write-Host "No SmartFoxServer service found. Start manually via $SfsHome\sfs2x-service\bin\start.bat" -ForegroundColor Yellow
}
