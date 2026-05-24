package com.freshplanet.ane.KeyboardSize
{
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.system.Capabilities;
   
   public class MeasureKeyboard extends EventDispatcher
   {
      
      public static var extContext:ExtensionContext = null;
      
      private static var _instance:MeasureKeyboard;
      
      private static const SOFT_INPUT_STATE_UNCHANGED:int = 1;
      
      private static const SOFT_INPUT_ADJUST_NOTHING:int = 48;
      
      private static const SOFT_INPUT_ADJUST_PAN:int = 32;
      
      private static const SOFT_INPUT_ADJUST_RESIZE:int = 16;
      
      public function MeasureKeyboard(param1:Boolean = true)
      {
         super();
         if(!isSupported)
         {
            return;
         }
         if(!_instance)
         {
            extContext = ExtensionContext.createExtensionContext("com.freshplanet.KeyboardSize",null);
            if(!extContext)
            {
               trace("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
               return;
            }
            extContext.call("init",param1);
            extContext.addEventListener("status",onStatusEvent,false,0,true);
            _instance = this;
            return;
         }
         throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
      }
      
      public static function getInstance() : MeasureKeyboard
      {
         return _instance ? _instance : new MeasureKeyboard();
      }
      
      public static function get isSupported() : Boolean
      {
         return Capabilities.manufacturer.indexOf("iOS") > -1 || Capabilities.manufacturer.indexOf("Android") > -1;
      }
      
      public function onStatusEvent(param1:StatusEvent) : void
      {
         if(hasEventListener(param1.code))
         {
            dispatchEvent(new MeasureKeyboardEvent(param1.code,param1.level));
         }
      }
      
      public function resetFullScreen() : void
      {
         if(Capabilities.manufacturer.indexOf("Android") > -1)
         {
            extContext.call("resetFullScreen");
         }
      }
      
      public function getKeyboardHeight() : Object
      {
         if(!isSupported)
         {
            return null;
         }
         return extContext.call("getKeyboardHeight");
      }
      
      public function getKeyboardY() : Object
      {
         if(!isSupported)
         {
            return null;
         }
         return extContext.call("getKeyboardY");
      }
      
      public function setKeyboardAdjustDefault() : void
      {
         if(!isSupported)
         {
            return;
         }
         extContext.call("setSoftInputMode",32);
      }
      
      public function setKeyboardAdjustNothing() : void
      {
         if(!isSupported)
         {
            return;
         }
         extContext.call("setSoftInputMode",48);
      }
      
      public function setKeyboardStateUnchanged() : void
      {
         if(!isSupported)
         {
            return;
         }
         extContext.call("setSoftInputMode",1);
      }
      
      public function removeClearButtonForiOS() : void
      {
         if(!isSupported)
         {
            return;
         }
         extContext.call("removeClearButtonForiOS");
      }
      
      public function getMultilineTextViewHeight() : Object
      {
         if(!isSupported)
         {
            return null;
         }
         return extContext.call("getMultilineTextViewHeight");
      }
      
      public function getScreenHeight() : int
      {
         if(!isSupported || Capabilities.manufacturer.indexOf("Android") == -1)
         {
            return Capabilities.screenResolutionY;
         }
         return extContext.call("getScreenHeight") as int;
      }
   }
}

