# patch-swf.ps1 — apply rebuild/inventory/snl_780_patch/ AS3 files to the
# uncompressed inner SWF via FFDec, then re-encrypt via pack-snl.py and
# install as rebuild/runtime/snl.780.swf.
#
# Inputs  : rebuild/inventory/snl_780_uncompressed.swf  (FWS, decrypted)
#           rebuild/inventory/snl_780_patch/             (.as bulk scripts)
# Outputs : rebuild/runtime/snl.780.swf                  (encrypted, ready to ship)
#
# Idempotent — always rebuilds from the pristine uncompressed FWS, so removing
# a patch file undoes that patch on the next run.

[CmdletBinding()]
param(
    [switch]$KeepPatchedFws
)

$ErrorActionPreference = "Stop"
$repoRoot   = Split-Path -Parent $PSScriptRoot
$ffdec      = Join-Path $PSScriptRoot "tools\ffdec\ffdec-cli.exe"
$srcFws     = Join-Path $PSScriptRoot "inventory\snl_780_uncompressed.swf"
$patchDir   = Join-Path $PSScriptRoot "inventory\snl_780_patch"
$packPy     = Join-Path $PSScriptRoot "pack-snl.py"
$runtimeSwf = Join-Path $PSScriptRoot "runtime\snl.780.swf"

if (-not (Test-Path $ffdec))    { throw "FFDec CLI not found: $ffdec" }
if (-not (Test-Path $srcFws))   { throw "Source FWS not found: $srcFws" }
if (-not (Test-Path $patchDir)) { throw "Patch dir not found: $patchDir" }
if (-not (Test-Path $packPy))   { throw "pack-snl.py not found: $packPy" }

$patchCount = (Get-ChildItem -Path $patchDir -Recurse -Filter '*.as' -File).Count
Write-Host "Patches : $patchCount .as files under $patchDir"

$patchedFws = Join-Path $env:TEMP "snl_780_patched.swf"
Remove-Item -ErrorAction SilentlyContinue $patchedFws

Write-Host "FFDec  : -importScript ..."
& $ffdec -importScript $srcFws $patchedFws $patchDir
if ($LASTEXITCODE -ne 0) { throw "ffdec importScript failed ($LASTEXITCODE)" }
if (-not (Test-Path $patchedFws)) { throw "ffdec produced no output: $patchedFws" }

Write-Host "Pack   : pack-snl.py $patchedFws"
& python $packPy $patchedFws
if ($LASTEXITCODE -ne 0) { throw "pack-snl.py failed ($LASTEXITCODE)" }

$repacked = "$runtimeSwf.repacked"
if (-not (Test-Path $repacked)) { throw "pack-snl.py did not produce $repacked" }

Move-Item -Force $repacked $runtimeSwf
$size = (Get-Item $runtimeSwf).Length
Write-Host "Wrote  : $runtimeSwf  ($size bytes)" -ForegroundColor Green

if (-not $KeepPatchedFws) { Remove-Item -ErrorAction SilentlyContinue $patchedFws }
