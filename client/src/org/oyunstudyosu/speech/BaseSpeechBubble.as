package org.oyunstudyosu.speech
{
   import com.oyunstudyosu.engine.ICharacter;
   import com.oyunstudyosu.sanalika.interfaces.ISpeechBubble;
   import com.oyunstudyosu.utils.STextField;
   import com.oyunstudyosu.utils.TextFieldManager;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import org.oyunstudyosu.components.CoreMovieClip;
   
   public class BaseSpeechBubble extends CoreMovieClip implements ISpeechBubble
   {
      
      protected var sText:STextField;
      
      protected var maxHeight:int = 100;
      
      protected var maxWidth:int = 110;
      
      private var nick:String;
      
      private var message:String;
      
      private var _sender:ICharacter;
      
      public function BaseSpeechBubble()
      {
         super();
      }
      
      public function get sender() : ICharacter
      {
         return this._sender;
      }
      
      public function set sender(param1:ICharacter) : void
      {
         if(this._sender == param1)
         {
            return;
         }
         this._sender = param1;
      }
      
      public function speech(param1:String = "", param2:String = "") : void
      {
         this.nick = param1;
         this.message = param2;
         if(this.sText == null)
         {
            this.sText = TextFieldManager.convertAsArabicTextField(getChildByName("speechTxt") as TextField,true,false);
         }
         this.sText.width = this.maxWidth;
      }
      
      public function applyNameColor(param1:String, param2:String) : void
      {
         if(param1 == null || param1 == "" || this.sText == null || param2 == null)
         {
            return;
         }
         if(param1.charAt(0) == "#")
         {
            param1 = param1.substr(1);
         }
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.color = uint("0x" + param1);
         var _loc4_:String = this.sText.text;
         var _loc5_:int = int(_loc4_.indexOf(param2));
         if(_loc5_ < 0)
         {
            var _tLen:int = _loc4_.length;
            if(_tLen < 2)
            {
               return;
            }
            var _colorAt0:uint = uint(this.sText.getTextFormat(0,1).color);
            var _colorAtEnd:uint = uint(this.sText.getTextFormat(_tLen - 1,_tLen).color);
            if(_colorAt0 != _colorAtEnd)
            {
               var _nickLen:int = param2.length + 2;
               var _count0:int = 0;
               var _countEnd:int = 0;
               var _ci:int = 0;
               while(_ci < _tLen)
               {
                  var _cc:uint = uint(this.sText.getTextFormat(_ci,_ci + 1).color);
                  if(_cc == _colorAt0)
                  {
                     _count0++;
                  }
                  else if(_cc == _colorAtEnd)
                  {
                     _countEnd++;
                  }
                  _ci++;
               }
               var _nickColor:uint = 0;
               if(_count0 - _nickLen < 0)
               {
                  _count0 = _nickLen - _count0;
               }
               else
               {
                  _count0 -= _nickLen;
               }
               if(_countEnd - _nickLen < 0)
               {
                  _countEnd = _nickLen - _countEnd;
               }
               else
               {
                  _countEnd -= _nickLen;
               }
               _nickColor = _countEnd <= _count0 ? _colorAtEnd : _colorAt0;
               _ci = 0;
               while(_ci < _tLen)
               {
                  if(uint(this.sText.getTextFormat(_ci,_ci + 1).color) == _nickColor)
                  {
                     this.sText.setTextFormat(_loc3_,_ci,_ci + 1);
                  }
                  _ci++;
               }
            }
            return;
         }
         var _loc6_:int = _loc5_;
         var _loc7_:int = _loc5_ + param2.length;
         if(_loc7_ < _loc4_.length && (_loc4_.charAt(_loc7_) == ":" || _loc4_.charAt(_loc7_) == " "))
         {
            if(++_loc7_ < _loc4_.length && (_loc4_.charAt(_loc7_) == ":" || _loc4_.charAt(_loc7_) == " "))
            {
               _loc7_++;
            }
         }
         else if(_loc6_ > 0 && (_loc4_.charAt(_loc6_ - 1) == ":" || _loc4_.charAt(_loc6_ - 1) == " "))
         {
            if(--_loc6_ > 0 && (_loc4_.charAt(_loc6_ - 1) == ":" || _loc4_.charAt(_loc6_ - 1) == " "))
            {
               _loc6_--;
            }
         }
         this.sText.setTextFormat(_loc3_,_loc6_,_loc7_);
      }
   }
}

