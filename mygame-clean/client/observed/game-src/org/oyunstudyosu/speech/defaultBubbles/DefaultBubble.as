package org.oyunstudyosu.speech.defaultBubbles
{
   import com.oyunstudyosu.capture.CaptureLog;
   import com.oyunstudyosu.chat.EmoticonParser;
   import com.oyunstudyosu.sanalika.interfaces.ISpeechBubble;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextLineMetrics;
   import org.oyunstudyosu.speech.BaseSpeechBubble;
   public class DefaultBubble extends BaseSpeechBubble implements ISpeechBubble
   {
      
      public var speechTxt:TextField;
      
      public var bg:MovieClip;
      
      public var tip:MovieClip;
      
      private var emoticonParser:EmoticonParser;
      
      private var emoticonContainer:Sprite;
      
      private const MAX_EMOTICONS:int = 3;
      
      public function DefaultBubble()
      {
         super();
         emoticonParser = new EmoticonParser();
         emoticonParser.setEmoticonSize(14);
      }
      
      override public function speech(param1:String = "", param2:String = "") : void
      {
         super.speech(param1,param2);
         if(sText == null || this.bg == null || this.tip == null)
         {
            CaptureLog.writeOnce("speechBubble.render.skip","DefaultBubble",{"bubble":"DefaultBubble","missingText":sText == null,"missingBg":this.bg == null,"missingTip":this.tip == null,"nick":param1,"message":param2});
            return;
         }
         cleanupEmoticons();
         if(emoticonParser.hasEmoticons(param2))
         {
            renderWithEmoticons(param1,param2);
         }
         else
         {
            renderNormal(param1,param2);
         }
      }
      
      private function renderWithEmoticons(nick:String, msg:String) : void
      {
         var allEmoticons:Array = emoticonParser.findEmoticons(msg);
         var emoticons:Array = allEmoticons.slice(0,MAX_EMOTICONS);
         var cleanMsg:String = msg;
         for each(var emo in allEmoticons)
         {
            cleanMsg = cleanMsg.split(emo.code).join("");
         }
         var isArabic:Boolean = checkArabic(cleanMsg);
         var emoSize:Number = emoticonParser.size;
         var emojiTotalWidth:Number = emoticons.length * (emoSize + 2);
         sText.htmlText = "<font color=\"#FF0000\">" + nick + ": </font><font color=\"#222222\">" + cleanMsg + "</font>";
         sText.height = sText.textHeight + 4;
         if(sText.textHeight > maxHeight)
         {
            sText.height = maxHeight;
         }
         sText.width = sText.textWidth + 8;
         bg.width = sText.width + emojiTotalWidth + 15;
         bg.height = sText.height + 10;
         if(isArabic)
         {
            sText.x = int((bg.width - sText.width) / 2) + emojiTotalWidth / 2;
         }
         else
         {
            sText.x = int((bg.width - sText.width) / 2) - emojiTotalWidth / 2;
         }
         sText.y = int(-3 + (bg.height - sText.height) / 2);
         tip.y = bg.height;
         tip.x = bg.width / 2;
         emoticonContainer = new Sprite();
         addChild(emoticonContainer);
         var numLines:int = sText.numLines;
         var lastLineIndex:int = numLines - 1;
         var lastLineMetrics:TextLineMetrics = sText.getLineMetrics(lastLineIndex);
         var lastLineY:Number = 0;
         var l:int = 0;
         while(l < lastLineIndex)
         {
            lastLineY += sText.getLineMetrics(l).height;
            l++;
         }
         var emoY:Number = sText.y + lastLineY + (lastLineMetrics.height - emoSize) / 2;
         var i:int = 0;
         while(i < emoticons.length)
         {
            loadEmoji(emoticons[i].code,i,isArabic,emoY,emojiTotalWidth);
            i++;
         }
      }
      
      private function checkArabic(text:String) : Boolean
      {
         var arabicRegex:RegExp = /[\u0600-\u06FF]/;
         return arabicRegex.test(text);
      }
      
      private function loadEmoji(code:String, index:int, isArabic:Boolean, emoY:Number, totalWidth:Number) : void
      {
         var url:String = emoticonParser.getEmojiUrl(code);
         var emoSize:Number = emoticonParser.size;
         var loader:Loader = new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void
         {
            loader.width = emoSize;
            loader.height = emoSize;
            if(isArabic)
            {
               loader.x = sText.x - totalWidth + index * (emoSize + 2);
            }
            else
            {
               loader.x = sText.x + sText.textWidth + 4 + index * (emoSize + 2);
            }
            loader.y = emoY;
            emoticonContainer.addChild(loader);
         });
         loader.load(new URLRequest(url));
      }
      
      private function renderNormal(nick:String, msg:String) : void
      {
         sText.htmlText = "<font color=\"#FF0000\">" + nick + ": </font><font color=\"#222222\">" + msg + "</font>";
         adjustSize();
      }
      
      private function adjustSize() : void
      {
         sText.height = sText.textHeight + 4;
         if(sText.textHeight > maxHeight)
         {
            sText.height = maxHeight;
         }
         sText.width = sText.textWidth + 8;
         bg.height = sText.height + 10;
         bg.width = sText.width + 10;
         sText.x = int((bg.width - sText.width) / 2);
         sText.y = int(-3 + (bg.height - sText.height) / 2);
         tip.y = bg.height;
         tip.x = bg.width / 2;
      }
      
      private function cleanupEmoticons() : void
      {
         if(emoticonContainer != null)
         {
            while(emoticonContainer.numChildren > 0)
            {
               emoticonContainer.removeChildAt(0);
            }
            if(contains(emoticonContainer))
            {
               removeChild(emoticonContainer);
            }
            emoticonContainer = null;
         }
      }
   }
}

