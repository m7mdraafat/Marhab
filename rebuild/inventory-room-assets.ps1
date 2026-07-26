[CmdletBinding()]
param(
    [switch]$Download,
    [switch]$Force,
    [string]$CdnBase = 'http://xo.newmarhab.net/global/dynamic',
    [string]$OutRoot = (Join-Path $PSScriptRoot 'inventory\room-assets'),
    [string]$VfPath = (Join-Path $PSScriptRoot 'inventory\room-assets\vf.19910')
)

$ErrorActionPreference = 'Stop'

function Expand-RoomToken {
    param([Parameter(Mandatory)][string]$Token)

    $normalized = $Token -replace '[–—]', '-'

    if ($normalized -match '^([A-Za-z_]+?)(\d+)-([A-Za-z_]*)(\d+)$') {
        $startPrefix = $Matches[1]
        $startNumberText = $Matches[2]
        $endPrefix = $Matches[3]
        $endNumberText = $Matches[4]
        if ([string]::IsNullOrWhiteSpace($endPrefix)) {
            $endPrefix = $startPrefix
        }
        if ($startPrefix -ne $endPrefix) {
            throw "Cannot expand mixed-prefix room range: $Token"
        }

        $width = $startNumberText.Length
        $startNumber = [int]$startNumberText
        $endNumber = [int]$endNumberText
        if ($endNumber -lt $startNumber) {
            throw "Cannot expand descending room range: $Token"
        }

        for ($i = $startNumber; $i -le $endNumber; $i++) {
            "$startPrefix$($i.ToString(('0' * $width)))"
        }
        return
    }

    if ($normalized -match '^(.+_)([a-z])-([a-z])$') {
        $prefix = $Matches[1]
        $startCode = [int][char]$Matches[2]
        $endCode = [int][char]$Matches[3]
        if ($endCode -lt $startCode) {
            throw "Cannot expand descending letter range: $Token"
        }

        for ($code = $startCode; $code -le $endCode; $code++) {
            "$prefix$([char]$code)"
        }
        return
    }

    $normalized
}

function Add-Rooms {
    param(
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string[]]$Tokens
    )

    foreach ($token in $Tokens) {
        foreach ($roomKey in (Expand-RoomToken $token)) {
            [pscustomobject]@{
                category = $Category
                roomKey = $roomKey
                swfPath = "rooms/$roomKey.swf"
            }
        }
    }
}

function Read-VfRoomCatalog {
    param([Parameter(Mandatory)][string]$Path)

    $raw = (Get-Content -Raw -Encoding UTF8 $Path).Trim()
    $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($raw))
    Set-Content -Encoding UTF8 -Path (Join-Path (Split-Path -Parent $Path) 'vf.19910.decoded.txt') -Value $decoded

    foreach ($pair in ($decoded -split '\|')) {
        $separator = $pair.IndexOf('=')
        if ($separator -le 0) {
            continue
        }

        $roomKey = $pair.Substring(0, $separator)
        $assetPath = $pair.Substring($separator + 1)
        if ($assetPath -notlike 'rooms/*') {
            continue
        }

        [pscustomobject]@{
            category = 'vf.19910'
            roomKey = $roomKey
            swfPath = $assetPath
        }
    }
}

$rooms = @()
$rooms += Add-Rooms 'streets-public' @(
    'street01-street13', 'street05Metro', 'testStreet', 'newStreet01', 'startpoint',
    'calleComercio', 'calledelSol', 'calleMarina01', 'calleMarina02', 'districtOne',
    'plazaMayor', 'plazaMayorNorte', 'plazaMayorSur', 'presidency', 'municipality',
    'pier', 'pierBeach', 'olimposPier', 'olimposMetro', 'nautilusPier', 'titanicaPier'
)
$rooms += Add-Rooms 'transportation' @(
    'airport', 'airplane', 'ferryboat', 'ship01', 'nautilusShip', 'spaceShip',
    'sanalikaXRocket', 'sanalikaXTransfer', 'sanalikaXMarsTransfer', 'engineRoom'
)
$rooms += Add-Rooms 'shops' @(
    'bank', 'realEstate', 'stockMarket', 'market', 'petshop', 'pharmacy', 'optika',
    'hatShop', 'toyStore', 'giftShop', 'candyShop', 'littlestPetShop', 'carShop',
    'modShop', 'musicMarket', 'secondHandShop', 'RoomShopPanel'
)
$rooms += Add-Rooms 'cafes-restaurants' @(
    'blueCafe', 'burgerika', 'burgerikaTerrace', 'cafetoria', 'cafetoriaWc', 'retroCafe',
    'restaurant', 'lubnanRestaurant', 'cafeMarina', 'cafeFaruk', 'cafeGradrey',
    'cafeRestoran', 'sanalikaTrCafe', 'cinemaCafe', 'summerCafe', 'gourmetPark'
)
$rooms += Add-Rooms 'hair-beauty' @(
    'hairdresser', 'diamondHairdresser', 'ottomanHairdresser', 'sanalikaTrKuafor',
    'hairFair', 'style', 'styleDome', 'dresser', 'fashionHouse'
)
$rooms += Add-Rooms 'entertainment-games' @(
    'bowling', 'billiards', 'cinema', 'cinemaSaloon01-04', 'comedy', 'amfiTheater',
    'iceRink', 'fitness', 'sportika', 'lootALot', 'gamerRoom', 'oyunika', 'klakk'
)
$rooms += Add-Rooms 'hotels-pools' @(
    'hotelLobby', 'goldenHorseHotelLobby', 'goldenHorseHotelPool', 'albusLobby',
    'albusSpa', 'albus01-04', 'bungalow', 'bungalow01', 'vipPool', 'sanalikaTrHavuz'
)
$rooms += Add-Rooms 'themed-events' @(
    'olimpos01-10', 'olimpos10Carnival', 'olimpos10Ramadan', 'olimposPirate',
    'farEast01-04', 'iceAge01-02', 'snowWorld01-02', 'summerCamp', 'summerTent01-02',
    'ottomanTent', 'partyIsland', 'partyIsland02', 'partyIsland03', 'pierBeach',
    'space', 'space01', 'sanalikaXHouse', 'sanalikaXMars', 'tropika', 'tortuga',
    'swamp', 'cave', 'mushRoom', 'galata'
)
$rooms += Add-Rooms 'academic-studios' @(
    'academy', 'academyCanteen', 'academyClass', 'academyLab', 'class01', 'library',
    'artStudio', 'painterStudio', 'greenStudio', 'studio', 'sculptureClub',
    'culturalCenter', 'mediaCenterLobby', 'mediaCenterMeetingRoom', 'mediaCenterRadio',
    'youtuberRoom'
)
$rooms += Add-Rooms 'health-services' @('hospital01', 'klinika', 'fortuneTeller')
$rooms += Add-Rooms 'farm-nature' @(
    'lazBakkalFarm', 'botanika', 'landelike01', 'landelike02', 'anemon', 'anemon01',
    'yosun01_a-e', 'yosun02_a-f', 'yosun03_a-h', 'yosunLobby'
)
$rooms += Add-Rooms 'user-house-templates' @(
    'cafe01-09', 'cafeGarage01-03', 'garage01', 'office01', 'office02', 'ghhotel01',
    'basfHome', 'cinemaHouse', 'mySpace01-03', 'sevgi01-04', 'legendRon', 'robins',
    'speedy', 'styleRoom', 'strippedRoom', 'tronTerrace', 'monitte', 'monitteLounge',
    'carpeModo', 'juguete'
)
$rooms += Add-Rooms 'cinema-exhibitions' @('exhibition', 'basfExhibition', 'hallofFame', 'artifika')
$rooms += Add-Rooms 'misc-events' @(
    'kido20180901-20180907', 'global01-07', 'nriettaLobby', 'clubBuilding', 'travertine'
)

$rooms = $rooms | Sort-Object roomKey -Unique
if (Test-Path $VfPath) {
    $rooms = Read-VfRoomCatalog $VfPath | Sort-Object roomKey -Unique
} else {
    Write-Warning "vf.19910 not found at $VfPath; using the approximate seed list instead."
}

$cacheRoot = Join-Path $env:APPDATA 'com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net\global\dynamic'
$mirrorRoot = Join-Path $OutRoot 'files\global\dynamic'
New-Item -ItemType Directory -Force -Path $OutRoot, $mirrorRoot | Out-Null

$report = foreach ($room in $rooms) {
    $relativeSwfPath = if ($room.swfPath -like '*.swf') { $room.swfPath } else { "$($room.swfPath).swf" }
    $cachePath = Join-Path $cacheRoot ($relativeSwfPath -replace '/', '\')
    $mirrorPath = Join-Path $mirrorRoot ($relativeSwfPath -replace '/', '\')
    $url = ($CdnBase.TrimEnd('/') + '/' + $relativeSwfPath)
    $status = 'missing'
    $source = ''
    $size = 0L
    $errorMessage = ''

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $mirrorPath) | Out-Null

    if ((Test-Path $mirrorPath) -and -not $Force) {
        $status = 'present'
        $source = 'mirror'
        $size = (Get-Item $mirrorPath).Length
    } elseif ((Test-Path $cachePath) -and -not $Force) {
        Copy-Item -Path $cachePath -Destination $mirrorPath -Force
        $status = 'present'
        $source = 'asset-cache'
        $size = (Get-Item $mirrorPath).Length
    } elseif ($Download) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $mirrorPath -TimeoutSec 20 -ErrorAction Stop | Out-Null
            $status = 'downloaded'
            $source = 'cdn'
            $size = (Get-Item $mirrorPath).Length
        } catch {
            $status = 'failed'
            $errorMessage = $_.Exception.Message
            if (Test-Path $mirrorPath) {
                Remove-Item $mirrorPath -Force
            }
        }
    }

    [pscustomobject]@{
        category = $room.category
        roomKey = $room.roomKey
        swfPath = $room.swfPath
        url = $url
        status = $status
        source = $source
        size = $size
        cachePath = $cachePath
        mirrorPath = $mirrorPath
        error = $errorMessage
    }
}

$catalog = $rooms | Select-Object category, roomKey, swfPath
$catalog | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutRoot 'room-catalog.seed.csv')
$catalog | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 (Join-Path $OutRoot 'room-catalog.seed.json')
$report | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutRoot 'room-assets.report.csv')
$report | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 (Join-Path $OutRoot 'room-assets.report.json')
$report.url | Set-Content -Encoding UTF8 (Join-Path $OutRoot 'rooms.urls.txt')
($report | Where-Object { $_.status -in @('present', 'downloaded') } | Select-Object -ExpandProperty roomKey) |
    Set-Content -Encoding UTF8 (Join-Path $OutRoot 'present-room-keys.txt')
($report | Where-Object { $_.status -in @('missing', 'failed') } | Select-Object -ExpandProperty roomKey) |
    Set-Content -Encoding UTF8 (Join-Path $OutRoot 'missing-room-keys.txt')

$presentCount = @($report | Where-Object { $_.status -in @('present', 'downloaded') }).Count
$missingCount = @($report | Where-Object { $_.status -eq 'missing' }).Count
$failedCount = @($report | Where-Object { $_.status -eq 'failed' }).Count

Write-Host "room catalog entries : $($rooms.Count)"
Write-Host "present/downloaded   : $presentCount"
Write-Host "missing              : $missingCount"
Write-Host "failed               : $failedCount"
Write-Host "output               : $OutRoot"
if (-not $Download) {
    Write-Host "network              : skipped (pass -Download to fetch missing URLs)"
}