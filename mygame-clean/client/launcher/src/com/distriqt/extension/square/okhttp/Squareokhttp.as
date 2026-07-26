package com.distriqt.extension.square.okhttp
{
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   public final class Squareokhttp extends EventDispatcher
   {
      
      public static const EXT_CONTEXT_ID:String = "com.distriqt.square.okhttp";
      
      public static const VERSION:String = "2.7.5";
      
      public static const VERSION_DEFAULT:String = "0";
      
      public static const IMPLEMENTATION_DEFAULT:String = "unknown";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use okhttp.service to access the functionality";
      
      private static var _instance:Squareokhttp;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext;
      
      public function Squareokhttp()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extContext = ExtensionContext.createExtensionContext("com.distriqt.square.okhttp",null);
               _extContext.addEventListener("status",extension_statusHandler,false,0,true);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use okhttp.service to access the functionality");
      }
      
      public static function get service() : Squareokhttp
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new Squareokhttp();
            _shouldCreateInstance = false;
         }
      }
      
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
         var _loc2_:String = "0";
         var _loc1_:String = "unknown";
         try
         {
            _loc2_ = _extContext.call("version") as String;
            _loc1_ = _extContext.call("implementation") as String;
         }
         catch(e:Error)
         {
         }
         return "2.7.5." + _loc1_ + "." + _loc2_;
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

