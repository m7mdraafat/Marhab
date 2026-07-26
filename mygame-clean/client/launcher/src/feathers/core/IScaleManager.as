package feathers.core
{
   import flash.display.DisplayObject;
   import flash.events.IEventDispatcher;
   import flash.geom.Rectangle;
   
   public interface IScaleManager extends IEventDispatcher
   {
      
      function set_target(param1:DisplayObject) : DisplayObject;
      
      function get_target() : DisplayObject;
      
      function getScale() : Number;
      
      function getBounds() : Rectangle;
   }
}

