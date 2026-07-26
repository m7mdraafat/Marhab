package com.distriqt.extension.googleidentity
{
   public class GoogleIdentityOptionsBuilder
   {
      
      private static const TAG:String = "GoogleIdentityOptionsBuilder";
      
      private var _options:GoogleIdentityOptions;
      
      public function GoogleIdentityOptionsBuilder(param1:String = "sign_in")
      {
         super();
         _options = new GoogleIdentityOptions();
         _options.defaultOptions = param1;
      }
      
      public function requestProfile(param1:Boolean = true) : GoogleIdentityOptionsBuilder
      {
         _options.requestProfile = param1;
         return this;
      }
      
      public function requestEmail(param1:Boolean = true) : GoogleIdentityOptionsBuilder
      {
         _options.requestEmail = param1;
         return this;
      }
      
      public function requestIdToken(param1:Boolean = true) : GoogleIdentityOptionsBuilder
      {
         _options.requestIdToken = param1;
         return this;
      }
      
      public function requestServerAuthCode(param1:Boolean = true) : GoogleIdentityOptionsBuilder
      {
         _options.requestServerAuthCode = param1;
         return this;
      }
      
      public function setClientID(param1:String) : GoogleIdentityOptionsBuilder
      {
         _options.clientID = param1;
         return this;
      }
      
      public function setServerClientID(param1:String) : GoogleIdentityOptionsBuilder
      {
         _options.serverClientID = param1;
         return this;
      }
      
      public function addScope(param1:String) : GoogleIdentityOptionsBuilder
      {
         _options.scopes.push(param1);
         return this;
      }
      
      public function setAndroidServerClientID(param1:String) : GoogleIdentityOptionsBuilder
      {
         if(_isAndroid)
         {
            _options.serverClientID = param1;
         }
         return this;
      }
      
      public function setiOSServerClientID(param1:String) : GoogleIdentityOptionsBuilder
      {
         if(_isIOS)
         {
            _options.serverClientID = param1;
         }
         return this;
      }
      
      public function setIOSClientID(param1:String) : GoogleIdentityOptionsBuilder
      {
         if(_isIOS)
         {
            _options.clientID = param1;
         }
         return this;
      }
      
      public function build() : GoogleIdentityOptions
      {
         if(_isIOS && _options.clientID == "")
         {
            throw new Error("Invalid iOS Client ID");
         }
         if((_options.requestIdToken || _options.requestServerAuthCode) && _options.serverClientID == "")
         {
            throw new Error("Server Client ID required to request idToken or server auth code");
         }
         return _options;
      }
      
      private function get _isAndroid() : Boolean
      {
         return GoogleIdentity.service.implementation == "Android";
      }
      
      private function get _isIOS() : Boolean
      {
         return GoogleIdentity.service.implementation == "iOS";
      }
   }
}

