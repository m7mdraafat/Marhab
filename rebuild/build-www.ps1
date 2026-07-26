# build-www.ps1 — assemble a complete www doc root the client can hit.
#
# Output: <repo>/server/www/
#   global/dynamic/{core,extensions,panels,rooms}/*.swf      (catalog-resolved)
#   global/static/data/{ifile.1366, vf.403}                   (active catalogs)
#   global/static/items/{clothes, inventory}/*                (static-list)
#   global/static/assets/*                                    (loader bg)
#   global/static/locale/ar.mo                                (generated)
#   crossdomain.xml                                           (Flash policy)
#   build-report.json                                         (audit trail)
#
# Sources (verified — see /memories/repo/mygame-asset-pipeline.md):
#   rebuild/inventory/room-assets/files/global/**             — 254 room SWFs
#   rebuild/inventory/vf-assets/files/global/**               — 85 panel/ext/core + ifile/vf
#   rebuild/inventory/item-assets-ifile1366/files/xo.newmarhab.net/global/**
#                                                             — 14,232 item assets
#   rebuild/inventory/item-assets/files/xo.newmarhab.net/global/**
#                                                             — curated cloth subset (merge)
#   %APPDATA%\com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net\global\static\assets\**
#                                                             — loader background PNGs
#
# Run from anywhere; no parameters needed for the standard build.

[CmdletBinding()]
param(
    [string]$OutRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'server\www'),
    [switch]$Clean,
    [switch]$NoLocale,
    [switch]$NoLiveCache
)

$ErrorActionPreference = 'Stop'
$repoRoot   = Split-Path -Parent $PSScriptRoot
$invRoot    = Join-Path $repoRoot 'rebuild\inventory'
$liveCache  = Join-Path $env:APPDATA 'com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net\global'
$globalRoot = Join-Path $OutRoot 'global'
$reportPath = Join-Path $OutRoot 'build-report.json'

# Sources: (rooted-at, strip-prefix). Order matters; later sources overwrite earlier ones.
$sources = @(
    @{ Name='rooms';        Root="$invRoot\room-assets\files";              Strip='' }
    @{ Name='vf-assets';    Root="$invRoot\vf-assets\files";                Strip='' }
    @{ Name='items-bulk';   Root="$invRoot\item-assets-ifile1366\files";    Strip='xo.newmarhab.net\' }
    @{ Name='items-curated';Root="$invRoot\item-assets\files";              Strip='xo.newmarhab.net\' }
)
if (-not $NoLiveCache -and (Test-Path -LiteralPath $liveCache)) {
    # only pull the static/assets subtree from the live cache — everything else
    # has a better source above.
    $sources += @{ Name='live-static-assets'; Root=(Split-Path -Parent $liveCache); Strip=''; Filter='global\static\assets\*' }
}

# --- helpers -----------------------------------------------------------------

$pngMagic = [byte[]](137,80,78,71,13,10,26,10)
$jpegMagic = [byte[]](0xFF,0xD8,0xFF)
function Test-AssetSignature {
    # Returns one of: 'ok' (recognized magic), 'unknown' (non-empty but signature
    # doesn't match what the filename implies — we still copy these because the
    # original CDN served encrypted SWFs and JPEG-as-.png loader backgrounds),
    # 'empty' (zero-byte; always skipped).
    param([System.IO.FileInfo]$File)
    if ($File.Length -le 0) { return 'empty' }
    $ext = $File.Extension.ToLowerInvariant()
    if ($ext -notin '.swf','.png') { return 'ok' }
    $fs = [System.IO.File]::OpenRead($File.FullName)
    try {
        if ($ext -eq '.swf') {
            $buf = New-Object byte[] 3
            [void]$fs.Read($buf,0,3)
            if (([System.Text.Encoding]::ASCII.GetString($buf)) -in 'FWS','CWS','ZWS') { return 'ok' }
            return 'unknown'   # likely an encrypted SWF — ship as-is
        } else {
            $buf = New-Object byte[] 8
            [void]$fs.Read($buf,0,8)
            $isPng = $true
            for ($i=0; $i -lt 8; $i++) { if ($buf[$i] -ne $pngMagic[$i]) { $isPng = $false; break } }
            if ($isPng) { return 'ok' }
            $isJpeg = ($buf[0] -eq $jpegMagic[0] -and $buf[1] -eq $jpegMagic[1] -and $buf[2] -eq $jpegMagic[2])
            if ($isJpeg) { return 'unknown' }   # JPEG content under a .png name; ship as-is
            return 'unknown'
        }
    } finally { $fs.Dispose() }
}

function Resolve-DestinationPath {
    param([string]$SourceRoot, [string]$FilePath, [string]$StripPrefix)
    $rel = $FilePath.Substring($SourceRoot.Length).TrimStart('\','/')
    if ($StripPrefix -and $rel.StartsWith($StripPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $rel = $rel.Substring($StripPrefix.Length).TrimStart('\','/')
    }
    # every keeper lives under global/...
    if (-not $rel.StartsWith('global\', [System.StringComparison]::OrdinalIgnoreCase) -and
        -not $rel.StartsWith('global/', [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }
    return Join-Path $OutRoot $rel
}

function Write-ArabicLocaleMo {
    param([string]$Path)
    $entries = [ordered]@{
        '' = "Content-Type: text/plain; charset=UTF-8`nLanguage: ar`nPlural-Forms: nplurals=2; plural=(n != 1);`n"
        # AvatarCreatePanel
        'avatarCreateButton'      = 'إنشاء'
        'avatarCreateHeader'      = 'إنشاء شخصية'
        'avatarCreateInfo'        = 'اختر مظهر شخصيتك واكتب اسمك'
        'avatarEditButton'        = 'حفظ'
        'avatarEditHeader'        = 'تعديل الشخصية'
        'avatarEditInfo'          = 'اختر مظهر شخصيتك'
        'avatarNameLengthError'   = 'يجب أن يكون الاسم بين 3 و20 حرفا'
        'Jack The One'            = 'لاعب جديد'
        'nickChangeFormatError'   = 'الاسم يحتوي على رموز غير مسموحة'
        # GuestPanel (kept in case a future flow re-opens it)
        'guestHeader'             = 'مرحبا بك'
        'guestLogin'              = 'لديك حساب؟ سجل الدخول'
        'guestBtnLogin'           = 'تسجيل الدخول'
        'guestRegister'           = 'ليس لديك حساب؟ سجل الآن'
        'guestBtnRegister'        = 'تسجيل جديد'
        'guestContinue'           = 'متابعة كزائر'
        'guestBtnContinue'        = 'متابعة'
        # Common HUD / error UI
        'Loading Client'          = 'جاري تحميل اللعبة'
        'Loading Client Failed'   = 'فشل تحميل اللعبة'
        'Disconnected'            = 'انقطع الاتصال'
        'LOGIN_ERROR_TITLE'       = 'خطأ في تسجيل الدخول'
        'errorDisconnectInactivity' = 'تم قطع الاتصال بسبب عدم النشاط'
        'errorDisconnectOther'    = 'تم تسجيل الدخول من جهاز آخر'
    }
    $sorted = @($entries.GetEnumerator() | Sort-Object Name)
    $count  = $sorted.Count
    $enc    = [System.Text.Encoding]::UTF8
    $oBytes = @($sorted | ForEach-Object { ,($enc.GetBytes([string]$_.Key)) })
    $tBytes = @($sorted | ForEach-Object { ,($enc.GetBytes([string]$_.Value)) })

    $hdr = 28
    $oTbl = $hdr
    $tTbl = $oTbl + ($count * 8)
    $strOffset = $tTbl + ($count * 8)
    $cursor = $strOffset
    $oMeta = for ($i=0; $i -lt $count; $i++) { $m=[pscustomobject]@{Length=$oBytes[$i].Length;Offset=$cursor}; $cursor += $oBytes[$i].Length+1; $m }
    $tMeta = for ($i=0; $i -lt $count; $i++) { $m=[pscustomobject]@{Length=$tBytes[$i].Length;Offset=$cursor}; $cursor += $tBytes[$i].Length+1; $m }

    $ms = [System.IO.MemoryStream]::new()
    $bw = [System.IO.BinaryWriter]::new($ms)
    try {
        foreach ($v in @(2500072158, 0, $count, $oTbl, $tTbl, 0, $cursor)) { $bw.Write([uint32]$v) }
        foreach ($m in $oMeta) { $bw.Write([uint32]$m.Length); $bw.Write([uint32]$m.Offset) }
        foreach ($m in $tMeta) { $bw.Write([uint32]$m.Length); $bw.Write([uint32]$m.Offset) }
        foreach ($b in $oBytes) { $bw.Write($b); $bw.Write([byte]0) }
        foreach ($b in $tBytes) { $bw.Write($b); $bw.Write([byte]0) }
        $bw.Flush()
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
        [System.IO.File]::WriteAllBytes($Path, $ms.ToArray())
    } finally { $bw.Dispose(); $ms.Dispose() }
}

$crossdomainXml = @'
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <site-control permitted-cross-domain-policies="master-only"/>
  <allow-access-from domain="*" secure="false"/>
</cross-domain-policy>
'@

# --- 1. prepare output root --------------------------------------------------

if ($Clean -and (Test-Path -LiteralPath $globalRoot)) {
    Write-Host "[clean] removing $globalRoot" -ForegroundColor Yellow
    Remove-Item -LiteralPath $globalRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $globalRoot | Out-Null

# --- 2. copy from sources ----------------------------------------------------

$stats = [ordered]@{ scanned=0; copied=0; overwritten=0; skippedEmpty=0; suspectSignature=0; skippedNoGlobal=0; bytes=[long]0 }
$bySource = [ordered]@{}
$bySection = [ordered]@{}
$suspectFiles = New-Object System.Collections.Generic.List[string]

foreach ($src in $sources) {
    $name = $src.Name
    $root = $src.Root
    if (-not (Test-Path -LiteralPath $root)) {
        Write-Host "[skip] source $name not found: $root" -ForegroundColor DarkYellow
        continue
    }
    Write-Host "[copy] $name <- $root" -ForegroundColor Cyan
    $srcStats = [ordered]@{ scanned=0; copied=0; overwritten=0; skippedEmpty=0; suspectSignature=0; skippedNoGlobal=0; bytes=[long]0 }
    $files = Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue
    if ($src.Filter) { $files = $files | Where-Object { $_.FullName -like (Join-Path $root $src.Filter) } }
    foreach ($f in $files) {
        $stats.scanned++; $srcStats.scanned++
        $dest = Resolve-DestinationPath -SourceRoot $root -FilePath $f.FullName -StripPrefix $src.Strip
        if (-not $dest) { $stats.skippedNoGlobal++; $srcStats.skippedNoGlobal++; continue }
        $sig = Test-AssetSignature -File $f
        if ($sig -eq 'empty') { $stats.skippedEmpty++; $srcStats.skippedEmpty++; continue }
        if ($sig -eq 'unknown') { $stats.suspectSignature++; $srcStats.suspectSignature++; $suspectFiles.Add($f.FullName) }
        $destDir = [System.IO.Path]::GetDirectoryName($dest)
        if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
        $existed = Test-Path -LiteralPath $dest
        [System.IO.File]::Copy($f.FullName, $dest, $true)
        if ($existed) { $stats.overwritten++; $srcStats.overwritten++ } else { $stats.copied++; $srcStats.copied++ }
        $stats.bytes += $f.Length; $srcStats.bytes += $f.Length

        # per-section tally (global/<dynamic|static>/<x>/* ...)
        $relParts = $dest.Substring($OutRoot.Length+1) -split '[\\/]'
        $section = if ($relParts.Length -ge 4) { ($relParts[0..2]) -join '/' } else { $relParts[0] }
        if (-not $bySection.Contains($section)) { $bySection[$section] = [pscustomobject]@{ files=0; bytes=[long]0 } }
        $bySection[$section].files++
        $bySection[$section].bytes += $f.Length
    }
    $bySource[$name] = $srcStats
    Write-Host ("        scanned={0} copied={1} overwritten={2} empty={3} suspect={4} no-global={5}  ({6:N1} MB)" -f $srcStats.scanned,$srcStats.copied,$srcStats.overwritten,$srcStats.skippedEmpty,$srcStats.suspectSignature,$srcStats.skippedNoGlobal,($srcStats.bytes/1MB))
}

# --- 3. generated bits -------------------------------------------------------

if (-not $NoLocale) {
    $locale = Join-Path $globalRoot 'static\locale\ar.mo'
    Write-ArabicLocaleMo -Path $locale
    Write-Host "[gen]  $locale ($((Get-Item $locale).Length) bytes)" -ForegroundColor Cyan
}

$crossdomain = Join-Path $OutRoot 'crossdomain.xml'
$crossdomainXml | Set-Content -LiteralPath $crossdomain -Encoding UTF8 -NoNewline
Write-Host "[gen]  $crossdomain" -ForegroundColor Cyan

# --- 4. report ---------------------------------------------------------------

$report = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    outRoot     = $OutRoot
    sources     = $sources | ForEach-Object { @{ name=$_.Name; root=$_.Root; strip=$_.Strip } }
    summary     = $stats
    bySource    = $bySource
    bySection   = $bySection
    suspectFiles = $suspectFiles | Select-Object -First 50
}
$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $reportPath -Encoding UTF8

# --- 5. final summary --------------------------------------------------------

Write-Host ""
Write-Host "www doc root: $OutRoot" -ForegroundColor Green
Write-Host ("  totals : scanned={0,6}  copied={1,6}  overwritten={2,5}  empty={3,3}  suspect={4,3}  no-global={5,3}" -f $stats.scanned,$stats.copied,$stats.overwritten,$stats.skippedEmpty,$stats.suspectSignature,$stats.skippedNoGlobal)
Write-Host ("           bytes  = {0:N1} MB" -f ($stats.bytes/1MB))
if ($stats.suspectSignature -gt 0) {
    Write-Host ("  note   : {0} files have a non-standard signature (likely encrypted SWFs / JPEG-as-PNG). They were copied as-is; see build-report.json -> suspectFiles." -f $stats.suspectSignature) -ForegroundColor DarkYellow
}
Write-Host "  per-section:"
foreach ($k in $bySection.Keys | Sort-Object) {
    $v = $bySection[$k]
    Write-Host ("    {0,-40} {1,6}  {2,8:N1} MB" -f $k,$v.files,($v.bytes/1MB))
}
Write-Host "  report : $reportPath"
