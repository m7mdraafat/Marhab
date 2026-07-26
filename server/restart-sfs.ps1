# restart-sfs.ps1 — stop ALL SFS java instances (by main-class), redeploy the
# latest extension jar, restart SFS, and verify a single PID owns all three
# ports. Use this every time the extension is rebuilt.
[CmdletBinding()]
param(
    [string]$SfsHome = 'C:\Users\t-malgharib\SmartFoxServer_2X\SFS2X',
    [string]$Jar    = (Join-Path $PSScriptRoot 'dist\HaraExtension.jar')
)
$ErrorActionPreference = 'Stop'

Write-Host "stopping SFS java instances..." -ForegroundColor Cyan
$pids = (Get-CimInstance Win32_Process |
    Where-Object { $_.Name -eq 'java.exe' -and $_.CommandLine -like '*smartfoxserver.v2.Main*' }).ProcessId
foreach ($p in $pids) {
    Write-Host "  taskkill /F /PID $p"
    & taskkill /F /PID $p 2>&1 | Out-Null
}
if ($pids) { Start-Sleep -Seconds 3 } else { Write-Host "  (none running)" }

if (Test-Path $Jar) {
    $dest = Join-Path $SfsHome 'extensions\HaraExtension\HaraExtension.jar'
    $extDir = Split-Path $dest
    New-Item -ItemType Directory -Force -Path $extDir | Out-Null
    Copy-Item $Jar $dest -Force
    Write-Host "deployed $((Get-Item $Jar).Length) bytes -> $dest" -ForegroundColor Green

    $wwwRoot = (Join-Path $PSScriptRoot 'www').Replace('\', '/')
    $props = @(
        'starter.room=street01',
        'cdn.host=127.0.0.1:8081',
        'catalog.item.file=data/ifile.1366',
        'catalog.version.file=data/vf.403',
        'locale.default.file=locale/ar',
        "www.root=$wwwRoot"
    )
    foreach ($name in 'config.properties','extension.properties') {
        $path = Join-Path $extDir $name
        Set-Content -LiteralPath $path -Value $props -Encoding ASCII
        Write-Host "wrote $path" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: $Jar not found; skipping deploy" -ForegroundColor Yellow
}

Write-Host "starting SFS..." -ForegroundColor Cyan
Start-Process -FilePath (Join-Path $SfsHome 'sfs2x.bat') -WorkingDirectory $SfsHome
Start-Sleep -Seconds 22

$listen = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { 8080,8443,9933 -contains $_.LocalPort } |
    Select-Object LocalPort,OwningProcess
$pidSet = ($listen | Select-Object -ExpandProperty OwningProcess -Unique)
if ($listen.Count -eq 0) {
    throw "SFS did not start: no listeners on 8080/8443/9933 after 22s"
} elseif ($pidSet.Count -gt 1) {
    $listen | Format-Table -AutoSize
    throw "SFS has multiple owning PIDs on the three ports — likely a stale instance. Re-run to clean."
} else {
    Write-Host "SFS up cleanly on single PID $($pidSet[0])" -ForegroundColor Green
    $listen | Format-Table -AutoSize
}
