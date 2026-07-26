package org.oyunstudyosu.alert.buttons
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   public dynamic class GreenButton extends MovieClip
   {
      
      public var lbl_Button:TextField;
      
      public function GreenButton()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

