Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class AirClickWin {
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
  public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L,T,R,B; }
}
"@

$target = [IntPtr]::Zero
[AirClickWin]::EnumWindows({
  param($h, $l)
  if ([AirClickWin]::IsWindowVisible($h)) {
    $sb = New-Object System.Text.StringBuilder 256
    [void][AirClickWin]::GetWindowText($h, $sb, 256)
    if ($sb.ToString() -eq "Adobe AIR") {
      $script:target = $h
      return $false
    }
  }
  return $true
}, [IntPtr]::Zero) | Out-Null

if ($target -eq [IntPtr]::Zero) {
  Write-Host "no Adobe AIR dialog"
  exit 0
}

$r = New-Object AirClickWin+RECT
[void][AirClickWin]::GetWindowRect($target, [ref]$r)
[void][AirClickWin]::SetForegroundWindow($target)
Start-Sleep -Milliseconds 200

# Dialog layout observed: Dismiss All button sits near the bottom-center-left.
$x = $r.L + 390
$y = $r.T + 292
[void][AirClickWin]::SetCursorPos($x, $y)
[AirClickWin]::mouse_event(0x0002,0,0,0,[UIntPtr]::Zero)
[AirClickWin]::mouse_event(0x0004,0,0,0,[UIntPtr]::Zero)
Write-Host "clicked Dismiss All on Adobe AIR dialog hWnd=$target at $x,$y"
