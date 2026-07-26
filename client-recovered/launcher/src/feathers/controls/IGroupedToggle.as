package feathers.controls
{
   import feathers.core.ToggleGroup;
   
   public interface IGroupedToggle extends IToggle
   {
      
      function set_toggleGroup(param1:ToggleGroup) : ToggleGroup;
      
      function get_toggleGroup() : ToggleGroup;
   }
}

