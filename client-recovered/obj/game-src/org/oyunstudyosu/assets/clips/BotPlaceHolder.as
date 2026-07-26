package org.oyunstudyosu.assets.clips
{
   import flash.display.MovieClip;
   public class BotPlaceHolder extends MovieClip
   {
      
      public function BotPlaceHolder()
      {
         super();
         addFrameScript(42,this.frame43);
      }
      
      internal function frame43() : *
      {
         gotoAndPlay(int(Math.random() * 10));
      }
   }
}

