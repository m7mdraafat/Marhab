package org.oyunstudyosu.alert.buttons
{
   import flash.display.MovieClip;
   public dynamic class ReportViewButton extends MovieClip
   {
      
      public function ReportViewButton()
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

