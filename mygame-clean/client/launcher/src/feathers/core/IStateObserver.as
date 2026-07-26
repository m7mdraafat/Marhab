package feathers.core
{
   public interface IStateObserver
   {
      
      function set_stateContext(param1:IStateContext) : IStateContext;
      
      function get_stateContext() : IStateContext;
   }
}

