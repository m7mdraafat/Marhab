package feathers.core
{
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.Event;
   import haxe.IMap;
   import haxe.ds.ObjectMap;
   
   public class FocusManager
   {
      
      public static var init__:Boolean;
      
      public static var stageToManager:IMap;
      
      public static var _focusManagerFactory:Function;
      
      public function FocusManager()
      {
      }
      
      public static function defaultFocusManagerFactory(param1:DisplayObject) : IFocusManager
      {
         return new DefaultFocusManager(param1);
      }
      
      public static function get_focusManagerFactory() : Function
      {
         return feathers.core.FocusManager._focusManagerFactory;
      }
      
      public static function set_focusManagerFactory(param1:Function) : Function
      {
         if(param1 == null)
         {
            feathers.core.FocusManager._focusManagerFactory = feathers.core.FocusManager.defaultFocusManagerFactory;
         }
         if(feathers.core.FocusManager._focusManagerFactory == param1)
         {
            return feathers.core.FocusManager._focusManagerFactory;
         }
         feathers.core.FocusManager._focusManagerFactory = param1;
         return feathers.core.FocusManager._focusManagerFactory;
      }
      
      public static function hasRoot(param1:Stage) : Boolean
      {
         return feathers.core.FocusManager.stageToManager[param1] != null;
      }
      
      public static function addRoot(param1:Stage) : IFocusManager
      {
         if(param1 == null)
         {
            throw new ArgumentError("FocusManager stage argument must not be null.");
         }
         if(feathers.core.FocusManager.stageToManager[param1] != null)
         {
            throw new ArgumentError("Focus manager root already exists");
         }
         var _loc2_:IFocusManager = feathers.core.FocusManager.stageToManager[param1];
         var _loc3_:Function = feathers.core.FocusManager.get_focusManagerFactory();
         if(_loc3_ == null)
         {
            _loc3_ = feathers.core.FocusManager.defaultFocusManagerFactory;
         }
         _loc2_ = _loc3_(param1);
         _loc2_.addEventListener(Event.CLEAR,feathers.core.FocusManager.focusManager_clearHandler,false,0,true);
         feathers.core.FocusManager.stageToManager[param1] = _loc2_;
         return _loc2_;
      }
      
      public static function removeRoot(param1:Stage) : void
      {
         var _loc2_:IFocusManager = feathers.core.FocusManager.stageToManager[param1];
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.dispose();
      }
      
      public static function dispose() : void
      {
         var _loc2_:* = null as Stage;
         var _loc3_:* = null as IFocusManager;
         var _loc1_:* = feathers.core.FocusManager.stageToManager.keys();
         while(Boolean(_loc1_.hasNext()))
         {
            _loc2_ = _loc1_.next();
            _loc3_ = feathers.core.FocusManager.stageToManager[_loc2_];
            _loc3_.dispose();
            feathers.core.FocusManager.stageToManager.remove(_loc2_);
         }
      }
      
      public static function setFocus(param1:IFocusObject) : void
      {
         var _loc2_:IFocusManager = param1.get_focusManager();
         if(_loc2_ == null)
         {
            throw new ArgumentError("Cannot set focus because focus manager is null.");
         }
         _loc2_.set_focus(param1);
      }
      
      public static function focusManager_clearHandler(param1:Event) : void
      {
         var _loc2_:IFocusManager = param1.currentTarget;
         _loc2_.removeEventListener(Event.CLEAR,feathers.core.FocusManager.focusManager_clearHandler);
         var _loc3_:DisplayObject = _loc2_.get_root();
         var _loc4_:Stage = _loc3_ as Stage;
         if(_loc4_ != null)
         {
            feathers.core.FocusManager.stageToManager.remove(_loc4_);
         }
      }
   }
}

