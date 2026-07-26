[CmdletBinding()]
param(
    [string]$LegacyRoot = "C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\MyGame",
    [switch]$IncludeProbeSubset,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$cdnRoot = Join-Path $repoRoot "assets\cdn"
$inventoryRoot = Join-Path $LegacyRoot "rebuild\inventory"

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Get-DirectoryStats {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return [pscustomobject]@{ Count = 0; Bytes = 0 }
    }

    $measure = Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum

    $bytes = 0
    if ($null -ne $measure.Sum) {
        $bytes = [int64]$measure.Sum
    }

    return [pscustomobject]@{
        Count = [int]$measure.Count
        Bytes = $bytes
    }
}

function Invoke-Robocopy {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Host "SKIP missing $Label source: $Source"
        return [pscustomobject]@{ Label = $Label; Source = $Source; Destination = $Destination; Status = "Missing"; ExitCode = $null }
    }

    Ensure-Directory -Path $Destination

    $before = Get-DirectoryStats -Path $Destination
    Write-Host "PROMOTE [$Label] $Source -> $Destination"

    if ($DryRun) {
        return [pscustomobject]@{ Label = $Label; Source = $Source; Destination = $Destination; Status = "DryRun"; ExitCode = 0 }
    }

    & robocopy $Source $Destination /E /MT:8 /R:2 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    $exitCode = $LASTEXITCODE

    if ($exitCode -gt 7) {
        throw "robocopy failed for $Label with exit code $exitCode"
    }

    $after = Get-DirectoryStats -Path $Destination
    return [pscustomobject]@{
        Label = $Label
        Source = $Source
        Destination = $Destination
        Status = "Promoted"
        ExitCode = $exitCode
        FilesBefore = $before.Count
        FilesAfter = $after.Count
        BytesBefore = $before.Bytes
        BytesAfter = $after.Bytes
    }
}

function Promote-FilesMirror {
    param(
        [string]$FilesRoot,
        [string]$Label
    )

    $results = @()

    if (-not (Test-Path -LiteralPath $FilesRoot)) {
        $results += [pscustomobject]@{ Label = $Label; Source = $FilesRoot; Destination = $cdnRoot; Status = "Missing"; ExitCode = $null }
        return $results
    }

    $directGlobal = Join-Path $FilesRoot "global"
    if (Test-Path -LiteralPath $directGlobal) {
        $results += Invoke-Robocopy -Source $directGlobal -Destination (Join-Path $cdnRoot "global") -Label $Label
        return $results
    }

    $hostRoots = Get-ChildItem -LiteralPath $FilesRoot -Directory -ErrorAction SilentlyContinue
    foreach ($hostRoot in $hostRoots) {
        $hostGlobal = Join-Path $hostRoot.FullName "global"
        if (Test-Path -LiteralPath $hostGlobal) {
            $results += Invoke-Robocopy -Source $hostGlobal -Destination (Join-Path $cdnRoot "global") -Label "$Label/$($hostRoot.Name)"
        }
        else {
            Write-Host "SKIP [$Label] no global folder under $($hostRoot.FullName)"
        }
    }

    return $results
}

if (-not (Test-Path -LiteralPath $inventoryRoot)) {
    throw "Inventory root not found: $inventoryRoot"
}

Ensure-Directory -Path $cdnRoot

$mirrors = @(
    [pscustomobject]@{ Label = "vf-assets"; Path = Join-Path $inventoryRoot "vf-assets\files" },
    [pscustomobject]@{ Label = "room-assets"; Path = Join-Path $inventoryRoot "room-assets\files" },
    [pscustomobject]@{ Label = "item-assets-ifile1366"; Path = Join-Path $inventoryRoot "item-assets-ifile1366\files" }
)

if ($IncludeProbeSubset) {
    $mirrors += [pscustomobject]@{ Label = "item-assets-probe-subset"; Path = Join-Path $inventoryRoot "item-assets\files" }
}

$results = @()
foreach ($mirror in $mirrors) {
    $results += Promote-FilesMirror -FilesRoot $mirror.Path -Label $mirror.Label
}

Write-Host ""
Write-Host "CDN asset promotion complete: $cdnRoot"
$results | Format-Table Label, Status, ExitCode, FilesBefore, FilesAfter, BytesBefore, BytesAfter -AutoSize

Write-Host ""
Write-Host "Current CDN totals:"
Get-DirectoryStats -Path $cdnRoot | Format-List