package org.oyunstudyosu.action
{
   public class SpecialIcon extends ActionIcon
   {
      
      public function SpecialIcon()
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

