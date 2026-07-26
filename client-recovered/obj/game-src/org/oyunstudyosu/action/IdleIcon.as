package org.oyunstudyosu.action
{
   public class IdleIcon extends ActionIcon
   {
      
      public function IdleIcon()
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

