package com.distriqt.extension.facebook.core
{
   import com.distriqt.extension.facebook.appevents.AppEventsLogger;
   import com.distriqt.extension.facebook.applinks.AppLinks;
   import com.distriqt.extension.facebook.graphapi.GraphAPI;
   import com.distriqt.extension.facebook.graphapi.GraphRequest;
   import com.distriqt.extension.facebook.graphapi.GraphRequestBatch;
   import flash.desktop.NativeApplication;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   use namespace facebook_core_internal;
   
   public final class Facebook extends EventDispatcher
   {
      
      public static const EXT_CONTEXT_ID:String = "com.distriqt.facebook.Core";
      
      private static const EXT_ID_NUMBER:int = -1;
      
      public static const VERSION:String = "9.3.3";
      
      private static const VERSION_DEFAULT:String = "0";
      
      private static const IMPLEMENTATION_DEFAULT:String = "unknown";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use Facebook.service to access the functionality";
      
      private static var _instance:Facebook;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext = null;
      
      private var _extensionId:String = "";
      
      private var _extensionIdNumber:int = -1;
      
      private var _appId:String = "";
      
      private var _appEventsLogger:AppEventsLogger;
      
      private var _graphAPI:GraphAPI;
      
      private var _appLinks:AppLinks;
      
      public function Facebook()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extensionId = "com.distriqt.facebook.Core";
               _extensionIdNumber = -1;
               _extContext = ExtensionContext.createExtensionContext("com.distriqt.facebook.Core",null);
               _extContext.addEventListener("status",extension_statusHandler,false,0,true);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use Facebook.service to access the functionality");
      }
      
      public static function get instance() : Facebook
      {
         createInstance();
         return _instance;
      }
      
      public static function get service() : Facebook
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new Facebook();
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
         if(_appEventsLogger != null)
         {
            _AppEventsLogger(_appEventsLogger).dispose();
            _appEventsLogger = null;
         }
         if(_graphAPI != null)
         {
            _GraphAPIImpl(_graphAPI).dispose();
            _graphAPI = null;
         }
         if(_extContext)
         {
            _extContext.removeEventListener("status",extension_statusHandler);
            _extContext.dispose();
            _extContext = null;
         }
         NativeApplication.nativeApplication.removeEventListener("activate",nativeApplication_activateHandler);
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
      
      public function getSDKVersion() : String
      {
         try
         {
            return _extContext.call("getSDKVersion") as String;
         }
         catch(e:Error)
         {
         }
         return "";
      }
      
      public function isFacebookAppInstalled() : Boolean
      {
         try
         {
            return _extContext.call("isFacebookAppInstalled");
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function initialise() : Boolean
      {
         try
         {
            NativeApplication.nativeApplication.addEventListener("activate",nativeApplication_activateHandler,false,0,true);
            return _extContext.call("initialise") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function getAutoInitEnabled() : Boolean
      {
         try
         {
            return _extContext.call("getAutoInitEnabled") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function setAutoInitEnabled(param1:Boolean) : void
      {
         try
         {
            _extContext.call("setAutoInitEnabled",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function getAutoLogAppEventsEnabled() : Boolean
      {
         try
         {
            return _extContext.call("getAutoLogAppEventsEnabled") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function setAutoLogAppEventsEnabled(param1:Boolean) : void
      {
         try
         {
            _extContext.call("setAutoLogAppEventsEnabled",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function getAdvertiserIDCollectionEnabled() : Boolean
      {
         try
         {
            return _extContext.call("getAdvertiserIDCollectionEnabled") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function setAdvertiserIDCollectionEnabled(param1:Boolean) : void
      {
         try
         {
            _extContext.call("setAdvertiserIDCollectionEnabled",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function getAdvertiserTrackingEnabled() : Boolean
      {
         try
         {
            return _extContext.call("getAdvertiserTrackingEnabled") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function setAdvertiserTrackingEnabled(param1:Boolean) : void
      {
         try
         {
            _extContext.call("setAdvertiserTrackingEnabled",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function getApplicationId() : String
      {
         try
         {
            return _extContext.call("getApplicationId") as String;
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function setApplicationId(param1:String) : void
      {
         try
         {
            _extContext.call("setApplicationId",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function getApplicationName() : String
      {
         try
         {
            return _extContext.call("getApplicationName") as String;
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function setApplicationName(param1:String) : void
      {
         try
         {
            _extContext.call("setApplicationName",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function get appEventsLogger() : AppEventsLogger
      {
         if(_appEventsLogger == null)
         {
            _appEventsLogger = new _AppEventsLogger(_extContext);
         }
         return _appEventsLogger;
      }
      
      public function get graphAPI() : GraphAPI
      {
         if(_graphAPI == null)
         {
            _graphAPI = new _GraphAPIImpl(_extContext);
         }
         return _graphAPI;
      }
      
      facebook_core_internal function createGraphRequest() : GraphRequest
      {
         return new _GraphRequestImpl();
      }
      
      facebook_core_internal function createGraphRequestBatch() : GraphRequestBatch
      {
         return new _GraphRequestBatchImpl();
      }
      
      public function get appLinks() : AppLinks
      {
         if(_appLinks == null)
         {
            _appLinks = new _AppLinksImpl(_extContext);
         }
         return _appLinks;
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:String = param1.code;
         if("extension:error" === _loc2_)
         {
            dispatchEvent(new ErrorEvent("error",false,false,param1.level));
         }
      }
      
      private function nativeApplication_activateHandler(param1:Event) : void
      {
         try
         {
            _extContext.call("activateApp",_appId);
         }
         catch(e:Error)
         {
         }
      }
   }
}

