# Inspect every cached cloth SWF and report whether its embedded SymbolClass
# matches the URL-derived key. If not, the panel will spin forever waiting
# for the class to register (see SwfRequest.registerClass -> EXPORT NOT FOUND).
$ffdec   = 'C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\MyGame\rebuild\tools\ffdec\ffdec-cli.exe'
$base    = "$env:APPDATA\com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net\global\static\items\clothes"
$ifile   = "$env:APPDATA\com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net\global\static\data\ifile.2013"
$dec     = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content $ifile -Raw).Trim()))
$ver     = @{}
foreach ($l in ($dec -split "`n")) { $p = $l -split '\|'; if ($p.Count -ge 7) { $ver[$p[0]] = [int]$p[$p.Count-1] } }

$entries = @(
  @('m','C',1),@('m','C',2),@('m','C',8),@('m','C',12),
  @('m','B',1),@('m','B',2),@('m','B',8),@('m','B',12),
  @('m','A',1),@('m','A',2),@('m','A',8),@('m','A',12),
  @('m','dg5sDd7n',3),@('m','dPnu3XPC',12),@('m','92',7),@('m','92',8),@('m','92',9),
  @('m','w53a7tcY',3),@('m','m8Oiqo9L',5),@('m','sw1',3),@('m','sw1',5),@('m','sw1',7),@('m','uhV5G2d6',3),
  @('m','bjb4xrw8',3),@('m','ymvDDtH6',10),@('m','fE3eds12',7),
  @('m','pys5hv47',4),@('m','pys5hv47',1),@('m','pys5hv47',8),@('m','pys5hv47',3),
  @('m','1427',4),@('m','1427',5),@('m','1427',8),
  @('m','tgdflOAT',3),@('m','tgdflOAT',4),@('m','tgdflOAT',5),@('m','tgdflOAT',7),@('m','tgdflOAT',13),
  @('m','dwxsxbsf',3),@('m','y55tRREf',10),@('m','yvygwir1',9),
  @('f','C',1),@('f','C',2),@('f','C',8),@('f','C',12),
  @('f','B',1),@('f','B',2),@('f','B',8),@('f','B',12),
  @('f','A',1),@('f','A',2),@('f','A',8),@('f','A',12),
  @('f','yc',1),
  @('f','debm8fsy',3),@('f','ep8225up',9),@('f','92',7),@('f','92',8),@('f','92',1),@('f','b94dmesj',1),
  @('f','g4BSse3E',10),@('f','w53a7tcY',3),@('f','8mzau8mn',8),
  @('f','fE3eds12',7),
  @('f','56utrmk8',3),@('f','56utrmk8',7),@('f','56utrmk8',6),@('f','56utrmk8',9),
  @('f','XbcCuV58',3),@('f','XbcCuV58',4),@('f','ulrpzhgi',9)
)
$bad = @(); $good = 0
foreach ($e in $entries) {
  $g=$e[0]; $c=$e[1]; $col=$e[2]
  $v = if ($ver.ContainsKey($c)) { $ver[$c] } else { 0 }
  $sfx = if ($v -gt 0) { ".$v" } else { '' }
  $expected = "${g}_${c}_${col}"
  $file = Join-Path $base "${expected}${sfx}.swf"
  if (-not (Test-Path $file)) { $bad += [pscustomobject]@{g=$g;clip=$c;col=$col;expected=$expected;actual='NO_FILE'}; continue }
  $out = (& $ffdec -dumpAS3 $file 2>&1) -join ' '
  $actual = $out.Trim().Split(' ')[0]
  if ($actual -eq $expected) { $good++ }
  else { $bad += [pscustomobject]@{g=$g;clip=$c;col=$col;expected=$expected;actual=$actual} }
}
"good=$good bad=$($bad.Count)"
$bad | Format-Table -AutoSize
