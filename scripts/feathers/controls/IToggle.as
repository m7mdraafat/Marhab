package feathers.controls
{
   import feathers.core.IUIControl;
   
   public interface IToggle extends IUIControl
   {
      
      function set_selected(param1:Boolean) : Boolean;
      
      function get_selected() : Boolean;
   }
}

