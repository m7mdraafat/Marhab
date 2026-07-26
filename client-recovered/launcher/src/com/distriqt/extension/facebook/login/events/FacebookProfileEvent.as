package com.distriqt.extension.facebook.login.events
{
   import com.distriqt.extension.facebook.login.Profile;
   import flash.events.Event;
   
   public class FacebookProfileEvent extends Event
   {
      
      private static const TAG:String = "FacebookProfileEvent";
      
      public static const CHANGED:String = "facebook:login:profile:changed";
      
      public var profile:Profile;
      
      public var oldProfile:Profile;
      
      public function FacebookProfileEvent(param1:String, param2:Profile, param3:Profile, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this.profile = param2;
         this.oldProfile = param3;
      }
      
      override public function clone() : Event
      {
         return new FacebookProfileEvent(type,profile,oldProfile,bubbles,cancelable);
      }
   }
}

