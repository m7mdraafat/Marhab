package com.oyunstudyosu.air.native
{
   import com.distriqt.extension.facebook.core.Facebook;
   import com.distriqt.extension.facebook.login.AccessToken;
   import com.distriqt.extension.facebook.login.FacebookLogin;
   import com.distriqt.extension.facebook.login.events.FacebookLoginEvent;
   import com.junkbyte.console.Cc;
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.GameEvent;
   import flash.Boot;
   
   public class FacebookAuthenticationModel
   {
      
      public function FacebookAuthenticationModel()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         FacebookLogin.instance.addEventListener(FacebookLoginEvent.SUCCESS,successHandler);
      }
      
      public function successHandler(param1:FacebookLoginEvent) : void
      {
         var _loc3_:* = null as GameEvent;
         var _loc2_:AccessToken = FacebookLogin.instance.getAccessToken();
         if(_loc2_ != null)
         {
            Cc.infoch("facebookSuccessHandler",_loc2_.token);
            _loc3_ = new GameEvent("FACEBOOK_AUTHENTICATION");
            _loc3_.data = _loc2_.token;
            Dispatcher.dispatchEvent(_loc3_);
         }
         else
         {
            Cc.warnch("facebookSuccessHandler","token not available");
         }
      }
      
      public function authenticate() : void
      {
         if(Facebook.isSupported && FacebookLogin.isSupported)
         {
            FacebookLogin.instance.logInWithReadPermissions(["public_profile","email"]);
         }
         else
         {
            Cc.warnch("facebookAuthenticate","Facebook login is not supported");
         }
      }
   }
}

