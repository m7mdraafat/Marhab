# dev-loop.ps1 — build MyGame.swf, launch in adl, capture stderr/log, summarize.
[CmdletBinding()]
param(
    [int]$WaitSeconds = 20,
    [string]$SdkHome = (Resolve-Path '..\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1').Path
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$env:AIR_SDK_HOME = $SdkHome
$logStore = "$env:APPDATA\com.mygame.standalone\Local Store\rebuild.log"
$errFile  = Join-Path $root 'rebuild\bin\adl.err'

Write-Host "--- PATCH INNER SWF ---" -ForegroundColor Cyan
& (Join-Path $PSScriptRoot 'patch-swf.ps1')
if ($LASTEXITCODE -ne 0) { throw "patch-swf failed ($LASTEXITCODE)" }

Write-Host "--- BUILD ---" -ForegroundColor Cyan
$build = & (Join-Path $PSScriptRoot 'compile.ps1') -SdkHome $SdkHome 2>&1
$errors = $build | Select-String -Pattern 'Error:' | Select-Object -Last 8
if ($errors) { $errors; throw "Build failed" }
$build | Select-String -Pattern 'bytes\)' | Select-Object -Last 1

Write-Host "--- WARM CACHE ---" -ForegroundColor Cyan
& (Join-Path $PSScriptRoot 'warm-cache.ps1')

Write-Host "--- LAUNCH ---" -ForegroundColor Cyan
Remove-Item -ErrorAction SilentlyContinue $logStore, $errFile
$adl = Join-Path $SdkHome 'bin\adl.exe'
$outFile = Join-Path $root 'rebuild\bin\adl.out'
$proc = Start-Process -FilePath $adl -ArgumentList '-nodebug','.\rebuild\application.xml','.\rebuild' -PassThru -RedirectStandardError $errFile -RedirectStandardOutput $outFile
Start-Sleep -Seconds $WaitSeconds
if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force; Write-Host "(adl killed after $WaitSeconds s)" -ForegroundColor Green } else { Write-Host "(adl exited code $($proc.ExitCode))" -ForegroundColor Yellow }
Start-Sleep -Milliseconds 500
if (Test-Path $outFile) {
    $extra = Get-Content $outFile -ErrorAction SilentlyContinue
    if ($extra) { Add-Content -Path $errFile -Value '--- stdout ---'; Add-Content -Path $errFile -Value $extra }
}

Write-Host "--- ERROR / TRACE TAIL ---" -ForegroundColor Cyan
$err = Get-Content $errFile -ErrorAction SilentlyContinue
$firstError = ($err | Select-String -Pattern '^(Error|TypeError|ReferenceError|VerifyError|RangeError|SecurityError):').LineNumber | Select-Object -First 1
if ($firstError) {
    $err | Select-Object -Skip ($firstError - 2) -First 20
} else {
    Write-Host "(no error -- showing last 15 traces)" -ForegroundColor Green
    $err | Select-Object -Last 15
}

Write-Host "--- REBUILD.LOG ---" -ForegroundColor Cyan
Get-Content $logStore -ErrorAction SilentlyContinue
