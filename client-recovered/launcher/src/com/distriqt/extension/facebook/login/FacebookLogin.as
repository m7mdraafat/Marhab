package com.distriqt.extension.facebook.login
{
   import com.distriqt.extension.facebook.login.events.FacebookAccessTokenEvent;
   import com.distriqt.extension.facebook.login.events.FacebookLoginErrorEvent;
   import com.distriqt.extension.facebook.login.events.FacebookLoginEvent;
   import com.distriqt.extension.facebook.login.events.FacebookProfileEvent;
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   public final class FacebookLogin extends EventDispatcher
   {
      
      public static const EXT_CONTEXT_ID:String = "com.distriqt.facebook.Login";
      
      private static const EXT_ID_NUMBER:int = -1;
      
      public static const VERSION:String = "9.3.3";
      
      private static const VERSION_DEFAULT:String = "0";
      
      private static const IMPLEMENTATION_DEFAULT:String = "unknown";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use FacebookLogin.service to access the functionality";
      
      private static var _instance:FacebookLogin;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext = null;
      
      private var _extensionId:String = "";
      
      private var _extensionIdNumber:int = -1;
      
      public function FacebookLogin()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extensionId = "com.distriqt.facebook.Login";
               _extensionIdNumber = -1;
               _extContext = ExtensionContext.createExtensionContext("com.distriqt.facebook.Login",null);
               _extContext.addEventListener("status",extension_statusHandler,false,0,true);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use FacebookLogin.service to access the functionality");
      }
      
      public static function get instance() : FacebookLogin
      {
         createInstance();
         return _instance;
      }
      
      public static function get service() : FacebookLogin
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new FacebookLogin();
            _shouldCreateInstance = false;
         }
      }
      
      public static function get isSupported() : Boolean
      {
         createInstance();
         return _extContext.call("isSupported");
      }
      
      public function dispose() : void
      {
         if(_extContext)
         {
            _extContext.removeEventListener("status",extension_statusHandler);
            _extContext.dispose();
            _extContext = null;
         }
         _instance = null;
      }
      
      public function get version() : String
      {
         return "9.3.3";
      }
      
      public function get nativeVersion() : String
      {
         try
         {
            return _extContext.call("version") as String;
         }
         catch(e:Error)
         {
         }
         return "0";
      }
      
      public function get implementation() : String
      {
         try
         {
            return _extContext.call("implementation") as String;
         }
         catch(e:Error)
         {
         }
         return "unknown";
      }
      
      public function isLoggedIn() : Boolean
      {
         try
         {
            return _extContext.call("isLoggedIn") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function logInWithReadPermissions(param1:Array) : void
      {
         logInWithConfiguration(new LoginConfiguration(param1));
      }
      
      public function logInWithConfiguration(param1:LoginConfiguration) : void
      {
         try
         {
            _extContext.call("logInWithConfiguration",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function logout() : void
      {
         try
         {
            _extContext.call("logout");
         }
         catch(e:Error)
         {
         }
      }
      
      public function getAccessToken() : AccessToken
      {
         try
         {
            return AccessToken.fromObject(JSON.parse(_extContext.call("getAccessToken") as String));
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function getProfile() : Profile
      {
         try
         {
            return Profile.fromObject(JSON.parse(_extContext.call("getProfile") as String));
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function getAuthenticationToken() : AuthenticationToken
      {
         try
         {
            return AuthenticationToken.fromObject(JSON.parse(_extContext.call("getAuthenticationToken") as String));
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         try
         {
            switch(param1.code)
            {
               case "extension:error":
                  dispatchEvent(new ErrorEvent("error",false,false,param1.level));
                  break;
               case "facebook:login:error":
                  _loc2_ = JSON.parse(param1.level);
                  _loc3_ = _loc2_.hasOwnProperty("errorMessage") ? _loc2_.errorMessage : "";
                  _loc4_ = int(_loc2_.hasOwnProperty("errorCode") ? _loc2_.errorCode : -1);
                  dispatchEvent(new FacebookLoginErrorEvent(param1.code,_loc3_,_loc4_));
                  break;
               case "facebook:login:success":
               case "facebook:login:cancel":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new FacebookLoginEvent(param1.code,AccessToken.fromObject(_loc2_["accessToken"]),Profile.fromObject(_loc2_["profile"]),AuthenticationToken.fromObject(_loc2_["authToken"])));
                  break;
               case "facebook:login:profile:changed":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new FacebookProfileEvent(param1.code,Profile.fromObject(_loc2_["profile"]),Profile.fromObject(_loc2_["oldProfile"])));
                  break;
               case "facebook:login:accesstoken:changed":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new FacebookAccessTokenEvent(param1.code,AccessToken.fromObject(_loc2_["accessToken"]),AccessToken.fromObject(_loc2_["oldAccessToken"])));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

