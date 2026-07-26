package org.oyunstudyosu.assets.clips
{
   import flash.display.Graphics;
   import flash.display.MovieClip;
   
   public class FortuneWheelButton extends MovieClip
   {
      
      public function FortuneWheelButton()
      {
         super();
         draw();
      }
      
      private function draw() : void
      {
         var g:Graphics = this.graphics;
         g.beginFill(16747520);
         g.drawCircle(0,0,16);
         g.endFill();
         g.beginFill(1710638);
         g.drawCircle(0,0,12);
         g.endFill();
         g.lineStyle(1.5,16766720,0.9);
         var i:int = 0;
         while(i < 6)
         {
            var angle:Number = i * Math.PI / 3;
            g.moveTo(0,0);
            g.lineTo(Math.cos(angle) * 11,Math.sin(angle) * 11);
            i++;
         }
         g.lineStyle();
         g.beginFill(16766720);
         g.drawCircle(0,0,4);
         g.endFill();
      }
   }
}

