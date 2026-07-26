package com.distriqt.extension.bolts.events
{
   import flash.events.Event;
   
   public class GenericEvent extends Event
   {
      
      public static const ERROR:String = "extension:error";
      
      public var message:String = "";
      
      public function GenericEvent(param1:String, param2:String = "", param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.message = param2;
      }
   }
}

