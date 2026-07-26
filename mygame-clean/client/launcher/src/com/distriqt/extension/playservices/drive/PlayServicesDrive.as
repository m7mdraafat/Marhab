package com.distriqt.extension.playservices.drive
{
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   public final class PlayServicesDrive extends EventDispatcher
   {
      
      public static const EXT_CONTEXT_ID:String = "com.distriqt.playservices.Drive";
      
      public static const VERSION:String = "17.0.0";
      
      public static const VERSION_DEFAULT:String = "0";
      
      public static const IMPLEMENTATION_DEFAULT:String = "unknown";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use Drive.service to access the functionality";
      
      private static var _instance:PlayServicesDrive;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext;
      
      public function PlayServicesDrive()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extContext = ExtensionContext.createExtensionContext("com.distriqt.playservices.Drive",null);
               _extContext.addEventListener("status",extension_statusHandler,false,0,true);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use Drive.service to access the functionality");
      }
      
      public static function get service() : PlayServicesDrive
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new PlayServicesDrive();
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
         return "17.0.0";
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
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:String = param1.code;
         if("extension:error" === _loc2_)
         {
            dispatchEvent(new ErrorEvent("error",false,false,param1.level));
         }
      }
   }
}

