package com.oyunstudyosu.air.components
{
   import feathers.controls.Button;
   import feathers.controls.ButtonState;
   import feathers.text.TextFormat;
   import feathers.text._TextFormat.AbstractTextFormat_Impl_;
   import flash.Boot;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.text.TextFormat;
   import openfl.utils.Assets;
   
   public class BaseAssetButton extends Button
   {
      
      public function BaseAssetButton()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         buttonMode = true;
         var _loc1_:Array = Type.getClassName(Type.getClass(this)).split(".");
         var _loc2_:String = _loc1_[int(_loc1_.length) - 1];
         set_embedFonts(true);
         set_textFormat(AbstractTextFormat_Impl_.fromSimpleTextFormat(getTextFormat()));
         set_backgroundSkin(new Bitmap(Assets.getBitmapData("assets:assets/components/buttons/" + _loc2_ + "/default.png")));
         if(Assets.exists("assets:assets/components/buttons/" + _loc2_ + "/hover.png","IMAGE"))
         {
            setSkinForState(ButtonState.HOVER,new Bitmap(Assets.getBitmapData("assets:assets/components/buttons/" + _loc2_ + "/hover.png")));
            setTextFormatForState(ButtonState.HOVER,AbstractTextFormat_Impl_.fromSimpleTextFormat(getTextFormat()));
         }
         if(Assets.exists("assets:assets/components/buttons/" + _loc2_ + "/down.png","IMAGE"))
         {
            setSkinForState(ButtonState.DOWN,new Bitmap(Assets.getBitmapData("assets:assets/components/buttons/" + _loc2_ + "/down.png")));
            setTextFormatForState(ButtonState.DOWN,AbstractTextFormat_Impl_.fromSimpleTextFormat(getTextFormat()));
         }
         width = get_backgroundSkin().width;
         height = get_backgroundSkin().height;
      }
      
      public function getTextFormat() : flash.text.TextFormat
      {
         var _loc1_:flash.text.TextFormat = new flash.text.TextFormat();
         _loc1_.font = "Co Text";
         _loc1_.size = 12;
         _loc1_.color = 86912;
         _loc1_.align = "center";
         return _loc1_;
      }
      
      public function center() : void
      {
         x = -(get_backgroundSkin().width / 2);
         y = -(get_backgroundSkin().height / 2);
      }
   }
}

