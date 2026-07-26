$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$cdnRoot = Join-Path $repoRoot "assets\cdn"
$cardsDir = Join-Path $cdnRoot "global\static\items\cards"
$panelsDir = Join-Path $cdnRoot "global\dynamic\panels"

New-Item -ItemType Directory -Force -Path $cardsDir | Out-Null

Add-Type -AssemblyName System.Drawing

$cards = @(
    @{ Name = "CARD_DIAMOND"; Label = "DIA"; Color = "#00A7D9" },
    @{ Name = "CARD_DIAMOND_CLUB"; Label = "DC"; Color = "#1DA1F2" },
    @{ Name = "CARD_GOLD"; Label = "GOLD"; Color = "#D4A72C" },
    @{ Name = "CARD_SILVER"; Label = "SIL"; Color = "#9EA7B3" },
    @{ Name = "CARD_ELITE"; Label = "ELT"; Color = "#263238" },
    @{ Name = "CARD_SANALIKAX"; Label = "X"; Color = "#F57C00" },
    @{ Name = "CARD_SECURITY"; Label = "SEC"; Color = "#D32F2F" },
    @{ Name = "CARD_MODERATOR"; Label = "MOD"; Color = "#263238" },
    @{ Name = "CARD_EDITOR_SECURITY"; Label = "EDS"; Color = "#5D4037" },
    @{ Name = "CARD_ADMIN_SECURITY"; Label = "ADM"; Color = "#B71C1C" },
    @{ Name = "CARD_JOURNALIST"; Label = "JRN"; Color = "#455A64" },
    @{ Name = "CARD_DIRECTOR"; Label = "DIR"; Color = "#6D4C41" },
    @{ Name = "CARD_PHOTOGRAPHER"; Label = "PHO"; Color = "#5E35B1" },
    @{ Name = "CARD_PAINTER"; Label = "ART"; Color = "#00897B" },
    @{ Name = "CARD_ACTOR"; Label = "ACT"; Color = "#C2185B" },
    @{ Name = "CARD_GUARD"; Label = "GRD"; Color = "#00796B" },
    @{ Name = "CARD_GUIDE"; Label = "GDE"; Color = "#2E7D32" },
    @{ Name = "CARD_MUSIC"; Label = "MUS"; Color = "#7B1FA2" },
    @{ Name = "CARD_CAPITAN"; Label = "CAP"; Color = "#00695C" },
    @{ Name = "vip"; Label = "VIP"; Color = "#7E57C2" },
    @{ Name = "vip_gold"; Label = "GOLD"; Color = "#D4A72C" },
    @{ Name = "vip_diamond"; Label = "DIA"; Color = "#00A7D9" },
    @{ Name = "vip_silver"; Label = "SIL"; Color = "#9EA7B3" },
    @{ Name = "diamond_club"; Label = "DC"; Color = "#1DA1F2" },
    @{ Name = "card_security"; Label = "SEC"; Color = "#D32F2F" },
    @{ Name = "card_journalist"; Label = "JRN"; Color = "#455A64" },
    @{ Name = "card_director"; Label = "DIR"; Color = "#6D4C41" },
    @{ Name = "card_photographer"; Label = "PHO"; Color = "#5E35B1" },
    @{ Name = "card_painter"; Label = "ART"; Color = "#00897B" },
    @{ Name = "card_actor"; Label = "ACT"; Color = "#C2185B" },
    @{ Name = "card_guard"; Label = "GRD"; Color = "#00796B" },
    @{ Name = "card_guide"; Label = "GDE"; Color = "#2E7D32" },
    @{ Name = "card_sanalikax"; Label = "X"; Color = "#F57C00" },
    @{ Name = "card_music"; Label = "MUS"; Color = "#7B1FA2" },
    @{ Name = "ship_license"; Label = "SHIP"; Color = "#0277BD" },
    @{ Name = "card_capitan"; Label = "CAP"; Color = "#00695C" },
    @{ Name = "card_moderator"; Label = "MOD"; Color = "#263238" },
    @{ Name = "card_editor_security"; Label = "EDS"; Color = "#5D4037" },
    @{ Name = "card_admin_security"; Label = "ADM"; Color = "#B71C1C" }
)

function Convert-HexColor([string]$hex) {
    $hex = $hex.TrimStart('#')
    return [System.Drawing.Color]::FromArgb(
        [Convert]::ToInt32($hex.Substring(0, 2), 16),
        [Convert]::ToInt32($hex.Substring(2, 2), 16),
        [Convert]::ToInt32($hex.Substring(4, 2), 16)
    )
}

foreach ($card in $cards) {
    $out = Join-Path $cardsDir ($card.Name + ".png")
    $bitmap = New-Object System.Drawing.Bitmap 96, 72
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle 0, 0, 96, 72),
        (Convert-HexColor $card.Color),
        [System.Drawing.Color]::FromArgb(35, 35, 42),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $graphics.FillRectangle($bg, 4, 4, 88, 64)

    $border = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 255, 255)), 3
    $graphics.DrawRectangle($border, 4, 4, 88, 64)

    $fontSize = if ($card.Label.Length -gt 3) { 15 } elseif ($card.Label.Length -gt 2) { 18 } else { 28 }
    $font = New-Object System.Drawing.Font "Arial", $fontSize, ([System.Drawing.FontStyle]::Bold)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $graphics.DrawString($card.Label, $font, [System.Drawing.Brushes]::White, (New-Object System.Drawing.RectangleF 6, 8, 84, 56), $format)

    $bitmap.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
}

$panelCopies = @(
    @{ Source = "PNCPP.34.swf"; Target = "PNCPP.32.swf" },
    @{ Source = "1449237199236-15.5.swf"; Target = "1449237199236-15.4.swf" }
)

foreach ($copy in $panelCopies) {
    $source = Join-Path $panelsDir $copy.Source
    $target = Join-Path $panelsDir $copy.Target
    if ((Test-Path $source) -and -not (Test-Path $target)) {
        Copy-Item -LiteralPath $source -Destination $target
    }
}

Write-Host "Created/verified card icons in $cardsDir"
Write-Host "Verified panel fallbacks in $panelsDir"
