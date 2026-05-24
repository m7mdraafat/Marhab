package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.accesspoint.AccessPoint;
   import com.distriqt.extension.gameservices.accesspoint.AccessPointOptions;
   import com.distriqt.extension.gameservices.events.AccessPointEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.geom.Rectangle;
   
   internal class _AccessPointImpl extends EventDispatcher implements AccessPoint
   {
      
      private static const TAG:String = "_AccessPointImpl";
      
      private var _extContext:ExtensionContext;
      
      public function _AccessPointImpl(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
         _extContext.addEventListener("status",extContext_statusHandler);
      }
      
      public function get isSupported() : Boolean
      {
         try
         {
            return _extContext.call("accessPoint_isSupported") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function get isVisible() : Boolean
      {
         try
         {
            return _extContext.call("accessPoint_isVisible") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function get isPresenting() : Boolean
      {
         try
         {
            return _extContext.call("accessPoint_isPresenting") as Boolean;
         }
         catch(e:Error)
         {
            trace(e);
         }
         return false;
      }
      
      public function activate(param1:AccessPointOptions = null) : Boolean
      {
         try
         {
            if(param1 == null)
            {
               param1 = new AccessPointOptions();
            }
            return _extContext.call("accessPoint_activate",param1) as Boolean;
         }
         catch(e:Error)
         {
            trace(e);
         }
         return false;
      }
      
      public function deactivate() : Boolean
      {
         try
         {
            return _extContext.call("accessPoint_deactivate") as Boolean;
         }
         catch(e:Error)
         {
            trace(e);
         }
         return false;
      }
      
      public function getFrame() : Rectangle
      {
         var _loc1_:Object = null;
         try
         {
            _loc1_ = JSON.parse(_extContext.call("accessPoint_getFrame") as String);
            return new Rectangle(_loc1_.x,_loc1_.y,_loc1_.width,_loc1_.height);
         }
         catch(e:Error)
         {
            trace(e);
         }
         return null;
      }
      
      public function get isFocused() : Boolean
      {
         return false;
      }
      
      public function focus(param1:Boolean = true) : Boolean
      {
         return false;
      }
      
      private function extContext_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:String = param1.code;
         if("accesspoint_frame_changed" === _loc2_)
         {
            dispatchEvent(new AccessPointEvent(param1.code));
         }
      }
   }
}

