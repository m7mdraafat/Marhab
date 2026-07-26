package com.junkbyte.console.addons.memoryRecorder
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.KeyBind;
   
   public class MemoryRecorderAddon
   {
      
      public function MemoryRecorderAddon()
      {
         super();
      }
      
      public static function registerToConsole(param1:Console, param2:String = "r") : void
      {
         var onMemoryRecorderStart:Function;
         var onMemoryRecorderEnd:Function;
         var console:Console = param1;
         var key:String = param2;
         MemoryRecorder.instance.reportCallback = function(... rest):void
         {
            rest.unshift("R");
            console.infoch.apply(null,rest);
         };
         onMemoryRecorderStart = function():void
         {
            if(MemoryRecorder.instance.running == false)
            {
               MemoryRecorder.instance.start();
            }
         };
         onMemoryRecorderEnd = function():void
         {
            if(MemoryRecorder.instance.running)
            {
               console.clear("R");
               MemoryRecorder.instance.end();
            }
         };
         console.bindKey(new KeyBind(key),onMemoryRecorderStart);
         console.bindKey(new KeyBind(key,false,false,false,true),onMemoryRecorderEnd);
      }
   }
}

