package com.distriqt.extension.facebook.applinks
{
   import flash.events.IEventDispatcher;
   
   [Event(name="facebook_applinks_applink",type="com.distriqt.extension.facebook.applinks.events.AppLinkEvent")]
   [Event(name="facebook_applinks_fetch_complete",type="com.distriqt.extension.facebook.applinks.events.AppLinkEvent")]
   public interface AppLinks extends IEventDispatcher
   {
      
      function openReferer(param1:AppLink) : Boolean;
      
      function fetchDeferredAppLink() : Boolean;
   }
}

