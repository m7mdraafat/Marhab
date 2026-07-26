package org.oyunstudyosu.assets.clips
{
   import flash.display.MovieClip;
   public dynamic class DoorIcon extends MovieClip
   {
      
      public function DoorIcon()
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

