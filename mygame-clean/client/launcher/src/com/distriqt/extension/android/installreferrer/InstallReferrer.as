package com.distriqt.extension.android.installreferrer
{
   import com.distriqt.extension.android.installreferrer.events.InstallReferrerEvent;
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   public final class InstallReferrer extends EventDispatcher
   {
      
      public static const EXT_CONTEXT_ID:String = "com.android.installreferrer";
      
      private static const EXT_ID_NUMBER:int = -1;
      
      public static const VERSION:String = "1.0.0";
      
      private static const VERSION_DEFAULT:String = "0";
      
      private static const IMPLEMENTATION_DEFAULT:String = "unknown";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use InstallReferrer.service to access the functionality";
      
      private static var _instance:InstallReferrer;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext = null;
      
      private var _extensionId:String = "";
      
      private var _extensionIdNumber:int = -1;
      
      public function InstallReferrer()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extensionId = "com.android.installreferrer";
               _extensionIdNumber = -1;
               _extContext = ExtensionContext.createExtensionContext("com.android.installreferrer",null);
               _extContext.addEventListener("status",extension_statusHandler,false,0,true);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use InstallReferrer.service to access the functionality");
      }
      
      public static function get instance() : InstallReferrer
      {
         createInstance();
         return _instance;
      }
      
      public static function get service() : InstallReferrer
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new InstallReferrer();
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
         return "1.0.0";
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
      
      public function getInstallReferrer() : void
      {
         try
         {
            _extContext.call("getInstallReferrer");
         }
         catch(e:Error)
         {
         }
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         try
         {
            switch(param1.code)
            {
               case "extension:error":
                  dispatchEvent(new ErrorEvent("error",false,false,param1.level));
                  break;
               case "installreferrer:feature_not_supported":
               case "installreferrer:service_unavailable":
                  dispatchEvent(new InstallReferrerEvent(param1.code,null));
                  break;
               case "installreferrer:complete":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new InstallReferrerEvent(param1.code,_loc2_.referrerUrl));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

