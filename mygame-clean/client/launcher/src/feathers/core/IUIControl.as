package feathers.core
{
   public interface IUIControl extends IDisplayObject
   {
      
      function set_toolTip(param1:String) : String;
      
      function set_enabled(param1:Boolean) : Boolean;
      
      function initializeNow() : void;
      
      function get_toolTip() : String;
      
      function get_enabled() : Boolean;
   }
}

