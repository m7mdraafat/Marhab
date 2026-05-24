# fix-haxe-imap.ps1
#
# The decompiled Haxe-to-AS3 code declares many local variables as `IMap`
# (the Haxe interface) even though they are immediately assigned a concrete
# `StringMap` / `IntMap` / `ObjectMap`. The accessors `.h[...]` and `.setReserved(...)`
# live on the concrete classes, not on the IMap interface, so the decompiled
# code throws "Property h not found on haxe.ds.XxxMap" at runtime.
#
# This pass rewrites such locals to their concrete map type. It is safe
# because the surrounding code only uses methods that exist on both the
# interface and the concrete class.
#
# Pattern handled (case sensitive, single line):
#     var _locN_:IMap = new StringMap();
#     var _locN_:IMap = new IntMap();
#     var _locN_:IMap = new ObjectMap();
#     _locN_ = new StringMap();
#     _locN_ = new IntMap();
#     _locN_ = new ObjectMap();
#     someLocalAlreadyTypedIMap that has both forms in the same method ...
#
# Strategy: for each .as file, scan line by line. When we see a
#     var _locN_:IMap = new XxxMap();
# rewrite to
#     var _locN_:XxxMap = new XxxMap();
#
# Reassignments without `var` (re-using a slot with a new concrete type) are
# left alone -- those are rare and would need scope analysis.

[CmdletBinding()]
param(
    [string]$Root = (Join-Path $PSScriptRoot '..\scripts'),
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path $Root).Path
Write-Host "Scanning $Root" -ForegroundColor Cyan

$pattern = [regex]'(?<prefix>\bvar\s+_loc\d+_):IMap(?<eq>\s*=\s*new\s+)(?<type>StringMap|IntMap|ObjectMap)\b'
$totalFiles = 0
$changedFiles = 0
$totalReplacements = 0
$script:_imapCount = 0

$asFiles = [System.IO.Directory]::EnumerateFiles($Root, '*.as', [System.IO.SearchOption]::AllDirectories)
foreach ($file in $asFiles) {
    $totalFiles++
    $text = [System.IO.File]::ReadAllText($file)
    if ($text -notmatch ':IMap') { continue }

    $count = 0
    $newText = [regex]::Replace($text, $pattern, {
        param($m)
        $script:_imapCount++
        return $m.Groups['prefix'].Value + ':' + $m.Groups['type'].Value + $m.Groups['eq'].Value + $m.Groups['type'].Value
    })
    $count = $script:_imapCount
    $script:_imapCount = 0

    if ($count -gt 0) {
        $changedFiles++
        $totalReplacements += $count
        $rel = $file.Substring($Root.Length).TrimStart('\','/')
        Write-Host ("  [{0,3}] {1}" -f $count, $rel)
        if (-not $DryRun) {
            [System.IO.File]::WriteAllText($file, $newText)
        }
    }
}

Write-Host ""
Write-Host "Files scanned:    $totalFiles"
Write-Host "Files changed:    $changedFiles"
Write-Host "Replacements:     $totalReplacements"
if ($DryRun) {
    Write-Host "(dry run -- no files written)" -ForegroundColor Yellow
}
