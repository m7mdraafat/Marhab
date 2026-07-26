package com.distriqt.extension.facebook.appevents
{
   import flash.events.IEventDispatcher;
   
   public interface AppEventsLogger extends IEventDispatcher
   {
      
      function activateApp() : void;
      
      function setFlushBehaviour(param1:String = "auto") : void;
      
      function flush() : Boolean;
      
      function setUserID(param1:String) : void;
      
      function getUserID() : String;
      
      function clearUserID() : Boolean;
      
      function logEvent(param1:AppEvent) : Boolean;
      
      function logPurchase(param1:AppPurchaseEvent) : Boolean;
   }
}

