package com.oyunstudyosu.components
{
   import com.oyunstudyosu.sanalika.extension.Connectr;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol24")]
   public class CloseButton extends SanalikaButton
   {
      
      public function CloseButton()
      {
         super();
         addFrameScript(0,this.frame1);
         if(Connectr.instance.airModel.isMobile())
         {
            this.scaleX = this.scaleY = 1.7;
         }
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

