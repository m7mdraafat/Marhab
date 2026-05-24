package com.oyunstudyosu.fortunewheel
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Sine;
   import com.greensock.plugins.GlowFilterPlugin;
   import com.greensock.plugins.TweenPlugin;
   import com.oyunstudyosu.events.PackPngEvent;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.utils.FlarabyAS3;
   import flash.display.GradientType;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class FortuneWheelItem extends Sprite
   {
      
      private static var _flaraby:FlarabyAS3;
      
      public static const RARITY_COMMON:uint = 8952234;
      
      public static const RARITY_UNCOMMON:uint = 5025616;
      
      public static const RARITY_RARE:uint = 4367861;
      
      public static const RARITY_EPIC:uint = 11225020;
      
      public static const RARITY_LEGENDARY:uint = 16757504;
      
      public var itemName:String;
      
      public var itemAmount:int;
      
      public var rarityColor:uint;
      
      public var itemIndex:int;
      
      public var clip:String;
      
      public var lifeDays:int;
      
      public var prizeType:String;
      
      private var bg:Sprite;
      
      private var iconHolder:Sprite;
      
      private var amountLabel:TextField;
      
      private var nameLabel:TextField;
      
      private var shine:Sprite;
      
      private var deco:Sprite;
      
      private var isHighlighted:Boolean = false;
      
      private var _cellW:int;
      
      private var _cellH:int;
      
      private var _waitingForImage:Boolean = false;
      
      public function FortuneWheelItem(param1:String, param2:int, param3:uint, param4:uint, param5:int, param6:String = null, param7:int = 0, param8:String = "DIAMOND", param9:int = 130, param10:int = 100)
      {
         super();
         this.itemName = param1;
         this.itemAmount = param2;
         this.rarityColor = param3;
         this.itemIndex = param5;
         this.clip = param6;
         this.lifeDays = param7;
         this.prizeType = param8;
         this._cellW = param9;
         this._cellH = param10;
         TweenPlugin.activate([GlowFilterPlugin]);
         buildCell(param4);
      }
      
      private static function getFlaraby() : FlarabyAS3
      {
         if(_flaraby == null)
         {
            _flaraby = new FlarabyAS3();
            _flaraby.dir = "RTL";
            _flaraby.embedFonts = false;
            _flaraby.html = true;
            _flaraby.multiline = false;
            _flaraby.extraCharWidth = 1;
         }
         return _flaraby;
      }
      
      private function setArabic(param1:TextField, param2:String) : void
      {
         var fmt:TextFormat = param1.defaultTextFormat;
         param1.htmlText = getFlaraby().convertArabicString(param2,param1.width + 5,fmt);
      }
      
      private function buildCell(param1:uint) : void
      {
         bg = new Sprite();
         var mat:Matrix = new Matrix();
         mat.createGradientBox(_cellW,_cellH,Math.PI / 2,0,0);
         bg.graphics.beginGradientFill(GradientType.LINEAR,[1708088,1050666],[1,1],[0,255],mat);
         bg.graphics.drawRoundRect(0,0,_cellW,_cellH,14,14);
         bg.graphics.endFill();
         bg.graphics.lineStyle(2,13215820,0.6);
         bg.graphics.drawRoundRect(0,0,_cellW,_cellH,14,14);
         bg.graphics.lineStyle(1,rarityColor,0.3);
         bg.graphics.drawRoundRect(2,2,_cellW - 4,_cellH - 4,12,12);
         addChild(bg);
         shine = new Sprite();
         var sMat:Matrix = new Matrix();
         sMat.createGradientBox(_cellW,_cellH / 2,Math.PI / 2,0,0);
         shine.graphics.beginGradientFill(GradientType.LINEAR,[16766720,16766720],[0.04,0],[0,255],sMat);
         shine.graphics.drawRoundRect(0,0,_cellW,_cellH / 2,14,14);
         shine.graphics.endFill();
         addChild(shine);
         deco = new Sprite();
         deco.graphics.beginFill(13215820,0.12);
         deco.graphics.drawCircle(_cellW - 8,8,3);
         deco.graphics.endFill();
         deco.graphics.beginFill(13215820,0.08);
         deco.graphics.drawCircle(8,_cellH - 8,2);
         deco.graphics.endFill();
         addChild(deco);
         iconHolder = new Sprite();
         iconHolder.x = _cellW / 2;
         iconHolder.y = 30;
         addChild(iconHolder);
         if(clip != null && clip != "")
         {
            loadProductImage(clip);
         }
         else if(prizeType == "DIAMOND")
         {
            drawDiamondIcon(iconHolder);
         }
         else if(prizeType == "SANIL")
         {
            drawGoldIcon(iconHolder);
         }
         else
         {
            drawIcon(iconHolder,param1);
         }
         var amtFmt:TextFormat = new TextFormat();
         amtFmt.font = "Arial";
         amtFmt.bold = true;
         amtFmt.align = TextFormatAlign.CENTER;
         amountLabel = new TextField();
         amountLabel.width = _cellW - 4;
         amountLabel.height = 26;
         amountLabel.x = 2;
         amountLabel.y = 52;
         amountLabel.selectable = false;
         amountLabel.mouseEnabled = false;
         if(clip != null && clip != "")
         {
            amtFmt.size = 12;
            amtFmt.color = 11583173;
            amountLabel.defaultTextFormat = amtFmt;
            if(lifeDays > 0)
            {
               setArabic(amountLabel,lifeDays + " يوم");
            }
            else
            {
               setArabic(amountLabel,"دائم");
            }
         }
         else
         {
            amtFmt.size = 17;
            amtFmt.color = 16769154;
            amountLabel.defaultTextFormat = amtFmt;
            setArabic(amountLabel,formatNumber(itemAmount));
         }
         addChild(amountLabel);
         var nameFmt:TextFormat = new TextFormat();
         nameFmt.font = "Arial";
         nameFmt.size = 11;
         nameFmt.color = rarityColor;
         nameFmt.align = TextFormatAlign.CENTER;
         nameFmt.bold = false;
         nameLabel = new TextField();
         nameLabel.defaultTextFormat = nameFmt;
         nameLabel.width = _cellW - 4;
         nameLabel.height = 20;
         nameLabel.x = 2;
         nameLabel.y = 76;
         nameLabel.selectable = false;
         nameLabel.mouseEnabled = false;
         if(clip != null && clip != "")
         {
            var translated:String = $("pro_" + clip);
            if(translated != null && translated != "" && translated != "pro_" + clip)
            {
               setArabic(nameLabel,translated);
            }
            else
            {
               setArabic(nameLabel,itemName);
            }
         }
         else
         {
            setArabic(nameLabel,itemName);
         }
         addChild(nameLabel);
      }
      
      private function loadProductImage(param1:String) : void
      {
         var gender:String = Sanalika.instance.avatarModel.gender;
         var img:MovieClip = Sanalika.instance.itemModel.getItemImage(gender + "_" + param1);
         if(img != null)
         {
            addProductImage(img);
         }
         else
         {
            drawIcon(iconHolder,rarityColor);
            _waitingForImage = true;
            Sanalika.instance.itemModel.addEventListener("png",onPngLoaded);
         }
      }
      
      private function onPngLoaded(param1:PackPngEvent) : void
      {
         if(param1.key == clip)
         {
            _waitingForImage = false;
            Sanalika.instance.itemModel.removeEventListener("png",onPngLoaded);
            iconHolder.graphics.clear();
            while(iconHolder.numChildren > 0)
            {
               iconHolder.removeChildAt(0);
            }
            var img:MovieClip = param1.getMovieClip();
            addProductImage(img);
         }
      }
      
      private function addProductImage(param1:MovieClip) : void
      {
         var maxSize:Number = 44;
         if(param1.width > 0 && param1.height > 0)
         {
            var s:Number = maxSize / Math.max(param1.width,param1.height);
            if(s < 1)
            {
               param1.scaleX = s;
               param1.scaleY = s;
            }
         }
         iconHolder.addChild(param1);
      }
      
      private function drawIcon(param1:Sprite, param2:uint) : void
      {
         param1.graphics.beginFill(13215820,0.15);
         param1.graphics.drawCircle(0,0,20);
         param1.graphics.endFill();
         param1.graphics.beginFill(param2,0.3);
         param1.graphics.drawCircle(0,0,16);
         param1.graphics.endFill();
         param1.graphics.beginFill(param2,0.9);
         param1.graphics.drawCircle(0,0,11);
         param1.graphics.endFill();
         param1.graphics.beginFill(16777215,0.35);
         param1.graphics.drawCircle(-3,-3,4);
         param1.graphics.endFill();
      }
      
      private function drawDiamondIcon(param1:Sprite) : void
      {
         param1.graphics.beginFill(48340,0.12);
         param1.graphics.drawCircle(0,0,20);
         param1.graphics.endFill();
         param1.graphics.beginFill(5099745);
         param1.graphics.moveTo(0,-15);
         param1.graphics.lineTo(13,-4);
         param1.graphics.lineTo(-13,-4);
         param1.graphics.lineTo(0,-15);
         param1.graphics.endFill();
         param1.graphics.beginFill(48340);
         param1.graphics.moveTo(-13,-4);
         param1.graphics.lineTo(0,-4);
         param1.graphics.lineTo(0,15);
         param1.graphics.lineTo(-13,-4);
         param1.graphics.endFill();
         param1.graphics.beginFill(44225);
         param1.graphics.moveTo(0,-4);
         param1.graphics.lineTo(13,-4);
         param1.graphics.lineTo(0,15);
         param1.graphics.lineTo(0,-4);
         param1.graphics.endFill();
         param1.graphics.beginFill(2541274);
         param1.graphics.moveTo(0,-15);
         param1.graphics.lineTo(5,-4);
         param1.graphics.lineTo(-5,-4);
         param1.graphics.lineTo(0,-15);
         param1.graphics.endFill();
         param1.graphics.beginFill(16777215,0.3);
         param1.graphics.moveTo(0,-15);
         param1.graphics.lineTo(-6,-4);
         param1.graphics.lineTo(-13,-4);
         param1.graphics.lineTo(0,-15);
         param1.graphics.endFill();
         param1.graphics.beginFill(16777215,0.5);
         param1.graphics.drawCircle(-4,-8,2);
         param1.graphics.endFill();
         param1.graphics.lineStyle(1,44225,0.5);
         param1.graphics.moveTo(-13,-4);
         param1.graphics.lineTo(13,-4);
         param1.graphics.lineStyle();
      }
      
      private function drawGoldIcon(param1:Sprite) : void
      {
         param1.graphics.beginFill(16761095,0.12);
         param1.graphics.drawCircle(0,0,20);
         param1.graphics.endFill();
         param1.graphics.beginFill(13145612);
         param1.graphics.drawCircle(1,1,14);
         param1.graphics.endFill();
         var mat:Matrix = new Matrix();
         mat.createGradientBox(28,28,Math.PI / 4,-14,-14);
         param1.graphics.beginGradientFill(GradientType.LINEAR,[16766287,16763432,15114496],[1,1,1],[0,128,255],mat);
         param1.graphics.drawCircle(0,0,14);
         param1.graphics.endFill();
         param1.graphics.lineStyle(1.5,13145612,0.5);
         param1.graphics.drawCircle(0,0,10);
         param1.graphics.lineStyle();
         param1.graphics.lineStyle(0.5,16769154,0.4);
         param1.graphics.drawCircle(0,0,10);
         param1.graphics.lineStyle();
         param1.graphics.lineStyle(2,15114496,0.8);
         param1.graphics.moveTo(0,-7);
         param1.graphics.curveTo(5,-5,3,-2);
         param1.graphics.curveTo(1,0,-3,0);
         param1.graphics.curveTo(-5,0,-3,2);
         param1.graphics.curveTo(-1,5,0,7);
         param1.graphics.lineStyle();
         param1.graphics.lineStyle(1,15114496,0.6);
         param1.graphics.moveTo(0,-9);
         param1.graphics.lineTo(0,-7);
         param1.graphics.moveTo(0,7);
         param1.graphics.lineTo(0,9);
         param1.graphics.lineStyle();
         param1.graphics.beginFill(16777215,0.25);
         param1.graphics.drawEllipse(-10,-12,14,10);
         param1.graphics.endFill();
         param1.graphics.beginFill(16777215,0.45);
         param1.graphics.drawCircle(-5,-6,2.5);
         param1.graphics.endFill();
      }
      
      private function formatNumber(param1:int) : String
      {
         var str:String = param1.toString();
         var result:String = "";
         var count:int = 0;
         var i:int = str.length - 1;
         while(i >= 0)
         {
            result = str.charAt(i) + result;
            if(++count % 3 == 0 && i > 0)
            {
               result = "," + result;
            }
            i--;
         }
         return result;
      }
      
      public function highlight(param1:uint = 16766720) : void
      {
         if(isHighlighted)
         {
            return;
         }
         isHighlighted = true;
         TweenMax.to(this,0.12,{
            "scaleX":1.08,
            "scaleY":1.08,
            "glowFilter":{
               "color":16766720,
               "alpha":1,
               "blurX":18,
               "blurY":18,
               "strength":3
            },
            "ease":Sine.easeOut
         });
      }
      
      public function unhighlight() : void
      {
         if(!isHighlighted)
         {
            return;
         }
         isHighlighted = false;
         TweenMax.to(this,0.12,{
            "scaleX":1,
            "scaleY":1,
            "glowFilter":{
               "color":16766720,
               "alpha":0,
               "blurX":0,
               "blurY":0,
               "strength":0
            },
            "ease":Sine.easeOut
         });
      }
      
      public function showWinAnimation() : void
      {
         TweenMax.to(this,0.35,{
            "glowFilter":{
               "color":16766720,
               "alpha":1,
               "blurX":26,
               "blurY":26,
               "strength":5
            },
            "scaleX":1.12,
            "scaleY":1.12,
            "repeat":3,
            "yoyo":true,
            "ease":Sine.easeInOut
         });
      }
      
      public function dispose() : void
      {
         TweenMax.killTweensOf(this);
         if(_waitingForImage)
         {
            Sanalika.instance.itemModel.removeEventListener("png",onPngLoaded);
            _waitingForImage = false;
         }
         if(bg && contains(bg))
         {
            removeChild(bg);
         }
         if(iconHolder && contains(iconHolder))
         {
            removeChild(iconHolder);
         }
         if(amountLabel && contains(amountLabel))
         {
            removeChild(amountLabel);
         }
         if(nameLabel && contains(nameLabel))
         {
            removeChild(nameLabel);
         }
         if(shine && contains(shine))
         {
            removeChild(shine);
         }
         if(deco && contains(deco))
         {
            removeChild(deco);
         }
         bg = null;
         iconHolder = null;
         amountLabel = null;
         nameLabel = null;
         shine = null;
         deco = null;
      }
   }
}

