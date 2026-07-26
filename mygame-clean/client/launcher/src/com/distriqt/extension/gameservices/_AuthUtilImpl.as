package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.auth.AuthUtil;
   import com.distriqt.extension.gameservices.events.AuthUtilEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _AuthUtilImpl extends EventDispatcher implements AuthUtil
   {
      
      private var _extContext:ExtensionContext = null;
      
      public function _AuthUtilImpl(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
         _extContext.addEventListener("status",extension_statusHandler,false,0,true);
      }
      
      public function dispose() : void
      {
         _extContext.removeEventListener("status",extension_statusHandler);
         _extContext = null;
      }
      
      public function get isSupported() : Boolean
      {
         try
         {
            return _extContext.call("authUtil_isSupported") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function getToken(param1:String = "") : Boolean
      {
         try
         {
            return _extContext.call("authUtil_getToken",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function clearToken(param1:String = "") : Boolean
      {
         try
         {
            return _extContext.call("authUtil_clearToken",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         switch(param1.code)
         {
            case "auth:token:success":
               try
               {
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new AuthUtilEvent("auth:token:success",_loc2_));
               }
               catch(e:Error)
               {
               }
               break;
            case "auth:token:error":
               try
               {
                  _loc3_ = JSON.parse(param1.level);
                  dispatchEvent(new AuthUtilEvent("auth:token:error",_loc3_.error));
               }
               catch(e:Error)
               {
               }
         }
      }
   }
}

