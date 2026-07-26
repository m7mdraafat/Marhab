[CmdletBinding()]
param(
    [int]$Port = 8081,
    [string]$MirrorRoot,
    [string]$HostName = "127.0.0.1"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($MirrorRoot)) {
    # Default to server/www (built by rebuild/build-www.ps1). Fall back to the
    # legacy assets/cdn-mirror so older docs / external invocations still work.
    $candidate = Join-Path $repoRoot "server\www"
    if (-not (Test-Path -LiteralPath (Join-Path $candidate "global"))) {
        $candidate = Join-Path $repoRoot "assets\cdn-mirror"
    }
    $MirrorRoot = $candidate
}
$MirrorRoot = (Resolve-Path -LiteralPath $MirrorRoot).Path

if (-not (Test-Path -LiteralPath (Join-Path $MirrorRoot "global"))) {
    throw "CDN mirror must contain a global folder: $MirrorRoot. Run rebuild/build-www.ps1 first."
}

$contentTypes = @{
    ".swf" = "application/x-shockwave-flash"
    ".png" = "image/png"
    ".jpg" = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif" = "image/gif"
    ".json" = "application/json; charset=utf-8"
    ".txt" = "text/plain; charset=utf-8"
    ".xml" = "application/xml; charset=utf-8"
    ".mo" = "application/octet-stream"
}

function Send-Bytes {
    param(
        [System.Net.HttpListenerResponse]$Response,
        [byte[]]$Bytes,
        [string]$ContentType,
        [int]$StatusCode = 200,
        [switch]$HeadOnly
    )

    $Response.StatusCode = $StatusCode
    $Response.ContentType = $ContentType
    $Response.ContentLength64 = $Bytes.Length
    $Response.Headers["Access-Control-Allow-Origin"] = "*"
    $Response.Headers["Cache-Control"] = "public, max-age=31536000"
    if (-not $HeadOnly) {
        $Response.OutputStream.Write($Bytes, 0, $Bytes.Length)
    }
    $Response.OutputStream.Close()
}

function Send-Text {
    param(
        [System.Net.HttpListenerResponse]$Response,
        [string]$Text,
        [string]$ContentType,
        [int]$StatusCode = 200,
        [switch]$HeadOnly
    )

    Send-Bytes -Response $Response -Bytes ([System.Text.Encoding]::UTF8.GetBytes($Text)) -ContentType $ContentType -StatusCode $StatusCode -HeadOnly:$HeadOnly
}

function Resolve-AssetPath {
    param([string]$UrlPath)

    $decodedPath = [System.Uri]::UnescapeDataString($UrlPath)
    $decodedPath = $decodedPath.Replace('/', [System.IO.Path]::DirectorySeparatorChar).TrimStart([System.IO.Path]::DirectorySeparatorChar)
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $MirrorRoot $decodedPath))
    $mirrorPrefix = [System.IO.Path]::GetFullPath($MirrorRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar

    if (-not $candidate.StartsWith($mirrorPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    return $candidate
}

$listener = [System.Net.HttpListener]::new()
$prefix = "http://$HostName`:$Port/"
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
    Write-Host "Local CDN server"
    Write-Host "  URL:         $prefix"
    Write-Host "  Mirror root: $MirrorRoot"
    Write-Host "  Serve path:  ${prefix}global/..."
    Write-Host "  Stop:        Ctrl+C"

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        try {
            Write-Host ("{0} {1} {2}" -f (Get-Date -Format "HH:mm:ss"), $request.HttpMethod, $request.Url.PathAndQuery)
            $headOnly = $request.HttpMethod -eq "HEAD"

            if ($request.HttpMethod -eq "OPTIONS") {
                $response.Headers["Access-Control-Allow-Origin"] = "*"
                $response.Headers["Access-Control-Allow-Methods"] = "GET, HEAD, OPTIONS"
                $response.Headers["Access-Control-Allow-Headers"] = "*"
                $response.StatusCode = 204
                $response.Close()
                continue
            }

            if ($request.Url.AbsolutePath -eq "/crossdomain.xml") {
                $policy = '<?xml version="1.0"?><cross-domain-policy><allow-access-from domain="*" secure="false" /></cross-domain-policy>'
                Send-Text -Response $response -Text $policy -ContentType "application/xml; charset=utf-8" -HeadOnly:$headOnly
                continue
            }

            if ($request.Url.AbsolutePath -notlike "/global/*") {
                Send-Text -Response $response -Text "Not found" -ContentType "text/plain; charset=utf-8" -StatusCode 404 -HeadOnly:$headOnly
                continue
            }

            $filePath = Resolve-AssetPath -UrlPath $request.Url.AbsolutePath
            if ($null -eq $filePath -or -not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
                Send-Text -Response $response -Text "Not found" -ContentType "text/plain; charset=utf-8" -StatusCode 404 -HeadOnly:$headOnly
                continue
            }

            $extension = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
            $contentType = $contentTypes[$extension]
            if ([string]::IsNullOrWhiteSpace($contentType)) {
                $contentType = "application/octet-stream"
            }

            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            Send-Bytes -Response $response -Bytes $bytes -ContentType $contentType -HeadOnly:$headOnly
        }
        catch {
            if ($response.OutputStream.CanWrite) {
                Send-Text -Response $response -Text $_.Exception.Message -ContentType "text/plain; charset=utf-8" -StatusCode 500 -HeadOnly:($request.HttpMethod -eq "HEAD")
            }
        }
    }
}
finally {
    if ($listener.IsListening) {
        $listener.Stop()
    }
    $listener.Close()
}