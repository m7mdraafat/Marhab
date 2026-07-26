package org.oyunstudyosu.emoticon
{
   import flash.display.MovieClip;
   public class Emoticons extends MovieClip
   {
      
      public function Emoticons()
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

