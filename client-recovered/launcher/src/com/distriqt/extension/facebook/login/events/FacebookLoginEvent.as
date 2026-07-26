package com.distriqt.extension.facebook.login.events
{
   import com.distriqt.extension.facebook.login.AccessToken;
   import com.distriqt.extension.facebook.login.AuthenticationToken;
   import com.distriqt.extension.facebook.login.Profile;
   import flash.events.Event;
   
   public class FacebookLoginEvent extends Event
   {
      
      private static const TAG:String = "FacebookLoginEvent";
      
      public static const SUCCESS:String = "facebook:login:success";
      
      public static const CANCEL:String = "facebook:login:cancel";
      
      public var accessToken:AccessToken = null;
      
      public var profile:Profile = null;
      
      public var authToken:AuthenticationToken = null;
      
      public function FacebookLoginEvent(param1:String, param2:AccessToken = null, param3:Profile = null, param4:AuthenticationToken = null, param5:Boolean = false, param6:Boolean = false)
      {
         super(param1,param5,param6);
         this.accessToken = param2;
         this.profile = param3;
         this.authToken = param4;
      }
      
      override public function clone() : Event
      {
         return new FacebookLoginEvent(type,accessToken,profile,authToken,bubbles,cancelable);
      }
   }
}

