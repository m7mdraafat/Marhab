package com.distriqt.extension.googleidentity.events
{
   import com.distriqt.extension.googleidentity.GoogleUser;
   import flash.events.Event;
   
   public class GoogleIdentityEvent extends Event
   {
      
      [Deprecated(message="setup is now synchronous. This will still be dispatched though if you wish to keep existing code.")]
      public static const SETUP_COMPLETE:String = "googleidentity:setupcomplete";
      
      public static const SIGN_IN:String = "googleidentity:signin";
      
      public static const SIGN_OUT:String = "googleidentity:signout";
      
      public static const DISCONNECT:String = "googleidentity:disconnect";
      
      public static const ERROR:String = "googleidentity:error";
      
      public static const TOKEN_UPDATED:String = "googleidentity:token:updated";
      
      public static const TOKEN_FAILED:String = "googleidentity:token:failed";
      
      public var user:GoogleUser;
      
      public var error:String;
      
      public var errorCode:int;
      
      public function GoogleIdentityEvent(param1:String, param2:GoogleUser, param3:String = null, param4:int = -1, param5:Boolean = false, param6:Boolean = false)
      {
         super(param1,param5,param6);
         this.user = param2;
         this.error = param3;
         this.errorCode = param4;
      }
      
      override public function clone() : Event
      {
         return new GoogleIdentityEvent(type,user,error,errorCode,bubbles,cancelable);
      }
   }
}

