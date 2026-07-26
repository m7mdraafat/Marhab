package com.distriqt.extension.facebook.login.events
{
   import com.distriqt.extension.facebook.login.AccessToken;
   import flash.events.Event;
   
   public class FacebookAccessTokenEvent extends Event
   {
      
      private static const TAG:String = "FacebookProfileEvent";
      
      public static const CHANGED:String = "facebook:login:accesstoken:changed";
      
      public var accessToken:AccessToken;
      
      public var oldAccessToken:AccessToken;
      
      public function FacebookAccessTokenEvent(param1:String, param2:AccessToken, param3:AccessToken, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this.accessToken = param2;
         this.oldAccessToken = param3;
      }
      
      override public function clone() : Event
      {
         return new FacebookAccessTokenEvent(type,accessToken,oldAccessToken,bubbles,cancelable);
      }
   }
}

