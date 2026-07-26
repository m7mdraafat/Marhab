# patch-avatar-panel.ps1 — apply AS3 overrides from
# rebuild/inventory/avatar_create_panel_patch/ to the AvatarCreatePanel SWF
# (panels are NOT encrypted — straight FFDec round-trip, no pack-snl.py).
#
# Inputs  : server/www/global/dynamic/panels/7530800THw.2.swf  (original CWS/ZWS)
#           rebuild/inventory/avatar_create_panel_patch/         (AS3 patch tree)
# Outputs : server/www/global/dynamic/panels/7530800THw.2.swf  (rewritten in place)
# Backup  : rebuild/inventory/avatar_create_panel_src/AvatarCreatePanel.original.swf
#
# Idempotent — restores from the .original.swf backup on every run so removing
# a patch file undoes that patch on the next invocation.

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot   = Split-Path -Parent $PSScriptRoot
$ffdec      = Join-Path $PSScriptRoot "tools\ffdec\ffdec-cli.exe"
$patchDir   = Join-Path $PSScriptRoot "inventory\avatar_create_panel_patch"
$panelSwf   = Join-Path $repoRoot   "server\www\global\dynamic\panels\7530800THw.2.swf"
$backupSwf  = Join-Path $PSScriptRoot "inventory\avatar_create_panel_src\AvatarCreatePanel.original.swf"

if (-not (Test-Path $ffdec))    { throw "FFDec CLI not found: $ffdec" }
if (-not (Test-Path $patchDir)) { throw "Patch dir not found: $patchDir" }
if (-not (Test-Path $panelSwf)) { throw "Panel SWF not found: $panelSwf" }

# First run: snapshot the pristine SWF so we can always reset to a known-good base.
if (-not (Test-Path $backupSwf)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $backupSwf) | Out-Null
    Copy-Item -LiteralPath $panelSwf -Destination $backupSwf
    Write-Host "Backup : seeded original -> $backupSwf" -ForegroundColor Yellow
}

$patchCount = (Get-ChildItem -Path $patchDir -Recurse -Filter '*.as' -File).Count
Write-Host "Patches : $patchCount .as files under $patchDir"

# Always start from the pristine backup so this script is idempotent.
$workInput = Join-Path $env:TEMP "avatar_create_panel.in.swf"
Copy-Item -Force -LiteralPath $backupSwf -Destination $workInput

$workOutput = Join-Path $env:TEMP "avatar_create_panel.out.swf"
Remove-Item -ErrorAction SilentlyContinue $workOutput

Write-Host "FFDec  : -importScript ..."
& $ffdec -importScript $workInput $workOutput $patchDir
if ($LASTEXITCODE -ne 0) { throw "ffdec importScript failed ($LASTEXITCODE)" }
if (-not (Test-Path $workOutput)) { throw "ffdec produced no output: $workOutput" }

# Sanity: SWF magic must be FWS / CWS / ZWS.
$magic = [System.IO.File]::ReadAllBytes($workOutput) | Select-Object -First 3
$magicStr = -join ($magic | ForEach-Object { [char]$_ })
if ($magicStr -notin @('FWS','CWS','ZWS')) {
    throw "Patched SWF has bad magic '$magicStr' — refusing to deploy"
}

Copy-Item -Force -LiteralPath $workOutput -Destination $panelSwf
$size = (Get-Item $panelSwf).Length
Write-Host "Wrote  : $panelSwf  ($size bytes, magic=$magicStr)" -ForegroundColor Green

Remove-Item -ErrorAction SilentlyContinue $workInput, $workOutput
