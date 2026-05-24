package com.distriqt.extension.playservices.base
{
   import com.distriqt.extension.playservices.base.events.GoogleApiAvailabilityEvent;
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   public class GoogleApiAvailability extends EventDispatcher
   {
      
      private static const TAG:String = "GoogleApiAvailability";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use GoogleApiAvailability.instance to access the functionality";
      
      private static var _instance:GoogleApiAvailability;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext;
      
      public function GoogleApiAvailability()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extContext = ExtensionContext.createExtensionContext("com.distriqt.playservices.Base","GoogleApiAvailability");
               _extContext.addEventListener("status",extension_statusHandler,false,0,true);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use GoogleApiAvailability.instance to access the functionality");
      }
      
      public static function get instance() : GoogleApiAvailability
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new GoogleApiAvailability();
            _shouldCreateInstance = false;
         }
      }
      
      public function getInstalledGooglePlayServicesVersion() : Number
      {
         try
         {
            return _extContext.call("getInstalledGooglePlayServicesVersion") as Number;
         }
         catch(e:Error)
         {
         }
         return 0;
      }
      
      public function isGooglePlayServicesAvailable() : int
      {
         try
         {
            return _extContext.call("isGooglePlayServicesAvailable") as int;
         }
         catch(e:Error)
         {
         }
         return 0;
      }
      
      public function isUserRecoverableError(param1:int) : Boolean
      {
         try
         {
            return _extContext.call("isUserRecoverableError",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function showErrorDialog(param1:int) : void
      {
         try
         {
            _extContext.call("showErrorDialog",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function showErrorNotification(param1:int) : void
      {
         try
         {
            _extContext.call("showErrorNotification",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function getErrorString(param1:int) : String
      {
         try
         {
            return _extContext.call("getErrorString",param1) as String;
         }
         catch(e:Error)
         {
         }
         return "Unknown";
      }
      
      public function attemptResolution(param1:int) : void
      {
         try
         {
            _extContext.call("attemptResolution",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         switch(param1.code)
         {
            case "extension:error":
               dispatchEvent(new ErrorEvent("error",false,false,param1.level));
               break;
            case "apiavailability_error_dialog_closed":
               dispatchEvent(new GoogleApiAvailabilityEvent(param1.code));
         }
      }
   }
}

