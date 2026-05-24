package feathers.themes.steel.components
{
   import feathers.controls.Application;
   import feathers.core.IScaleManager;
   import feathers.core.ScreenDensityScaleManager;
   import feathers.style.ClassVariantStyleProvider;
   import feathers.style.ITheme;
   import feathers.style.Theme;
   import feathers.themes.steel.BaseSteelTheme;
   import flash.display.Stage;
   
   public class SteelApplicationStyles
   {
      
      public function SteelApplicationStyles()
      {
      }
      
      public static function initialize(param1:BaseSteelTheme = undefined) : void
      {
         var _loc2_:* = null as ITheme;
         if(param1 == null)
         {
            _loc2_ = Theme.get_fallbackTheme();
            param1 = _loc2_ as BaseSteelTheme;
         }
         if(param1 == null)
         {
            return;
         }
         var _loc3_:ClassVariantStyleProvider = param1.styleProvider;
         if(_loc3_.getStyleFunction(Application,null) == null)
         {
            _loc3_.setStyleFunction(Application,null,function(param1:Application):void
            {
               if(param1.get_scaleManager() == null)
               {
                  param1.set_scaleManager(new ScreenDensityScaleManager());
               }
            });
         }
      }
      
      public static function refreshStageColor(param1:Stage, param2:BaseSteelTheme) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.color = param2.rootFillColor;
      }
   }
}

