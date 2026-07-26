package org.oyunstudyosu.action
{
   public class DanceIcon extends ActionIcon
   {
      
      public function DanceIcon()
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

