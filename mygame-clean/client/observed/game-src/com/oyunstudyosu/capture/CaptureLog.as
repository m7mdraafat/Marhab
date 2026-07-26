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