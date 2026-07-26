package feathers.themes.steel.components
{
   import feathers.controls.Label;
   import feathers.core.DefaultToolTipManager;
   import feathers.graphics.FillStyle;
   import feathers.graphics.LineStyle;
   import feathers.skins.RectangleSkin;
   import feathers.style.ClassVariantStyleProvider;
   import feathers.style.ITheme;
   import feathers.style.Theme;
   import feathers.text.TextFormat;
   import feathers.themes.steel.BaseSteelTheme;
   import flash.display.DisplayObject;
   
   public class SteelToolTipStyles
   {
      
      public function SteelToolTipStyles()
      {
      }
      
      public static function initialize(param1:BaseSteelTheme = undefined) : void
      {
         var theme:BaseSteelTheme;
         var _loc2_:* = null as ITheme;
         theme = param1;
         if(theme == null)
         {
            _loc2_ = Theme.get_fallbackTheme();
            theme = _loc2_ as BaseSteelTheme;
         }
         if(theme == null)
         {
            return;
         }
         var _loc3_:ClassVariantStyleProvider = theme.styleProvider;
         if(_loc3_.getStyleFunction(Label,DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP) == null)
         {
            _loc3_.setStyleFunction(Label,DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP,function(param1:Label):void
            {
               var _loc2_:* = null as RectangleSkin;
               if(param1.get_backgroundSkin() == null)
               {
                  _loc2_ = new RectangleSkin();
                  _loc2_.set_border(theme.getBorder());
                  _loc2_.set_fill(theme.getContainerFill());
                  _loc2_.set_cornerRadius(2);
                  _loc2_.set_maxWidth(276);
                  param1.set_backgroundSkin(_loc2_);
               }
               if(param1.get_textFormat() == null)
               {
                  param1.set_textFormat(theme.getTextFormat());
               }
               if(param1.get_disabledTextFormat() == null)
               {
                  param1.set_disabledTextFormat(theme.getDisabledDetailTextFormat());
               }
               param1.set_wordWrap(true);
               param1.set_paddingTop(2);
               param1.set_paddingRight(2);
               param1.set_paddingBottom(2);
               param1.set_paddingLeft(2);
            });
         }
      }
   }
}

