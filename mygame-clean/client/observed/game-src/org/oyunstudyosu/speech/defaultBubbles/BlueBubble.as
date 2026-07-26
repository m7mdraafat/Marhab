package org.oyunstudyosu.speech.defaultBubbles
{
   import com.oyunstudyosu.capture.CaptureLog;
   import com.oyunstudyosu.sanalika.interfaces.ISpeechBubble;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import org.oyunstudyosu.speech.BaseSpeechBubble;
   public class BlueBubble extends BaseSpeechBubble implements ISpeechBubble
   {
      
      public var speechTxt:TextField;
      
      public var bg:MovieClip;
      
      public var tip:MovieClip;
      
      public function BlueBubble()
      {
         super();
      }
      
      override public function speech(param1:String = "", param2:String = "") : void
      {
         super.speech(param1,param2);
         if(sText == null || this.bg == null || this.tip == null)
         {
            CaptureLog.writeOnce("speechBubble.render.skip","BlueBubble",{"bubble":"BlueBubble","missingText":sText == null,"missingBg":this.bg == null,"missingTip":this.tip == null,"nick":param1,"message":param2});
            return;
         }
         sText.htmlText = "<font color=\"#FF0000\">" + param1 + ": " + "</font>" + "<font color=\"#000000\">" + param2 + "</font>";
         sText.height = sText.textHeight + 4;
         if(sText.textHeight > maxHeight)
         {
            sText.height = maxHeight;
         }
         sText.width = sText.textWidth + 8;
         this.bg.height = sText.height + 10;
         this.bg.width = sText.width + 10;
         sText.x = int((this.bg.width - sText.width) / 2);
         sText.y = int(-3 + (this.bg.height - sText.height) / 2);
         this.tip.y = this.bg.height;
         this.tip.x = this.bg.width / 2;
      }
   }
}

