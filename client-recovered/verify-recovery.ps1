[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

$requiredFiles = @(
    "launcher/src/boot_338d.as",
    "launcher/src/ApplicationMain.as",
    "launcher/src/SanalikaClient.as",
    "loader/src/extensions/MainLoader.as",
    "game/src/Sanalika.as",
    "game/assets/symbolClass/symbols.csv",
    "runtime/ml.21.9",
    "runtime/snl.780.swf",
    "runtime/c.local.json"
)

$missing = @()
foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        $missing += $relativePath
    }
}

$counts = [ordered]@{
    launcherActionScript = (Get-ChildItem -LiteralPath (Join-Path $root "launcher/src") -Recurse -File -Filter *.as).Count
    loaderActionScript = (Get-ChildItem -LiteralPath (Join-Path $root "loader/src") -Recurse -File -Filter *.as).Count
    gameActionScript = (Get-ChildItem -LiteralPath (Join-Path $root "game/src") -Recurse -File -Filter *.as).Count
    extractedAssetFiles = (Get-ChildItem -LiteralPath (Join-Path $root "game/assets") -Recurse -File).Count
    runtimeFiles = (Get-ChildItem -LiteralPath (Join-Path $root "runtime") -Recurse -File).Count
}

[pscustomobject]$counts | Format-List

if ($missing.Count -gt 0) {
    Write-Error ("Missing recovered client files: " + ($missing -join ", "))
}

Write-Host "Recovery check passed: required client entrypoints and runtime files are present."