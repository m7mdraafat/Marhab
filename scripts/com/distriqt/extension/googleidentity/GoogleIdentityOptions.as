package com.distriqt.extension.googleidentity
{
   public class GoogleIdentityOptions
   {
      
      public static const DEFAULT_SIGN_IN:String = "sign_in";
      
      public static const DEFAULT_GAMES_SIGN_IN:String = "games_sign_in";
      
      public var defaultOptions:String = "sign_in";
      
      public var clientID:String = "";
      
      public var serverClientID:String = "";
      
      public var scopes:Vector.<String>;
      
      public var requestIdToken:Boolean = false;
      
      public var requestServerAuthCode:Boolean = false;
      
      public var requestEmail:Boolean = true;
      
      public var requestProfile:Boolean = false;
      
      public function GoogleIdentityOptions()
      {
         super();
         this.scopes = new Vector.<String>();
      }
   }
}

