package com.distriqt.extension.googleidentity
{
   import com.distriqt.extension.googleidentity.events.GoogleIdentityEvent;
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   [Event(name="googleidentity:setupcomplete",type="com.distriqt.extension.googleidentity.events.GoogleIdentityEvent")]
   [Event(name="googleidentity:signin",type="com.distriqt.extension.googleidentity.events.GoogleIdentityEvent")]
   [Event(name="googleidentity:signout",type="com.distriqt.extension.googleidentity.events.GoogleIdentityEvent")]
   [Event(name="googleidentity:disconnect",type="com.distriqt.extension.googleidentity.events.GoogleIdentityEvent")]
   [Event(name="googleidentity:error",type="com.distriqt.extension.googleidentity.events.GoogleIdentityEvent")]
   [Event(name="googleidentity:token:updated",type="com.distriqt.extension.googleidentity.events.GoogleIdentityEvent")]
   [Event(name="googleidentity:token:failed",type="com.distriqt.extension.googleidentity.events.GoogleIdentityEvent")]
   public final class GoogleIdentity extends EventDispatcher
   {
      
      public static const EXT_CONTEXT_ID:String = "com.distriqt.GoogleIdentity";
      
      private static const EXT_ID_NUMBER:int = 68;
      
      public static const VERSION:String = "5.2.3";
      
      private static const VERSION_DEFAULT:String = "0";
      
      private static const IMPLEMENTATION_DEFAULT:String = "unknown";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use GoogleIdentity.service to access the functionality";
      
      private static var _instance:GoogleIdentity;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext = null;
      
      private var _extensionId:String = "";
      
      private var _extensionIdNumber:int = -1;
      
      public function GoogleIdentity()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extensionId = "com.distriqt.GoogleIdentity";
               _extensionIdNumber = 68;
               _extContext = ExtensionContext.createExtensionContext("com.distriqt.GoogleIdentity",null);
               _extContext.addEventListener("status",extension_statusHandler,false,0,true);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use GoogleIdentity.service to access the functionality");
      }
      
      public static function get service() : GoogleIdentity
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new GoogleIdentity();
            _shouldCreateInstance = false;
         }
      }
      
      [Deprecated(message="You no longer need to use an application key")]
      public static function init(param1:String = "") : void
      {
         createInstance();
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
         return "5.2.3";
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
      
      public function setup(param1:GoogleIdentityOptions) : void
      {
         try
         {
            if(param1 == null)
            {
               param1 = new GoogleIdentityOptions();
            }
            _extContext.call("setup",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function isSignedIn() : Boolean
      {
         try
         {
            return _extContext.call("isSignedIn") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function signIn() : Boolean
      {
         try
         {
            return _extContext.call("signIn") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function signInSilently() : Boolean
      {
         try
         {
            return _extContext.call("signInSilently") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function signOut() : Boolean
      {
         try
         {
            return _extContext.call("signOut") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function getUser() : GoogleUser
      {
         var _loc2_:String = null;
         var _loc1_:Object = null;
         try
         {
            _loc2_ = _extContext.call("getUser") as String;
            if(_loc2_ != null && _loc2_.length > 0)
            {
               _loc1_ = JSON.parse(_loc2_);
               if(_loc1_ != null && _loc1_.hasOwnProperty("userID"))
               {
                  return GoogleUser.fromObject(_loc1_);
               }
            }
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function disconnect() : Boolean
      {
         try
         {
            return _extContext.call("disconnect") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      [Deprecated(message="This has been deprecated as it is against best practice to use an access token on a device")]
      public function getToken(param1:String) : Boolean
      {
         try
         {
            return _extContext.call("getToken",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:GoogleUser = null;
         switch(param1.code)
         {
            case "extension:error":
               dispatchEvent(new ErrorEvent("error",false,false,param1.level));
               break;
            case "googleidentity:setupcomplete":
            case "googleidentity:signout":
            case "googleidentity:disconnect":
               dispatchEvent(new GoogleIdentityEvent(param1.code,null));
               break;
            case "googleidentity:signin":
            case "googleidentity:token:updated":
               _loc2_ = JSON.parse(param1.level);
               _loc3_ = GoogleUser.fromObject(_loc2_);
               dispatchEvent(new GoogleIdentityEvent(param1.code,_loc3_));
               break;
            case "googleidentity:token:failed":
            case "googleidentity:error":
               _loc2_ = JSON.parse(param1.level);
               dispatchEvent(new GoogleIdentityEvent(param1.code,null,_loc2_.error,_loc2_.errorCode));
         }
      }
   }
}

