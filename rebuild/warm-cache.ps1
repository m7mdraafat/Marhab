# Pre-warm the avatar-editor asset cache.
# Walks the (gender, clip, color) entries hard-coded in
# server/src/com/mygame/extension/ListHandler.java, resolves each clip's
# version suffix from ifile.2013, GETs the SWF from the live CDN, and
# writes it into the MyGameAssetProxy on-disk cache so the first time the
# avatar editor opens it's already offline.
#
# Safe to re-run; existing files are skipped unless -Force.

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$cdnBase   = 'http://xo.newmarhab.net/global/static/items/clothes'
$cacheRoot = Join-Path $env:APPDATA 'com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net\global\static\items\clothes'
$ifilePath = Join-Path $env:APPDATA 'com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net\global\static\data\ifile.2013'

if (-not (Test-Path $ifilePath)) {
    # First ever run -- proxy hasn't cached ifile yet. Skip silently; the
    # next dev-loop pass (after the client has fetched ifile once) will warm.
    Write-Host "warm-cache: ifile.2013 not yet cached -- skipping (run again after first launch)" -ForegroundColor DarkYellow
    exit 0
}
New-Item -ItemType Directory -Force -Path $cacheRoot | Out-Null

# clip -> version (last "|" field in ifile; 0 = no suffix, N = .N.swf)
Write-Host "parsing ifile..." -NoNewline
$ifileRaw = Get-Content $ifilePath -Raw
$ifileTxt = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($ifileRaw.Trim()))
$versions = @{}
foreach ($line in ($ifileTxt -split "`n")) {
    $parts = $line -split '\|'
    if ($parts.Count -ge 7) {
        $clip = $parts[0]
        $ver  = [int]$parts[$parts.Count - 1]
        $versions[$clip] = $ver
    }
}
Write-Host " $($versions.Count) clips indexed."

# Mirror of CLOTHES_M / CLOTHES_F from ListHandler.java.
# Schema: @{ clip = ''; colors = @(...) }
$tables = @{
    m = @(
        @{ clip='C';        colors=@(1,2,8,12) },
        @{ clip='B';        colors=@(1,2,8,12) },
        @{ clip='A';        colors=@(1,2,8,12) },
        @{ clip='dg5sDd7n'; colors=@(3) },
        @{ clip='dPnu3XPC'; colors=@(12) },
        @{ clip='92';       colors=@(7,8,9) },
        @{ clip='w53a7tcY'; colors=@(3) },
        @{ clip='m8Oiqo9L'; colors=@(5) },
        @{ clip='sw1';      colors=@(3,5,7) },
        @{ clip='uhV5G2d6'; colors=@(3) },
        @{ clip='bjb4xrw8'; colors=@(3) },
        @{ clip='ymvDDtH6'; colors=@(10) },
        @{ clip='fE3eds12'; colors=@(7) },
        @{ clip='pys5hv47'; colors=@(4,1,8,3) },
        @{ clip='1427';     colors=@(4,5,8) },
        @{ clip='tgdflOAT'; colors=@(3,4,5,7,13) },
        @{ clip='y55tRREf'; colors=@(10) },
        @{ clip='yvygwir1'; colors=@(9) }
    )
    f = @(
        @{ clip='C';        colors=@(1,2,8,12) },
        @{ clip='B';        colors=@(1,2,8,12) },
        @{ clip='A';        colors=@(1,2,8,12) },
        @{ clip='yc';       colors=@(1) },
        @{ clip='debm8fsy'; colors=@(3) },
        @{ clip='ep8225up'; colors=@(9) },
        @{ clip='92';       colors=@(7,8,1) },
        @{ clip='b94dmesj'; colors=@(1) },
        @{ clip='g4BSse3E'; colors=@(10) },
        @{ clip='w53a7tcY'; colors=@(3) },
        @{ clip='8mzau8mn'; colors=@(8) },
        @{ clip='fE3eds12'; colors=@(7) },
        @{ clip='56utrmk8'; colors=@(3,7,6,9) },
        @{ clip='XbcCuV58'; colors=@(3,4) },
        @{ clip='ulrpzhgi'; colors=@(9) }
    )
}

$tot = 0; $hit = 0; $ok = 0; $err = 0
foreach ($g in 'm','f') {
    foreach ($row in $tables[$g]) {
        $clip = $row.clip
        $ver  = if ($versions.ContainsKey($clip)) { $versions[$clip] } else { 0 }
        $suffix = if ($ver -gt 0) { ".$ver" } else { '' }
        foreach ($col in $row.colors) {
            $tot++
            $name = "${g}_${clip}_${col}${suffix}.swf"
            $dest = Join-Path $cacheRoot $name
            if ((Test-Path $dest) -and -not $Force) { $hit++; continue }
            $url = "$cdnBase/$name"
            try {
                Invoke-WebRequest -Uri $url -OutFile $dest -TimeoutSec 15 -ErrorAction Stop | Out-Null
                $ok++
                Write-Host "  cached $name ($((Get-Item $dest).Length)B)"
            } catch {
                $err++
                Write-Warning "  FAILED $name -> $($_.Exception.Message)"
                if (Test-Path $dest) { Remove-Item $dest -Force }
            }
        }
    }
}
Write-Host ""
Write-Host "done. total=$tot  already-cached=$hit  newly-cached=$ok  failed=$err"
