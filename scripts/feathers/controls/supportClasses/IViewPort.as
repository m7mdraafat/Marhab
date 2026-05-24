package feathers.controls.supportClasses
{
   import feathers.core.IMeasureObject;
   import feathers.core.IUIControl;
   import feathers.core.IValidating;
   
   public interface IViewPort extends IMeasureObject, IValidating, IUIControl
   {
      
      function set_visibleWidth(param1:Object) : Object;
      
      function set_visibleHeight(param1:Object) : Object;
      
      function set_scrollY(param1:Number) : Number;
      
      function set_scrollX(param1:Number) : Number;
      
      function set_minVisibleWidth(param1:Object) : Object;
      
      function set_minVisibleHeight(param1:Object) : Object;
      
      function set_maxVisibleWidth(param1:Object) : Object;
      
      function set_maxVisibleHeight(param1:Object) : Object;
      
      function get_visibleWidth() : Object;
      
      function get_visibleHeight() : Object;
      
      function get_scrollY() : Number;
      
      function get_scrollX() : Number;
      
      function get_minVisibleWidth() : Object;
      
      function get_minVisibleHeight() : Object;
      
      function get_maxVisibleWidth() : Object;
      
      function get_maxVisibleHeight() : Object;
   }
}

