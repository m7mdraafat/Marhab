package com.distriqt.extension.facebook.core
{
   import com.distriqt.extension.facebook.appevents.AppEvent;
   import com.distriqt.extension.facebook.appevents.AppEventsLogger;
   import com.distriqt.extension.facebook.appevents.AppPurchaseEvent;
   import flash.events.EventDispatcher;
   import flash.external.ExtensionContext;
   
   internal class _AppEventsLogger extends EventDispatcher implements AppEventsLogger
   {
      
      private static const TAG:String = "_AppEventsLogger";
      
      private var _extContext:ExtensionContext;
      
      public function _AppEventsLogger(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
      }
      
      public function dispose() : void
      {
         _extContext = null;
      }
      
      public function activateApp() : void
      {
         try
         {
            _extContext.call("appEvents_activateApp");
         }
         catch(e:Error)
         {
         }
      }
      
      public function setFlushBehaviour(param1:String = "auto") : void
      {
         try
         {
            _extContext.call("appEvents_setFlushBehaviour",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function flush() : Boolean
      {
         try
         {
            return _extContext.call("appEvents_flush") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function setUserID(param1:String) : void
      {
         try
         {
            _extContext.call("appEvents_setUserID",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function getUserID() : String
      {
         try
         {
            return _extContext.call("appEvents_getUserID") as String;
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function clearUserID() : Boolean
      {
         try
         {
            return _extContext.call("appEvents_clearUserID") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function logEvent(param1:AppEvent) : Boolean
      {
         if(param1 == null || param1.eventName == null || param1.eventName.length == 0)
         {
            throw new Error("You must specify the eventName property for the FacebookAppEvent.");
         }
         try
         {
            return _extContext.call("appEvents_logEvent",JSON.stringify(param1.toObject())) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function logPurchase(param1:AppPurchaseEvent) : Boolean
      {
         if(param1 == null || param1.currency == null || param1.currency.length == 0)
         {
            throw new Error("You must specify the purchaseAmount and currency properties for the FacebookAppPurchaseEvent object.");
         }
         try
         {
            return _extContext.call("appEvents_logPurchase",JSON.stringify(param1.toObject())) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
   }
}

