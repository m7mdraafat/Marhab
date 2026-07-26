package feathers.core
{
   public interface IFocusObject extends IDisplayObject, IFocusManagerAware
   {
      
      function showFocus(param1:Boolean) : void;
      
      function set_focusOwner(param1:IFocusObject) : IFocusObject;
      
      function set_focusEnabled(param1:Boolean) : Boolean;
      
      function get_focusOwner() : IFocusObject;
      
      function get_focusEnabled() : Boolean;
   }
}

