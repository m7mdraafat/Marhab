Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class Win {
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L,T,R,B; }
}
"@

$adl = Get-Process adl -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $adl) { Write-Host "no adl window"; exit 1 }
[void][Win]::ShowWindow($adl.MainWindowHandle, 9)  # SW_RESTORE
[void][Win]::SetForegroundWindow($adl.MainWindowHandle)
Start-Sleep -Milliseconds 800

$r = New-Object Win+RECT
[void][Win]::GetWindowRect($adl.MainWindowHandle, [ref]$r)
$w = $r.R - $r.L; $h = $r.B - $r.T
Write-Host "adl window: ${w}x${h} at $($r.L),$($r.T)  pid=$($adl.Id)"

$bmp = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($r.L, $r.T, 0, 0, $bmp.Size)
$out = "C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\MyGame\mygame-clean\server\logs\adl-state.png"
$bmp.Save($out)
$g.Dispose(); $bmp.Dispose()
Write-Host "saved $out"
