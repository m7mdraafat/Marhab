package com.oyunstudyosu.events
{
   import flash.events.Event;
   
   public class DiscordEvent extends Event
   {
      
      public var params:*;
      
      public function DiscordEvent(param1:String, param2:* = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.params = param2;
      }
      
      override public function clone() : Event
      {
         return new DiscordEvent(type,this.params,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("DiscordEvent","params","type","bubbles","cancelable");
      }
   }
}

