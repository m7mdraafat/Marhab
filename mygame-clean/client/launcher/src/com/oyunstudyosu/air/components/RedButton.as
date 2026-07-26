package com.oyunstudyosu.air.components
{
   import flash.Boot;
   import flash.text.TextFormat;
   
   public class RedButton extends BaseAssetButton
   {
      
      public function RedButton()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         center();
      }
      
      override public function getTextFormat() : TextFormat
      {
         var _loc1_:TextFormat = new TextFormat();
         _loc1_.font = "Co Text";
         _loc1_.size = 12;
         _loc1_.color = 16777215;
         _loc1_.align = "center";
         _loc1_.leading = 50;
         return _loc1_;
      }
   }
}

