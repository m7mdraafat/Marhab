package org.oyunstudyosu.action
{
   public class DanceIcon extends ActionIcon
   {
      
      public function DanceIcon()
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

