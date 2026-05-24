[CmdletBinding()]
param(
    [string]$SdkHome,
    [string]$Certificate = "cert/MyGame.p12",
    [string]$CertificatePassword = "mygame-dev",
    [string]$Output = "dist/MyGame"
)

$ErrorActionPreference = "Stop"

function Resolve-Adt {
    param([string]$SdkRoot)

    $command = Get-Command "adt" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    if ($SdkRoot) {
        foreach ($name in @("adt.bat", "adt.exe")) {
            $candidate = Join-Path $SdkRoot "bin/$name"
            if (Test-Path $candidate) {
                return $candidate
            }
        }
    }

    return $null
}

$sdkRoot = $SdkHome
if (-not $sdkRoot) { $sdkRoot = $env:AIR_SDK_HOME }
if (-not $sdkRoot) { $sdkRoot = $env:AIRSDK_HOME }
if (-not $sdkRoot) { $sdkRoot = $env:FLEX_HOME }
if ($sdkRoot) {
    $sdkRoot = (Resolve-Path $sdkRoot).Path
    $env:FLEX_HOME = $sdkRoot
    $env:AIR_HOME = $sdkRoot
    $env:AIR_SDK_HOME = $sdkRoot
}

$adt = Resolve-Adt -SdkRoot $sdkRoot
if (-not $adt) {
    throw "No AIR Developer Tool found. Install Harman AIR SDK, add adt to PATH, or set AIR_SDK_HOME."
}

$descriptorPath = Join-Path $PSScriptRoot "application.xml"
$swfPath = Join-Path $PSScriptRoot "bin/MyGame.swf"
$runtimePath = Join-Path $PSScriptRoot "runtime"
$libPath = Join-Path $PSScriptRoot "lib"
$certificatePath = Join-Path $PSScriptRoot $Certificate
$outputPath = Join-Path $PSScriptRoot $Output

if (-not (Test-Path $descriptorPath)) {
    throw "AIR descriptor not found: $descriptorPath"
}
if (-not (Test-Path $swfPath)) {
    throw "Compiled SWF not found: $swfPath. Run rebuild/compile.ps1 first."
}
if (-not (Test-Path $runtimePath)) {
    throw "Runtime cache not found: $runtimePath"
}
if (-not (Test-Path $libPath)) {
    throw "Preload library folder not found: $libPath"
}

New-Item -ItemType Directory -Force -Path (Split-Path $certificatePath -Parent) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $outputPath -Parent) | Out-Null

if (-not (Test-Path $certificatePath)) {
    & $adt -certificate -cn MyGameDev -ou Dev -o MyGame -c US 2048-RSA $certificatePath $CertificatePassword
    if ($LASTEXITCODE -ne 0) {
        throw "Certificate generation failed with exit code $LASTEXITCODE."
    }
}

if (Test-Path $outputPath) {
    Remove-Item $outputPath -Recurse -Force
}

Write-Host "ADT:        $adt"
Write-Host "Descriptor: $descriptorPath"
Write-Host "Output:     $outputPath"

Push-Location $PSScriptRoot
try {
    & $adt -package -storetype pkcs12 -keystore $certificatePath -storepass $CertificatePassword -tsa none -target bundle $outputPath application.xml bin runtime lib
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw "Packaging failed with exit code $LASTEXITCODE."
}

Write-Host "Packaged $outputPath"