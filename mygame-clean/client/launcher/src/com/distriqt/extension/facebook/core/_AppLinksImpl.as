package com.distriqt.extension.facebook.core
{
   import com.distriqt.extension.facebook.applinks.AppLink;
   import com.distriqt.extension.facebook.applinks.AppLinks;
   import com.distriqt.extension.facebook.applinks.events.AppLinkEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _AppLinksImpl extends EventDispatcher implements AppLinks
   {
      
      private var _extContext:ExtensionContext;
      
      public function _AppLinksImpl(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
         _extContext.addEventListener("status",extContext_statusHandler);
      }
      
      public function dispose() : void
      {
         if(_extContext != null)
         {
            _extContext.removeEventListener("status",extContext_statusHandler);
            _extContext = null;
         }
      }
      
      public function openReferer(param1:AppLink) : Boolean
      {
         try
         {
            return _extContext.call("appLinks_openReferer",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function fetchDeferredAppLink() : Boolean
      {
         try
         {
            return _extContext.call("appLinks_fetchDeferredAppLink") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function extContext_statusHandler(param1:StatusEvent) : void
      {
         var _loc3_:Object = null;
         var _loc2_:AppLink = null;
         try
         {
            switch(param1.code)
            {
               case "facebook_applinks_applink":
               case "facebook_applinks_fetch_complete":
                  _loc3_ = JSON.parse(param1.level);
                  _loc2_ = null;
                  if(_loc3_.hasOwnProperty("appLinkData"))
                  {
                     _loc2_ = new AppLink();
                     _loc2_.data = _loc3_.appLinkData;
                  }
                  dispatchEvent(new AppLinkEvent(param1.code,_loc2_));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

