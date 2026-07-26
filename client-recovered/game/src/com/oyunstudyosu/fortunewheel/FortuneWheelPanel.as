package com.oyunstudyosu.fortunewheel
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Sine;
   import com.greensock.plugins.GlowFilterPlugin;
   import com.greensock.plugins.TweenPlugin;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.panel.Panel;
   import com.oyunstudyosu.panel.PanelType;
   import com.oyunstudyosu.panel.PanelVO;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import com.oyunstudyosu.utils.FlarabyAS3;
   import flash.display.GradientType;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   
   public class FortuneWheelPanel extends Panel
   {
      
      private static var _flaraby:FlarabyAS3;
      
      private static const CELL_W:int = 130;
      
      private static const CELL_H:int = 100;
      
      private static const GAP:int = 8;
      
      private static const COLS:int = 3;
      
      private static const ROWS:int = 3;
      
      private static const GRID_POSITIONS:Array = [[0,0],[1,0],[2,0],[2,1],[2,2],[1,2],[0,2],[0,1]];
      
      private var items:Array;
      
      private var container:Sprite;
      
      private var starsLayer:Sprite;
      
      private var spinButton:Sprite;
      
      private var spinLabel:TextField;
      
      private var spinCostLabel:TextField;
      
      private var closeBtn:Sprite;
      
      private var tabGems:Sprite;
      
      private var tabGold:Sprite;
      
      private var tabGemsLabel:TextField;
      
      private var tabGoldLabel:TextField;
      
      private var tabGemsIcon:Sprite;
      
      private var tabGoldIcon:Sprite;
      
      private var activeTab:String = "gems";
      
      private var isSpinning:Boolean = false;
      
      private var spinTimer:Timer;
      
      private var currentHighlight:int = -1;
      
      private var spinStep:int = 0;
      
      private var totalSpinSteps:int = 0;
      
      private var winIndex:int = 0;
      
      private var spinGlowTween:TweenMax;
      
      private var currentProducts:Array;
      
      private var waitingForServer:Boolean = false;
      
      private var hasFreeSpinVar:Boolean = true;
      
      private var spinCostVar:int = 0;
      
      private var costCurrencyVar:String = "DIAMOND";
      
      public function FortuneWheelPanel()
      {
         super();
         TweenPlugin.activate([GlowFilterPlugin]);
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
      
      override public function init() : void
      {
         this.panelWidth = COLS * (CELL_W + GAP) + GAP + 70;
         this.panelHeight = ROWS * (CELL_H + GAP) + GAP + 180;
         var vo:PanelVO = new PanelVO("FortuneWheelPanel",PanelType.STATIC);
         this.data = vo;
         super.init();
         buildUI();
         this.show();
         fitToScreen();
         Dispatcher.addEventListener(GameEvent.RESIZE,onFitResize);
         requestPrizes();
      }
      
      private function requestPrizes() : void
      {
         Sanalika.instance.serviceModel.requestData("fortunewheel",{
            "action":"getprizes",
            "tab":activeTab
         },onPrizesReceived);
      }
      
      private function onPrizesReceived(param1:Object) : void
      {
         if(param1 == null || param1.errorCode != null)
         {
            return;
         }
         if(param1.hasFree != null)
         {
            hasFreeSpinVar = param1.hasFree;
         }
         if(param1.spinCost != null)
         {
            spinCostVar = param1.spinCost;
         }
         if(param1.costCurrency != null)
         {
            costCurrencyVar = param1.costCurrency;
         }
         var prizesData:* = param1.prizes;
         if(prizesData == null)
         {
            return;
         }
         currentProducts = [];
         var i:int = 0;
         while(i < prizesData.length)
         {
            currentProducts.push({
               "name":prizesData[i].name,
               "amount":prizesData[i].amount,
               "rarity":prizesData[i].rarity,
               "iconColor":prizesData[i].iconColor,
               "prizeType":prizesData[i].prizeType,
               "clip":(prizesData[i].clip != null ? prizesData[i].clip : null),
               "lifeDays":(prizesData[i].lifeDays != null ? prizesData[i].lifeDays : 0)
            });
            i++;
         }
         buildGrid();
         buildSpinButton();
      }
      
      private function buildUI() : void
      {
         container = new Sprite();
         addChild(container);
         drawBackground();
         drawStars();
         drawCrescent();
         drawHeader();
         drawOrnaments();
         drawTabs();
         if(stage)
         {
            stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
         }
      }
      
      private function drawBackground() : void
      {
         var mat:Matrix = new Matrix();
         mat.createGradientBox(panelWidth,panelHeight,Math.PI / 2,0,0);
         container.graphics.beginGradientFill(GradientType.LINEAR,[854056,1707582,1181749,525338],[1,1,1,1],[0,80,180,255],mat);
         container.graphics.drawRoundRect(0,0,panelWidth,panelHeight,24,24);
         container.graphics.endFill();
         container.graphics.lineStyle(2,13215820,0.65);
         container.graphics.drawRoundRect(0,0,panelWidth,panelHeight,24,24);
         container.graphics.lineStyle(1,13215820,0.2);
         container.graphics.drawRoundRect(4,4,panelWidth - 8,panelHeight - 8,20,20);
         var cornerSize:int = 20;
         var cs:int = cornerSize;
         container.graphics.lineStyle(1,13215820,0.3);
         container.graphics.moveTo(8,8 + cs);
         container.graphics.lineTo(8,8);
         container.graphics.lineTo(8 + cs,8);
         container.graphics.moveTo(panelWidth - 8 - cs,8);
         container.graphics.lineTo(panelWidth - 8,8);
         container.graphics.lineTo(panelWidth - 8,8 + cs);
         container.graphics.moveTo(panelWidth - 8,panelHeight - 8 - cs);
         container.graphics.lineTo(panelWidth - 8,panelHeight - 8);
         container.graphics.lineTo(panelWidth - 8 - cs,panelHeight - 8);
         container.graphics.moveTo(8 + cs,panelHeight - 8);
         container.graphics.lineTo(8,panelHeight - 8);
         container.graphics.lineTo(8,panelHeight - 8 - cs);
      }
      
      private function drawStars() : void
      {
         starsLayer = new Sprite();
         var starPositions:Array = [[30,18,2.5,0.7],[65,10,1.5,0.4],[panelWidth - 70,12,2,0.6],[panelWidth - 35,22,1.5,0.5],[panelWidth / 2 - 60,8,1.8,0.5],[panelWidth / 2 + 55,14,1.2,0.3],[50,40,1,0.25],[panelWidth - 50,38,1.3,0.3],[panelWidth / 2 - 90,30,1,0.2],[panelWidth / 2 + 85,25,1.5,0.35]];
         var i:int = 0;
         while(i < starPositions.length)
         {
            drawStar(starsLayer,starPositions[i][0],starPositions[i][1],starPositions[i][2],starPositions[i][3]);
            i++;
         }
         container.addChild(starsLayer);
         TweenMax.to(starsLayer,2.5,{
            "alpha":0.4,
            "repeat":-1,
            "yoyo":true,
            "ease":Sine.easeInOut
         });
      }
      
      private function drawStar(param1:Sprite, px:Number, py:Number, size:Number, alpha:Number) : void
      {
         param1.graphics.beginFill(16769154,alpha);
         param1.graphics.moveTo(px,py - size);
         param1.graphics.lineTo(px + size * 0.3,py - size * 0.3);
         param1.graphics.lineTo(px + size,py);
         param1.graphics.lineTo(px + size * 0.3,py + size * 0.3);
         param1.graphics.lineTo(px,py + size);
         param1.graphics.lineTo(px - size * 0.3,py + size * 0.3);
         param1.graphics.lineTo(px - size,py);
         param1.graphics.lineTo(px - size * 0.3,py - size * 0.3);
         param1.graphics.lineTo(px,py - size);
         param1.graphics.endFill();
         param1.graphics.beginFill(16777215,alpha * 0.6);
         param1.graphics.drawCircle(px,py,size * 0.3);
         param1.graphics.endFill();
      }
      
      private function drawCrescent() : void
      {
         var crescent:Sprite = new Sprite();
         var cx:Number = panelWidth / 2;
         var cy:Number = 38;
         crescent.graphics.beginFill(16766720,0.9);
         crescent.graphics.drawCircle(cx + 75,cy - 8,14);
         crescent.graphics.endFill();
         crescent.graphics.beginFill(854056);
         crescent.graphics.drawCircle(cx + 81,cy - 12,12);
         crescent.graphics.endFill();
         crescent.graphics.beginFill(16766720,0.8);
         crescent.graphics.drawCircle(cx + 95,cy - 16,2.5);
         crescent.graphics.endFill();
         crescent.graphics.beginFill(16769154,0.5);
         crescent.graphics.drawCircle(cx - 80,cy - 5,2);
         crescent.graphics.endFill();
         container.addChild(crescent);
      }
      
      private function drawOrnaments() : void
      {
         var ornament:Sprite = new Sprite();
         var lineMat:Matrix = new Matrix();
         lineMat.createGradientBox(panelWidth - 80,3,0,0,0);
         ornament.graphics.beginGradientFill(GradientType.LINEAR,[13215820,16766720,13215820],[0,0.8,0],[0,128,255],lineMat);
         ornament.graphics.drawRect(0,0,panelWidth - 80,1);
         ornament.graphics.endFill();
         ornament.graphics.beginGradientFill(GradientType.LINEAR,[13215820,16766720,13215820],[0,0.4,0],[0,128,255],lineMat);
         ornament.graphics.drawRect(0,3,panelWidth - 80,1);
         ornament.graphics.endFill();
         ornament.graphics.beginFill(16766720,0.7);
         ornament.graphics.drawCircle((panelWidth - 80) / 2,2,3);
         ornament.graphics.endFill();
         ornament.graphics.beginFill(16766720,0.4);
         ornament.graphics.drawCircle(30,2,1.5);
         ornament.graphics.endFill();
         ornament.graphics.beginFill(16766720,0.4);
         ornament.graphics.drawCircle(panelWidth - 80 - 30,2,1.5);
         ornament.graphics.endFill();
         ornament.x = 40;
         ornament.y = 56;
         container.addChild(ornament);
         var bottomLine:Sprite = new Sprite();
         var bMat:Matrix = new Matrix();
         bMat.createGradientBox(panelWidth - 100,2,0,0,0);
         bottomLine.graphics.beginGradientFill(GradientType.LINEAR,[13215820,16766720,13215820],[0,0.35,0],[0,128,255],bMat);
         bottomLine.graphics.drawRect(0,0,panelWidth - 100,1);
         bottomLine.graphics.endFill();
         bottomLine.x = 50;
         bottomLine.y = panelHeight - 20;
         container.addChild(bottomLine);
      }
      
      private function drawHeader() : void
      {
         var titleFmt:TextFormat = new TextFormat();
         titleFmt.font = "Arial";
         titleFmt.size = 24;
         titleFmt.color = 16766720;
         titleFmt.bold = true;
         titleFmt.align = TextFormatAlign.CENTER;
         titleFmt.letterSpacing = 3;
         var title:TextField = new TextField();
         title.defaultTextFormat = titleFmt;
         title.width = panelWidth;
         title.height = 40;
         title.x = 0;
         title.y = 14;
         title.selectable = false;
         title.mouseEnabled = false;
         setArabic(title,"هدايا رمضان");
         container.addChild(title);
         closeBtn = new Sprite();
         closeBtn.graphics.beginFill(2757957,0.9);
         closeBtn.graphics.drawRoundRect(-15,-15,30,30,10,10);
         closeBtn.graphics.endFill();
         closeBtn.graphics.lineStyle(1,13215820,0.4);
         closeBtn.graphics.drawRoundRect(-15,-15,30,30,10,10);
         closeBtn.graphics.lineStyle(2.5,16737877,0.9);
         closeBtn.graphics.moveTo(-6,-6);
         closeBtn.graphics.lineTo(6,6);
         closeBtn.graphics.moveTo(6,-6);
         closeBtn.graphics.lineTo(-6,6);
         closeBtn.x = panelWidth - 24;
         closeBtn.y = 24;
         closeBtn.buttonMode = true;
         closeBtn.addEventListener(MouseEvent.CLICK,onCloseClick);
         container.addChild(closeBtn);
      }
      
      private function drawTabs() : void
      {
         var tabY:int = 66;
         var tabW:int = 135;
         var tabH:int = 38;
         var centerX:int = panelWidth / 2;
         tabGems = new Sprite();
         drawTabBg(tabGems,tabW,tabH,true);
         tabGems.x = centerX - tabW - 8;
         tabGems.y = tabY;
         tabGems.buttonMode = true;
         tabGems.addEventListener(MouseEvent.CLICK,onTabGemsClick);
         container.addChild(tabGems);
         tabGemsIcon = new Sprite();
         tabGemsIcon.graphics.beginFill(48340);
         tabGemsIcon.graphics.drawCircle(0,0,7);
         tabGemsIcon.graphics.endFill();
         tabGemsIcon.graphics.beginFill(16777215,0.35);
         tabGemsIcon.graphics.drawCircle(-2,-2,3);
         tabGemsIcon.graphics.endFill();
         tabGemsIcon.x = tabW - 22;
         tabGemsIcon.y = tabH / 2;
         tabGems.addChild(tabGemsIcon);
         var gemsFmt:TextFormat = new TextFormat();
         gemsFmt.font = "Arial";
         gemsFmt.size = 14;
         gemsFmt.color = 16769154;
         gemsFmt.bold = true;
         gemsFmt.align = TextFormatAlign.CENTER;
         tabGemsLabel = new TextField();
         tabGemsLabel.defaultTextFormat = gemsFmt;
         tabGemsLabel.width = tabW - 30;
         tabGemsLabel.height = tabH;
         tabGemsLabel.x = 0;
         tabGemsLabel.y = 8;
         tabGemsLabel.selectable = false;
         tabGemsLabel.mouseEnabled = false;
         setArabic(tabGemsLabel,"جواهر");
         tabGems.addChild(tabGemsLabel);
         tabGold = new Sprite();
         drawTabBg(tabGold,tabW,tabH,false);
         tabGold.x = centerX + 8;
         tabGold.y = tabY;
         tabGold.buttonMode = true;
         tabGold.addEventListener(MouseEvent.CLICK,onTabGoldClick);
         container.addChild(tabGold);
         tabGoldIcon = new Sprite();
         tabGoldIcon.graphics.beginFill(16761095);
         tabGoldIcon.graphics.drawCircle(0,0,7);
         tabGoldIcon.graphics.endFill();
         tabGoldIcon.graphics.beginFill(16777215,0.35);
         tabGoldIcon.graphics.drawCircle(-2,-2,3);
         tabGoldIcon.graphics.endFill();
         tabGoldIcon.x = tabW - 22;
         tabGoldIcon.y = tabH / 2;
         tabGold.addChild(tabGoldIcon);
         var goldFmt:TextFormat = new TextFormat();
         goldFmt.font = "Arial";
         goldFmt.size = 14;
         goldFmt.color = 8943462;
         goldFmt.bold = true;
         goldFmt.align = TextFormatAlign.CENTER;
         tabGoldLabel = new TextField();
         tabGoldLabel.defaultTextFormat = goldFmt;
         tabGoldLabel.width = tabW - 30;
         tabGoldLabel.height = tabH;
         tabGoldLabel.x = 0;
         tabGoldLabel.y = 8;
         tabGoldLabel.selectable = false;
         tabGoldLabel.mouseEnabled = false;
         setArabic(tabGoldLabel,"ذهب");
         tabGold.addChild(tabGoldLabel);
      }
      
      private function drawTabBg(param1:Sprite, param2:int, param3:int, param4:Boolean) : void
      {
         param1.graphics.clear();
         var mat:Matrix = new Matrix();
         mat.createGradientBox(param2,param3,Math.PI / 2,0,0);
         if(param4)
         {
            param1.graphics.beginGradientFill(GradientType.LINEAR,[3807854,2756174],[1,1],[0,255],mat);
            param1.graphics.drawRoundRect(0,0,param2,param3,12,12);
            param1.graphics.endFill();
            param1.graphics.lineStyle(1,13215820,0.6);
            param1.graphics.drawRoundRect(0,0,param2,param3,12,12);
         }
         else
         {
            param1.graphics.beginFill(1181744,0.8);
            param1.graphics.drawRoundRect(0,0,param2,param3,12,12);
            param1.graphics.endFill();
            param1.graphics.lineStyle(1,2757957,0.5);
            param1.graphics.drawRoundRect(0,0,param2,param3,12,12);
         }
      }
      
      private function buildGrid() : void
      {
         var offsetX:int = 35;
         var offsetY:int = 115;
         if(items != null)
         {
            var i:int = 0;
            while(i < items.length)
            {
               if(items[i] && container.contains(items[i]))
               {
                  (items[i] as FortuneWheelItem).dispose();
                  container.removeChild(items[i]);
               }
               i++;
            }
         }
         if(currentProducts == null || currentProducts.length == 0)
         {
            return;
         }
         items = [];
         i = 0;
         while(i < GRID_POSITIONS.length && i < currentProducts.length)
         {
            var product:Object = currentProducts[i];
            var col:int = int(GRID_POSITIONS[i][0]);
            var row:int = int(GRID_POSITIONS[i][1]);
            var item:FortuneWheelItem = new FortuneWheelItem(product.name,product.amount,product.rarity,product.iconColor,i,product.clip,product.lifeDays,product.prizeType,CELL_W,CELL_H);
            item.x = offsetX + col * (CELL_W + GAP);
            item.y = offsetY + row * (CELL_H + GAP);
            container.addChild(item);
            items.push(item);
            i++;
         }
      }
      
      private function buildSpinButton() : void
      {
         if(spinButton && container.contains(spinButton))
         {
            if(spinGlowTween)
            {
               spinGlowTween.kill();
               spinGlowTween = null;
            }
            spinButton.removeEventListener(MouseEvent.CLICK,onSpinClick);
            container.removeChild(spinButton);
         }
         spinButton = new Sprite();
         var btnW:int = CELL_W;
         var btnH:int = CELL_H;
         var mat:Matrix = new Matrix();
         mat.createGradientBox(btnW,btnH,Math.PI / 2,0,0);
         if(hasFreeSpinVar)
         {
            spinButton.graphics.beginGradientFill(GradientType.LINEAR,[3046706,1793568],[1,1],[0,255],mat);
         }
         else
         {
            spinButton.graphics.beginGradientFill(GradientType.LINEAR,[13215820,9136404],[1,1],[0,255],mat);
         }
         spinButton.graphics.drawRoundRect(0,0,btnW,btnH,16,16);
         spinButton.graphics.endFill();
         spinButton.graphics.lineStyle(1.5,hasFreeSpinVar ? 6732650 : 16766720,0.6);
         spinButton.graphics.drawRoundRect(0,0,btnW,btnH,16,16);
         var sMat:Matrix = new Matrix();
         sMat.createGradientBox(btnW,btnH / 2,Math.PI / 2,0,0);
         spinButton.graphics.lineStyle();
         spinButton.graphics.beginGradientFill(GradientType.LINEAR,[16777215,16777215],[0.15,0],[0,255],sMat);
         spinButton.graphics.drawRoundRect(2,2,btnW - 4,btnH / 2 - 2,14,14);
         spinButton.graphics.endFill();
         spinButton.graphics.lineStyle(1,hasFreeSpinVar ? 5025616 : 13215820,0.15);
         spinButton.graphics.drawRoundRect(3,3,btnW - 6,btnH - 6,13,13);
         var mainFmt:TextFormat = new TextFormat();
         mainFmt.font = "Arial";
         mainFmt.size = 18;
         mainFmt.color = 16777215;
         mainFmt.bold = true;
         mainFmt.align = TextFormatAlign.CENTER;
         spinLabel = new TextField();
         spinLabel.defaultTextFormat = mainFmt;
         spinLabel.width = btnW;
         spinLabel.height = 28;
         spinLabel.selectable = false;
         spinLabel.mouseEnabled = false;
         if(hasFreeSpinVar)
         {
            spinLabel.y = (btnH - 24) / 2;
            setArabic(spinLabel,"مجاني");
            spinButton.addChild(spinLabel);
         }
         else
         {
            setArabic(spinLabel,"العب");
            spinLabel.y = 16;
            spinButton.addChild(spinLabel);
            var costFmt:TextFormat = new TextFormat();
            costFmt.font = "Arial";
            costFmt.size = 12;
            costFmt.color = 16777181;
            costFmt.bold = true;
            costFmt.align = TextFormatAlign.CENTER;
            spinCostLabel = new TextField();
            spinCostLabel.defaultTextFormat = costFmt;
            spinCostLabel.width = btnW;
            spinCostLabel.height = 22;
            spinCostLabel.y = 50;
            spinCostLabel.selectable = false;
            spinCostLabel.mouseEnabled = false;
            var costText:String = formatNumber(spinCostVar);
            if(costCurrencyVar == "DIAMOND")
            {
               costText += " جوهرة";
            }
            else
            {
               costText += " ذهب";
            }
            setArabic(spinCostLabel,costText);
            spinButton.addChild(spinCostLabel);
         }
         var offsetX:int = 35;
         var offsetY:int = 115;
         spinButton.x = offsetX + 1 * (CELL_W + GAP);
         spinButton.y = offsetY + 1 * (CELL_H + GAP);
         spinButton.buttonMode = true;
         spinButton.addEventListener(MouseEvent.CLICK,onSpinClick);
         container.addChild(spinButton);
         var glowColor:uint = uint(hasFreeSpinVar ? 5025616 : 16766720);
         spinGlowTween = TweenMax.to(spinButton,1.8,{
            "glowFilter":{
               "color":glowColor,
               "alpha":0.7,
               "blurX":22,
               "blurY":22,
               "strength":2
            },
            "repeat":-1,
            "yoyo":true,
            "ease":Sine.easeInOut
         });
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
      
      private function onTabGemsClick(param1:MouseEvent) : void
      {
         if(activeTab == "gems" || isSpinning || waitingForServer)
         {
            return;
         }
         activeTab = "gems";
         drawTabBg(tabGems,135,38,true);
         drawTabBg(tabGold,135,38,false);
         tabGems.addChild(tabGemsIcon);
         tabGems.addChild(tabGemsLabel);
         tabGold.addChild(tabGoldIcon);
         tabGold.addChild(tabGoldLabel);
         updateTabLabelColors();
         requestPrizes();
      }
      
      private function onTabGoldClick(param1:MouseEvent) : void
      {
         if(activeTab == "gold" || isSpinning || waitingForServer)
         {
            return;
         }
         activeTab = "gold";
         drawTabBg(tabGems,135,38,false);
         drawTabBg(tabGold,135,38,true);
         tabGems.addChild(tabGemsIcon);
         tabGems.addChild(tabGemsLabel);
         tabGold.addChild(tabGoldIcon);
         tabGold.addChild(tabGoldLabel);
         updateTabLabelColors();
         requestPrizes();
      }
      
      private function updateTabLabelColors() : void
      {
         var activeFmt:TextFormat = new TextFormat();
         activeFmt.font = "Arial";
         activeFmt.size = 14;
         activeFmt.color = 16769154;
         activeFmt.bold = true;
         activeFmt.align = TextFormatAlign.CENTER;
         var inactiveFmt:TextFormat = new TextFormat();
         inactiveFmt.font = "Arial";
         inactiveFmt.size = 14;
         inactiveFmt.color = 8943462;
         inactiveFmt.bold = true;
         inactiveFmt.align = TextFormatAlign.CENTER;
         if(activeTab == "gems")
         {
            tabGemsLabel.defaultTextFormat = activeFmt;
            setArabic(tabGemsLabel,"جواهر");
            tabGoldLabel.defaultTextFormat = inactiveFmt;
            setArabic(tabGoldLabel,"ذهب");
         }
         else
         {
            tabGemsLabel.defaultTextFormat = inactiveFmt;
            setArabic(tabGemsLabel,"جواهر");
            tabGoldLabel.defaultTextFormat = activeFmt;
            setArabic(tabGoldLabel,"ذهب");
         }
      }
      
      private function onSpinClick(param1:MouseEvent) : void
      {
         if(isSpinning || waitingForServer)
         {
            return;
         }
         startSpin();
      }
      
      private function startSpin() : void
      {
         isSpinning = true;
         waitingForServer = true;
         spinButton.buttonMode = false;
         spinButton.alpha = 0.5;
         if(spinGlowTween)
         {
            spinGlowTween.kill();
         }
         TweenMax.to(spinButton,0.1,{"glowFilter":{
            "color":16766720,
            "alpha":0,
            "blurX":0,
            "blurY":0,
            "strength":0
         }});
         Sanalika.instance.serviceModel.requestData("fortunewheel",{
            "action":"spin",
            "tab":activeTab
         },onSpinResult);
      }
      
      private function onSpinResult(param1:Object) : void
      {
         waitingForServer = false;
         if(param1 == null || param1.errorCode != null || param1.action == "error")
         {
            isSpinning = false;
            spinButton.buttonMode = true;
            spinButton.alpha = 1;
            var gc:uint = uint(hasFreeSpinVar ? 5025616 : 16766720);
            spinGlowTween = TweenMax.to(spinButton,1.8,{
               "glowFilter":{
                  "color":gc,
                  "alpha":0.7,
                  "blurX":22,
                  "blurY":22,
                  "strength":2
               },
               "repeat":-1,
               "yoyo":true,
               "ease":Sine.easeInOut
            });
            return;
         }
         winIndex = param1.winIndex;
         var itemCount:int = items != null ? int(items.length) : 8;
         var fullRotations:int = 5;
         totalSpinSteps = fullRotations * itemCount + winIndex + 1;
         spinStep = 0;
         currentHighlight = -1;
         advanceSpin();
      }
      
      private function advanceSpin() : void
      {
         if(spinStep >= totalSpinSteps)
         {
            onSpinComplete();
            return;
         }
         if(currentHighlight >= 0 && currentHighlight < items.length)
         {
            (items[currentHighlight] as FortuneWheelItem).unhighlight();
         }
         currentHighlight = spinStep % items.length;
         (items[currentHighlight] as FortuneWheelItem).highlight();
         var progress:Number = spinStep / totalSpinSteps;
         var interval:Number = 50 + 350 * progress * progress * progress;
         var remaining:int = totalSpinSteps - spinStep;
         if(remaining <= 3)
         {
            interval += 150;
         }
         if(remaining <= 1)
         {
            interval += 200;
         }
         ++spinStep;
         spinTimer = new Timer(interval,1);
         spinTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onSpinTimerTick);
         spinTimer.start();
      }
      
      private function onSpinTimerTick(param1:TimerEvent) : void
      {
         if(spinTimer)
         {
            spinTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onSpinTimerTick);
            spinTimer.stop();
            spinTimer = null;
         }
         advanceSpin();
      }
      
      private function onSpinComplete() : void
      {
         var winner:FortuneWheelItem = items[winIndex] as FortuneWheelItem;
         winner.showWinAnimation();
         TweenMax.delayedCall(1.5,showWinTooltip);
         TweenMax.delayedCall(3,claimAndReset);
      }
      
      private function showWinTooltip() : void
      {
         if(currentProducts == null || winIndex >= currentProducts.length)
         {
            return;
         }
         var product:Object = currentProducts[winIndex];
         var tooltip:Sprite = new Sprite();
         var tMat:Matrix = new Matrix();
         tMat.createGradientBox(280,54,Math.PI / 2,0,0);
         tooltip.graphics.beginGradientFill(GradientType.LINEAR,[1707582,853280],[0.95,0.95],[0,255],tMat);
         tooltip.graphics.drawRoundRect(0,0,280,54,14,14);
         tooltip.graphics.endFill();
         tooltip.graphics.lineStyle(1.5,16766720,0.7);
         tooltip.graphics.drawRoundRect(0,0,280,54,14,14);
         tooltip.graphics.lineStyle();
         tooltip.graphics.beginFill(16766720,0.5);
         tooltip.graphics.drawCircle(20,27,2);
         tooltip.graphics.endFill();
         tooltip.graphics.beginFill(16766720,0.5);
         tooltip.graphics.drawCircle(260,27,2);
         tooltip.graphics.endFill();
         var fmt:TextFormat = new TextFormat();
         fmt.font = "Arial";
         fmt.size = 16;
         fmt.color = 16766720;
         fmt.bold = true;
         fmt.align = TextFormatAlign.CENTER;
         var tf:TextField = new TextField();
         tf.defaultTextFormat = fmt;
         tf.width = 280;
         tf.height = 32;
         tf.y = 12;
         tf.selectable = false;
         tf.mouseEnabled = false;
         if(product.clip != null && product.clip != "")
         {
            var prodName:String = $("pro_" + product.clip);
            if(prodName == null || prodName == "" || prodName == "pro_" + product.clip)
            {
               prodName = product.name;
            }
            setArabic(tf,"مبارك! ربحت " + prodName);
         }
         else
         {
            setArabic(tf,"مبارك! ربحت " + formatNumber(product.amount) + " " + product.name);
         }
         tooltip.addChild(tf);
         tooltip.x = (panelWidth - 280) / 2;
         tooltip.y = panelHeight - 75;
         tooltip.name = "winTooltip";
         container.addChild(tooltip);
         TweenMax.from(tooltip,0.4,{
            "alpha":0,
            "y":tooltip.y + 15,
            "ease":Back.easeOut
         });
      }
      
      private function claimAndReset() : void
      {
         Sanalika.instance.serviceModel.requestData("fortunewheel",{
            "action":"claim",
            "tab":activeTab
         },onClaimResult);
         resetAfterWin();
      }
      
      private function onClaimResult(param1:Object) : void
      {
         if(param1 != null && param1.hasFree != null)
         {
            hasFreeSpinVar = param1.hasFree;
            buildSpinButton();
         }
      }
      
      private function resetAfterWin() : void
      {
         if(items)
         {
            var i:int = 0;
            while(i < items.length)
            {
               (items[i] as FortuneWheelItem).unhighlight();
               i++;
            }
         }
         var tooltip:* = container.getChildByName("winTooltip");
         if(tooltip && container.contains(tooltip))
         {
            container.removeChild(tooltip);
         }
         isSpinning = false;
         spinButton.buttonMode = true;
         spinButton.alpha = 1;
         currentHighlight = -1;
      }
      
      private function onCloseClick(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ESCAPE)
         {
            close();
         }
      }
      
      override protected function close() : void
      {
         disposeInternal();
         super.close();
      }
      
      private function fitToScreen() : void
      {
         var sw:Number = Number(Connectr.instance.layerModel.stage.stageWidth);
         var sh:Number = Number(Connectr.instance.layerModel.stage.stageHeight);
         var fitScX:Number = (sw - 20) / panelWidth;
         var fitScY:Number = (sh - 20) / panelHeight;
         var fitSc:Number = Math.min(fitScX,fitScY,1);
         if(fitSc < 0.3)
         {
            fitSc = 0.3;
         }
         this.scaleX = fitSc;
         this.scaleY = fitSc;
         this.x = (sw - panelWidth * fitSc) / 2;
         var yPos:Number = (sh - panelHeight * fitSc) / 2;
         if(yPos < 5)
         {
            yPos = 5;
         }
         this.y = yPos;
      }
      
      private function onFitResize(param1:GameEvent) : void
      {
         fitToScreen();
      }
      
      override public function dispose() : void
      {
         Dispatcher.removeEventListener(GameEvent.RESIZE,onFitResize);
         disposeInternal();
         super.dispose();
      }
      
      private function disposeInternal() : void
      {
         if(spinTimer)
         {
            spinTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onSpinTimerTick);
            spinTimer.stop();
            spinTimer = null;
         }
         TweenMax.killDelayedCallsTo(showWinTooltip);
         TweenMax.killDelayedCallsTo(claimAndReset);
         if(spinGlowTween)
         {
            spinGlowTween.kill();
            spinGlowTween = null;
         }
         if(starsLayer)
         {
            TweenMax.killTweensOf(starsLayer);
         }
         if(stage)
         {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
         }
         if(closeBtn)
         {
            closeBtn.removeEventListener(MouseEvent.CLICK,onCloseClick);
         }
         if(spinButton)
         {
            spinButton.removeEventListener(MouseEvent.CLICK,onSpinClick);
         }
         if(tabGems)
         {
            tabGems.removeEventListener(MouseEvent.CLICK,onTabGemsClick);
         }
         if(tabGold)
         {
            tabGold.removeEventListener(MouseEvent.CLICK,onTabGoldClick);
         }
         if(items)
         {
            var i:int = 0;
            while(i < items.length)
            {
               if(items[i])
               {
                  (items[i] as FortuneWheelItem).dispose();
               }
               i++;
            }
            items = null;
         }
         currentProducts = null;
      }
   }
}

