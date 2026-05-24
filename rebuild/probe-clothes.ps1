$entries = @(
  @{c='C';        pb=1;      v=0; cols=@(1,2,8,12)},
  @{c='yc';       pb=1;      v=0; cols=@(1)},
  @{c='debm8fsy'; pb=131072; v=0; cols=@(3)},
  @{c='dg5sDd7n'; pb=131072; v=0; cols=@(3)},
  @{c='ep8225up'; pb=131072; v=0; cols=@(9)},
  @{c='dPnu3XPC'; pb=131072; v=0; cols=@(12)},
  @{c='92';       pb=131072; v=0; cols=@(7,8,9,1)},
  @{c='b94dmesj'; pb=131072; v=0; cols=@(1)},
  @{c='g4BSse3E'; pb=512;    v=1; cols=@(10)},
  @{c='w53a7tcY'; pb=512;    v=0; cols=@(3)},
  @{c='8mzau8mn'; pb=512;    v=0; cols=@(8)},
  @{c='m8Oiqo9L'; pb=512;    v=0; cols=@(5)},
  @{c='sw1';      pb=512;    v=0; cols=@(3,5,7)},
  @{c='uhV5G2d6'; pb=512;    v=0; cols=@(3)},
  @{c='bjb4xrw8'; pb=64;     v=0; cols=@(3)},
  @{c='ymvDDtH6'; pb=64;     v=0; cols=@(10)},
  @{c='fE3eds12'; pb=64;     v=0; cols=@(7)},
  @{c='pys5hv47'; pb=64;     v=0; cols=@(4,1,8,3)},
  @{c='1427';     pb=64;     v=0; cols=@(4,5,8)},
  @{c='tgdflOAT'; pb=64;     v=0; cols=@(3,4,5,7,13)},
  @{c='56utrmk8'; pb=16;     v=0; cols=@(3,7,6,9)},
  @{c='XbcCuV58'; pb=16;     v=0; cols=@(3,4)},
  @{c='dwxsxbsf'; pb=16;     v=0; cols=@(3,4,5,7,13)},
  @{c='y55tRREf'; pb=16;     v=0; cols=@(10)},
  @{c='ulrpzhgi'; pb=16;     v=0; cols=@(9)},
  @{c='yvygwir1'; pb=16;     v=0; cols=@(9)}
)
$ProgressPreference='SilentlyContinue'
$results = @()
foreach ($e in $entries) {
  foreach ($g in @('m','f')) {
    foreach ($col in $e.cols) {
      $vp = if ($e.v -gt 0) { '.' + $e.v } else { '' }
      $u = "http://xo.newmarhab.net/global/static/items/clothes/${g}_$($e.c)_${col}${vp}.swf"
      try {
        $r = Invoke-WebRequest -Uri $u -Method Head -TimeoutSec 8 -ErrorAction Stop
        $results += [pscustomobject]@{clip=$e.c; pb=$e.pb; g=$g; col=$col; status=$r.StatusCode; ok=$true}
      } catch {
        $sc = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { -1 }
        $results += [pscustomobject]@{clip=$e.c; pb=$e.pb; g=$g; col=$col; status=$sc; ok=$false}
      }
      Start-Sleep -Milliseconds 80
    }
  }
}
$results | Group-Object clip | ForEach-Object {
  $bad = ($_.Group | Where-Object { -not $_.ok }).Count
  $tot = $_.Group.Count
  $sample = ($_.Group | ForEach-Object { "$($_.g)_$($_.col)=$($_.status)" }) -join ','
  "{0,-12} pb={1,-7} {2}/{3} ok  [{4}]" -f $_.Name, ($_.Group[0].pb), ($tot - $bad), $tot, $sample
}
