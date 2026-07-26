# compute-workspace-hash.ps1 - VS Code workspace storage key = MD5(workspace URI)
# For .code-workspace files, the URI is file:///<path>/<name>.code-workspace
param(
    [Parameter(Mandatory)] [string]$WorkspaceFile
)
# Build the file:// URI exactly how VS Code does it.
$uri = ([Uri]$WorkspaceFile).AbsoluteUri
Write-Host "URI: $uri"
$md5 = [System.Security.Cryptography.MD5]::Create()
$bytes = [Text.Encoding]::UTF8.GetBytes($uri)
$hash = ($md5.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join ''
$md5.Dispose()
Write-Host "Hash: $hash"
$hash
