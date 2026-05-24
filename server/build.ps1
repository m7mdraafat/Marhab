# build.ps1 -- compile HaraExtension.jar using plain javac (no Maven).
#
# Prereqs:
#   1. Java 8+ on PATH (you have Java 25 Adoptium installed)
#   2. SmartFoxServer 2X installed; copy SFS2X/lib/sfs2x.jar and sfs2x-core.jar
#      into server/lib/ before running.
#
# Output: server/dist/MyGameExtension.jar
[CmdletBinding()]
param([switch]$Clean)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$prevLoc = $PWD
Push-Location $here
try {

$srcDir   = Join-Path $here 'src'
$libDir   = Join-Path $here 'lib'
$buildDir = Join-Path $here 'build'
$distDir  = Join-Path $here 'dist'
$jarOut   = Join-Path $distDir 'HaraExtension.jar'

if ($Clean) {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $buildDir, $distDir
}
New-Item -ItemType Directory -Force -Path $buildDir, $distDir | Out-Null

# Locate SFS jars
$sfsJars = @()
if (Test-Path $libDir) {
    $sfsJars = Get-ChildItem $libDir -Filter 'sfs2x*.jar' -File | ForEach-Object FullName
}
if ($sfsJars.Count -eq 0) {
    Write-Host "WARNING: no sfs2x*.jar under $libDir" -ForegroundColor Yellow
    Write-Host "  Install SmartFoxServer 2X and copy SFS2X/lib/sfs2x.jar plus" -ForegroundColor Yellow
    Write-Host "  SFS2X/lib/sfs2x-core.jar into server/lib/." -ForegroundColor Yellow
    Write-Host "  Skipping compile (would fail without SFS classpath)." -ForegroundColor Yellow
    exit 1
}

$classpath = ($sfsJars + $buildDir) -join ';'
$sources = Get-ChildItem $srcDir -Filter '*.java' -File -Recurse | ForEach-Object FullName

Write-Host "Sources : $($sources.Count) .java files"
Write-Host "Classpath: $classpath"

# SFS 2X ships with bundled Java 11 (class file version 55). Targeting --release 11
# ensures the jar loads in SFS's JVM even though we compile with newer Java
# (Adoptium JDK 25, class file version 69) on the dev box.
javac --release 11 -d $buildDir -cp $classpath @sources
if ($LASTEXITCODE -ne 0) { throw "javac failed ($LASTEXITCODE)" }

# Package
Push-Location $buildDir
try {
    jar cf $jarOut .
}
finally {
    Pop-Location
}
if ($LASTEXITCODE -ne 0) { throw "jar failed ($LASTEXITCODE)" }

Write-Host "Built: $jarOut ($((Get-Item $jarOut).Length) bytes)" -ForegroundColor Green

}
finally {
    Pop-Location
}
