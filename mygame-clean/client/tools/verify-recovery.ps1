[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../..")

$requiredFiles = @(
    "client/launcher/src/boot_338d.as",
    "client/launcher/src/ApplicationMain.as",
    "client/launcher/src/SanalikaClient.as",
    "client/recovered/loader-src/extensions/MainLoader.as",
    "client/recovered/game-src/Sanalika.as",
    "client/recovered/assets/symbolClass/symbols.csv",
    "client/runtime/ml.21.9",
    "client/runtime/snl.780.swf",
    "client/runtime/c.local.json"
)

$missing = @()
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath))) { $missing += $relativePath }
}

$counts = [ordered]@{
    launcherActionScript = (Get-ChildItem -LiteralPath (Join-Path $repoRoot "client/launcher/src") -Recurse -File -Filter *.as).Count
    loaderActionScript = (Get-ChildItem -LiteralPath (Join-Path $repoRoot "client/recovered/loader-src") -Recurse -File -Filter *.as).Count
    gameActionScript = (Get-ChildItem -LiteralPath (Join-Path $repoRoot "client/recovered/game-src") -Recurse -File -Filter *.as).Count
    extractedAssetFiles = (Get-ChildItem -LiteralPath (Join-Path $repoRoot "client/recovered/assets") -Recurse -File).Count
    runtimeFiles = (Get-ChildItem -LiteralPath (Join-Path $repoRoot "client/runtime") -Recurse -File).Count
}

[pscustomobject]$counts | Format-List
if ($missing.Count -gt 0) { Write-Error ("Missing recovered client files: " + ($missing -join ", ")) }
Write-Host "Recovery check passed."