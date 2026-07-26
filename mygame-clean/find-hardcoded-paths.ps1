# find-hardcoded-paths.ps1 - lists every file containing the OneDrive prefix
$prefix = 'OneDrive - Microsoft\Desktop\MyGame'
$root = 'C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\MyGame\mygame-clean'
Get-ChildItem $root -Recurse -File -Include *.ps1,*.json,*.code-workspace,*.properties,*.xml,*.md,*.cfg -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notlike '*\build\*' -and $_.FullName -notlike '*\.gradle\*' -and $_.FullName -notlike '*\node_modules\*' -and $_.FullName -notlike '*\dist*\*' } |
    Select-String -SimpleMatch $prefix -List |
    ForEach-Object {
        $rel = $_.Path.Substring($root.Length)
        '{0}' -f $rel
    } | Sort-Object
