package feathers.core
{
   public interface IMeasureObject extends IDisplayObject
   {
      
      function set_minWidth(param1:Number) : Number;
      
      function set_minHeight(param1:Number) : Number;
      
      function set_maxWidth(param1:Number) : Number;
      
      function set_maxHeight(param1:Number) : Number;
      
      function resetWidth() : void;
      
      function resetMinWidth() : void;
      
      function resetMinHeight() : void;
      
      function resetMaxWidth() : void;
      
      function resetMaxHeight() : void;
      
      function resetHeight() : void;
      
      function get_minWidth() : Number;
      
      function get_minHeight() : Number;
      
      function get_maxWidth() : Number;
      
      function get_maxHeight() : Number;
      
      function get_explicitWidth() : Object;
      
      function get_explicitMinWidth() : Object;
      
      function get_explicitMinHeight() : Object;
      
      function get_explicitMaxWidth() : Object;
      
      function get_explicitMaxHeight() : Object;
      
      function get_explicitHeight() : Object;
   }
}

