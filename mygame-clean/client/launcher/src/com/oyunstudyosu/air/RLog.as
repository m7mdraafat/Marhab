package com.oyunstudyosu.air
{
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.Capabilities;
   import flash.utils.getQualifiedClassName;

   public class RLog
   {
      private static var started:Boolean = false;
      private static var failed:Boolean = false;
      private static var sequence:int = 0;
      private static var sessionId:String;
      private static var sessionDir:File;
      private static var eventsFile:File;
      private static const MAX_DEPTH:int = 6;
      private static const MAX_STRING:int = 32768;

      public function RLog()
      {
      }

      public static function start(mode:String = "logged-clean") : void
      {
         if(started)
         {
            return;
         }
         started = true;
         try
         {
            var now:Date = new Date();
            sessionId = "session-" + formatDate(now) + "-" + String(now.getTime());
            sessionDir = File.applicationStorageDirectory.resolvePath("sessions/" + sessionId);
            sessionDir.createDirectory();
            eventsFile = sessionDir.resolvePath("events.jsonl");
            writeText(File.applicationStorageDirectory.resolvePath("sessions/latest.txt"),sessionDir.nativePath + "\n");
            write("session.start",{
               "mode": mode,
               "sessionId": sessionId,
               "sessionDir": sessionDir.nativePath,
               "applicationDirectory": File.applicationDirectory.nativePath,
               "applicationStorageDirectory": File.applicationStorageDirectory.nativePath,
               "os": Capabilities.os,
               "playerType": Capabilities.playerType,
               "version": Capabilities.version
            });
         }
         catch(error:Error)
         {
            failed = true;
         }
      }

      public static function get currentSessionId() : String
      {
         return sessionId;
      }

      public static function get currentSessionPath() : String
      {
         return sessionDir != null ? sessionDir.nativePath : null;
      }

      public static function write(kind:String, payload:* = null) : void
      {
         if(failed)
         {
            return;
         }
         if(!started)
         {
            start("auto");
         }
         try
         {
            append(JSON.stringify({
               "seq": ++sequence,
               "time": new Date().getTime(),
               "kind": kind,
               "payload": safe(payload)
            }));
         }
         catch(error:Error)
         {
            try
            {
               append(JSON.stringify({
                  "seq": ++sequence,
                  "time": new Date().getTime(),
                  "kind": "rlog.error",
                  "payload": {"kind":kind,"message":error.message}
               }));
            }
            catch(inner:Error)
            {
               failed = true;
            }
         }
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
         if(value is Error)
         {
            return {"name":String(Error(value).name),"message":String(Error(value).message),"errorID":Error(value).errorID,"stack":truncate(String(Error(value).getStackTrace()))};
         }
         if(value is Event)
         {
            return {"type":Event(value).type,"className":getQualifiedClassName(value)};
         }
         if(value is XML || value is XMLList)
         {
            return truncate(value.toString());
         }
         if(value is Array)
         {
            var output:Array = [];
            var source:Array = value as Array;
            var index:int = 0;
            while(index < source.length)
            {
               output[index] = safe(source[index],depth + 1);
               index++;
            }
            return output;
         }
         if(value is File)
         {
            return {"nativePath":File(value).nativePath,"url":File(value).url,"exists":File(value).exists};
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

      private static function append(line:String) : void
      {
         if(eventsFile == null)
         {
            failed = true;
            return;
         }
         var stream:FileStream = new FileStream();
         stream.open(eventsFile,FileMode.APPEND);
         stream.writeUTFBytes(line + "\n");
         stream.close();
      }

      private static function writeText(file:File, text:String) : void
      {
         var parent:File = file.parent;
         if(parent != null && !parent.exists)
         {
            parent.createDirectory();
         }
         var stream:FileStream = new FileStream();
         stream.open(file,FileMode.WRITE);
         stream.writeUTFBytes(text);
         stream.close();
      }

      private static function shouldRedact(key:String) : Boolean
      {
         var lower:String = key.toLowerCase();
         return lower.indexOf("token") >= 0 || lower.indexOf("password") >= 0 || lower.indexOf("secret") >= 0 || lower == "at" || lower == "auth" || lower == "fbtoken";
      }

      private static function truncate(value:String) : String
      {
         if(value != null && value.length > MAX_STRING)
         {
            return value.substr(0,MAX_STRING) + "...[truncated " + value.length + "]";
         }
         return value;
      }

      private static function formatDate(value:Date) : String
      {
         return String(value.getFullYear()) + pad2(value.getMonth() + 1) + pad2(value.getDate()) + "-" + pad2(value.getHours()) + pad2(value.getMinutes()) + pad2(value.getSeconds());
      }

      private static function pad2(value:int) : String
      {
         return value < 10 ? "0" + value : String(value);
      }
   }
}
