# identify-java.ps1 - prints command lines of all java processes
Get-Process -Name java -ErrorAction SilentlyContinue | ForEach-Object {
    $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction SilentlyContinue).CommandLine
    if ($cmd) {
        $snippet = $cmd.Substring(0, [Math]::Min(220, $cmd.Length))
        '{0} | {1}' -f $_.Id, $snippet
    }
}
