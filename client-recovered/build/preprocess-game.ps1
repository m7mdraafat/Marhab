[CmdletBinding()]
param(
    [string]$Source = "game/src",
    [string]$Output = "obj/game-src"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$sourceRoot = Join-Path $root $Source
$outputRoot = Join-Path $root $Output

if (-not (Test-Path -LiteralPath $sourceRoot)) {
    throw "Source directory not found: $sourceRoot"
}

if (Test-Path -LiteralPath $outputRoot) {
    Remove-Item -LiteralPath $outputRoot -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $outputRoot) {
        & cmd.exe /c "rmdir /s /q `"$outputRoot`""
    }
}

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
Copy-Item -Path (Join-Path $sourceRoot "*") -Destination $outputRoot -Recurse -Force

$files = Get-ChildItem -LiteralPath $outputRoot -Recurse -File -Filter *.as
$changed = 0

function Move-FirstSuperCallAfterConstructorOpen {
    param(
        [string]$SourceText,
        [string]$ClassName
    )

    $lines = $SourceText -split "`r?`n", -1
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -notmatch ('^\s*public\s+function\s+' + [regex]::Escape($ClassName) + '\s*\(')) {
            continue
        }

        $constructorLine = $index
        $braceLine = -1
        $braceDepth = 0
        $entered = $false
        $superLine = -1

        for ($cursor = $index; $cursor -lt $lines.Count; $cursor++) {
            $line = $lines[$cursor]
            $opens = ([regex]::Matches($line, '\{')).Count
            $closes = ([regex]::Matches($line, '\}')).Count
            if ($opens -gt 0 -and -not $entered) {
                $entered = $true
                $braceLine = $cursor
            }
            $braceDepth += $opens - $closes

            if ($entered -and $cursor -gt $constructorLine -and $line -match '^\s*super\([^;]*\);\s*$') {
                $superLine = $cursor
                break
            }

            if ($entered -and $braceDepth -le 0) {
                break
            }
        }

        if ($superLine -gt ($constructorLine + 1)) {
            $super = $lines[$superLine]
            $before = if ($superLine -gt 0) { $lines[0..($superLine - 1)] } else { @() }
            $after = if ($superLine + 1 -lt $lines.Count) { $lines[($superLine + 1)..($lines.Count - 1)] } else { @() }
            $lines = @($before + $after)
            $insertAt = $braceLine + 1
            if ($superLine -lt $insertAt) { $insertAt-- }
            $prefix = if ($insertAt -gt 0) { $lines[0..($insertAt - 1)] } else { @() }
            $suffix = if ($insertAt -lt $lines.Count) { $lines[$insertAt..($lines.Count - 1)] } else { @() }
            $lines = @($prefix + $super + $suffix)
        }
    }

    return ($lines -join "`r`n")
}

foreach ($file in $files) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $original = $text

    # FFDec emits source-level stack pseudo-instructions that are not AS3.
    $text = $text.Replace("§§push(", "FFDecStack.push(")
    $text = $text.Replace("§§pop()", "FFDecStack.pop()")
    $text = $text.Replace("§§findproperty(", "FFDecStack.findproperty(")
    $text = $text.Replace("§§nextvalue(", "flash.Boot.__nextvalue(")
    $text = $text.Replace("§§nextname(", "flash.Boot.__nextname(")
    $text = $text.Replace("§§hasnext(", "flash.Boot.__hasnext(")
    $text = $text.Replace("§typeof§", "typeofValue")
    $text = $text.Replace("§as§", "asValue")
    $text = [regex]::Replace($text, '(?m)^var\s+_temp_\d+:\*\s*=\s*global;\r?\n?', '')
    $text = [regex]::Replace($text, '(?m)^var\s+_temp_\d+:\*\s*=\s*§§newclass\([^;]*;\r?\n?', '')

    # Symbol embeds reference FFDec-generated binary bundles that are not reliable
    # source artifacts here. Drop all Embed metadata in the generated tree so these
    # wrapper classes compile as empty MovieClip/Sprite/ByteArray stand-ins.
    $text = [regex]::Replace($text, '(?m)^\s*\[Embed\(source="/_assets/assets\.swf",\s*symbol="symbol\d+"\)\]\r?\n', '')
    $text = [regex]::Replace($text, '(?m)^\s*\[Embed\([^\]]*\)\]\r?\n', '')

    # Decompiler constructor guard often appears before super(), which AS3 rejects.
    # Move the first direct super(...) call to the top of the constructor body,
    # then keep the Boot guard immediately after it.
    if ($text.Contains("Boot.skip_constructor") -and $text -match '(?m)^\s*super\([^;]*\);') {
        $text = [regex]::Replace(
            $text,
            '(?s)(public\s+function\s+\w+\s*\([^)]*\)\s*\{\s*)if\s*\(Boot\.skip_constructor\)\s*\{\s*return;\s*\}(.*?)(\s*super\s*\([^;]*\);)',
            "`$1`$3`r`n         if(Boot.skip_constructor)`r`n         {`r`n            return;`r`n         }`$2"
        )
    }

    # Command subclasses accidentally decompile dispose() as private, conflicting
    # with Command.dispose(). Keep generated edits narrow to command files.
    if ($file.FullName -like "*\com\oyunstudyosu\commands\*.as") {
        $text = $text.Replace("private function dispose() : void", "override public function dispose() : void")
    }

    if ($file.FullName -like "*\as3reflect\*.as" -and $file.Name -ne "Type.as") {
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bType\b', 'as3reflect.Type')
    }

    if ($file.FullName -like "*\as3reflect\Type.as") {
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bIMetaDataContainer\b', 'as3reflect.IMetaDataContainer')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bIMember\b', 'as3reflect.IMember')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bType\b', 'as3reflect.Type')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bAccessor\b', 'as3reflect.Accessor')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bMethod\b', 'as3reflect.Method')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bParameter\b', 'as3reflect.Parameter')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bConstant\b', 'as3reflect.Constant')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bVariable\b', 'as3reflect.Variable')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bAccessorAccess\b', 'as3reflect.AccessorAccess')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bMetaData\b', 'as3reflect.MetaData')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bMetaDataArgument\b', 'as3reflect.MetaDataArgument')
        $text = $text.Replace("public function as3reflect.Type()", "public function Type()")
        $text = $text.Replace("class as3reflect.TypeXmlParser", "class TypeXmlParser")
        $text = $text.Replace("public class as3reflect.Type extends", "public class Type extends")
    }

    $text = $text.Replace("as3reflect.as3reflect.", "as3reflect.")

    # Apache Flex occasionally crashes on decompiled named Bindable metadata.
    # It is not needed for the recovered runtime path, so drop it in obj only.
    $text = [regex]::Replace($text, '(?m)^\s*\[Bindable\([^\]]*\)\]\r?\n', '')
    $text = [regex]::Replace($text, '(?m)^\s*\[(?!Embed\()[^\]]+\]\r?\n', '')

    if ($text.Contains("import as3reflect.Type;")) {
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bType\.forInstance', 'as3reflect.Type.forInstance')
        $text = [regex]::Replace($text, '(?<!as3reflect\.)\bType\.forName', 'as3reflect.Type.forName')
    }

    if ($text.Contains("import hx.Std;")) {
        $text = [regex]::Replace($text, '(?<!hx\.)\bStd\.', 'hx.Std.')
    }

    if ($text -match '(?m)^\s*public\s+function\s+' + [regex]::Escape($file.BaseName) + '\s*\(' -and $text -match '(?m)^\s*super\([^;]*\);') {
        $text = Move-FirstSuperCallAfterConstructorOpen -SourceText $text -ClassName $file.BaseName
    }

    if ($file.FullName -like "*\com\oyunstudyosu\displayAd\AdBot.as" -or $file.FullName -like "*\com\oyunstudyosu\displayAd\NpcBot.as") {
        $text = [regex]::Replace($text, '(?m)^\s*private\s+var\s+direction:int;\r?\n', '')
    }

    if ($file.FullName -like "*\de\polygonal\ds\LinkedQueueIterator.as") {
        $text = $text.Replace("return param1._removeNode(param2);", "param1._removeNode(param2);")
    }

    if ($file.FullName -like "*\extensions\notification\RoomMessageTip.as") {
        $text = $text.Replace("private function addedToStage(param1:Event) : void", "public function addedToStage(param1:Event) : void")
    }

    if ($file.FullName -like "*\com\oyunstudyosu\buddy\BuddyController.as" -and -not $text.Contains("com.oyunstudyosu.sanalika.interfaces.IBuddyModel")) {
        $text = $text.Replace("import com.oyunstudyosu.service.IServiceModel;", "import com.oyunstudyosu.service.IServiceModel;`r`n   import com.oyunstudyosu.sanalika.interfaces.IBuddyModel;")
    }

    if ($file.FullName -like "*\com\printfas3\printf.as") {
        $text = $text.Replace(
            'var _loc3_:RegExp = /%(?!^%)(\((?P<var_name>[\w]+[\w_\d]+)\))?(?P<padding>[0-9]{1,2})?(\.(?P<precision>[0-9]+))?(?P<formater>[sxofaAbBcdHIjmMpSUwWxXyYZ])/ig;',
            'var _loc3_:RegExp = /%(?!^%)(\(([\w]+[\w_\d]+)\))?([0-9]{1,2})?(\.([0-9]+))?([sxofaAbBcdHIjmMpSUwWxXyYZ])/ig;'
        )
        $text = $text.Replace('_loc12_ = _loc5_.formater;', '_loc12_ = _loc5_[6];')
        $text = $text.Replace('_loc13_ = _loc5_.var_name;', '_loc13_ = _loc5_[2];')
        $text = $text.Replace('_loc14_ = _loc5_.precision;', '_loc14_ = _loc5_[5];')
        $text = $text.Replace('_loc15_ = _loc5_.padding;', '_loc15_ = _loc5_[3];')
    }

    if ($text -ne $original) {
        Set-Content -LiteralPath $file.FullName -Value $text -NoNewline
        $changed++
    }
}

$helperPath = Join-Path $outputRoot "FFDecStack.as"
@'
package
{
   public class FFDecStack
   {
      private static var stack:Array = [];

      public function FFDecStack()
      {
      }

      public static function push(value:*) : *
      {
         stack.push(value);
         return value;
      }

      public static function pop() : *
      {
         return stack.length == 0 ? null : stack.pop();
      }

      public static function findproperty(value:*) : *
      {
         return value;
      }
   }
}
'@ | Set-Content -LiteralPath $helperPath -NoNewline

Write-Host "Preprocessed game source: $outputRoot"
Write-Host "Changed AS files:       $changed"
Write-Host "Helper:                 $helperPath"