package com.distriqt.extension.playservices.security
{
   import com.distriqt.extension.playservices.security.events.ProviderInstallerEvent;
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   public class ProviderInstaller extends EventDispatcher
   {
      
      private static const TAG:String = "ProviderInstaller";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use ProviderInstaller.instance to access the functionality";
      
      private static var _instance:ProviderInstaller;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext;
      
      public function ProviderInstaller()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extContext = ExtensionContext.createExtensionContext("com.distriqt.playservices.Base","ProviderInstaller");
               _extContext.addEventListener("status",extension_statusHandler,false,0,true);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use ProviderInstaller.instance to access the functionality");
      }
      
      public static function get instance() : ProviderInstaller
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new ProviderInstaller();
            _shouldCreateInstance = false;
         }
      }
      
      public function installIfNeeded() : void
      {
         try
         {
            _extContext.call("installIfNeeded");
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
               case "providerinstaller_install_failed":
               case "providerinstaller_installed":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new ProviderInstallerEvent(param1.code,_loc2_.hasOwnProperty("errorCode") ? _loc2_.errorCode : -1));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

