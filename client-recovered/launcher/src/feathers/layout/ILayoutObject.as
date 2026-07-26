package feathers.layout
{
   import flash.events.IEventDispatcher;
   
   public interface ILayoutObject extends IEventDispatcher
   {
      
      function set_layoutData(param1:ILayoutData) : ILayoutData;
      
      function set_includeInLayout(param1:Boolean) : Boolean;
      
      function get_layoutData() : ILayoutData;
      
      function get_includeInLayout() : Boolean;
   }
}

