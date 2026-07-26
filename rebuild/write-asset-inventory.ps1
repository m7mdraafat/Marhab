param(
    [string]$MirrorRoot,
    [string]$JsonPath,
    [string]$CsvPath,
    [switch]$IncludeHash,
    [switch]$ValidateHeaders
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($MirrorRoot)) {
    $MirrorRoot = Join-Path $repoRoot "assets\cdn-mirror"
}
if ([string]::IsNullOrWhiteSpace($JsonPath)) {
    $JsonPath = Join-Path $repoRoot "assets\reports\asset-inventory.json"
}
if ([string]::IsNullOrWhiteSpace($CsvPath)) {
    $CsvPath = Join-Path $repoRoot "assets\reports\asset-inventory.csv"
}

function Test-AssetFile {
    param([System.IO.FileInfo]$File)

    if ($File.Length -le 0) {
        return "empty"
    }

    $extension = $File.Extension.ToLowerInvariant()
    if ($extension -eq ".swf") {
        $stream = [System.IO.File]::OpenRead($File.FullName)
        try {
            if ($stream.Length -lt 3) { return "invalid-swf-header" }
            $bytes = New-Object byte[] 3
            [void]$stream.Read($bytes, 0, 3)
            $signature = [System.Text.Encoding]::ASCII.GetString($bytes)
            if ($signature -in @("FWS", "CWS", "ZWS")) { return "valid" }
            return "invalid-swf-header"
        }
        finally {
            $stream.Dispose()
        }
    }

    if ($extension -eq ".png") {
        $stream = [System.IO.File]::OpenRead($File.FullName)
        try {
            if ($stream.Length -lt 8) { return "invalid-png-header" }
            $bytes = New-Object byte[] 8
            [void]$stream.Read($bytes, 0, 8)
            $expected = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
            for ($index = 0; $index -lt $expected.Length; $index++) {
                if ($bytes[$index] -ne $expected[$index]) { return "invalid-png-header" }
            }
            return "valid"
        }
        finally {
            $stream.Dispose()
        }
    }

    return "valid"
}

function Get-AssetCategory {
    param([string]$UrlPath)

    $normalized = $UrlPath.Replace("\", "/").ToLowerInvariant()
    if ($normalized -like "/global/dynamic/rooms/*") { return "dynamic-room" }
    if ($normalized -like "/global/dynamic/panels/*") { return "dynamic-panel" }
    if ($normalized -like "/global/dynamic/extensions/*") { return "dynamic-extension" }
    if ($normalized -like "/global/dynamic/core/*") { return "dynamic-core" }
    if ($normalized -like "/global/static/items/clothes/*") { return "item-clothes" }
    if ($normalized -like "/global/static/items/inventory/*") { return "item-inventory" }
    if ($normalized -like "/global/static/items/smiley/*") { return "item-smiley" }
    if ($normalized -like "/global/static/bots/*") { return "bot" }
    if ($normalized -like "/global/static/pubs/*") { return "ad-bot" }
    if ($normalized -like "/global/static/data/*") { return "data" }
    if ($normalized -like "/global/static/locale/*") { return "locale" }
    return "other"
}

if (-not (Test-Path -LiteralPath $MirrorRoot)) {
    throw "Mirror root does not exist: $MirrorRoot"
}

$inventory = Get-ChildItem -LiteralPath $MirrorRoot -Recurse -File | Where-Object {
    [System.IO.Path]::GetRelativePath($MirrorRoot, $_.FullName) -match '^global[\\/]'
} | Sort-Object FullName | ForEach-Object {
    $relativePath = [System.IO.Path]::GetRelativePath($MirrorRoot, $_.FullName).Replace("\", "/")
    $urlPath = "/$relativePath"
    $localPath = [System.IO.Path]::GetRelativePath($repoRoot, $_.FullName).Replace("\", "/")
    $validation = "not-checked"
    if ($ValidateHeaders) {
        $validation = Test-AssetFile -File $_
    }

    $sha256 = ""
    if ($IncludeHash) {
        $sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant()
    }

    [pscustomobject][ordered]@{
        urlPath = $urlPath
        localPath = $localPath
        category = Get-AssetCategory -UrlPath $urlPath
        extension = $_.Extension.ToLowerInvariant().TrimStart(".")
        sizeBytes = $_.Length
        sha256 = $sha256
        valid = ($validation -ne "empty" -and $validation -notlike "invalid-*")
        validation = $validation
    }
}

$report = [ordered]@{
    generatedAt = (Get-Date).ToString("o")
    mirrorRoot = $MirrorRoot
    totalFiles = @($inventory).Count
    totalBytes = (@($inventory) | Measure-Object sizeBytes -Sum).Sum
    byCategory = @($inventory) | Group-Object category | Sort-Object Name | ForEach-Object {
        [pscustomobject][ordered]@{
            category = $_.Name
            files = $_.Count
            bytes = ($_.Group | Measure-Object sizeBytes -Sum).Sum
        }
    }
    files = $inventory
}

foreach ($path in @($JsonPath, $CsvPath)) {
    $directory = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
}

$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $JsonPath -Encoding UTF8
@($inventory) | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8

Write-Host "Asset inventory written"
Write-Host "  Mirror root: $MirrorRoot"
Write-Host "  JSON:        $JsonPath"
Write-Host "  CSV:         $CsvPath"
Write-Host "  Files:       $($report.totalFiles)"
Write-Host "  Bytes:       $($report.totalBytes)"