package feathers.core
{
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import haxe.IMap;
   import haxe.ds.ObjectMap;
   
   public class ToolTipManager
   {
      
      public static var init__:Boolean;
      
      public static var _toolTipManagerFactory:Function;
      
      public static var stageToManager:IMap;
      
      public function ToolTipManager()
      {
      }
      
      public static function defaultToolTipManagerFactory(param1:DisplayObject) : IToolTipManager
      {
         return new DefaultToolTipManager(param1);
      }
      
      public static function get_toolTipManagerFactory() : Function
      {
         return feathers.core.ToolTipManager._toolTipManagerFactory;
      }
      
      public static function set_toolTipManagerFactory(param1:Function) : Function
      {
         if(param1 == null)
         {
            feathers.core.ToolTipManager._toolTipManagerFactory = feathers.core.ToolTipManager.defaultToolTipManagerFactory;
         }
         if(feathers.core.ToolTipManager._toolTipManagerFactory == param1)
         {
            return feathers.core.ToolTipManager._toolTipManagerFactory;
         }
         feathers.core.ToolTipManager._toolTipManagerFactory = param1;
         return feathers.core.ToolTipManager._toolTipManagerFactory;
      }
      
      public static function hasRoot(param1:Stage) : Boolean
      {
         return feathers.core.ToolTipManager.stageToManager[param1] != null;
      }
      
      public static function forRoot(param1:Stage) : IToolTipManager
      {
         return feathers.core.ToolTipManager.stageToManager[param1];
      }
      
      public static function addRoot(param1:Stage) : IToolTipManager
      {
         if(param1 == null)
         {
            throw new ArgumentError("ToolTipManager stage argument must not be null.");
         }
         if(feathers.core.ToolTipManager.stageToManager[param1] != null)
         {
            throw new ArgumentError("Tool tip manager root already exists");
         }
         var _loc2_:IToolTipManager = feathers.core.ToolTipManager.stageToManager[param1];
         var _loc3_:Function = feathers.core.ToolTipManager.get_toolTipManagerFactory();
         if(_loc3_ == null)
         {
            _loc3_ = feathers.core.ToolTipManager.defaultToolTipManagerFactory;
         }
         _loc2_ = _loc3_(param1);
         feathers.core.ToolTipManager.stageToManager[param1] = _loc2_;
         return _loc2_;
      }
      
      public static function removeRoot(param1:Stage) : void
      {
         var _loc2_:IToolTipManager = feathers.core.ToolTipManager.stageToManager[param1];
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.dispose();
         feathers.core.ToolTipManager.stageToManager.remove(param1);
      }
      
      public static function dispose() : void
      {
         var _loc2_:* = null as Stage;
         var _loc1_:* = feathers.core.ToolTipManager.stageToManager.keys();
         while(Boolean(_loc1_.hasNext()))
         {
            _loc2_ = _loc1_.next();
            feathers.core.ToolTipManager.stageToManager.remove(_loc2_);
         }
      }
   }
}

