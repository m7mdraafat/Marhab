package com.distriqt.extension.facebook.applinks.events
{
   import com.distriqt.extension.facebook.applinks.AppLink;
   import flash.events.Event;
   
   public class AppLinkEvent extends Event
   {
      
      public static const APP_LINK:String = "facebook_applinks_applink";
      
      public static const FETCH_COMPLETE:String = "facebook_applinks_fetch_complete";
      
      public var appLink:AppLink;
      
      public function AppLinkEvent(param1:String, param2:AppLink = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.appLink = param2;
      }
      
      override public function clone() : Event
      {
         return new AppLinkEvent(type,appLink,bubbles,cancelable);
      }
   }
}

