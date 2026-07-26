package com.distriqt.extension.facebook.login.events
{
   import flash.events.ErrorEvent;
   import flash.events.Event;
   
   public class FacebookLoginErrorEvent extends ErrorEvent
   {
      
      private static const TAG:String = "FacebookLoginEvent";
      
      public static const ERROR:String = "facebook:login:error";
      
      public function FacebookLoginErrorEvent(param1:String, param2:String, param3:int, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5,param2,param3);
      }
      
      override public function clone() : Event
      {
         return new FacebookLoginErrorEvent(type,text,errorID,bubbles,cancelable);
      }
   }
}

