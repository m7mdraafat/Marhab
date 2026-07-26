package com.oyunstudyosu.air.events
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class Dispatcher
   {
      
      public static var eventDispatcher:EventDispatcher;
      
      public static var listenerCount:uint = 0;
      
      public function Dispatcher()
      {
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:Boolean = false, param5:int = 0) : void
      {
         if(Dispatcher.eventDispatcher == null)
         {
            Dispatcher.eventDispatcher = new EventDispatcher();
         }
         ++Dispatcher.listenerCount;
         Dispatcher.eventDispatcher.addEventListener(param1,param2,param4,param5,param3);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         if(Dispatcher.eventDispatcher == null)
         {
            return;
         }
         if(Dispatcher.eventDispatcher.hasEventListener(param1))
         {
            Dispatcher.eventDispatcher.removeEventListener(param1,param2,param3);
         }
         --Dispatcher.listenerCount;
      }
      
      public static function dispatchEvent(param1:Event) : void
      {
         if(Dispatcher.eventDispatcher == null)
         {
            return;
         }
         Dispatcher.eventDispatcher.dispatchEvent(param1);
      }
   }
}

