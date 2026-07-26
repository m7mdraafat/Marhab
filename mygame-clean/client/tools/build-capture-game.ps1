[CmdletBinding()]
param(
    [string]$SdkHome,
    [string]$JavaHome = "C:/Program Files/Microsoft/jdk-17.0.18.8-hotspot",
    [string]$Source = "client/recovered/game-src",
    [string]$Output = "client/generated/capture-game-src",
    [string]$SwfOutput = "client/generated/capture/snl.780.capture.swf",
    [string]$MainClass = "Sanalika",
    [switch]$Compile,
   [switch]$PromoteToRuntime,
   [switch]$ValidateOnly,
   [switch]$UseExistingGenerated
)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../..")
$sourceRoot = Join-Path $repoRoot $Source
$outputRoot = Join-Path $repoRoot $Output
$mainFile = Join-Path $outputRoot "$MainClass.as"
$swfOutputPath = Join-Path $repoRoot $SwfOutput
$swfOutputDir = Split-Path $swfOutputPath -Parent
$runtimeSwf = Join-Path $repoRoot "client/runtime/snl.780.swf"
$assetDir = Join-Path $outputRoot "_assets"
$assetBundle = Join-Path $assetDir "assets.swf"

function Resolve-SdkRoot {
    param([string]$ExplicitSdkHome)

    $candidates = @(
        $ExplicitSdkHome,
        $env:AIR_SDK_HOME,
        $env:AIRSDK_HOME,
        $env:FLEX_HOME,
        $env:AIR_HOME
    ) | Where-Object { $_ }

    foreach ($candidate in $candidates) {
      if (-not (Test-Path -LiteralPath $candidate)) {
         Write-Warning "AIR/Flex SDK path does not exist: $candidate"
         continue
      }

      $resolved = (Resolve-Path $candidate).Path
      if (Test-Path -LiteralPath (Join-Path $resolved "lib\mxmlc.jar")) { return $resolved }

      Write-Warning "Skipping AIR/Flex path without lib\mxmlc.jar: $resolved"
    }

    return $null
}

function Resolve-Tool {
    param([string[]]$Names, [string]$SdkRoot)

    foreach ($name in $Names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }

    if ($SdkRoot) {
        foreach ($name in $Names) {
            foreach ($extension in ".bat", ".cmd", ".exe", "") {
                $candidate = Join-Path $SdkRoot "bin/$name$extension"
                if (Test-Path -LiteralPath $candidate) { return $candidate }
            }
        }
    }

    return $null
}

function Move-FirstSuperCallAfterConstructorOpen {
    param([string]$SourceText, [string]$ClassName)

   $lines = [regex]::Split($SourceText, '\r\n|\n|\r')
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -notmatch ('^\s*public\s+function\s+' + [regex]::Escape($ClassName) + '\s*\(')) { continue }

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

            if ($entered -and $braceDepth -le 0) { break }
        }

      if ($superLine -ge 0 -and $braceLine -ge 0 -and $superLine -ne ($braceLine + 1)) {
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

function Write-CaptureLogHelper {
    param([string]$OutputRoot)

    $captureDir = Join-Path $OutputRoot "com/oyunstudyosu/capture"
    New-Item -ItemType Directory -Force -Path $captureDir | Out-Null
    $captureFile = Join-Path $captureDir "CaptureLog.as"

@'
package com.oyunstudyosu.capture
{
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;

   public class CaptureLog
   {
      private static var captureFile:File;
      private static var failed:Boolean = false;
      private static var onceKeys:Object = {};
      private static var sequence:int = 0;
      private static const MAX_DEPTH:int = 8;
      private static const MAX_STRING:int = 250000;
      private static const MAX_BYTE_HEX:int = 512;

      public function CaptureLog()
      {
      }

      public static function write(kind:String, payload:* = null) : void
      {
         if(failed)
         {
            return;
         }
         try
         {
            var record:Object = {};
            record.seq = ++sequence;
            record.time = new Date().getTime();
            record.kind = kind;
            record.payload = safe(payload);
            append(JSON.stringify(record));
         }
         catch(error:Error)
         {
            try
            {
               append(JSON.stringify({"seq":++sequence,"time":new Date().getTime(),"kind":"capture.error","payload":{"kind":kind,"message":error.message}}));
            }
            catch(inner:Error)
            {
               failed = true;
            }
         }
      }

      public static function writeOnce(kind:String, key:String, payload:* = null) : void
      {
         var onceKey:String = kind + ":" + key;
         if(onceKeys[onceKey])
         {
            return;
         }
         onceKeys[onceKey] = true;
         write(kind,payload);
      }

      public static function writeSfsPacket(direction:String, packet:*) : void
      {
         var summary:Object = {};
         try
         {
            if(packet != null && packet.containsKey("c"))
            {
               summary.controller = packet.getByte("c");
            }
            if(packet != null && packet.containsKey("a"))
            {
               summary.action = packet.getShort("a");
            }
            if(packet != null && packet.containsKey("p"))
            {
               var params:* = packet.getSFSObject("p");
               if(params != null && params.containsKey("c"))
               {
                  summary.extensionCommand = params.getUtfString("c");
               }
            }
         }
         catch(error:Error)
         {
            summary.summaryError = error.message;
         }
         write("sfs." + direction,{"summary":summary,"packet":packet});
      }

      public static function writeEvent(event:Event) : void
      {
         var payload:Object = {"type":event != null ? event.type : null};
         try
         {
            payload.params = Object(event)["params"];
         }
         catch(error:Error)
         {
         }
         write("sfs.event",payload);
      }

      public static function writeRoomVariables(kind:String, room:*, changedVars:Array) : void
      {
         var values:Object = {};
         var name:String = null;
         if(room != null && changedVars != null)
         {
            for each(name in changedVars)
            {
               try
               {
                  values[name] = room.getVariable(name);
               }
               catch(error:Error)
               {
                  values[name] = {"captureError":error.message};
               }
            }
         }
         write(kind,{"room":room,"changedVars":changedVars,"values":values});
      }

      public static function writeUserVariables(kind:String, user:*, changedVars:Array) : void
      {
         var values:Object = {};
         var name:String = null;
         if(user != null && changedVars != null)
         {
            for each(name in changedVars)
            {
               try
               {
                  values[name] = user.getVariable(name);
               }
               catch(error:Error)
               {
                  values[name] = {"captureError":error.message};
               }
            }
         }
         write(kind,{"user":user,"changedVars":changedVars,"values":values});
      }

      public static function safe(value:*, depth:int = 0, keyHint:String = null) : *
      {
         if(keyHint != null && shouldRedact(keyHint))
         {
            return "[REDACTED]";
         }
         if(depth > MAX_DEPTH)
         {
            return "[MaxDepth]";
         }
         if(value == null)
         {
            return null;
         }
         if(value is String)
         {
            return truncate(String(value));
         }
         if(value is Number || value is Boolean || value is int || value is uint)
         {
            return value;
         }
         if(value is ByteArray)
         {
            return safeByteArray(ByteArray(value));
         }
         if(value is XML || value is XMLList)
         {
            return truncate(value.toString());
         }
         if(value is Array)
         {
            var array:Array = [];
            var source:Array = value as Array;
            var index:int = 0;
            while(index < source.length)
            {
               array[index] = safe(source[index],depth + 1);
               index++;
            }
            return array;
         }

         try
         {
            if(value.hasOwnProperty("toObject"))
            {
               return safe(value.toObject(),depth + 1);
            }
         }
         catch(toObjectError:Error)
         {
         }

         try
         {
            if(value.hasOwnProperty("size") && value.hasOwnProperty("getElementAt"))
            {
               return safeSfsArray(value,depth + 1);
            }
         }
         catch(sfsArrayError:Error)
         {
         }

         try
         {
            if(value.hasOwnProperty("getValue") && value.hasOwnProperty("name") && value.hasOwnProperty("type"))
            {
               return safeVariable(value,depth + 1);
            }
         }
         catch(variableError:Error)
         {
         }

         try
         {
            if(value.hasOwnProperty("getVariables") && value.hasOwnProperty("groupId"))
            {
               return safeRoom(value,depth + 1);
            }
         }
         catch(roomError:Error)
         {
         }

         try
         {
            if(value.hasOwnProperty("getVariables") && value.hasOwnProperty("privilegeId"))
            {
               return safeUser(value,depth + 1);
            }
         }
         catch(userError:Error)
         {
         }

         var result:Object = {"__class":getQualifiedClassName(value)};
         try
         {
            for(var key:String in value)
            {
               result[key] = safe(value[key],depth + 1,key);
            }
         }
         catch(error:Error)
         {
            result.__captureError = error.message;
            try
            {
               result.__string = truncate(String(value));
            }
            catch(inner:Error)
            {
            }
         }
         return result;
      }

      private static function safeSfsArray(value:*, depth:int) : Array
      {
         var result:Array = [];
         var index:int = 0;
         while(index < value.size())
         {
            result[index] = safe(value.getElementAt(index),depth + 1);
            index++;
         }
         return result;
      }

      private static function safeVariable(value:*, depth:int) : Object
      {
         return {
            "name":value.name,
            "type":value.type,
            "value":safe(value.getValue(),depth + 1)
         };
      }

      private static function safeRoom(room:*, depth:int) : Object
      {
         var variables:Object = {};
         var list:Array = room.getVariables();
         var variable:* = null;
         for each(variable in list)
         {
            variables[variable.name] = safeVariable(variable,depth + 1);
         }
         return {
            "id":room.id,
            "name":room.name,
            "groupId":room.groupId,
            "isJoined":room.isJoined,
            "isGame":room.isGame,
            "userCount":room.userCount,
            "maxUsers":room.maxUsers,
            "variables":variables
         };
      }

      private static function safeUser(user:*, depth:int) : Object
      {
         var variables:Object = {};
         var list:Array = user.getVariables();
         var variable:* = null;
         for each(variable in list)
         {
            variables[variable.name] = safeVariable(variable,depth + 1);
         }
         return {
            "id":user.id,
            "name":user.name,
            "playerId":user.playerId,
            "privilegeId":user.privilegeId,
            "isItMe":user.isItMe,
            "variables":variables
         };
      }

      private static function safeByteArray(bytes:ByteArray) : Object
      {
         var oldPosition:uint = bytes.position;
         var hex:Array = [];
         var count:int = Math.min(bytes.length,MAX_BYTE_HEX);
         bytes.position = 0;
         var index:int = 0;
         while(index < count)
         {
            var item:String = bytes.readUnsignedByte().toString(16);
            if(item.length == 1)
            {
               item = "0" + item;
            }
            hex.push(item);
            index++;
         }
         bytes.position = oldPosition;
         return {"length":bytes.length,"hexPrefix":hex.join(" ")};
      }

      private static function append(line:String) : void
      {
         if(captureFile == null)
         {
            var dir:File = File.applicationStorageDirectory.resolvePath("captures");
            if(!dir.exists)
            {
               dir.createDirectory();
            }
            captureFile = dir.resolvePath("sfs-capture-" + new Date().getTime() + ".jsonl");
            trace("[CAPTURE] writing " + captureFile.nativePath);
         }
         var stream:FileStream = new FileStream();
         stream.open(captureFile,FileMode.APPEND);
         stream.writeUTFBytes(line + "\n");
         stream.close();
      }

      private static function truncate(value:String) : String
      {
         if(value == null || value.length <= MAX_STRING)
         {
            return value;
         }
         return value.substr(0,MAX_STRING) + "...[truncated " + value.length + "]";
      }

      private static function shouldRedact(key:String) : Boolean
      {
         var lower:String = key.toLowerCase();
         return lower == "at" || lower.indexOf("password") >= 0 || lower.indexOf("passwd") >= 0 || lower.indexOf("token") >= 0 || lower.indexOf("secret") >= 0 || lower.indexOf("authorization") >= 0 || lower.indexOf("cookie") >= 0;
      }
   }
}
'@ | Set-Content -LiteralPath $captureFile -NoNewline

    $runtimeFile = Join-Path $captureDir "CaptureRuntime.as"
@'
package com.oyunstudyosu.capture
{
   import flash.utils.getDefinitionByName;

   public class CaptureRuntime
   {
      public function CaptureRuntime()
      {
      }

      public static function get sanalikaInstance() : *
      {
         return getDefinitionByName("Sanalika")["instance"];
      }
   }
}
'@ | Set-Content -LiteralPath $runtimeFile -NoNewline
}

function Add-CaptureImport {
    param([string]$Path, [string]$Import)

    $text = Get-Content -LiteralPath $Path -Raw
    $line = "   import $Import;"
    if ($text.Contains($line)) { return }
    $text = [regex]::Replace($text, '(?m)^(\{\r?\n)', "`$1$line`r`n", 1)
    Set-Content -LiteralPath $Path -Value $text -NoNewline
}

function Update-TextOnce {
    param([string]$Path, [string]$Old, [string]$New)

    $text = Get-Content -LiteralPath $Path -Raw
   if (-not $text.Contains($Old)) {
      throw "Instrumentation marker not found in ${Path}: $Old"
    }
    $text = $text.Replace($Old, $New)
    Set-Content -LiteralPath $Path -Value $text -NoNewline
}

function Test-CaptureSourceAnchors {
   $checks = @(
      @("com/smartfoxserver/v2/core/SFSProtocolCodec.as", @("         this.dispatchRequest(_loc2_);", "         this.ioHandler.onDataWrite(param1);")),
      @("com/smartfoxserver/v2/SmartFox.as", @("      public function enableFullPacketDump(param1:Boolean) : void")),
      @("com/oyunstudyosu/service/ServiceModel.as", @("         _sfs.send(new ExtensionRequest(param1,_loc7_.getSFSObject(),param4));", "         _loc6_ = _loc5_.toObject();", "         var _loc5_:Room = param1.params.room as Room;", "         var _loc3_:User = param1.params.user as User;")),
      @("com/oyunstudyosu/room/RoomModel.as", @("         roomData = param1;", "         _map = XMLList(Base64.decode(param1));")),
      @("com/oyunstudyosu/door/DoorModel.as", @("         var _loc2_:IDoorVO = _map[param1];", "         Sanalika.instance.roomModel.buildingData = param4;", "         var _loc4_:int = 0;", "         var _loc2_:Array = JSON.parse(param1) as Array;")),
      @("com/oyunstudyosu/model/GridModel.as", @("         this._data[param2 * this._width + param1] = param3;", "         var byteArray:ByteArray = Base64.decodeToByteArray(value);", "            this.inited = true;"))
   )

   foreach ($check in $checks) {
      $path = Join-Path $sourceRoot $check[0]
      if (-not (Test-Path -LiteralPath $path)) { throw "Capture source anchor file missing: $path" }
      $text = Get-Content -LiteralPath $path -Raw
      foreach ($needle in $check[1]) {
         if (-not $text.Contains($needle)) { throw "Capture source anchor missing in ${path}: $needle" }
      }
   }
}

function Invoke-RecoveredSourcePreprocess {
    param([string]$OutputRoot)

    $files = Get-ChildItem -LiteralPath $OutputRoot -Recurse -File -Filter *.as
    $changed = 0

    foreach ($file in $files) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        $original = $text

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
        $text = [regex]::Replace($text, '(?m)^\s*\[Embed\(source="/_assets/assets\.swf",\s*symbol="symbol\d+"\)\]\r?\n', '')
        $text = [regex]::Replace($text, '(?m)^\s*\[Embed\([^\]]*\)\]\r?\n', '')

        if ($text.Contains("Boot.skip_constructor") -and $text -match '(?m)^\s*super\([^;]*\);') {
            $text = [regex]::Replace(
                $text,
                '(?s)(public\s+function\s+\w+\s*\([^)]*\)\s*\{\s*)if\s*\(Boot\.skip_constructor\)\s*\{\s*return;\s*\}(.*?)(\s*super\s*\([^;]*\);)',
                "`$1`$3`r`n         if(Boot.skip_constructor)`r`n         {`r`n            return;`r`n         }`$2"
            )
        }

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
        $text = [regex]::Replace($text, '(?m)^\s*\[Bindable\([^\]]*\)\]\r?\n', '')
        $text = [regex]::Replace($text, '(?m)^\s*\[(?!Embed\()[^\]]+\]\r?\n', '')

        if ($text.Contains("import as3reflect.Type;")) {
            $text = [regex]::Replace($text, '(?<!as3reflect\.)\bType\.forInstance', 'as3reflect.Type.forInstance')
            $text = [regex]::Replace($text, '(?<!as3reflect\.)\bType\.forName', 'as3reflect.Type.forName')
        }

        if ($text.Contains("import hx.Std;")) {
            $text = [regex]::Replace($text, '(?<!hx\.)\bStd\.', 'hx.Std.')
        }

      if (($text -match ('(?m)^\s*public\s+function\s+' + [regex]::Escape($file.BaseName) + '\s*\(')) -and ($text -match '(?m)^\s*super\([^;]*\);')) {
            $text = Move-FirstSuperCallAfterConstructorOpen -SourceText $text -ClassName $file.BaseName
        }

        if ($file.FullName -like "*\com\oyunstudyosu\displayAd\AdBot.as" -or $file.FullName -like "*\com\oyunstudyosu\displayAd\NpcBot.as") {
            $text = [regex]::Replace($text, '(?m)^\s*private\s+var\s+direction:int;\r?\n', '')
        }

        if ($file.FullName -like "*\de\polygonal\ds\LinkedQueueIterator.as") {
            $text = $text.Replace("return param1._removeNode(param2);", "param1._removeNode(param2);")
        }

      if ($file.FullName -like "*\extensions\notification\RoomMessageTip.as") {
         $text = $text.Replace("private function addedToStage(param1:Event) : void", "private function unusedAddedToStage(param1:Event) : void")
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

         if ($file.FullName -like "*\lime\_internal\format\Base64.as") {
            $markerIndex = $text.IndexOf("null as String;", [StringComparison]::Ordinal)
            if ($markerIndex -ge 0) {
               $text = $text.Substring(0,$markerIndex).TrimEnd() + "`r`n"
            }
         }

         if ($file.FullName -like "*\flash\Boot.as" -or $file.FullName -like "*\lime\app\Application.as" -or $file.FullName -like "*\lime\math\_RGBA\RGBA_Impl_.as") {
            $cleanupLines = [regex]::Split($text, '\r\n|\n|\r')
            $braceDepth = 0
            $enteredPackageBlock = $false
            for ($cleanupIndex = 0; $cleanupIndex -lt $cleanupLines.Count; $cleanupIndex++) {
               $cleanupLine = $cleanupLines[$cleanupIndex]
               $braceDepth += ([regex]::Matches($cleanupLine, '\{')).Count - ([regex]::Matches($cleanupLine, '\}')).Count
               if ($braceDepth -gt 0) {
                  $enteredPackageBlock = $true
               }
               if ($enteredPackageBlock -and $braceDepth -eq 0 -and $cleanupIndex + 1 -lt $cleanupLines.Count) {
                  $trailingText = ($cleanupLines[($cleanupIndex + 1)..($cleanupLines.Count - 1)] -join "").Trim()
                  if ($trailingText.Length -gt 0) {
                     $text = ($cleanupLines[0..$cleanupIndex] -join "`r`n") + "`r`n"
                  }
                  break
               }
            }
         }

         if ($file.FullName -like "*\flash\Boot.as") {
            if (-not $text.Contains("import com.oyunstudyosu.capture.CaptureLog;")) {
               $text = [regex]::Replace($text, '(?m)^\s*import\s+haxe\.Exception;\r?\n', "   import haxe.Exception;`r`n   import com.oyunstudyosu.capture.CaptureLog;`r`n", 1)
            }
            if (-not $text.Contains('CaptureLog.write("startup.boot"')) {
               $text = $text.Replace("         super();", '         super();' + "`r`n" + '         try { CaptureLog.write("startup.boot",{}); } catch(_captureError:*) {}')
            }
         }

         if ($file.Name -ne "Sanalika.as" -and $text.Contains("Sanalika.instance")) {
            $text = $text.Replace("Sanalika.instance", "CaptureRuntime.sanalikaInstance")
            if (-not $text.Contains("import com.oyunstudyosu.capture.CaptureRuntime;")) {
               $text = [regex]::Replace($text, '(?s)^(\s*package(?:\s+[A-Za-z_][A-Za-z0-9_.]*)?\s*\{\s*)', "`$1   import com.oyunstudyosu.capture.CaptureRuntime;`r`n", 1)
            }
         }

         if ($file.Name -eq "Sanalika.as") {
            if (-not $text.Contains("import com.oyunstudyosu.capture.CaptureLog;")) {
               $text = [regex]::Replace($text, '(?m)^\s*import\s+com\.adobe\.crypto\.MD5;\r?\n', "   import com.adobe.crypto.MD5;`r`n   import com.oyunstudyosu.capture.CaptureLog;`r`n", 1)
            }
            if (-not $text.Contains('CaptureLog.write("startup.sanalika"')) {
               $text = $text.Replace("         super();", '         super();' + "`r`n" + '         CaptureLog.write("startup.sanalika",{"playerType":Capabilities.playerType});')
            }
         }

         if ($file.FullName -like "*\com\smartfoxserver\v2\*") {
            if ($file.Name -ne "SmartFox.as") {
               $text = [regex]::Replace($text, '(?m)^\s*import\s+com\.smartfoxserver\.v2\.SmartFox;\r?\n', '')
               $text = [regex]::Replace($text, '(:\s*)SmartFox\b', '$1*')
            }
            if ($file.Name -ne "BitSwarmClient.as" -and $file.Name -ne "SmartFox.as") {
               $text = [regex]::Replace($text, '(?m)^\s*import\s+com\.smartfoxserver\.v2\.bitswarm\.BitSwarmClient;\r?\n', '')
               $text = [regex]::Replace($text, '(:\s*)BitSwarmClient\b', '$1*')
            }
         }

        if ($file.FullName -like "*\de\polygonal\ds\HashMap.as") {
            $text = @'
package de.polygonal.ds
{
   import flash.utils.Dictionary;

   public class HashMap implements Map
   {
      public var reuseIterator:Boolean = false;
      public var maxSize:int = -1;
      public var key:int = 0;
      public var _weak:Boolean;
      public var _size:int = 0;
      public var _map:Dictionary;

      public function HashMap(param1:Boolean = false, param2:int = -1)
      {
         _weak = param1;
         maxSize = param2;
         _map = new Dictionary(_weak);
      }

      public function set(param1:Object, param2:Object) : Boolean
      {
         if(_map[param1] !== undefined)
         {
            return false;
         }
         _map[param1] = param2;
         _size++;
         return true;
      }

      public function remap(param1:Object, param2:Object) : Boolean
      {
         if(_map[param1] === undefined)
         {
            return false;
         }
         _map[param1] = param2;
         return true;
      }

      public function get(param1:Object) : Object
      {
         return _map[param1];
      }

      public function hasKey(param1:Object) : Boolean
      {
         return _map[param1] !== undefined;
      }

      public function has(param1:Object) : Boolean
      {
         return contains(param1);
      }

      public function contains(param1:Object) : Boolean
      {
         for each(var value:Object in _map)
         {
            if(value === param1)
            {
               return true;
            }
         }
         return false;
      }

      public function clr(param1:Object) : Boolean
      {
         if(_map[param1] === undefined)
         {
            return false;
         }
         delete _map[param1];
         _size--;
         return true;
      }

      public function remove(param1:Object) : Boolean
      {
         for(var keyObject:Object in _map)
         {
            if(_map[keyObject] === param1)
            {
               delete _map[keyObject];
               _size--;
               return true;
            }
         }
         return false;
      }

      public function keys() : Itr
      {
         return new HashMapKeyIterator(this);
      }

      public function iterator() : Itr
      {
         return new HashMapValIterator(this);
      }

      public function toKeyArray() : Array
      {
         var result:Array = [];
         for(var keyObject:Object in _map)
         {
            result.push(keyObject);
         }
         return result;
      }

      public function toArray() : Array
      {
         var result:Array = [];
         for each(var value:Object in _map)
         {
            result.push(value);
         }
         return result;
      }

      public function size() : int
      {
         return _size;
      }

      public function isEmpty() : Boolean
      {
         return _size == 0;
      }

      public function clear(param1:Boolean = false) : void
      {
         _map = new Dictionary(_weak);
         _size = 0;
      }

      public function free() : void
      {
         clear();
      }

      public function clone(param1:Boolean = false, param2:Function = null) : Collection
      {
         var copy:HashMap = new HashMap(_weak,maxSize);
         for(var keyObject:Object in _map)
         {
            copy.set(keyObject,param2 != null ? param2(_map[keyObject]) : _map[keyObject]);
         }
         return copy;
      }

      public function toValSet() : Set
      {
         return null;
      }

      public function toKeySet() : Set
      {
         return null;
      }

      public function toKeyDA() : DA
      {
         return null;
      }

      public function toDA() : DA
      {
         return null;
      }

      public function toString() : String
      {
         return "{HashMap, size: " + _size + "}";
      }
   }
}
'@
        }

        if ($file.FullName -like "*\de\polygonal\ds\HashMapKeyIterator.as") {
            $text = @'
package de.polygonal.ds
{
   public class HashMapKeyIterator implements Itr
   {
      private var _f:HashMap;
      private var _keys:Array;
      private var _i:int;

      public function HashMapKeyIterator(param1:HashMap)
      {
         _f = param1;
         reset();
      }

      public function reset() : Itr
      {
         _keys = _f.toKeyArray();
         _i = 0;
         return this;
      }

      public function remove() : void
      {
         if(_i > 0)
         {
            _f.clr(_keys[_i - 1]);
         }
      }

      public function next() : Object
      {
         return _keys[_i++];
      }

      public function hasNext() : Boolean
      {
         return _i < _keys.length;
      }
   }
}
'@
        }

        if ($file.FullName -like "*\de\polygonal\ds\HashMapValIterator.as") {
            $text = @'
package de.polygonal.ds
{
   public class HashMapValIterator implements Itr
   {
      private var _f:HashMap;
      private var _keys:Array;
      private var _i:int;

      public function HashMapValIterator(param1:HashMap)
      {
         _f = param1;
         reset();
      }

      public function reset() : Itr
      {
         _keys = _f.toKeyArray();
         _i = 0;
         return this;
      }

      public function remove() : void
      {
         if(_i > 0)
         {
            _f.clr(_keys[_i - 1]);
         }
      }

      public function next() : Object
      {
         return _f.get(_keys[_i++]);
      }

      public function hasNext() : Boolean
      {
         return _i < _keys.length;
      }
   }
}
'@
        }

        if ($text -ne $original) {
            Set-Content -LiteralPath $file.FullName -Value $text -NoNewline
            $changed++
        }
    }

    $helperPath = Join-Path $OutputRoot "FFDecStack.as"
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

    $cairoDir = Join-Path $OutputRoot "lime\graphics\cairo"
    New-Item -ItemType Directory -Force -Path $cairoDir | Out-Null
    $cairoPath = Join-Path $cairoDir "Cairo.as"
@'
package lime.graphics.cairo
{
   public class Cairo
   {
      public function Cairo()
      {
      }
   }
}
'@ | Set-Content -LiteralPath $cairoPath -NoNewline

    $bytePointerPath = Join-Path $OutputRoot "lime\utils\BytePointerData.as"
@'
package lime.utils
{
   import haxe.io.Bytes;

   public class BytePointerData
   {
      public var bytes:Bytes;
      public var offset:int;

      public function BytePointerData(param1:Bytes = null, param2:int = 0)
      {
         bytes = param1;
         offset = param2;
      }
   }
}
'@ | Set-Content -LiteralPath $bytePointerPath -NoNewline

    Write-Host "Preprocessed capture source: $OutputRoot"
    Write-Host "Changed AS files:            $changed"
}

function Add-CaptureInstrumentation {
    param([string]$OutputRoot)

   $nl = "`r`n"

    $sfsProtocol = Join-Path $OutputRoot "com/smartfoxserver/v2/core/SFSProtocolCodec.as"
   Add-CaptureImport -Path $sfsProtocol -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $sfsProtocol -Old '         this.dispatchRequest(_loc2_);' -New ('         CaptureLog.writeSfsPacket("in",_loc2_);' + $nl + '         this.dispatchRequest(_loc2_);')
   Update-TextOnce -Path $sfsProtocol -Old '         this.ioHandler.onDataWrite(param1);' -New ('         CaptureLog.writeSfsPacket("out",_loc2_);' + $nl + '         this.ioHandler.onDataWrite(param1);')

   # Keep SmartFox itself unmodified for compiler stability. Packet, extension,
   # room variable, user variable, room map, door, and grid hooks still capture
   # the server contract we need.

    $serviceModel = Join-Path $OutputRoot "com/oyunstudyosu/service/ServiceModel.as"
   Add-CaptureImport -Path $serviceModel -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $serviceModel -Old '         _sfs.send(new ExtensionRequest(param1,_loc7_.getSFSObject(),param4));' -New ('         CaptureLog.write("extension.out",{"cmd":param1,"data":CaptureLog.safe(param2)});' + $nl + '         CaptureLog.write("extension.send.before",{"cmd":param1,"connected":_sfs.isConnected,"roomId":_sfs.lastJoinedRoom == null ? null : _sfs.lastJoinedRoom.id});' + $nl + '         try' + $nl + '         {' + $nl + '            _sfs.send(new ExtensionRequest(param1,_loc7_.getSFSObject(),param4));' + $nl + '            CaptureLog.write("extension.send.after",{"cmd":param1,"connected":_sfs.isConnected});' + $nl + '         }' + $nl + '         catch(_captureSendError:*)' + $nl + '         {' + $nl + '            CaptureLog.write("extension.send.error",{"cmd":param1,"message":String(_captureSendError)});' + $nl + '            throw _captureSendError;' + $nl + '         }')
   Update-TextOnce -Path $serviceModel -Old '         _loc6_ = _loc5_.toObject();' -New ('         _loc6_ = _loc5_.toObject();' + $nl + '         CaptureLog.write("extension.in",{"cmd":_loc13_,"data":CaptureLog.safe(_loc6_)});')
   Update-TextOnce -Path $serviceModel -Old '         var _loc5_:Room = param1.params.room as Room;' -New ('         var _loc5_:Room = param1.params.room as Room;' + $nl + '         CaptureLog.writeRoomVariables("roomVariablesUpdate",_loc5_,_loc6_);')
   Update-TextOnce -Path $serviceModel -Old '         var _loc3_:User = param1.params.user as User;' -New ('         var _loc3_:User = param1.params.user as User;' + $nl + '         CaptureLog.writeUserVariables("userVariablesUpdate",_loc3_,_loc4_);')

         $extensionModel = Join-Path $OutputRoot "com/oyunstudyosu/model/ExtensionModel.as"
         Add-CaptureImport -Path $extensionModel -Import "com.oyunstudyosu.capture.CaptureLog"
         Add-CaptureImport -Path $extensionModel -Import "flash.utils.setTimeout"
         Update-TextOnce -Path $extensionModel -Old '            _loc7_ = param1[_loc6_];' -New ('            _loc7_ = param1[_loc6_];' + $nl + '            if(_loc6_ == "SoundExtension" || _loc6_ == "CursorExtension" || _loc6_ == "FishingExtension")' + $nl + '            {' + $nl + '               CaptureLog.write("extension.load.skip",{"name":_loc6_,"reason":"capture-optional-presentation","property":CaptureLog.safe(_loc7_)});' + $nl + '               continue;' + $nl + '            }')
         Update-TextOnce -Path $extensionModel -Old '            _loc5_.priority = 97;' -New ('            _loc5_.priority = 97;' + $nl + '            CaptureLog.write("extension.load.request",{"name":_loc5_.name,"assetId":_loc5_.assetId,"type":param2,"property":CaptureLog.safe(_loc7_)});')
         Update-TextOnce -Path $extensionModel -Old '         var _loc4_:AssetRequestQueue = new AssetRequestQueue(_loc3_);' -New ('         if(_loc3_.length == 0)' + $nl + '         {' + $nl + '            CaptureLog.write("extension.load.complete",{"skippedOnly":true,"async":true});' + $nl + '            setTimeout(function():void' + $nl + '            {' + $nl + '               CaptureLog.write("extension.load.dispatch",{"event":"EXTENSIONS_LOADED"});' + $nl + '               Dispatcher.dispatchEvent(new GameEvent("EXTENSIONS_LOADED"));' + $nl + '            },1);' + $nl + '            return;' + $nl + '         }' + $nl + '         var _loc4_:AssetRequestQueue = new AssetRequestQueue(_loc3_);')
         Update-TextOnce -Path $extensionModel -Old '               _loc3_ = _loc4_.getDefinition("extensions." + _loc2_.name) as Class;' -New ('               try' + $nl + '               {' + $nl + '                  CaptureLog.write("extension.load.definition",{"name":_loc2_.name,"assetId":_loc2_.assetId});' + $nl + '                  _loc3_ = _loc4_.getDefinition("extensions." + _loc2_.name) as Class;' + $nl + '               }' + $nl + '               catch(_captureExtensionDefinitionError:*)' + $nl + '               {' + $nl + '                  CaptureLog.write("extension.load.error",{"phase":"definition","name":_loc2_.name,"assetId":_loc2_.assetId,"message":String(_captureExtensionDefinitionError)});' + $nl + '                  _loc3_ = null;' + $nl + '               }')
         Update-TextOnce -Path $extensionModel -Old '                  addExtension(_loc2_.name,_loc3_,_loc2_.data.property,_loc2_.data.type);' -New ('                  try' + $nl + '                  {' + $nl + '                     CaptureLog.write("extension.load.instantiate",{"name":_loc2_.name,"assetId":_loc2_.assetId});' + $nl + '                     addExtension(_loc2_.name,_loc3_,_loc2_.data.property,_loc2_.data.type);' + $nl + '                  }' + $nl + '                  catch(_captureExtensionInstantiateError:*)' + $nl + '                  {' + $nl + '                     CaptureLog.write("extension.load.error",{"phase":"instantiate","name":_loc2_.name,"assetId":_loc2_.assetId,"message":String(_captureExtensionInstantiateError)});' + $nl + '                  }')

      $configCommand = Join-Path $OutputRoot "com/oyunstudyosu/commands/ConfigCommand.as"
      Add-CaptureImport -Path $configCommand -Import "com.oyunstudyosu.capture.CaptureLog"
      Update-TextOnce -Path $configCommand -Old '         CaptureRuntime.sanalikaInstance.gameModel.fileServer = param1.fileServer[0] + "/global";' -New ('         var _captureFileServer:String = String(param1.fileServer[0]);' + $nl + '         while(_captureFileServer.indexOf("http://") == 0)' + $nl + '         {' + $nl + '            _captureFileServer = _captureFileServer.substr(7);' + $nl + '         }' + $nl + '         while(_captureFileServer.indexOf("https://") == 0)' + $nl + '         {' + $nl + '            _captureFileServer = _captureFileServer.substr(8);' + $nl + '         }' + $nl + '         CaptureRuntime.sanalikaInstance.gameModel.fileServer = _captureFileServer + "/global";' + $nl + '         var _captureConfigFileServer:Object = new Object();' + $nl + '         _captureConfigFileServer.rawFileServer = String(param1.fileServer[0]);' + $nl + '         _captureConfigFileServer.protocol = String(CaptureRuntime.sanalikaInstance.gameModel.protocol);' + $nl + '         _captureConfigFileServer.storedFileServer = _captureFileServer + "/global";' + $nl + '         _captureConfigFileServer.fileServer = CaptureRuntime.sanalikaInstance.gameModel.fileServer;' + $nl + '         _captureConfigFileServer.itemInfoFile = CaptureRuntime.sanalikaInstance.gameModel.itemInfoFile;' + $nl + '         _captureConfigFileServer.versionFile = CaptureRuntime.sanalikaInstance.gameModel.versionFile;' + $nl + '         _captureConfigFileServer.languageFileVersion = CaptureRuntime.sanalikaInstance.gameModel.languageFileVersion;' + $nl + '         CaptureLog.write("config.fileServer",_captureConfigFileServer);')
      Update-TextOnce -Path $configCommand -Old ('         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.CONFIG_READY));' + $nl + '         complete();') -New ('         CaptureLog.write("config.ready",{});' + $nl + '         complete();' + $nl + '         try' + $nl + '         {' + $nl + '            Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.CONFIG_READY));' + $nl + '         }' + $nl + '         catch(_captureProgressError:*)' + $nl + '         {' + $nl + '            CaptureLog.write("config.progress.error",{"message":String(_captureProgressError)});' + $nl + '         }')

      $serialCommand = Join-Path $OutputRoot "com/oyunstudyosu/commands/SerialCommand.as"
      Add-CaptureImport -Path $serialCommand -Import "com.oyunstudyosu.capture.CaptureLog"
      Add-CaptureImport -Path $serialCommand -Import "flash.utils.getQualifiedClassName"
      Update-TextOnce -Path $serialCommand -Old '         _loc1_.execute();' -New ('         CaptureLog.write("serial.execute",{"index":this._completedCommandCount,"command":getQualifiedClassName(_loc1_)});' + $nl + '         try' + $nl + '         {' + $nl + '            _loc1_.execute();' + $nl + '         }' + $nl + '         catch(_captureCommandError:*)' + $nl + '         {' + $nl + '            CaptureLog.write("serial.execute.error",{"index":this._completedCommandCount,"command":getQualifiedClassName(_loc1_),"message":String(_captureCommandError)});' + $nl + '            _loc1_.dispatchEvent(new Event(Event.COMPLETE));' + $nl + '         }')
      Update-TextOnce -Path $serialCommand -Old '            _loc2_.execute();' -New ('            CaptureLog.write("serial.execute",{"index":this._completedCommandCount,"command":getQualifiedClassName(_loc2_)});' + $nl + '            try' + $nl + '            {' + $nl + '               _loc2_.execute();' + $nl + '            }' + $nl + '            catch(_captureCommandError:*)' + $nl + '            {' + $nl + '               CaptureLog.write("serial.execute.error",{"index":this._completedCommandCount,"command":getQualifiedClassName(_loc2_),"message":String(_captureCommandError)});' + $nl + '               _loc2_.dispatchEvent(new Event(Event.COMPLETE));' + $nl + '            }')

      $localizationCommand = Join-Path $OutputRoot "com/oyunstudyosu/commands/LocalizationCommand.as"
      Add-CaptureImport -Path $localizationCommand -Import "com.oyunstudyosu.capture.CaptureLog"
      Update-TextOnce -Path $localizationCommand -Old '         CaptureRuntime.sanalikaInstance.localizationModel = new LocalizationModel();' -New ('         CaptureLog.write("startup.localization.execute",{});' + $nl + '         CaptureRuntime.sanalikaInstance.localizationModel = new LocalizationModel();')
      Update-TextOnce -Path $localizationCommand -Old '         CaptureRuntime.sanalikaInstance.localizationModel.init(_loc1_);' -New ('         CaptureLog.write("startup.localization.start",{"language":_loc1_.language,"fileServer":_loc1_.fileServer,"version":_loc1_.version});' + $nl + '         CaptureRuntime.sanalikaInstance.localizationModel.init(_loc1_);')
      Update-TextOnce -Path $localizationCommand -Old '         complete();' -New ('         CaptureLog.write("startup.localization.complete",{});' + $nl + '         complete();')

      $localizationModel = Join-Path $OutputRoot "com/oyunstudyosu/local/LocalizationModel.as"
      Add-CaptureImport -Path $localizationModel -Import "com.oyunstudyosu.capture.CaptureLog"
      Add-CaptureImport -Path $localizationModel -Import "flash.events.ErrorEvent"
      Add-CaptureImport -Path $localizationModel -Import "flash.events.SecurityErrorEvent"
      Update-TextOnce -Path $localizationModel -Old '         GetText.debugMode = param1.debugMode;' -New ('         GetText.debugMode = param1.debugMode;' + $nl + '         CaptureLog.write("localization.init",{"language":param1.language,"fileServer":param1.fileServer,"version":param1.version});')
      Update-TextOnce -Path $localizationModel -Old '            this.primaryTranslator.addEventListener(IOErrorEvent.IO_ERROR,this.onError);' -New ('            this.primaryTranslator.addEventListener(IOErrorEvent.IO_ERROR,this.onError);' + $nl + '            this.primaryTranslator.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);' + $nl + '            this.primaryTranslator.addEventListener(ErrorEvent.ERROR,this.onError);')
      Update-TextOnce -Path $localizationModel -Old '         trace("translation load error.");' -New ('         CaptureLog.write("localization.error",{"type":param1.type,"text":param1.toString()});' + $nl + '         trace("translation load error.");')
      Update-TextOnce -Path $localizationModel -Old '            this.primaryTranslator.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);' -New ('            this.primaryTranslator.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);' + $nl + '            this.primaryTranslator.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);' + $nl + '            this.primaryTranslator.removeEventListener(ErrorEvent.ERROR,this.onError);')
      Update-TextOnce -Path $localizationModel -Old '               this.secondaryTranslator.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);' -New ('               this.secondaryTranslator.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);' + $nl + '               this.secondaryTranslator.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);' + $nl + '               this.secondaryTranslator.removeEventListener(ErrorEvent.ERROR,this.onError);')
      Update-TextOnce -Path $localizationModel -Old '            Dispatcher.dispatchEvent(new Event(LOCALIZATION_DATA_READY));' -New ('            CaptureLog.write("localization.ready",{});' + $nl + '            Dispatcher.dispatchEvent(new Event(LOCALIZATION_DATA_READY));')
      Update-TextOnce -Path $localizationModel -Old '         this.check();' -New ('         CaptureLog.write("localization.complete",{"type":param1.type});' + $nl + '         this.check();')

      $getText = Join-Path $OutputRoot "com/oyunstudyosu/local/GetText.as"
      Add-CaptureImport -Path $getText -Import "com.oyunstudyosu.capture.CaptureLog"
      Update-TextOnce -Path $getText -Old '         _loc1_ = fileServer + version;' -New ('         _loc1_ = fileServer + version;' + $nl + '         CaptureLog.write("localization.getText.load",{"language":this.language,"url":_loc1_});')
      Update-TextOnce -Path $getText -Old '         var event:Event = param1;' -New ('         var event:Event = param1;' + $nl + '         CaptureLog.write("localization.getText.event",{"type":event.type,"text":event.toString()});')
      Update-TextOnce -Path $getText -Old '               errEvent = new ErrorEvent(ErrorEvent.ERROR,true,false,"EOFError: " + e.message);' -New ('               CaptureLog.write("localization.getText.parseError",{"message":e.message});' + $nl + '               errEvent = new ErrorEvent(ErrorEvent.ERROR,true,false,"EOFError: " + e.message);')

       $sanalika = Join-Path $OutputRoot "Sanalika.as"
      Update-TextOnce -Path $sanalika -Old '         this.removeEventListener("addedToStage",onAddedToStage);' -New ('         this.removeEventListener("addedToStage",onAddedToStage);' + $nl + '         try' + $nl + '         {' + $nl + '            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,onUncaughtErrorHandler);' + $nl + '         }' + $nl + '         catch(_captureUncaughtHookError:*)' + $nl + '         {' + $nl + '            CaptureLog.write("child.error.hookFailed",{"message":String(_captureUncaughtHookError)});' + $nl + '         }')
      Update-TextOnce -Path $sanalika -Old '         layerModel.loadBackground();' -New ('         CaptureLog.write("startup.initCommandsCompleted",{"fileServer":gameModel.fileServer,"itemInfoFile":gameModel.itemInfoFile,"versionFile":gameModel.versionFile,"languageFileVersion":gameModel.languageFileVersion});' + $nl + '         layerModel.loadBackground();')
      Update-TextOnce -Path $sanalika -Old '         itemModel = new ItemModel(gameModel.itemInfoFile);' -New ('         CaptureLog.write("startup.itemInfo.load",{"url":gameModel.fileServer + gameModel.itemInfoFile});' + $nl + '         itemModel = new ItemModel(gameModel.itemInfoFile);')
      Update-TextOnce -Path $sanalika -Old '         Dispatcher.removeEventListener("ITEM_INFO_FILE_LOADED",onItemInfoFileLoaded);' -New ('         CaptureLog.write("startup.itemInfo.loaded",{});' + $nl + '         Dispatcher.removeEventListener("ITEM_INFO_FILE_LOADED",onItemInfoFileLoaded);')
      Update-TextOnce -Path $sanalika -Old '         versionModel = new VersionModel(gameModel.versionFile);' -New ('         CaptureLog.write("startup.version.load",{"url":gameModel.fileServer + gameModel.versionFile});' + $nl + '         versionModel = new VersionModel(gameModel.versionFile);')
      Update-TextOnce -Path $sanalika -Old '         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.INFO_FILE_READY));' -New ('         CaptureLog.write("startup.version.loaded",{});' + $nl + '         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.INFO_FILE_READY));')
         Update-TextOnce -Path $sanalika -Old '         Dispatcher.addEventListener("INITIALIZE",initialize);' -New ('         Dispatcher.addEventListener("INITIALIZE",initialize);' + $nl + '         CaptureLog.write("startup.guestPanel.check",{"privilegeId":Sanalika.instance.serviceModel.sfs.mySelf.privilegeId,"guest":avatarModel.guest});')
         Update-TextOnce -Path $sanalika -Old '            _loc2_ = new PanelVO();' -New ('            CaptureLog.write("startup.guestPanel.open",{"fileServer":Sanalika.instance.gameModel.fileServer,"modulePath":Sanalika.instance.moduleModel.getPath("GuestPanel","ModuleType.PANEL")});' + $nl + '            _loc2_ = new PanelVO();')
         Update-TextOnce -Path $sanalika -Old '            initialize();' -New ('            CaptureLog.write("startup.guestPanel.notRequired",{});' + $nl + '            initialize();')
      Update-TextOnce -Path $sanalika -Old '         serviceModel.requestData("init",{},onInited);' -New ('         CaptureLog.write("startup.init.request",{});' + $nl + '         serviceModel.requestData("init",{},onInited);')
      Update-TextOnce -Path $sanalika -Old '         this.data = param1;' -New ('         CaptureLog.write("init.received",{"keys":CaptureLog.safe(param1)});' + $nl + '         this.data = param1;')
         Update-TextOnce -Path $sanalika -Old ('         SyncTimer.setTimestamp(param1.timestamp);' + $nl + '         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",new ProgressVo(0,"QUEUE",param1.p)));') -New ('         CaptureLog.write("init.queue",{"ts":param1.ts,"timestamp":param1.timestamp,"p":param1.p});' + $nl + '         if(param1.ts != undefined)' + $nl + '         {' + $nl + '            SyncTimer.setTimestamp(param1.ts);' + $nl + '         }' + $nl + '         else' + $nl + '         {' + $nl + '            SyncTimer.setTimestamp(param1.timestamp);' + $nl + '         }' + $nl + '         try' + $nl + '         {' + $nl + '            Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",new ProgressVo(0,"QUEUE",param1.p)));' + $nl + '         }' + $nl + '         catch(_captureQueueProgressError:*)' + $nl + '         {' + $nl + '            CaptureLog.write("init.queue.progress.error",{"message":String(_captureQueueProgressError)});' + $nl + '         }')
         Update-TextOnce -Path $sanalika -Old '         Mouse.cursor = "auto";' -New ('         Mouse.cursor = "auto";' + $nl + '         try' + $nl + '         {' + $nl + '            if(param1.error is Error)' + $nl + '            {' + $nl + '               var _captureChildError:Error = param1.error as Error;' + $nl + '               CaptureLog.write("child.error",{"name":_captureChildError.name,"message":_captureChildError.message,"stack":_captureChildError.getStackTrace()});' + $nl + '            }' + $nl + '            else if(param1.error is ErrorEvent)' + $nl + '            {' + $nl + '               CaptureLog.write("child.error",{"name":"ErrorEvent","message":ErrorEvent(param1.error).text});' + $nl + '            }' + $nl + '            else' + $nl + '            {' + $nl + '               CaptureLog.write("child.error",{"name":"unknown","message":String(param1.error)});' + $nl + '            }' + $nl + '         }' + $nl + '         catch(_captureChildErrorLogError:*)' + $nl + '         {' + $nl + '         }')

    $roomModel = Join-Path $OutputRoot "com/oyunstudyosu/room/RoomModel.as"
   Add-CaptureImport -Path $roomModel -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $roomModel -Old '         roomData = param1;' -New ('         roomData = param1;' + $nl + '         CaptureLog.write("room.checkMap",CaptureLog.safe(param1));')
   Update-TextOnce -Path $roomModel -Old '         _map = XMLList(Base64.decode(param1));' -New ('         CaptureLog.write("room.map",{"base64Length":param1 == null ? 0 : param1.length,"xml":Base64.decode(param1)});' + $nl + '         _map = XMLList(Base64.decode(param1));')

    $doorModel = Join-Path $OutputRoot "com/oyunstudyosu/door/DoorModel.as"
   Add-CaptureImport -Path $doorModel -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $doorModel -Old '         var _loc2_:IDoorVO = _map[param1];' -New ('         CaptureLog.write("door.useDoorByKey",{"key":param1});' + $nl + '         var _loc2_:IDoorVO = _map[param1];')
   Update-TextOnce -Path $doorModel -Old '         CaptureRuntime.sanalikaInstance.roomModel.buildingData = param4;' -New ('         CaptureLog.write("door.useHouseDoor",{"flatID":param1,"avatarID":param2,"buildingData":CaptureLog.safe(param4)});' + $nl + '         CaptureRuntime.sanalikaInstance.roomModel.buildingData = param4;')
   Update-TextOnce -Path $doorModel -Old '         var _loc4_:int = 0;' -New ('         var _loc4_:int = 0;' + $nl + '         CaptureLog.write("door.load",CaptureLog.safe(param1));')
   Update-TextOnce -Path $doorModel -Old '         var _loc2_:Array = JSON.parse(param1) as Array;' -New ('         var _loc2_:Array = JSON.parse(param1) as Array;' + $nl + '         CaptureLog.write("door.loadJSON",{"raw":param1,"data":CaptureLog.safe(_loc2_)});')

    $gridModel = Join-Path $OutputRoot "com/oyunstudyosu/model/GridModel.as"
   Add-CaptureImport -Path $gridModel -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $gridModel -Old '         this._data[param2 * this._width + param1] = param3;' -New ('         CaptureLog.write("grid.setCellValue",{"x":param1,"y":param2,"value":param3});' + $nl + '         this._data[param2 * this._width + param1] = param3;')
   Update-TextOnce -Path $gridModel -Old '         var byteArray:ByteArray = Base64.decodeToByteArray(value);' -New ('         var byteArray:ByteArray = Base64.decodeToByteArray(value);' + $nl + '         CaptureLog.write("grid.load.raw",{"base64Length":value == null ? 0 : value.length});')
   Update-TextOnce -Path $gridModel -Old '            this.inited = true;' -New ('            this.inited = true;' + $nl + '            CaptureLog.write("grid.load",{"width":this._width,"height":this._height,"data":this._data});')

   $idleCacher = Join-Path $OutputRoot "com/oyunstudyosu/engine/character/IdleCacher.as"
   Add-CaptureImport -Path $idleCacher -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $idleCacher -Old '         var _loc13_:BitmapData = new BitmapData(int(_loc11_.width + 0.5),int(_loc11_.height + 0.5),true,0);' -New ('         var _captureIdleBitmapWidth:int = int(_loc11_.width + 0.5);' + $nl + '         var _captureIdleBitmapHeight:int = int(_loc11_.height + 0.5);' + $nl + '         if(_captureIdleBitmapWidth < 1 || _captureIdleBitmapHeight < 1)' + $nl + '         {' + $nl + '            CaptureLog.write("bitmap.invalid.skip",{"source":"IdleCacher","width":_captureIdleBitmapWidth,"height":_captureIdleBitmapHeight});' + $nl + '            return null;' + $nl + '         }' + $nl + '         var _loc13_:BitmapData = new BitmapData(_captureIdleBitmapWidth,_captureIdleBitmapHeight,true,0);')

   $youtubePlayer = Join-Path $OutputRoot "com/oyunstudyosu/video/youtube/YoutubePlayer.as"
   Add-CaptureImport -Path $youtubePlayer -Import "com.oyunstudyosu.capture.CaptureLog"
      Update-TextOnce -Path $youtubePlayer -Old '         stageWebView.viewPort = new Rectangle(-_loc4_,-_loc3_,_loc4_,_loc3_);' -New ('         if(_loc4_ < 1 || _loc3_ < 1)' + $nl + '         {' + $nl + '            CaptureLog.write("bitmap.invalid.skip",{"source":"YoutubePlayer","width":_loc4_,"height":_loc3_,"scale":_loc2_,"superWidth":superWidth,"superHeight":superHeight});' + $nl + '            Sanalika.instance.stage.removeEventListener("enterFrame",onEnterFrame);' + $nl + '            stageWebView = null;' + $nl + '            return;' + $nl + '         }' + $nl + '         stageWebView.viewPort = new Rectangle(-_loc4_,-_loc3_,_loc4_,_loc3_);')

   $connectCommand = Join-Path $OutputRoot "com/oyunstudyosu/commands/ConnectCommand.as"
   Add-CaptureImport -Path $connectCommand -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $connectCommand -Old ('      override public function dispose() : void' + $nl + '      {' + $nl + '         sfs.removeEventListener("connection",onConnection);' + $nl + '         sfs.removeEventListener("connectionResume",onConnectionResume);' + $nl + '         sfs = null;' + $nl + '      }') -New ('      override public function dispose() : void' + $nl + '      {' + $nl + '         if(sfs != null)' + $nl + '         {' + $nl + '            try' + $nl + '            {' + $nl + '               sfs.removeEventListener("connection",onConnection);' + $nl + '               sfs.removeEventListener("connectionResume",onConnectionResume);' + $nl + '            }' + $nl + '            catch(_captureConnectDisposeError:*)' + $nl + '            {' + $nl + '               CaptureLog.write("command.dispose.error",{"command":"ConnectCommand","message":String(_captureConnectDisposeError)});' + $nl + '            }' + $nl + '         }' + $nl + '         sfs = null;' + $nl + '      }')

   $loginCommand = Join-Path $OutputRoot "com/oyunstudyosu/commands/LoginCommand.as"
   Add-CaptureImport -Path $loginCommand -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $loginCommand -Old ('      override public function dispose() : void' + $nl + '      {' + $nl + '         sfs.removeEventListener("login",onLogin);' + $nl + '         sfs.removeEventListener("loginError",onLoginError);' + $nl + '         sfs = null;' + $nl + '      }') -New ('      override public function dispose() : void' + $nl + '      {' + $nl + '         if(sfs != null)' + $nl + '         {' + $nl + '            try' + $nl + '            {' + $nl + '               sfs.removeEventListener("login",onLogin);' + $nl + '               sfs.removeEventListener("loginError",onLoginError);' + $nl + '            }' + $nl + '            catch(_captureLoginDisposeError:*)' + $nl + '            {' + $nl + '               CaptureLog.write("command.dispose.error",{"command":"LoginCommand","message":String(_captureLoginDisposeError)});' + $nl + '            }' + $nl + '         }' + $nl + '         sfs = null;' + $nl + '      }')

   $buddyController = Join-Path $OutputRoot "com/oyunstudyosu/buddy/BuddyController.as"
   Add-CaptureImport -Path $buddyController -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $buddyController -Old ('         var _loc1_:IBuddyModel = CaptureRuntime.sanalikaInstance.buddyModel;' + $nl + '         _loc1_.clear();') -New ('         var _loc1_:IBuddyModel = CaptureRuntime.sanalikaInstance.buddyModel;' + $nl + '         if(_loc1_ != null && "clear" in _loc1_)' + $nl + '         {' + $nl + '            Object(_loc1_)["clear"]();' + $nl + '         }' + $nl + '         else' + $nl + '         {' + $nl + '            CaptureLog.write("buddy.dispose.clear.skip",{});' + $nl + '         }')

   $questController = Join-Path $OutputRoot "com/oyunstudyosu/quest/QuestController.as"
   Add-CaptureImport -Path $questController -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $questController -Old ('                     CaptureRuntime.sanalikaInstance.toolTipModel.addTip(questIcon,$("quest_" + _loc2_[_loc4_].metaKey + "_title"));' + $nl + '                     bot.getClip().addChildAt(questIcon,bot.questCount);') -New ('                     try' + $nl + '                     {' + $nl + '                        if(CaptureRuntime.sanalikaInstance.toolTipModel != null)' + $nl + '                        {' + $nl + '                           CaptureRuntime.sanalikaInstance.toolTipModel.addTip(questIcon,$("quest_" + _loc2_[_loc4_].metaKey + "_title"));' + $nl + '                        }' + $nl + '                        var _captureQuestClip:* = bot.getClip();' + $nl + '                        if(_captureQuestClip != null)' + $nl + '                        {' + $nl + '                           _captureQuestClip.addChildAt(questIcon,bot.questCount);' + $nl + '                        }' + $nl + '                        else' + $nl + '                        {' + $nl + '                           CaptureLog.write("quest.icon.skip",{"reason":"missingBotClip","metaKey":_loc2_[_loc4_].metaKey});' + $nl + '                        }' + $nl + '                     }' + $nl + '                     catch(_captureQuestIconError:*)' + $nl + '                     {' + $nl + '                        CaptureLog.write("quest.sceneLoaded.error",{"message":String(_captureQuestIconError),"metaKey":_loc2_[_loc4_].metaKey});' + $nl + '                     }')

   $baseSpeechBubble = Join-Path $OutputRoot "org/oyunstudyosu/speech/BaseSpeechBubble.as"
   Add-CaptureImport -Path $baseSpeechBubble -Import "com.oyunstudyosu.capture.CaptureLog"
   Update-TextOnce -Path $baseSpeechBubble -Old ('            this.sText = TextFieldManager.convertAsArabicTextField(getChildByName("speechTxt") as TextField,true,false);' + $nl + '         }' + $nl + '         this.sText.width = this.maxWidth;') -New ('            var _captureSpeechText:TextField = getChildByName("speechTxt") as TextField;' + $nl + '            if(_captureSpeechText == null)' + $nl + '            {' + $nl + '               CaptureLog.writeOnce("speechBubble.missingTextField",String(this),{"bubble":String(this),"nick":param1,"message":param2});' + $nl + '               return;' + $nl + '            }' + $nl + '            this.sText = TextFieldManager.convertAsArabicTextField(_captureSpeechText,true,false);' + $nl + '         }' + $nl + '         if(this.sText == null)' + $nl + '         {' + $nl + '            CaptureLog.writeOnce("speechBubble.missingTextField",String(this),{"bubble":String(this),"nick":param1,"message":param2});' + $nl + '            return;' + $nl + '         }' + $nl + '         this.sText.width = this.maxWidth;')

      $blueBubble = Join-Path $OutputRoot "org/oyunstudyosu/speech/defaultBubbles/BlueBubble.as"
      Add-CaptureImport -Path $blueBubble -Import "com.oyunstudyosu.capture.CaptureLog"
      Update-TextOnce -Path $blueBubble -Old ('         super.speech(param1,param2);' + $nl + '         sText.htmlText = "<font color=\"#FF0000\">" + param1 + ": " + "</font>" + "<font color=\"#000000\">" + param2 + "</font>";') -New ('         super.speech(param1,param2);' + $nl + '         if(sText == null || this.bg == null || this.tip == null)' + $nl + '         {' + $nl + '            CaptureLog.writeOnce("speechBubble.render.skip","BlueBubble",{"bubble":"BlueBubble","missingText":sText == null,"missingBg":this.bg == null,"missingTip":this.tip == null,"nick":param1,"message":param2});' + $nl + '            return;' + $nl + '         }' + $nl + '         sText.htmlText = "<font color=\"#FF0000\">" + param1 + ": " + "</font>" + "<font color=\"#000000\">" + param2 + "</font>";')

      $blackBubble = Join-Path $OutputRoot "org/oyunstudyosu/speech/defaultBubbles/BlackBubble.as"
      Add-CaptureImport -Path $blackBubble -Import "com.oyunstudyosu.capture.CaptureLog"
      Update-TextOnce -Path $blackBubble -Old ('         super.speech(param1,param2);' + $nl + '         sText.htmlText = "<font color=\"#cacaca\">" + param1 + ": " + "</font>" + "<font color=\"#fafafa\">" + param2 + "</font>";') -New ('         super.speech(param1,param2);' + $nl + '         if(sText == null || this.bg == null || this.tip == null)' + $nl + '         {' + $nl + '            CaptureLog.writeOnce("speechBubble.render.skip","BlackBubble",{"bubble":"BlackBubble","missingText":sText == null,"missingBg":this.bg == null,"missingTip":this.tip == null,"nick":param1,"message":param2});' + $nl + '            return;' + $nl + '         }' + $nl + '         sText.htmlText = "<font color=\"#cacaca\">" + param1 + ": " + "</font>" + "<font color=\"#fafafa\">" + param2 + "</font>";')

      $defaultBubble = Join-Path $OutputRoot "org/oyunstudyosu/speech/defaultBubbles/DefaultBubble.as"
      Add-CaptureImport -Path $defaultBubble -Import "com.oyunstudyosu.capture.CaptureLog"
      Update-TextOnce -Path $defaultBubble -Old ('         super.speech(param1,param2);' + $nl + '         cleanupEmoticons();') -New ('         super.speech(param1,param2);' + $nl + '         if(sText == null || this.bg == null || this.tip == null)' + $nl + '         {' + $nl + '            CaptureLog.writeOnce("speechBubble.render.skip","DefaultBubble",{"bubble":"DefaultBubble","missingText":sText == null,"missingBg":this.bg == null,"missingTip":this.tip == null,"nick":param1,"message":param2});' + $nl + '            return;' + $nl + '         }' + $nl + '         cleanupEmoticons();')

      $speechBalloon = Join-Path $OutputRoot "com/oyunstudyosu/chat/SpeechBalloon.as"
      Add-CaptureImport -Path $speechBalloon -Import "com.oyunstudyosu.capture.CaptureLog"
      Update-TextOnce -Path $speechBalloon -Old ('            _loc6_ = bubble as MovieClip;' + $nl + '            _loc6_.cacheAsBitmap = true;') -New ('            _loc6_ = bubble as MovieClip;' + $nl + '            if(_loc6_ == null)' + $nl + '            {' + $nl + '               CaptureLog.writeOnce("speechBalloon.bubble.skip",String(param1),{"type":param1,"reason":"missingBubbleMovieClip"});' + $nl + '               bubble = null;' + $nl + '               return;' + $nl + '            }' + $nl + '            _loc6_.cacheAsBitmap = true;')
      Update-TextOnce -Path $speechBalloon -Old ('            _loc8_ = (bubble as CoreMovieClip).getChildByName("bg") as MovieClip;' + $nl + '            this.x = _loc7_ + int(param1 - _loc8_.width / 2);' + $nl + '            this.y = _loc9_ + int(param2 - (bubble as CoreMovieClip).height);') -New ('            _loc8_ = (bubble as CoreMovieClip).getChildByName("bg") as MovieClip;' + $nl + '            if(_loc8_ != null)' + $nl + '            {' + $nl + '               this.x = _loc7_ + int(param1 - _loc8_.width / 2);' + $nl + '               this.y = _loc9_ + int(param2 - (bubble as CoreMovieClip).height);' + $nl + '            }' + $nl + '            else' + $nl + '            {' + $nl + '               CaptureLog.writeOnce("speechBalloon.position.skip",String(lastType),{"reason":"missingBg","type":lastType});' + $nl + '            }')
      Update-TextOnce -Path $speechBalloon -Old ('            reportButton.y = ((bubble as CoreMovieClip).getChildByName("bg") as MovieClip).y;' + $nl + '            (bubble as CoreMovieClip).addChild(reportButton);') -New ('            var _captureReportBg:MovieClip = (bubble as CoreMovieClip).getChildByName("bg") as MovieClip;' + $nl + '            if(_captureReportBg == null)' + $nl + '            {' + $nl + '               CaptureLog.writeOnce("speechBalloon.report.skip",String(param1),{"reason":"missingBg","type":param1});' + $nl + '               reportButton = null;' + $nl + '               return;' + $nl + '            }' + $nl + '            reportButton.y = _captureReportBg.y;' + $nl + '            (bubble as CoreMovieClip).addChild(reportButton);')

         Update-TextOnce -Path $sanalika -Old '         hudModel.init();' -New ('         CaptureLog.write("startup.hud.skip",{"reason":"capture-missing-timeline"});')
         Update-TextOnce -Path $sanalika -Old '            controllerList[BuddyController].dispose();' -New ('            try' + $nl + '            {' + $nl + '               controllerList[BuddyController].dispose();' + $nl + '            }' + $nl + '            catch(_captureBuddyDisposeError:*)' + $nl + '            {' + $nl + '               CaptureLog.write("startup.buddy.dispose.error",{"message":String(_captureBuddyDisposeError)});' + $nl + '            }')
         Update-TextOnce -Path $sanalika -Old '         controllerList[BuddyController] = new BuddyController();' -New ('         try' + $nl + '         {' + $nl + '            controllerList[BuddyController] = new BuddyController();' + $nl + '         }' + $nl + '         catch(_captureBuddyInitError:*)' + $nl + '         {' + $nl + '            CaptureLog.write("startup.buddy.init.error",{"message":String(_captureBuddyInitError)});' + $nl + '         }')
      Update-TextOnce -Path $sanalika -Old '         engine.start();' -New ('         try' + $nl + '         {' + $nl + '            CaptureLog.write("startup.engine.start",{});' + $nl + '            engine.start();' + $nl + '         }' + $nl + '         catch(_captureEngineError:*)' + $nl + '         {' + $nl + '            CaptureLog.write("startup.engine.error",{"message":String(_captureEngineError)});' + $nl + '         }')
      Update-TextOnce -Path $sanalika -Old '         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.INIT_READY));' -New ('         CaptureLog.write("startup.init.ready",{});' + $nl + '         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.INIT_READY));' + $nl + '         CaptureLog.write("startup.progress.full",{});' + $nl + '         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.PROGRESS_FULL));')

         $sanalikaAlert = Join-Path $OutputRoot "org/oyunstudyosu/alert/SanalikaAlert.as"
         Add-CaptureImport -Path $sanalikaAlert -Import "com.oyunstudyosu.capture.CaptureLog"
         Update-TextOnce -Path $sanalikaAlert -Old '         var _loc1_:Object = ApplicationDomain.currentDomain.getDefinition("org.oyunstudyosu.alert.views::" + data.params.alertType + "View");' -New ('         var _loc1_:Object = null;' + $nl + '         try' + $nl + '         {' + $nl + '            _loc1_ = ApplicationDomain.currentDomain.getDefinition("org.oyunstudyosu.alert.views::" + data.params.alertType + "View");' + $nl + '         }' + $nl + '         catch(_captureAlertViewError:*)' + $nl + '         {' + $nl + '            var _captureAlertType:String = data == null || data.params == null ? "unknown" : String(data.params.alertType);' + $nl + '            CaptureLog.writeOnce("alert.view.missing",_captureAlertType,{"alertType":_captureAlertType,"message":String(_captureAlertViewError)});' + $nl + '            return;' + $nl + '         }')
            Update-TextOnce -Path $sanalikaAlert -Old '         this.view.init();' -New ('         try' + $nl + '         {' + $nl + '            this.view.init();' + $nl + '         }' + $nl + '         catch(_captureAlertInitError:*)' + $nl + '         {' + $nl + '            var _captureAlertInitType:String = data == null || data.params == null ? "unknown" : String(data.params.alertType);' + $nl + '            CaptureLog.writeOnce("alert.view.init.error",_captureAlertInitType,{"alertType":_captureAlertInitType,"message":String(_captureAlertInitError)});' + $nl + '            return;' + $nl + '         }')

    Write-Host "Injected capture hooks into generated source."
}

function Repair-GeneratedSourceArtifacts {
   param([string]$OutputRoot)

   $section = [string][char]0x00A7
   $stackPrefix = $section + $section
   $changed = 0

   foreach ($file in Get-ChildItem -LiteralPath $OutputRoot -Recurse -File -Filter *.as) {
      $text = Get-Content -LiteralPath $file.FullName -Raw
      $original = $text

      $text = $text.Replace($stackPrefix + "push(", "FFDecStack.push(")
      $text = $text.Replace($stackPrefix + "pop()", "FFDecStack.pop()")
      $text = $text.Replace($stackPrefix + "findproperty(", "FFDecStack.findproperty(")
      $text = $text.Replace($stackPrefix + "nextvalue(", "flash.Boot.__nextvalue(")
      $text = $text.Replace($stackPrefix + "nextname(", "flash.Boot.__nextname(")
      $text = $text.Replace($stackPrefix + "hasnext(", "flash.Boot.__hasnext(")
      $text = [regex]::Replace($text, '(?m)^\s*\[Embed\([^\]]*\)\]\r?\n', '')

      if ($file.FullName -like "*\com\oyunstudyosu\commands\*.as") {
         $text = $text.Replace("private function dispose() : void", "override public function dispose() : void")
      }

      if ($text -ne $original) {
         Set-Content -LiteralPath $file.FullName -Value $text -NoNewline
         $changed++
      }
   }

   Write-Host "Repaired generated AS artifacts: $changed"
}

function Invoke-CaptureGameCompile {
    $sdkRoot = Resolve-SdkRoot -ExplicitSdkHome $SdkHome
   if (-not $sdkRoot) { throw "No AIR/Flex SDK compiler found. -SdkHome must point to an SDK root containing lib\mxmlc.jar. The Adobe AIR runtime alone is not enough, and you do not need to run AIR first." }

    $compilerJar = Join-Path $sdkRoot "lib/mxmlc.jar"
    if (-not (Test-Path -LiteralPath $compilerJar)) { throw "Flex compiler jar not found: $compilerJar" }

    $java = $null
    if ($JavaHome) {
        $javaCandidate = Join-Path $JavaHome "bin/java.exe"
        if (Test-Path -LiteralPath $javaCandidate) { $java = $javaCandidate }
    }
    if (-not $java) {
        $javaCommand = Get-Command java -ErrorAction SilentlyContinue
        if ($javaCommand) { $java = $javaCommand.Source }
    }
    if (-not $java) { throw "No Java runtime found. Pass -JavaHome or add java to PATH." }
    if (-not (Test-Path -LiteralPath $mainFile)) { throw "Main class file not found after preprocessing: $mainFile" }
    if (-not (Test-Path -LiteralPath $runtimeSwf)) { throw "Runtime SWF not found: $runtimeSwf" }

    $env:FLEX_HOME = $sdkRoot
    $env:AIR_HOME = $sdkRoot
    $env:AIR_SDK_HOME = $sdkRoot

    New-Item -ItemType Directory -Force -Path $swfOutputDir | Out-Null
    New-Item -ItemType Directory -Force -Path $assetDir | Out-Null
    Copy-Item -LiteralPath $runtimeSwf -Destination $assetBundle -Force

    $compilerArgs = @(
        "-Xmx1024m",
        "-Dsun.io.useCanonCaches=false",
        "-Djava.util.Arrays.useLegacyMergeSort=true",
        "-jar",
        $compilerJar,
        "+configname=air",
        "+flexlib=$sdkRoot/frameworks",
        "-source-path+=$outputRoot",
        "-debug=true",
        "-warnings=false",
        "-strict=false",
        "-compiler.verbose-stacktraces=true",
        "-static-link-runtime-shared-libraries=true",
        "-output=$swfOutputPath",
        $mainFile
    )

    Write-Host "SDK:      $sdkRoot"
    Write-Host "Compiler: $compilerJar"
    Write-Host "Java:     $java"
    Write-Host "Main:     $mainFile"
    Write-Host "Output:   $swfOutputPath"

    $previousLocation = Get-Location
    Set-Location $outputRoot
    try { & $java @compilerArgs }
    finally { Set-Location $previousLocation }

    if ($LASTEXITCODE -ne 0) { throw "Compiler failed with exit code $LASTEXITCODE." }

    Write-Host "Compiled capture SWF: $swfOutputPath"

    if ($PromoteToRuntime) {
        $backup = Join-Path (Split-Path $runtimeSwf -Parent) "snl.780.swf.before-capture"
        if (-not (Test-Path -LiteralPath $backup)) {
            Copy-Item -LiteralPath $runtimeSwf -Destination $backup -Force
        }
        Copy-Item -LiteralPath $swfOutputPath -Destination $runtimeSwf -Force
        Write-Host "Promoted capture SWF to client/runtime/snl.780.swf"
        Write-Host "Backup: $backup"
    }
}

if (-not (Test-Path -LiteralPath $sourceRoot)) { throw "Source directory not found: $sourceRoot" }

Test-CaptureSourceAnchors
if ($ValidateOnly) {
   Write-Host "Capture source anchors validated in: $sourceRoot"
   return
}

if ($UseExistingGenerated) {
   if (-not (Test-Path -LiteralPath $mainFile)) {
      throw "Generated source is missing: $mainFile. Run once without -UseExistingGenerated first."
   }

   Repair-GeneratedSourceArtifacts -OutputRoot $outputRoot
   Write-Host "Using existing generated capture source: $outputRoot"

   if ($Compile -or $PromoteToRuntime) {
      Invoke-CaptureGameCompile
   }
   else {
      Write-Host "Compile skipped. Add -Compile to build $SwfOutput"
   }

   return
}

if (Test-Path -LiteralPath $outputRoot) {
    Remove-Item -LiteralPath $outputRoot -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $outputRoot) {
        & cmd.exe /c "rmdir /s /q `"$outputRoot`""
    }
}

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
Copy-Item -Path (Join-Path $sourceRoot "*") -Destination $outputRoot -Recurse -Force

Invoke-RecoveredSourcePreprocess -OutputRoot $outputRoot
Write-CaptureLogHelper -OutputRoot $outputRoot
Add-CaptureInstrumentation -OutputRoot $outputRoot
Repair-GeneratedSourceArtifacts -OutputRoot $outputRoot

if ($Compile) {
   Invoke-CaptureGameCompile
}
else {
    Write-Host "Capture source is ready: $outputRoot"
   Write-Host "Run again with -Compile to build $SwfOutput"
}
<# Duplicate script body from an interrupted parallel patch is kept commented out.
[CmdletBinding()]
param(
    [string]$SdkHome,
    [string]$JavaHome = "C:/Program Files/Microsoft/jdk-17.0.18.8-hotspot",
    [string]$Source = "client/recovered/game-src",
    [string]$OutputSource = "client/generated/capture-game-src",
    [string]$SwfOutput = "client/generated/capture/snl.780.capture.swf",
    [string]$MainClass = "Sanalika",
    [switch]$Compile,
    [switch]$PromoteToRuntime,
    [switch]$ValidateOnly
)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../..")
$sourceRoot = Join-Path $repoRoot $Source
$outputRoot = Join-Path $repoRoot $OutputSource
$outputPath = Join-Path $repoRoot $SwfOutput
$runtimeSwf = Join-Path $repoRoot "client/runtime/snl.780.swf"
$runtimeBackup = Join-Path $repoRoot "client/runtime/snl.780.swf.pre-capture"

function Resolve-SdkRoot {
    param([string]$ExplicitSdkHome)

    $candidates = @($ExplicitSdkHome, $env:AIR_SDK_HOME, $env:AIRSDK_HOME, $env:FLEX_HOME, $env:AIR_HOME) | Where-Object { $_ }
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) { return (Resolve-Path $candidate).Path }
    }
    return $null
}

function Resolve-Tool {
    param([string[]]$Names, [string]$SdkRoot)

    foreach ($name in $Names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }

    if ($SdkRoot) {
        foreach ($name in $Names) {
            foreach ($extension in ".bat", ".cmd", ".exe", "") {
                $candidate = Join-Path $SdkRoot "bin/$name$extension"
                if (Test-Path -LiteralPath $candidate) { return $candidate }
            }
        }
    }
    return $null
}

function Move-FirstSuperCallAfterConstructorOpen {
    param([string]$SourceText, [string]$ClassName)

    $lines = $SourceText -split "`r?`n", -1
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -notmatch ('^\s*public\s+function\s+' + [regex]::Escape($ClassName) + '\s*\(')) { continue }

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

            if ($entered -and $braceDepth -le 0) { break }
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

function Read-Text {
    param([string]$Path)
    return Get-Content -LiteralPath $Path -Raw
}

function Write-Text {
    param([string]$Path, [string]$Text)
    Set-Content -LiteralPath $Path -Value $Text -NoNewline
}

function Add-Import {
    param([string]$Text, [string]$Anchor, [string]$Import)
    if ($Text.Contains($Import)) { return $Text }
    if (-not $Text.Contains($Anchor)) { throw "Import anchor not found: $Anchor" }
    return $Text.Replace($Anchor, "$Anchor`r`n   $Import")
}

function Insert-BeforeFirst {
    param([string]$Text, [string]$Needle, [string]$Insert, [string]$Guard)
    if ($Guard -and $Text.Contains($Guard)) { return $Text }
    $index = $Text.IndexOf($Needle, [StringComparison]::Ordinal)
    if ($index -lt 0) { throw "Injection anchor not found: $Needle" }
    return $Text.Insert($index, "$Insert`r`n")
}

function Insert-AfterFirst {
    param([string]$Text, [string]$Needle, [string]$Insert, [string]$Guard)
    if ($Guard -and $Text.Contains($Guard)) { return $Text }
    $index = $Text.IndexOf($Needle, [StringComparison]::Ordinal)
    if ($index -lt 0) { throw "Injection anchor not found: $Needle" }
    return $Text.Insert($index + $Needle.Length, "`r`n$Insert")
}

function Test-AnchorFile {
    param([string]$RelativePath, [string[]]$Needles)
    $path = Join-Path $sourceRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) { throw "Required source file missing: $path" }
    $text = Read-Text $path
    foreach ($needle in $Needles) {
        if (-not $text.Contains($needle)) { throw "Required capture anchor missing in ${RelativePath}: $needle" }
    }
}

function Preprocess-GeneratedSource {
    param([string]$Root)

    $files = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.as
    $changed = 0

    foreach ($file in $files) {
        $text = Read-Text $file.FullName
        $original = $text

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
        $text = [regex]::Replace($text, '(?m)^\s*\[Embed\(source="/_assets/assets\.swf",\s*symbol="symbol\d+"\)\]\r?\n', '')
        $text = [regex]::Replace($text, '(?m)^\s*\[Embed\([^\]]*\)\]\r?\n', '')

        if ($text.Contains("Boot.skip_constructor") -and $text -match '(?m)^\s*super\([^;]*\);') {
            $text = [regex]::Replace(
                $text,
                '(?s)(public\s+function\s+\w+\s*\([^)]*\)\s*\{\s*)if\s*\(Boot\.skip_constructor\)\s*\{\s*return;\s*\}(.*?)(\s*super\s*\([^;]*\);)',
                "`$1`$3`r`n         if(Boot.skip_constructor)`r`n         {`r`n            return;`r`n         }`$2"
            )
        }

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
            Write-Text $file.FullName $text
            $changed++
        }
    }

    $helperPath = Join-Path $Root "FFDecStack.as"
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

    Write-Host "Preprocessed capture source: $Root"
    Write-Host "Changed AS files:              $changed"
}

function Add-CaptureLogger {
    param([string]$Root)

    $captureDir = Join-Path $Root "com/oyunstudyosu/capture"
    New-Item -ItemType Directory -Force -Path $captureDir | Out-Null
    $capturePath = Join-Path $captureDir "CaptureLog.as"
@'
package com.oyunstudyosu.capture
{
   import com.smartfoxserver.v2.core.SFSEvent;
   import com.smartfoxserver.v2.entities.Room;
   import com.smartfoxserver.v2.entities.User;
   import com.smartfoxserver.v2.entities.data.ISFSArray;
   import com.smartfoxserver.v2.entities.data.ISFSObject;
   import com.smartfoxserver.v2.entities.variables.Variable;
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;

   public class CaptureLog
   {
      private static const MAX_DEPTH:int = 8;
      private static const MAX_STRING:int = 500000;
      private static const MAX_ARRAY:int = 20000;
      private static var file:File;
      private static var sequence:int = 0;
      private static var failed:Boolean = false;
      private static var announced:Boolean = false;

      public function CaptureLog()
      {
      }

      public static function write(kind:String, payload:* = null) : void
      {
         if(failed)
         {
            return;
         }
         try
         {
            ensureFile();
            var record:Object = {};
            record.seq = ++sequence;
            record.time = new Date().getTime();
            record.kind = kind;
            record.payload = safe(payload);
            var stream:FileStream = new FileStream();
            stream.open(file,FileMode.APPEND);
            stream.writeUTFBytes(JSON.stringify(record) + "\n");
            stream.close();
         }
         catch(error:*)
         {
            failed = true;
            try
            {
               trace("[SFS-CAPTURE] disabled: " + error);
            }
            catch(traceError:*)
            {
            }
         }
      }

      public static function writeSfsPacket(direction:String, packet:ISFSObject) : void
      {
         var controller:* = null;
         var action:* = null;
         try
         {
            if(packet != null && packet.containsKey("c"))
            {
               controller = packet.getByte("c");
            }
            if(packet != null && packet.containsKey("a"))
            {
               action = packet.getShort("a");
            }
         }
         catch(error:*)
         {
         }
         write("sfs." + direction,{
            "controller":controller,
            "action":action,
            "packet":safe(packet)
         });
      }

      public static function writeEvent(event:Event) : void
      {
         var params:* = null;
         try
         {
            if(event is SFSEvent)
            {
               params = SFSEvent(event).params;
            }
            else if(Object(event).hasOwnProperty("params"))
            {
               params = Object(event)["params"];
            }
         }
         catch(error:*)
         {
         }
         write("sfs.event",{
            "type":event != null ? event.type : null,
            "params":safe(params)
         });
      }

      public static function writeRoomVariables(kind:String, room:Room, changedVars:Array) : void
      {
         var changed:Array = [];
         var variables:Array = [];
         try
         {
            for each(var name:* in changedVars)
            {
               changed.push(String(name));
               if(room != null && room.containsVariable(String(name)))
               {
                  variables.push(variableSummary(room.getVariable(String(name)),1));
               }
            }
         }
         catch(error:*)
         {
         }
         write(kind,{
            "room":roomSummary(room,1),
            "changedVars":changed,
            "variables":variables
         });
      }

      public static function writeUserVariables(kind:String, user:User, changedVars:Array) : void
      {
         var changed:Array = [];
         var variables:Array = [];
         try
         {
            for each(var name:* in changedVars)
            {
               changed.push(String(name));
               if(user != null && user.containsVariable(String(name)))
               {
                  variables.push(variableSummary(user.getVariable(String(name)),1));
               }
            }
         }
         catch(error:*)
         {
         }
         write(kind,{
            "user":userSummary(user,1),
            "changedVars":changed,
            "variables":variables
         });
      }

      public static function safe(value:*, depth:int = 0) : *
      {
         if(depth > MAX_DEPTH)
         {
            return "[MaxDepth]";
         }
         if(value == null)
         {
            return null;
         }
         if(value is String)
         {
            return truncate(String(value));
         }
         if(value is Boolean || value is Number || value is int || value is uint)
         {
            return value;
         }
         if(value is ISFSObject)
         {
            try
            {
               return safe(ISFSObject(value).toObject(),depth + 1);
            }
            catch(sfsObjectError:*)
            {
               return {"className":getQualifiedClassName(value),"error":String(sfsObjectError)};
            }
         }
         if(value is ISFSArray)
         {
            return sfsArraySummary(ISFSArray(value),depth + 1);
         }
         if(value is ByteArray)
         {
            return byteArraySummary(ByteArray(value));
         }
         if(value is XML)
         {
            return truncate(XML(value).toXMLString());
         }
         if(value is XMLList)
         {
            return truncate(XMLList(value).toXMLString());
         }
         if(value is Room)
         {
            return roomSummary(Room(value),depth + 1);
         }
         if(value is User)
         {
            return userSummary(User(value),depth + 1);
         }
         if(value is Variable)
         {
            return variableSummary(Variable(value),depth + 1);
         }
         if(value is Array)
         {
            return arraySummary(value as Array,depth + 1);
         }
         return objectSummary(value,depth + 1);
      }

      private static function ensureFile() : void
      {
         if(file != null)
         {
            return;
         }
         var dir:File = File.applicationStorageDirectory.resolvePath("captures");
         if(!dir.exists)
         {
            dir.createDirectory();
         }
         file = dir.resolvePath("sfs-client-capture.jsonl");
         if(!announced)
         {
            announced = true;
            trace("[SFS-CAPTURE] " + file.nativePath);
         }
      }

      private static function objectSummary(value:*, depth:int) : Object
      {
         var result:Object = {};
         try
         {
            result.className = getQualifiedClassName(value);
         }
         catch(error:*)
         {
         }
         try
         {
            for(var key:String in value)
            {
               if(isRedactedKey(key))
               {
                  result[key] = "[REDACTED]";
               }
               else
               {
                  result[key] = safe(value[key],depth + 1);
               }
            }
         }
         catch(loopError:*)
         {
            result.value = truncate(String(value));
         }
         return result;
      }

      private static function arraySummary(values:Array, depth:int) : Object
      {
         var result:Object = {};
         var items:Array = [];
         var count:int = values.length;
         var limit:int = Math.min(count,MAX_ARRAY);
         var index:int = 0;
         while(index < limit)
         {
            items.push(safe(values[index],depth + 1));
            index++;
         }
         result.length = count;
         result.items = items;
         if(count > limit)
         {
            result.truncated = count - limit;
         }
         return result;
      }

      private static function sfsArraySummary(values:ISFSArray, depth:int) : Object
      {
         var result:Object = {};
         var items:Array = [];
         var count:int = values.size();
         var limit:int = Math.min(count,MAX_ARRAY);
         var index:int = 0;
         while(index < limit)
         {
            items.push(safe(values.getElementAt(index),depth + 1));
            index++;
         }
         result.length = count;
         result.items = items;
         if(count > limit)
         {
            result.truncated = count - limit;
         }
         return result;
      }

      private static function byteArraySummary(bytes:ByteArray) : Object
      {
         var result:Object = {};
         var oldPosition:uint = bytes.position;
         var hex:Array = [];
         var limit:int = Math.min(bytes.length,256);
         bytes.position = 0;
         var index:int = 0;
         while(index < limit)
         {
            var part:String = bytes.readUnsignedByte().toString(16);
            if(part.length == 1)
            {
               part = "0" + part;
            }
            hex.push(part);
            index++;
         }
         bytes.position = oldPosition;
         result.length = bytes.length;
         result.hexPrefix = hex.join(" ");
         if(bytes.length > limit)
         {
            result.truncated = bytes.length - limit;
         }
         return result;
      }

      private static function roomSummary(room:Room, depth:int) : Object
      {
         if(room == null)
         {
            return null;
         }
         var result:Object = {};
         try
         {
            result.id = room.id;
            result.name = room.name;
            result.groupId = room.groupId;
            result.isJoined = room.isJoined;
            result.isGame = room.isGame;
            result.isHidden = room.isHidden;
            result.userCount = room.userCount;
            result.maxUsers = room.maxUsers;
            result.spectatorCount = room.spectatorCount;
            result.maxSpectators = room.maxSpectators;
            result.variables = [];
            for each(var variable:Variable in room.getVariables())
            {
               result.variables.push(variableSummary(variable,depth + 1));
            }
         }
         catch(error:*)
         {
            result.error = String(error);
         }
         return result;
      }

      private static function userSummary(user:User, depth:int) : Object
      {
         if(user == null)
         {
            return null;
         }
         var result:Object = {};
         try
         {
            result.id = user.id;
            result.name = user.name;
            result.playerId = user.playerId;
            result.privilegeId = user.privilegeId;
            result.isItMe = user.isItMe;
            result.variables = [];
            for each(var variable:Variable in user.getVariables())
            {
               result.variables.push(variableSummary(variable,depth + 1));
            }
         }
         catch(error:*)
         {
            result.error = String(error);
         }
         return result;
      }

      private static function variableSummary(variable:Variable, depth:int) : Object
      {
         if(variable == null)
         {
            return null;
         }
         var result:Object = {};
         try
         {
            result.name = variable.name;
            result.type = variable.type;
            result.value = safe(variable.getValue(),depth + 1);
         }
         catch(error:*)
         {
            result.error = String(error);
         }
         return result;
      }

      private static function isRedactedKey(key:String) : Boolean
      {
         if(key == null)
         {
            return false;
         }
         var normalized:String = key.toLowerCase();
         return normalized == "password" || normalized == "pass" || normalized == "token" || normalized == "at" || normalized == "fbtoken" || normalized == "sessiontoken" || normalized == "authorization" || normalized == "auth";
      }

      private static function truncate(value:String) : String
      {
         if(value == null || value.length <= MAX_STRING)
         {
            return value;
         }
         return value.substr(0,MAX_STRING) + "...[truncated " + (value.length - MAX_STRING) + " chars]";
      }
   }
}
'@ | Set-Content -LiteralPath $capturePath -NoNewline
}

function Inject-CaptureHooks {
    param([string]$Root)

    $path = Join-Path $Root "com/smartfoxserver/v2/core/SFSProtocolCodec.as"
    $text = Read-Text $path
    $text = Add-Import $text "import flash.utils.ByteArray;" "import com.oyunstudyosu.capture.CaptureLog;"
    $text = Insert-BeforeFirst $text "         this.dispatchRequest(_loc2_);" "         CaptureLog.writeSfsPacket(\"in\",_loc2_);" "CaptureLog.writeSfsPacket(\"in\""
    $text = Insert-BeforeFirst $text "         this.ioHandler.onDataWrite(param1);" "         CaptureLog.writeSfsPacket(\"out\",_loc2_);" "CaptureLog.writeSfsPacket(\"out\""
    Write-Text $path $text

    $path = Join-Path $Root "com/smartfoxserver/v2/SmartFox.as"
    $text = Read-Text $path
    $text = Add-Import $text "import com.smartfoxserver.v2.bitswarm.BitSwarmClient;" "import com.oyunstudyosu.capture.CaptureLog;"
    $text = Add-Import $text "import flash.errors.IllegalOperationError;" "import flash.events.Event;"
    $dispatchOverride = @'
      override public function dispatchEvent(param1:Event) : Boolean
      {
         CaptureLog.writeEvent(param1);
         return super.dispatchEvent(param1);
      }

'@
    $text = Insert-BeforeFirst $text "      public function loadConfig(param1:String = \"sfs-config.xml\", param2:Boolean = true) : void" $dispatchOverride "override public function dispatchEvent"
    Write-Text $path $text

    $path = Join-Path $Root "com/oyunstudyosu/service/ServiceModel.as"
    $text = Read-Text $path
    $text = Add-Import $text "import com.oyunstudyosu.panel.PanelVO;" "import com.oyunstudyosu.capture.CaptureLog;"
    $text = Insert-BeforeFirst $text "         _sfs.send(new ExtensionRequest(param1,_loc7_.getSFSObject(),param4));" @'
         CaptureLog.write("extension.out",{
            "cmd":param1,
            "data":CaptureLog.safe(param2)
         });
'@ "CaptureLog.write(\"extension.out\""
    $text = Insert-AfterFirst $text "         _loc6_ = _loc5_.toObject();" @'
         CaptureLog.write("extension.in",{
            "cmd":_loc13_,
            "data":CaptureLog.safe(_loc6_)
         });
'@ "CaptureLog.write(\"extension.in\""
    $text = Insert-AfterFirst $text "         var _loc5_:Room = param1.params.room as Room;" "         CaptureLog.writeRoomVariables(\"roomVariablesUpdate\",_loc5_,_loc6_);" "CaptureLog.writeRoomVariables"
    $text = Insert-AfterFirst $text "         var _loc3_:User = param1.params.user as User;" "         CaptureLog.writeUserVariables(\"userVariablesUpdate\",_loc3_,_loc4_);" "CaptureLog.writeUserVariables"
    Write-Text $path $text

    $path = Join-Path $Root "com/oyunstudyosu/room/RoomModel.as"
    $text = Read-Text $path
    $text = Add-Import $text "import com.oyunstudyosu.bot.IBotModel;" "import com.oyunstudyosu.capture.CaptureLog;"
    $text = Insert-AfterFirst $text "         roomData = param1;" "         CaptureLog.write(\"room.checkMap\",CaptureLog.safe(param1));" "CaptureLog.write(\"room.checkMap\""
    $text = Insert-AfterFirst $text "         var _loc2_:String = StringUtils.replaceAll(param1,\"\\\\u003d\",\"=\");" @'
         CaptureLog.write("room.map",{
            "base64Length":param1 == null ? 0 : param1.length,
            "xml":Base64.decode(param1)
         });
'@ "CaptureLog.write(\"room.map\""
    Write-Text $path $text

    $path = Join-Path $Root "com/oyunstudyosu/door/DoorModel.as"
    $text = Read-Text $path
    $text = Add-Import $text "import com.oyunstudyosu.alert.AlertVo;" "import com.oyunstudyosu.capture.CaptureLog;"
    $text = Insert-AfterFirst $text "      public function useDoorByKey(param1:String) : void`r`n      {" "         CaptureLog.write(\"door.useDoorByKey\",{\"key\":param1});" "CaptureLog.write(\"door.useDoorByKey\""
    $text = Insert-AfterFirst $text "         mapData = [];" "         CaptureLog.write(\"door.useHouseDoor\",{\"flatID\":param1,\"avatarID\":param2,\"buildingData\":CaptureLog.safe(param4)});" "CaptureLog.write(\"door.useHouseDoor\""
    $text = Insert-BeforeFirst $text "         _loc4_ = 0;`r`n         while(_loc4_ < param1.length)" "         CaptureLog.write(\"door.load\",CaptureLog.safe(param1));" "CaptureLog.write(\"door.load\""
    $text = Insert-AfterFirst $text "         var _loc2_:Array = JSON.parse(param1) as Array;" "         CaptureLog.write(\"door.loadJSON\",{\"raw\":param1,\"data\":CaptureLog.safe(_loc2_)});" "CaptureLog.write(\"door.loadJSON\""
    Write-Text $path $text

    $path = Join-Path $Root "com/oyunstudyosu/model/GridModel.as"
    $text = Read-Text $path
    $text = Add-Import $text "import com.hurlant.util.Base64;" "import com.oyunstudyosu.capture.CaptureLog;"
    $text = Insert-BeforeFirst $text "         this._data[param2 * this._width + param1] = param3;" "         CaptureLog.write(\"grid.setCellValue\",{\"x\":param1,\"y\":param2,\"value\":param3});" "CaptureLog.write(\"grid.setCellValue\""
    $text = Insert-AfterFirst $text "         var byteArray:ByteArray = Base64.decodeToByteArray(value);" "         CaptureLog.write(\"grid.load.raw\",{\"base64Length\":value == null ? 0 : value.length});" "CaptureLog.write(\"grid.load.raw\""
    $text = Insert-AfterFirst $text "            this.inited = true;" "            CaptureLog.write(\"grid.load\",{\"width\":this._width,\"height\":this._height,\"data\":CaptureLog.safe(this._data)});" "CaptureLog.write(\"grid.load\""
    Write-Text $path $text
}

function Test-CaptureAnchors {
    Test-AnchorFile "com/smartfoxserver/v2/core/SFSProtocolCodec.as" @(
        "         this.dispatchRequest(_loc2_);",
        "         this.ioHandler.onDataWrite(param1);"
    )
    Test-AnchorFile "com/smartfoxserver/v2/SmartFox.as" @(
        "      public function loadConfig(param1:String = \"sfs-config.xml\", param2:Boolean = true) : void"
    )
    Test-AnchorFile "com/oyunstudyosu/service/ServiceModel.as" @(
        "         _sfs.send(new ExtensionRequest(param1,_loc7_.getSFSObject(),param4));",
        "         _loc6_ = _loc5_.toObject();",
        "         var _loc5_:Room = param1.params.room as Room;",
        "         var _loc3_:User = param1.params.user as User;"
    )
    Test-AnchorFile "com/oyunstudyosu/room/RoomModel.as" @(
        "         roomData = param1;",
        "         var _loc2_:String = StringUtils.replaceAll(param1,\"\\u003d\",\"=\");"
    )
    Test-AnchorFile "com/oyunstudyosu/door/DoorModel.as" @(
        "      public function useDoorByKey(param1:String) : void`r`n      {",
        "         var _loc2_:Array = JSON.parse(param1) as Array;"
    )
    Test-AnchorFile "com/oyunstudyosu/model/GridModel.as" @(
        "         this._data[param2 * this._width + param1] = param3;",
        "         var byteArray:ByteArray = Base64.decodeToByteArray(value);"
    )
}

function Compile-CaptureSwf {
    param([string]$Root)

    if (-not (Test-Path -LiteralPath $runtimeSwf)) { throw "Runtime SWF not found: $runtimeSwf" }

    $sdkRoot = Resolve-SdkRoot -ExplicitSdkHome $SdkHome
    if (-not $sdkRoot) { throw "No AIR/Flex SDK found. Pass -SdkHome or set AIR_SDK_HOME/FLEX_HOME." }

    $compilerJar = Join-Path $sdkRoot "lib/mxmlc.jar"
    if (-not (Test-Path -LiteralPath $compilerJar)) { throw "Flex compiler jar not found: $compilerJar" }

    $java = $null
    if ($JavaHome) {
        $javaCandidate = Join-Path $JavaHome "bin/java.exe"
        if (Test-Path -LiteralPath $javaCandidate) { $java = $javaCandidate }
    }
    if (-not $java) {
        $javaCommand = Get-Command java -ErrorAction SilentlyContinue
        if ($javaCommand) { $java = $javaCommand.Source }
    }
    if (-not $java) { throw "No Java runtime found. Pass -JavaHome or add java to PATH." }

    $mainFile = Join-Path $Root "$MainClass.as"
    if (-not (Test-Path -LiteralPath $mainFile)) { throw "Main class file not found: $mainFile" }

    $outputDir = Split-Path $outputPath -Parent
    $assetDir = Join-Path $Root "_assets"
    $assetBundle = Join-Path $assetDir "assets.swf"
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    New-Item -ItemType Directory -Force -Path $assetDir | Out-Null
    Copy-Item -LiteralPath $runtimeSwf -Destination $assetBundle -Force

    $env:FLEX_HOME = $sdkRoot
    $env:AIR_HOME = $sdkRoot
    $env:AIR_SDK_HOME = $sdkRoot

    $compilerArgs = @(
        "-Xmx1024m",
        "-Dsun.io.useCanonCaches=false",
        "-Djava.util.Arrays.useLegacyMergeSort=true",
        "-jar",
        $compilerJar,
        "+configname=air",
        "+flexlib=$sdkRoot/frameworks",
        "-source-path+=$Root",
        "-debug=true",
        "-warnings=false",
        "-strict=false",
        "-compiler.verbose-stacktraces=true",
        "-static-link-runtime-shared-libraries=true",
        "-output=$outputPath",
        $mainFile
    )

    Write-Host "SDK:      $sdkRoot"
    Write-Host "Compiler: $compilerJar"
    Write-Host "Java:     $java"
    Write-Host "Main:     $mainFile"
    Write-Host "Output:   $outputPath"

    $previousLocation = Get-Location
    Set-Location $Root
    try { & $java @compilerArgs }
    finally { Set-Location $previousLocation }

    if ($LASTEXITCODE -ne 0) { throw "Compiler failed with exit code $LASTEXITCODE." }

    if ($PromoteToRuntime) {
        if (-not (Test-Path -LiteralPath $runtimeBackup)) {
            Copy-Item -LiteralPath $runtimeSwf -Destination $runtimeBackup -Force
        }
        Copy-Item -LiteralPath $outputPath -Destination $runtimeSwf -Force
        Write-Host "Promoted capture SWF to: $runtimeSwf"
        Write-Host "Original backup:         $runtimeBackup"
    }
}

if (-not (Test-Path -LiteralPath $sourceRoot)) { throw "Source directory not found: $sourceRoot" }

Test-CaptureAnchors
if ($ValidateOnly) {
    Write-Host "Capture hook anchors validated in: $sourceRoot"
    return
}

if (Test-Path -LiteralPath $outputRoot) {
    Remove-Item -LiteralPath $outputRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
Copy-Item -Path (Join-Path $sourceRoot "*") -Destination $outputRoot -Recurse -Force
Preprocess-GeneratedSource -Root $outputRoot
Add-CaptureLogger -Root $outputRoot
Inject-CaptureHooks -Root $outputRoot
Write-Host "Capture hooks injected: $outputRoot"

if ($Compile -or $PromoteToRuntime) {
    Compile-CaptureSwf -Root $outputRoot
}
else {
    Write-Host "Compile skipped. Rerun with -Compile to build $outputPath"
}
#>