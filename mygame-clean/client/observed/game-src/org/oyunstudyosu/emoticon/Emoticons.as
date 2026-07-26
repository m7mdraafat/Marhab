package org.oyunstudyosu.emoticon
{
   import flash.display.MovieClip;
   public class Emoticons extends MovieClip
   {
      
      public function Emoticons()
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

