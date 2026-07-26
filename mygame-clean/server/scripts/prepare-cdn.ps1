[CmdletBinding()]
param(
    [string]$LegacyRoot = "C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\MyGame",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$cdnRoot = Join-Path $repoRoot "assets\cdn"

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Copy-IfExists {
    param(
        [string]$Source,
        [string]$Destination,
        [switch]$Required
    )

    Ensure-Directory -Path (Split-Path $Destination -Parent)

    if (Test-Path -LiteralPath $Source) {
        if ($Force -or -not (Test-Path -LiteralPath $Destination)) {
            Copy-Item -LiteralPath $Source -Destination $Destination -Force
            Write-Host "COPIED $Source -> $Destination"
        }
        else {
            Write-Host "SKIP existing $Destination"
        }

        return $true
    }

    if ($Required) {
        Write-Warning "Missing required source: $Source"
    }
    else {
        Write-Host "MISS optional source: $Source"
    }

    return $false
}

function Write-PlaceholderPng {
    param([string]$Destination)

    Ensure-Directory -Path (Split-Path $Destination -Parent)

    if ((Test-Path -LiteralPath $Destination) -and -not $Force) {
        Write-Host "SKIP existing $Destination"
        return
    }

    # 1x1 transparent PNG
    $base64 =
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAFgwJ/l+fK9QAAAABJRU5ErkJggg=="

    [IO.File]::WriteAllBytes($Destination, [Convert]::FromBase64String($base64))
    Write-Host "WROTE placeholder PNG $Destination"
}

function Write-PlaceholderMo {
    param([string]$Destination)

    Ensure-Directory -Path (Split-Path $Destination -Parent)

    if ((Test-Path -LiteralPath $Destination) -and -not $Force) {
        Write-Host "SKIP existing $Destination"
        return
    }

    # Minimal GNU gettext .mo file with zero entries.
    # Magic: 0x950412de, revision 0, string count 0.
    $bytes = [byte[]]@(
        0xde, 0x12, 0x04, 0x95,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x1c, 0x00, 0x00, 0x00,
        0x1c, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x1c, 0x00, 0x00, 0x00
    )

    [IO.File]::WriteAllBytes($Destination, $bytes)
    Write-Host "WROTE placeholder MO $Destination"
}

Ensure-Directory -Path $cdnRoot

$dataRoot = Join-Path $cdnRoot "global\static\data"
$localeRoot = Join-Path $cdnRoot "global\static\locale"
$assetsRoot = Join-Path $cdnRoot "global\static\assets"

Ensure-Directory -Path $dataRoot
Ensure-Directory -Path $localeRoot
Ensure-Directory -Path $assetsRoot

$ifileSource = Join-Path $LegacyRoot "rebuild\inventory\vf-assets\files\global\static\data\ifile.1366"
$vfSource = Join-Path $LegacyRoot "rebuild\inventory\vf-assets\files\global\static\data\vf.403"

$ifileDest = Join-Path $dataRoot "ifile.1366"
$vfDest = Join-Path $dataRoot "vf.403"
$arMoDest = Join-Path $localeRoot "ar.mo"
$mainBgDest = Join-Path $assetsRoot "mainBackGround.png"
$mainBgNDest = Join-Path $assetsRoot "mainBackGroundN.png"

Copy-IfExists -Source $ifileSource -Destination $ifileDest -Required
Copy-IfExists -Source $vfSource -Destination $vfDest -Required

# Try to find real versions first.
$possibleMoSources = @(
    (Join-Path $LegacyRoot "rebuild\runtime\ar.mo"),
    (Join-Path $LegacyRoot "rebuild\inventory\vf-assets\files\global\static\locale\ar.mo"),
    (Join-Path $LegacyRoot "rebuild\inventory\vf-assets\files\global\static\locale\ar_AR.585.mo")
)

$copiedMo = $false
foreach ($source in $possibleMoSources) {
    if (Copy-IfExists -Source $source -Destination $arMoDest) {
        $copiedMo = $true
        break
    }
}

if (-not $copiedMo) {
    Write-PlaceholderMo -Destination $arMoDest
}

$possibleBgSources = @(
    (Join-Path $LegacyRoot "rebuild\runtime\loader-bg.jpg"),
    (Join-Path $LegacyRoot "images\1007.png"),
    (Join-Path $LegacyRoot "client-recovered\launcher\src\_assets\1007___ASSET__assets_background_png.png")
)

$copiedBg = $false
foreach ($source in $possibleBgSources) {
    if (Copy-IfExists -Source $source -Destination $mainBgDest) {
        $copiedBg = $true
        break
    }
}

if (-not $copiedBg) {
    Write-PlaceholderPng -Destination $mainBgDest
}

if ((Test-Path -LiteralPath $mainBgDest) -and ($Force -or -not (Test-Path -LiteralPath $mainBgNDest))) {
    Copy-Item -LiteralPath $mainBgDest -Destination $mainBgNDest -Force
    Write-Host "COPIED background fallback $mainBgDest -> $mainBgNDest"
}

Write-Host ""
Write-Host "CDN prepared at $cdnRoot"
Write-Host "Expected files:"
Get-Item `
    $ifileDest, `
    $vfDest, `
    $arMoDest, `
    $mainBgDest, `
    $mainBgNDest `
    -ErrorAction SilentlyContinue |
    Select-Object FullName, Length, LastWriteTime |
    Format-Table -AutoSize