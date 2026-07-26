package feathers.skins
{
   import feathers.core.IMeasureObject;
   import feathers.core.IUIControl;
   
   public interface IProgrammaticSkin extends IMeasureObject
   {
      
      function set_uiContext(param1:IUIControl) : IUIControl;
      
      function get_uiContext() : IUIControl;
   }
}

