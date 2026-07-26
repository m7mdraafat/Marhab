package org.oyunstudyosu.action
{
   public class SpecialIcon extends ActionIcon
   {
      
      public function SpecialIcon()
      {
         addFrameScript(0,this.frame1);
         super();
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

