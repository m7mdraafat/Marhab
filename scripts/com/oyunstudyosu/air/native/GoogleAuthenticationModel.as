package com.oyunstudyosu.air.native
{
   import com.distriqt.extension.gameservices.events.AuthUtilEvent;
   import com.distriqt.extension.googleidentity.GoogleIdentity;
   import com.distriqt.extension.googleidentity.events.GoogleIdentityEvent;
   import com.junkbyte.console.Cc;
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.GameEvent;
   
   public class GoogleAuthenticationModel
   {
      
      public function GoogleAuthenticationModel()
      {
      }
      
      public function setupCompleteHandler(param1:GoogleIdentityEvent) : void
      {
         GoogleIdentity.service.signInSilently();
      }
      
      public function googleIdentityTokenUpdated(param1:GoogleIdentityEvent) : void
      {
         Cc.info(param1.user);
         Cc.info(param1.user.authentication.accessToken);
         var _loc2_:GameEvent = new GameEvent("GOOGLE_AUTHENTICATION");
         _loc2_.data = param1.user.authentication.accessToken;
         Dispatcher.dispatchEvent(_loc2_);
         GoogleIdentity.service.signOut();
      }
      
      public function googleIdentityTokenFailed(param1:GoogleIdentityEvent) : void
      {
         Cc.warnch("googleIdentityTokenFailed",param1.error);
      }
      
      public function googleIdentitySignInHandler(param1:GoogleIdentityEvent) : void
      {
         GoogleIdentity.service.getToken("gy-oFJHzifoP2Nqk-tx8ZSNa");
      }
      
      public function googleIdentityErrorHandler(param1:GoogleIdentityEvent) : void
      {
         Cc.warnch("googleIdentityErrorHandler",param1.error);
      }
      
      public function authenticate() : void
      {
         GoogleIdentity.service.signIn();
      }
      
      public function authTokenErrorHandler(param1:AuthUtilEvent) : void
      {
         Cc.warnch("authTokenErrorHandler",param1.data);
      }
   }
}

