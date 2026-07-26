package org.oyunstudyosu.action
{
   public class IdleIcon extends ActionIcon
   {
      
      public function IdleIcon()
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

