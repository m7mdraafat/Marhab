[CmdletBinding()]
param(
    [switch]$IncludeRooms,
    [switch]$Force,
    [string]$VfPath = (Join-Path $PSScriptRoot 'inventory\room-assets\vf.19910'),
    [string]$OutRoot = (Join-Path $PSScriptRoot 'inventory\vf-assets')
)

$ErrorActionPreference = 'Stop'

function Read-VfCatalog {
    param([Parameter(Mandatory)][string]$Path)

    $raw = (Get-Content -Raw -Encoding UTF8 $Path).Trim()
    $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($raw))
    foreach ($pair in ($decoded -split '\|')) {
        $separator = $pair.IndexOf('=')
        if ($separator -le 0) {
            continue
        }

        $assetPath = $pair.Substring($separator + 1)
        [pscustomobject]@{
            key = $pair.Substring(0, $separator)
            assetPath = $assetPath
            prefix = ($assetPath -split '/')[0]
        }
    }
}

function Get-CandidateUrls {
    param(
        [Parameter(Mandatory)][string]$AssetPath,
        [Parameter(Mandatory)][string]$Prefix
    )

    switch ($Prefix) {
        'rooms' { @("http://xo.newmarhab.net/global/dynamic/$AssetPath.swf") }
        'panels' { @("http://xo.newmarhab.net/global/dynamic/$AssetPath.swf") }
        'extensions' { @("http://xo.newmarhab.net/global/dynamic/$AssetPath.swf") }
        'core' { @("http://xo.newmarhab.net/global/dynamic/$AssetPath", "http://xo.newmarhab.net/global/dynamic/$AssetPath.swf") }
        'data' { @("http://xo.newmarhab.net/global/static/$AssetPath", "http://xo.newmarhab.net/global/dynamic/$AssetPath") }
        'locale' { @("http://xo.newmarhab.net/global/static/$AssetPath", "http://xo.newmarhab.net/global/dynamic/$AssetPath") }
        default { @("http://xo.newmarhab.net/global/dynamic/$AssetPath") }
    }
}

function Convert-UrlToMirrorPath {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$MirrorRoot
    )

    $uri = [Uri]$Url
    Join-Path $MirrorRoot ($uri.AbsolutePath.TrimStart('/') -replace '/', '\')
}

if (-not (Test-Path $VfPath)) {
    throw "vf.19910 not found: $VfPath"
}

$mirrorRoot = Join-Path $OutRoot 'files'
New-Item -ItemType Directory -Force -Path $OutRoot, $mirrorRoot | Out-Null

$assets = Read-VfCatalog $VfPath
if (-not $IncludeRooms) {
    $assets = $assets | Where-Object { $_.prefix -ne 'rooms' }
}

$report = foreach ($asset in $assets) {
    $status = 'failed'
    $source = ''
    $selectedUrl = ''
    $mirrorPath = ''
    $size = 0L
    $errorMessage = ''

    foreach ($url in (Get-CandidateUrls -AssetPath $asset.assetPath -Prefix $asset.prefix)) {
        $candidateMirrorPath = Convert-UrlToMirrorPath -Url $url -MirrorRoot $mirrorRoot
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $candidateMirrorPath) | Out-Null

        if ((Test-Path $candidateMirrorPath) -and -not $Force) {
            $status = 'present'
            $source = 'mirror'
            $selectedUrl = $url
            $mirrorPath = $candidateMirrorPath
            $size = (Get-Item $candidateMirrorPath).Length
            $errorMessage = ''
            break
        }

        try {
            Invoke-WebRequest -Uri $url -OutFile $candidateMirrorPath -TimeoutSec 20 -ErrorAction Stop | Out-Null
            $status = 'downloaded'
            $source = 'cdn'
            $selectedUrl = $url
            $mirrorPath = $candidateMirrorPath
            $size = (Get-Item $candidateMirrorPath).Length
            $errorMessage = ''
            break
        } catch {
            $errorMessage = $_.Exception.Message
            if (Test-Path $candidateMirrorPath) {
                Remove-Item $candidateMirrorPath -Force
            }
        }
    }

    [pscustomobject]@{
        key = $asset.key
        prefix = $asset.prefix
        assetPath = $asset.assetPath
        url = $selectedUrl
        status = $status
        source = $source
        size = $size
        mirrorPath = $mirrorPath
        error = $errorMessage
    }
}

$report | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutRoot 'vf-assets.report.csv')
$report | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 (Join-Path $OutRoot 'vf-assets.report.json')
($report | Where-Object { $_.url } | Select-Object -ExpandProperty url) |
    Set-Content -Encoding UTF8 (Join-Path $OutRoot 'vf-assets.urls.txt')
($report | Where-Object { $_.status -eq 'failed' } | Select-Object key, prefix, assetPath, error) |
    ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 (Join-Path $OutRoot 'vf-assets.failed.json')

$report | Group-Object prefix, status | Sort-Object Name | ForEach-Object {
    '{0,-24} {1,4}' -f $_.Name, $_.Count
}
Write-Host "output               : $OutRoot"