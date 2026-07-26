# run-air.ps1 — one-shot dev launcher: ensure SFS + CDN are up, launch AIR
# via adl with debug enabled, then live-tail every log surface in colour-tagged
# columns. Ctrl+C terminates adl and stops the tails cleanly.
#
# USAGE
#   .\rebuild\run-air.ps1                       # launch + tail
#   .\rebuild\run-air.ps1 -Reset                # clear AIR cache + old logs first
#   .\rebuild\run-air.ps1 -Rebuild              # recompile MyGame.swf first
#   .\rebuild\run-air.ps1 -NoServices           # don't auto-start SFS/CDN
#   .\rebuild\run-air.ps1 -NoTail               # launch only, no log streaming
#
# WHAT IT TAILS (each line is colour-tagged so you can scan fast)
#   [server]      C:\...\SFS2X\logs\smartfox.log
#   [audit]       lines matching "hara.audit" inside smartfox.log
#   [adl-err]     rebuild/bin/adl.err   (AS3 uncaught errors)
#   [adl-out]     rebuild/bin/adl.out   (trace() output)
#   [client-log]  %APPDATA%\com.mygame.standalone\Local Store\rebuild.log
#
# EXIT
#   Ctrl+C kills adl + ends the tails; the SFS/CDN services keep running so
#   you don't pay the restart cost on the next launch.

[CmdletBinding()]
param(
    [switch]$Reset,
    [switch]$Rebuild,
    [switch]$NoServices,
    [switch]$NoTail,
    [switch]$NoDebug,                       # AIR debug ON by default for full stacks
    [string]$SdkHome = 'C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1',
    [string]$SfsHome = 'C:\Users\t-malgharib\SmartFoxServer_2X\SFS2X',
    [int]$ServiceStartTimeoutSec = 20
)

$ErrorActionPreference = 'Stop'
$repoRoot   = Split-Path -Parent $PSScriptRoot
$serverDir  = Join-Path $repoRoot 'server'
$rebuildDir = $PSScriptRoot
$binDir     = Join-Path $rebuildDir 'bin'
$descriptor = Join-Path $rebuildDir 'application.xml'
$swf        = Join-Path $rebuildDir 'bin\MyGame.swf'
$adlErr     = Join-Path $binDir 'adl.err'
$adlOut     = Join-Path $binDir 'adl.out'
$clientLog  = Join-Path $env:APPDATA 'com.mygame.standalone\Local Store\rebuild.log'
$serverLog  = Join-Path $SfsHome 'logs\smartfox.log'
$cache      = Join-Path $env:APPDATA 'com.mygame.standalone\Local Store\asset-cache'

# Colour-tagged logger so script output is readable interleaved with tails.
function Write-Step([string]$msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok  ([string]$msg) { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn([string]$msg) { Write-Host "    $msg" -ForegroundColor Yellow }
function Write-Bad ([string]$msg) { Write-Host "    $msg" -ForegroundColor Red }

# -----------------------------------------------------------------------
# pre-flight: SDK, SWF, services
# -----------------------------------------------------------------------

function Test-Port([int]$port) {
    $c = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    return [bool]$c
}

function Ensure-Sfs {
    if ((Test-Port 9933) -and (Test-Port 8080) -and (Test-Port 8443)) {
        Write-Ok 'SFS already listening on 9933/8080/8443'
        return
    }
    Write-Warn 'SFS not running — invoking server\restart-sfs.ps1'
    Push-Location $serverDir
    try { & .\restart-sfs.ps1 } finally { Pop-Location }
}

function Ensure-Cdn {
    if (Test-Port 8081) {
        Write-Ok 'serve-cdn already listening on 8081'
        return
    }
    Write-Warn 'serve-cdn not running — starting hidden'
    Start-Process pwsh `
        -ArgumentList '-NoProfile','-File',(Join-Path $serverDir 'serve-cdn.ps1') `
        -WindowStyle Hidden
    $deadline = (Get-Date).AddSeconds($ServiceStartTimeoutSec)
    while ((Get-Date) -lt $deadline -and -not (Test-Port 8081)) { Start-Sleep -Milliseconds 250 }
    if (Test-Port 8081) { Write-Ok 'serve-cdn is up' }
    else { throw "serve-cdn failed to bind 8081 within $ServiceStartTimeoutSec s" }
}

function Reset-State {
    Write-Step 'Reset: wiping AIR cache + old logs'
    Remove-Item -ErrorAction SilentlyContinue -Recurse -Force $cache
    Remove-Item -ErrorAction SilentlyContinue -Force $clientLog, $adlErr, $adlOut
    Write-Ok 'cleared'
}

# -----------------------------------------------------------------------
# preflight
# -----------------------------------------------------------------------

Write-Step 'Pre-flight'
$adl = Join-Path $SdkHome 'bin\adl.exe'
if (-not (Test-Path $adl)) {
    throw "AIR SDK adl.exe not found at $adl. Pass -SdkHome or install Harman/Apache AIR SDK."
}
Write-Ok "adl: $adl"

$env:AIR_SDK_HOME = $SdkHome
$env:FLEX_HOME    = $SdkHome
$env:AIR_HOME     = $SdkHome

if (-not (Test-Path $descriptor)) { throw "AIR descriptor missing: $descriptor" }
if (-not (Test-Path $swf))        { Write-Warn "SWF missing: $swf (will -Rebuild)"; $Rebuild = $true }
New-Item -ItemType Directory -Force -Path $binDir | Out-Null

if ($Rebuild) {
    Write-Step 'Rebuild client SWF'
    & (Join-Path $rebuildDir 'compile.ps1') -SdkHome $SdkHome
    if ($LASTEXITCODE -ne 0) { throw "compile.ps1 failed ($LASTEXITCODE)" }
}

if ($Reset) { Reset-State }

if (-not $NoServices) {
    Write-Step 'Ensure SFS + CDN are running'
    Ensure-Sfs
    Ensure-Cdn
} else {
    Write-Warn 'Skipping service preflight (-NoServices)'
}

# -----------------------------------------------------------------------
# launch adl
# -----------------------------------------------------------------------

# Truncate per-run log files so each launch starts clean. We deliberately do
# NOT touch the SFS log — it's shared state across launches.
Set-Content -LiteralPath $adlErr -Value '' -Encoding UTF8
Set-Content -LiteralPath $adlOut -Value '' -Encoding UTF8
$serverTailStart = if (Test-Path $serverLog) { (Get-Item $serverLog).Length } else { 0 }
$clientTailStart = if (Test-Path $clientLog) { (Get-Item $clientLog).Length } else { 0 }

Write-Step ('Launch AIR  ({0})' -f $(if ($NoDebug) { 'no-debug' } else { 'debug' }))
# adl resolves the descriptor path relative to the working directory, and the
# absolute MyGame path contains spaces + a hyphen which Start-Process can
# mis-quote. Setting WorkingDirectory + passing simple file names sidesteps
# that and matches what rebuild/run.ps1 + dev-loop.ps1 do.
$adlArgs = @()
if ($NoDebug) { $adlArgs += '-nodebug' }
$adlArgs += @((Split-Path $descriptor -Leaf), '.')

$proc = Start-Process -FilePath $adl -ArgumentList $adlArgs `
    -WorkingDirectory $rebuildDir `
    -RedirectStandardError $adlErr -RedirectStandardOutput $adlOut `
    -PassThru -WindowStyle Normal
Write-Ok "adl pid $($proc.Id) (cwd=$rebuildDir)"

if ($NoTail) {
    Write-Step 'Detached — adl runs until you close it. Ctrl+C this shell to kill adl.'
    try {
        while (-not $proc.HasExited) { Start-Sleep -Milliseconds 500 }
    } finally {
        if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
    }
    return
}

# -----------------------------------------------------------------------
# live tail (background jobs feed lines into a single coloured stream)
# -----------------------------------------------------------------------

Write-Step 'Tailing logs — Ctrl+C to stop everything'
Write-Host "  [server]  $serverLog"
Write-Host "  [adl-err] $adlErr"
Write-Host "  [adl-out] $adlOut"
Write-Host "  [client]  $clientLog"
Write-Host ''

# Single tail loop that reads new bytes from each file since launch.
# Background Jobs work but stream colours and ordering cleanly with one loop.
$cursors = @{ server = $serverTailStart; client = $clientTailStart; err = 0; out = 0 }

function Read-Delta([string]$path, [string]$key, [int]$max = 40) {
    if (-not (Test-Path $path)) { return @() }
    $len = (Get-Item $path).Length
    if ($len -le $cursors[$key]) { return @() }
    try {
        $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        try {
            $fs.Seek($cursors[$key], [System.IO.SeekOrigin]::Begin) | Out-Null
            $sr = New-Object System.IO.StreamReader($fs)
            $text = $sr.ReadToEnd()
            $sr.Dispose()
        } finally { $fs.Dispose() }
    } catch { return @() }
    $cursors[$key] = $len
    $lines = $text -split "`r?`n" | Where-Object { $_ }
    if ($lines.Count -gt $max) {
        return @("...(<truncated $($lines.Count - $max) earlier lines>)") + ($lines | Select-Object -Last $max)
    }
    return $lines
}

function Emit-Tagged([string]$tag, [ConsoleColor]$colour, [string[]]$lines) {
    # Pad the tag once; concatenate $line via + so curly braces in log
    # output don't get interpreted as -f format placeholders (they will when
    # the client logs JSON / SFSObject dumps).
    $paddedTag = $tag.PadRight(9)
    foreach ($line in $lines) {
        $ts = (Get-Date).ToString('HH:mm:ss.fff')
        $isAudit = ($tag -eq 'server') -and ($line -match 'hara\.audit')
        if ($isAudit) {
            Write-Host ($ts + ' [audit]    ' + $line) -ForegroundColor Magenta
        } else {
            Write-Host ($ts + ' [' + $paddedTag + '] ' + $line) -ForegroundColor $colour
        }
    }
}

[Console]::TreatControlCAsInput = $false
try {
    while (-not $proc.HasExited) {
        Emit-Tagged 'server'    DarkGray (Read-Delta $serverLog 'server')
        Emit-Tagged 'adl-err'   Red      (Read-Delta $adlErr    'err')
        Emit-Tagged 'adl-out'   Gray     (Read-Delta $adlOut    'out')
        Emit-Tagged 'client'    Green    (Read-Delta $clientLog 'client')
        Start-Sleep -Milliseconds 350
    }
    Write-Step "adl exited code $($proc.ExitCode)"
} finally {
    if (-not $proc.HasExited) {
        Write-Step 'Stopping adl…'
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
    # final flush — drain anything that arrived in the last interval
    Emit-Tagged 'server'  DarkGray (Read-Delta $serverLog 'server')
    Emit-Tagged 'adl-err' Red      (Read-Delta $adlErr    'err')
    Emit-Tagged 'adl-out' Gray     (Read-Delta $adlOut    'out')
    Emit-Tagged 'client'  Green    (Read-Delta $clientLog 'client')
    Write-Step 'Done.'
}
