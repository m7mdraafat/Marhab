# preprocess.ps1 — fix systemic Haxe->AS3 decompiler artifacts in scripts/.
#
# The decompiler emits local-variable declarations as `:IMap` even though the
# RHS is always a concrete map type (`StringMap`, `IntMap`, `ObjectMap`). Code
# downstream then accesses the concrete `.h` backing field, which is not on
# the `IMap` interface, producing runtime `ReferenceError #1081`.
#
# This script retypes those local variable declarations to the concrete type
# the constructor returns. Idempotent: running it twice is a no-op.
#
# It also fixes the small family of `var XX:IMap = openfl.Lib.__timers` style
# declarations where the IMap-typed field actually holds an IntMap. We retype
# those locals too so subsequent `.h[]` access works.

[CmdletBinding()]
param(
    [string]$ScriptsRoot = (Join-Path $PSScriptRoot '..\scripts'),
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ScriptsRoot = (Resolve-Path $ScriptsRoot).Path

# Pattern 1: local var directly assigned `new SomeMap()`
$reCtor = [regex]'(?m)^(?<indent>\s*)var\s+(?<name>_loc\d+_)\s*:\s*IMap\s*=\s*new\s+(?<ctor>StringMap|IntMap|ObjectMap)\s*\('

# Pattern 2: local var assigned a known-IMap field whose real type we can infer
#   var _locN_:IMap = openfl.Lib.__timers;   // __timers is IntMap
$reTimers = [regex]'(?m)^(?<indent>\s*)var\s+(?<name>_loc\d+_)\s*:\s*IMap\s*=\s*openfl\.Lib\.__timers\s*;'

$files = Get-ChildItem -Path $ScriptsRoot -Recurse -File -Filter *.as
$changedFiles = 0
$totalSubs    = 0

foreach ($f in $files) {
    $orig = [IO.File]::ReadAllText($f.FullName)
    $new  = $orig
    $subs = 0

    $new = $reCtor.Replace($new, {
        param($m)
        $script:subs++
        '{0}var {1}:{2} = new {2}(' -f $m.Groups['indent'].Value, $m.Groups['name'].Value, $m.Groups['ctor'].Value
    })

    $new = $reTimers.Replace($new, {
        param($m)
        $script:subs++
        '{0}var {1}:IntMap = openfl.Lib.__timers as IntMap;' -f $m.Groups['indent'].Value, $m.Groups['name'].Value
    })

    if ($subs -gt 0 -and $new -ne $orig) {
        $changedFiles++
        $totalSubs += $subs
        if (-not $DryRun) {
            [IO.File]::WriteAllText($f.FullName, $new, [Text.UTF8Encoding]::new($false))
        }
    }
}

if ($DryRun) {
    Write-Host "[DRY RUN] would change $changedFiles files, $totalSubs substitutions" -ForegroundColor Yellow
} else {
    Write-Host "preprocess: $changedFiles files modified, $totalSubs substitutions" -ForegroundColor Green
}
