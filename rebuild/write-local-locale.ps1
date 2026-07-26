[CmdletBinding()]
param(
    [string]$Output = "assets/cdn-mirror/global/static/locale/ar.mo"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputPath = Join-Path $repoRoot $Output
New-Item -ItemType Directory -Force -Path (Split-Path $outputPath -Parent) | Out-Null

$translations = [ordered]@{
    "" = "Content-Type: text/plain; charset=UTF-8`nLanguage: ar`nPlural-Forms: nplurals=2; plural=(n != 1);`n"
    "avatarEditHeader" = "تعديل الشخصية"
    "avatarEditInfo" = "اختر مظهر شخصيتك"
    "avatarEditButton" = "حفظ"
    "avatarCreateHeader" = "إنشاء شخصية"
    "avatarCreateInfo" = "اختر مظهر شخصيتك واكتب اسمك"
    "avatarCreateButton" = "إنشاء"
    "Jack The One" = "لاعب جديد"
    "avatarNameLengthError" = "يجب أن يكون الاسم بين 3 و20 حرفا"
    "nickChangeFormatError" = "الاسم يحتوي على رموز غير مسموحة"
}

$entries = @($translations.GetEnumerator() | Sort-Object Name)
$encoding = [System.Text.Encoding]::UTF8
$count = $entries.Count
$headerSize = 28
$originalTableOffset = $headerSize
$translationTableOffset = $originalTableOffset + ($count * 8)
$stringOffset = $translationTableOffset + ($count * 8)

$originalBytes = @()
$translationBytes = @()
foreach ($entry in $entries) {
    $originalBytes += ,($encoding.GetBytes([string]$entry.Key))
    $translationBytes += ,($encoding.GetBytes([string]$entry.Value))
}

$offset = $stringOffset
$originalMeta = @()
for ($index = 0; $index -lt $count; $index++) {
    $originalMeta += ,[pscustomobject]@{ Length = $originalBytes[$index].Length; Offset = $offset }
    $offset += $originalBytes[$index].Length + 1
}

$translationMeta = @()
for ($index = 0; $index -lt $count; $index++) {
    $translationMeta += ,[pscustomobject]@{ Length = $translationBytes[$index].Length; Offset = $offset }
    $offset += $translationBytes[$index].Length + 1
}

$stream = [System.IO.MemoryStream]::new()
$writer = [System.IO.BinaryWriter]::new($stream)
try {
    foreach ($value in @(2500072158, 0, $count, $originalTableOffset, $translationTableOffset, 0, $offset)) {
        $writer.Write([uint32]$value)
    }
    foreach ($meta in $originalMeta) {
        $writer.Write([uint32]$meta.Length)
        $writer.Write([uint32]$meta.Offset)
    }
    foreach ($meta in $translationMeta) {
        $writer.Write([uint32]$meta.Length)
        $writer.Write([uint32]$meta.Offset)
    }
    foreach ($bytes in $originalBytes) {
        $writer.Write($bytes)
        $writer.Write([byte]0)
    }
    foreach ($bytes in $translationBytes) {
        $writer.Write($bytes)
        $writer.Write([byte]0)
    }
    $writer.Flush()
    [System.IO.File]::WriteAllBytes($outputPath, $stream.ToArray())
}
finally {
    $writer.Dispose()
    $stream.Dispose()
}

Write-Host "Wrote $outputPath ($((Get-Item $outputPath).Length) bytes)"