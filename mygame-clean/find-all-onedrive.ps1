# find-all-onedrive.ps1 - any reference to OneDrive in scripts/configs
$root = 'C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\MyGame\mygame-clean'
Get-ChildItem $root -Recurse -File -Include *.ps1,*.json,*.code-workspace,*.properties,*.xml -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notlike '*\build\*' -and $_.FullName -notlike '*\.gradle\*' -and $_.FullName -notlike '*\node_modules\*' -and $_.FullName -notlike '*\dist*\*' -and $_.FullName -notlike '*\.git\*' } |
    Select-String -SimpleMatch 'OneDrive' -List |
    ForEach-Object {
        $rel = $_.Path.Substring($root.Length)
        $rel
    } | Sort-Object
