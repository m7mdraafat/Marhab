package org.oyunstudyosu.assets.clips
{
   import flash.display.MovieClip;
   public dynamic class LockIcon extends MovieClip
   {
      
      public function LockIcon()
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

