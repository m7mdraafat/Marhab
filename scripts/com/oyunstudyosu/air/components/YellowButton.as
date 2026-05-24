package com.oyunstudyosu.air.components
{
   import flash.Boot;
   
   public class YellowButton extends BaseAssetButton
   {
      
      public function YellowButton()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         center();
      }
   }
}

