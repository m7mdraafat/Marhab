package org.oyunstudyosu.business
{
   import com.greensock.TweenMax;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.HudEvent;
   import com.oyunstudyosu.events.OrderEvent;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.panel.PanelType;
   import com.oyunstudyosu.panel.PanelVO;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import org.oyunstudyosu.alert.views.InfoView;
   import org.oyunstudyosu.commands.OpenRoomChangePasswordCommand;
   import org.oyunstudyosu.components.CoreMovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1075")]
   public class BusinessMenu extends CoreMovieClip
   {
      
      public var cafeListTab:SimpleButton;
      
      public var modifyTab:SimpleButton;
      
      public var passwordTab:SimpleButton;
      
      public var messageTab:SimpleButton;
      
      public var restrictedListTab:SimpleButton;
      
      public var infoTab:SimpleButton;
      
      public var orderTab:SimpleButton;
      
      public var bgOrder:MovieClip;
      
      public var txtOrder:TextField;
      
      private var outEvent:HudEvent;
      
      private var musicTab:Sprite;
      
      private var musicListTab:Sprite;
      
      private var contestTab:Sprite;
      
      private var contestPanel:Sprite;
      
      private var contestStatusLabel:TextField;
      
      public function BusinessMenu()
      {
         super();
      }
      
      override public function added() : void
      {
         Connectr.instance.toolTipModel.addTip(this.cafeListTab,$("Room List"));
         Connectr.instance.toolTipModel.addTip(this.modifyTab,$("Design"));
         Connectr.instance.toolTipModel.addTip(this.messageTab,$("Send Message"));
         Connectr.instance.toolTipModel.addTip(this.infoTab,$("Room Info"));
         Connectr.instance.toolTipModel.addTip(this.passwordTab,$("Room Password"));
         Connectr.instance.toolTipModel.addTip(this.restrictedListTab,$("Restricted List"));
         Connectr.instance.toolTipModel.addTip(this.orderTab,$("orderLIST"));
         this.cafeListTab.addEventListener(MouseEvent.CLICK,this.cafeListTabClicked);
         this.modifyTab.addEventListener(MouseEvent.CLICK,this.modifyTabClicked);
         this.messageTab.addEventListener(MouseEvent.CLICK,this.messageTabClicked);
         this.restrictedListTab.addEventListener(MouseEvent.CLICK,this.restrictedListTabClicked);
         this.infoTab.addEventListener(MouseEvent.CLICK,this.infoTabClicked);
         this.passwordTab.addEventListener(MouseEvent.CLICK,this.passwordTabClicked);
         this.orderTab.addEventListener(MouseEvent.CLICK,this.orderTabClicked);
         this.createMusicButtons();
         this.createContestButton();
      }
      
      private function createMusicButtons() : void
      {
         var btnSize:Number = this.orderTab.width * 1.4;
         var centerX:Number = this.orderTab.x + btnSize / 2 - 6;
         var startY:Number = this.orderTab.y + this.orderTab.height + 10;
         var spacing:Number = btnSize + 8;
         this.musicTab = new Sprite();
         var g1:Graphics = this.musicTab.graphics;
         g1.beginFill(0,0);
         g1.drawRect(0,0,btnSize,btnSize);
         g1.endFill();
         this.musicTab.buttonMode = true;
         this.musicTab.useHandCursor = true;
         this.musicTab.mouseChildren = false;
         this.musicTab.x = centerX - btnSize / 2;
         this.musicTab.y = startY;
         this.musicTab.name = "musicTab";
         this.drawMusicNoteIcon(this.musicTab,btnSize);
         addChild(this.musicTab);
         Connectr.instance.toolTipModel.addTip(this.musicTab,$("Add Music"));
         this.musicTab.addEventListener(MouseEvent.CLICK,this.musicTabClicked);
         this.musicListTab = new Sprite();
         var g2:Graphics = this.musicListTab.graphics;
         g2.beginFill(0,0);
         g2.drawRect(0,0,btnSize,btnSize);
         g2.endFill();
         this.musicListTab.buttonMode = true;
         this.musicListTab.useHandCursor = true;
         this.musicListTab.mouseChildren = false;
         this.musicListTab.x = centerX - btnSize / 2;
         this.musicListTab.y = startY + spacing;
         this.musicListTab.name = "musicListTab";
         this.drawMusicListIcon(this.musicListTab,btnSize);
         addChild(this.musicListTab);
         Connectr.instance.toolTipModel.addTip(this.musicListTab,$("Music List"));
         this.musicListTab.addEventListener(MouseEvent.CLICK,this.musicListTabClicked);
      }
      
      private function drawMusicNoteIcon(target:Sprite, size:Number) : void
      {
         var icon:Shape = new Shape();
         var g:Graphics = icon.graphics;
         var s:Number = size * 0.85;
         var ox:Number = (size - s) / 2;
         var oy:Number = (size - s) / 2;
         var headR:Number = s * 0.22;
         var headCX:Number = ox + s * 0.32;
         var headCY:Number = oy + s * 0.75;
         g.beginFill(16717424);
         g.drawCircle(headCX,headCY,headR);
         g.endFill();
         g.beginFill(16734878,0.5);
         g.drawCircle(headCX - headR * 0.25,headCY - headR * 0.25,headR * 0.5);
         g.endFill();
         var stemW:Number = s * 0.08;
         var stemX:Number = headCX + headR - stemW;
         var stemTop:Number = oy + s * 0.12;
         var stemBot:Number = headCY - headR * 0.3;
         g.beginFill(16717424);
         g.drawRect(stemX,stemTop,stemW,stemBot - stemTop);
         g.endFill();
         g.beginFill(16717424);
         g.moveTo(stemX + stemW,stemTop);
         g.curveTo(ox + s * 0.85,oy + s * 0.18,ox + s * 0.78,oy + s * 0.38);
         g.curveTo(ox + s * 0.72,oy + s * 0.48,ox + s * 0.62,oy + s * 0.5);
         g.curveTo(ox + s * 0.78,oy + s * 0.35,ox + s * 0.72,oy + s * 0.25);
         g.curveTo(ox + s * 0.68,oy + s * 0.2,stemX + stemW,stemTop + s * 0.1);
         g.lineTo(stemX + stemW,stemTop);
         g.endFill();
         target.addChild(icon);
      }
      
      private function drawMusicListIcon(target:Sprite, size:Number) : void
      {
         var icon:Shape = new Shape();
         var g:Graphics = icon.graphics;
         var s:Number = size * 0.85;
         var ox:Number = (size - s) / 2;
         var oy:Number = (size - s) / 2;
         var barH:Number = s * 0.1;
         var barR:Number = barH / 2;
         var barGap:Number = s * 0.2;
         var barX:Number = ox;
         var barW:Number = s * 0.62;
         var i:int = 0;
         while(i < 4)
         {
            var barY:Number = oy + s * 0.08 + i * barGap;
            g.beginFill(2737654);
            g.drawRoundRect(barX,barY,barW,barH,barR,barR);
            g.endFill();
            i++;
         }
         var nx:Number = ox + s * 0.38;
         var ny:Number = oy;
         var headR:Number = s * 0.22;
         var headCX:Number = nx + s * 0.32;
         var headCY:Number = ny + s * 0.75;
         g.beginFill(16717424);
         g.drawCircle(headCX,headCY,headR);
         g.endFill();
         g.beginFill(16734878,0.5);
         g.drawCircle(headCX - headR * 0.25,headCY - headR * 0.25,headR * 0.5);
         g.endFill();
         var stemW:Number = s * 0.08;
         var stemX:Number = headCX + headR - stemW;
         var stemTop:Number = ny + s * 0.12;
         var stemBot:Number = headCY - headR * 0.3;
         g.beginFill(16717424);
         g.drawRect(stemX,stemTop,stemW,stemBot - stemTop);
         g.endFill();
         g.beginFill(16717424);
         g.moveTo(stemX + stemW,stemTop);
         g.curveTo(nx + s * 0.85,ny + s * 0.18,nx + s * 0.78,ny + s * 0.38);
         g.curveTo(nx + s * 0.72,ny + s * 0.48,nx + s * 0.62,ny + s * 0.5);
         g.curveTo(nx + s * 0.78,ny + s * 0.35,nx + s * 0.72,ny + s * 0.25);
         g.curveTo(nx + s * 0.68,ny + s * 0.2,stemX + stemW,stemTop + s * 0.1);
         g.lineTo(stemX + stemW,stemTop);
         g.endFill();
         target.addChild(icon);
      }
      
      private function createContestButton() : void
      {
         var btnSize:Number = this.orderTab.width * 1.4;
         var centerX:Number = this.orderTab.x + btnSize / 2 - 6;
         var spacing:Number = btnSize + 8;
         var startY:Number = this.orderTab.y + this.orderTab.height + 10 + spacing * 2 + 12;
         this.contestTab = new Sprite();
         var g:Graphics = this.contestTab.graphics;
         g.beginFill(0,0);
         g.drawRect(0,0,btnSize,btnSize);
         g.endFill();
         this.contestTab.buttonMode = true;
         this.contestTab.useHandCursor = true;
         this.contestTab.mouseChildren = false;
         this.contestTab.x = centerX - btnSize / 2;
         this.contestTab.y = startY;
         this.contestTab.name = "contestTab";
         this.drawAnonMicIcon(this.contestTab,btnSize);
         addChild(this.contestTab);
         Connectr.instance.toolTipModel.addTip(this.contestTab,$("مسابقة"));
         this.contestTab.addEventListener(MouseEvent.CLICK,this.contestTabClicked);
      }
      
      private function drawAnonMicIcon(target:Sprite, size:Number) : void
      {
         var icon:Shape = new Shape();
         var g:Graphics = icon.graphics;
         var s:Number = size * 0.75;
         var cx:Number = size / 2;
         var cy:Number = size / 2;
         g.beginFill(16750848);
         g.moveTo(cx - s * 0.3,cy - s * 0.15);
         g.lineTo(cx + s * 0.35,cy - s * 0.38);
         g.lineTo(cx + s * 0.35,cy + s * 0.38);
         g.lineTo(cx - s * 0.3,cy + s * 0.15);
         g.lineTo(cx - s * 0.3,cy - s * 0.15);
         g.endFill();
         g.beginFill(16750848);
         g.drawRect(cx - s * 0.45,cy - s * 0.15,s * 0.18,s * 0.3);
         g.endFill();
         g.beginFill(16750848);
         g.drawRect(cx - s * 0.42,cy + s * 0.15,s * 0.06,s * 0.22);
         g.endFill();
         g.lineStyle(2,16750848,0.7);
         g.moveTo(cx + s * 0.4,cy - s * 0.18);
         g.curveTo(cx + s * 0.55,cy,cx + s * 0.4,cy + s * 0.18);
         g.moveTo(cx + s * 0.45,cy - s * 0.28);
         g.curveTo(cx + s * 0.65,cy,cx + s * 0.45,cy + s * 0.28);
         g.lineStyle();
         target.addChild(icon);
      }
      
      protected function contestTabClicked(param1:MouseEvent) : void
      {
         var chrome:InfoView;
         var selectedType:int;
         var lbl:TextField;
         var lFmt:TextFormat;
         var btn1:Sprite;
         var g1:Graphics;
         var lbl1:TextField;
         var fmt1:TextFormat;
         var btn2:Sprite;
         var g2:Graphics;
         var lbl2:TextField;
         var fmt2:TextFormat;
         var self:BusinessMenu;
         var blueFmt:TextFormat;
         var grayFmt:TextFormat;
         var stFmt:TextFormat;
         var sendBtn:Sprite;
         var sG:Graphics;
         var sendLbl:TextField;
         var sendFmt:TextFormat;
         var vo:PanelVO;
         if(this.contestPanel && this.contestPanel.parent)
         {
            return;
         }
         this.contestPanel = new Sprite();
         chrome = new InfoView();
         this.contestPanel.addChild(chrome);
         chrome.background.height = 200;
         chrome.lbl_Title.text = "اعلان مسابقة";
         chrome.btnClose.addEventListener(MouseEvent.CLICK,this.closeContestPanel);
         chrome.btnOk.visible = false;
         chrome.lblMsg.visible = false;
         selectedType = 0;
         lbl = new TextField();
         lbl.selectable = false;
         lbl.mouseEnabled = false;
         lbl.width = 200;
         lbl.height = 22;
         lbl.x = 50;
         lbl.y = 45;
         lFmt = new TextFormat();
         lFmt.font = "Arial";
         lFmt.size = 12;
         lFmt.bold = true;
         lFmt.color = 3355443;
         lbl.defaultTextFormat = lFmt;
         lbl.text = "اختر نوع المسابقة:";
         this.contestPanel.addChild(lbl);
         btn1 = new Sprite();
         g1 = btn1.graphics;
         g1.lineStyle(1,11184810,1);
         g1.beginFill(16777215);
         g1.drawRoundRect(0,0,130,32,8,8);
         g1.endFill();
         g1.lineStyle();
         btn1.x = 30;
         btn1.y = 75;
         btn1.buttonMode = true;
         btn1.name = "1";
         lbl1 = new TextField();
         lbl1.selectable = false;
         lbl1.mouseEnabled = false;
         lbl1.width = 120;
         lbl1.height = 22;
         lbl1.x = 5;
         lbl1.y = 6;
         fmt1 = new TextFormat();
         fmt1.font = "Arial";
         fmt1.size = 13;
         fmt1.bold = true;
         fmt1.color = 6710886;
         fmt1.align = TextFormatAlign.CENTER;
         lbl1.defaultTextFormat = fmt1;
         lbl1.text = "ضربات";
         btn1.addChild(lbl1);
         this.contestPanel.addChild(btn1);
         btn2 = new Sprite();
         g2 = btn2.graphics;
         g2.lineStyle(1,11184810,1);
         g2.beginFill(16777215);
         g2.drawRoundRect(0,0,130,32,8,8);
         g2.endFill();
         g2.lineStyle();
         btn2.x = 175;
         btn2.y = 75;
         btn2.buttonMode = true;
         btn2.name = "2";
         lbl2 = new TextField();
         lbl2.selectable = false;
         lbl2.mouseEnabled = false;
         lbl2.width = 120;
         lbl2.height = 22;
         lbl2.x = 5;
         lbl2.y = 6;
         fmt2 = new TextFormat();
         fmt2.font = "Arial";
         fmt2.size = 13;
         fmt2.bold = true;
         fmt2.color = 6710886;
         fmt2.align = TextFormatAlign.CENTER;
         lbl2.defaultTextFormat = fmt2;
         lbl2.text = "متنوعة";
         btn2.addChild(lbl2);
         this.contestPanel.addChild(btn2);
         self = this;
         blueFmt = new TextFormat();
         blueFmt.font = "Arial";
         blueFmt.size = 13;
         blueFmt.bold = true;
         blueFmt.color = 3381759;
         blueFmt.align = TextFormatAlign.CENTER;
         grayFmt = new TextFormat();
         grayFmt.font = "Arial";
         grayFmt.size = 13;
         grayFmt.bold = true;
         grayFmt.color = 6710886;
         grayFmt.align = TextFormatAlign.CENTER;
         btn1.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void
         {
            selectedType = 1;
            g1.clear();
            g1.lineStyle(2,3381759,1);
            g1.beginFill(15066597);
            g1.drawRoundRect(0,0,130,32,8,8);
            g1.endFill();
            g1.lineStyle();
            lbl1.setTextFormat(blueFmt);
            g2.clear();
            g2.lineStyle(1,11184810,1);
            g2.beginFill(16777215);
            g2.drawRoundRect(0,0,130,32,8,8);
            g2.endFill();
            g2.lineStyle();
            lbl2.setTextFormat(grayFmt);
         });
         btn2.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void
         {
            selectedType = 2;
            g2.clear();
            g2.lineStyle(2,3381759,1);
            g2.beginFill(15066597);
            g2.drawRoundRect(0,0,130,32,8,8);
            g2.endFill();
            g2.lineStyle();
            lbl2.setTextFormat(blueFmt);
            g1.clear();
            g1.lineStyle(1,11184810,1);
            g1.beginFill(16777215);
            g1.drawRoundRect(0,0,130,32,8,8);
            g1.endFill();
            g1.lineStyle();
            lbl1.setTextFormat(grayFmt);
         });
         this.contestStatusLabel = new TextField();
         this.contestStatusLabel.selectable = false;
         this.contestStatusLabel.mouseEnabled = false;
         this.contestStatusLabel.width = 280;
         this.contestStatusLabel.height = 20;
         this.contestStatusLabel.x = 30;
         this.contestStatusLabel.y = 170;
         stFmt = new TextFormat();
         stFmt.font = "Arial";
         stFmt.size = 11;
         stFmt.color = 10066329;
         stFmt.align = TextFormatAlign.CENTER;
         this.contestStatusLabel.defaultTextFormat = stFmt;
         this.contestStatusLabel.text = "";
         this.contestPanel.addChild(this.contestStatusLabel);
         sendBtn = new Sprite();
         sG = sendBtn.graphics;
         sG.beginFill(16750848);
         sG.drawRoundRect(0,0,120,30,8,8);
         sG.endFill();
         sendBtn.x = 110;
         sendBtn.y = 125;
         sendBtn.buttonMode = true;
         sendLbl = new TextField();
         sendLbl.selectable = false;
         sendLbl.mouseEnabled = false;
         sendLbl.width = 110;
         sendLbl.height = 22;
         sendLbl.x = 5;
         sendLbl.y = 4;
         sendFmt = new TextFormat();
         sendFmt.font = "Arial";
         sendFmt.size = 13;
         sendFmt.bold = true;
         sendFmt.color = 16777215;
         sendFmt.align = TextFormatAlign.CENTER;
         sendLbl.defaultTextFormat = sendFmt;
         sendLbl.text = "ارسال";
         sendBtn.addChild(sendLbl);
         sendBtn.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void
         {
            if(selectedType == 0)
            {
               self.contestStatusLabel.text = "اختر نوع المسابقة اولا!";
               return;
            }
            var roomName:String = Connectr.instance.roomModel.currentRoom.name;
            var senderId:* = Connectr.instance.avatarModel.avatarId;
            Connectr.instance.serviceModel.requestExtension("CAFEADSMARHAB",{
               "room":roomName,
               "type":selectedType,
               "sender":senderId
            },self.onContestResponse);
            self.contestStatusLabel.text = "جاري الارسال...";
         });
         this.contestPanel.addChild(sendBtn);
         vo = new PanelVO("ContestAd",PanelType.HUD);
         this.contestPanel.scaleX = Connectr.instance.scaleModel.uiScale;
         this.contestPanel.scaleY = Connectr.instance.scaleModel.uiScale;
         this.contestPanel.x = (Connectr.instance.layerModel.stage.stageWidth - chrome.background.width * Connectr.instance.scaleModel.uiScale) / 2;
         this.contestPanel.y = (Connectr.instance.layerModel.stage.stageHeight - 200 * Connectr.instance.scaleModel.uiScale) / 2;
         Connectr.instance.layerModel.panelLayer.addChild(this.contestPanel);
      }
      
      private function onContestResponse(param1:Object) : void
      {
         Connectr.instance.serviceModel.removeRequestExtension("CAFEADSMARHAB",this.onContestResponse);
         if(param1 && param1.success)
         {
            if(this.contestStatusLabel)
            {
               this.contestStatusLabel.text = "تم الارسال بنجاح!";
            }
            TweenMax.delayedCall(1.5,this.closeContestPanel);
         }
         else if(this.contestStatusLabel)
         {
            this.contestStatusLabel.text = param1 && param1.message ? String(param1.message) : "فشل الارسال";
         }
      }
      
      private function closeContestPanel(param1:* = null) : void
      {
         this.removeContestPanel();
      }
      
      private function removeContestPanel() : void
      {
         if(this.contestPanel && this.contestPanel.parent)
         {
            this.contestPanel.parent.removeChild(this.contestPanel);
         }
         this.contestPanel = null;
         this.contestStatusLabel = null;
      }
      
      protected function updateOrderCount(param1:OrderEvent = null) : void
      {
         this.bgOrder.visible = true;
         this.txtOrder.visible = true;
         this.txtOrder.text = Connectr.instance.orderModel.orderList.length + "";
      }
      
      protected function passwordTabClicked(param1:MouseEvent) : void
      {
         var _loc2_:OpenRoomChangePasswordCommand = new OpenRoomChangePasswordCommand();
         _loc2_.execute();
      }
      
      protected function infoTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.OPEN_ROOM_INFO);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      protected function orderTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.OPEN_ORDER_PANEL);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      public function init() : void
      {
         this.bgOrder.visible = false;
         this.txtOrder.visible = false;
         var isOwner:Boolean = Connectr.instance.roomModel.ownerId == Connectr.instance.avatarModel.avatarId;
         if(isOwner)
         {
            Dispatcher.addEventListener(OrderEvent.NEW_ORDER,this.updateOrderCount);
            Dispatcher.addEventListener(OrderEvent.TIMEDOUT,this.updateOrderCount);
            Dispatcher.addEventListener(OrderEvent.DELIVERED,this.updateOrderCount);
            Dispatcher.addEventListener(OrderEvent.CANCELLED,this.updateOrderCount);
            Connectr.instance.serviceModel.requestData("orderlist",{},this.onListResponse);
            this.cafeListTab.visible = this.restrictedListTab.visible = this.modifyTab.visible = this.messageTab.visible = this.infoTab.visible = this.passwordTab.visible = this.orderTab.visible = true;
         }
         else
         {
            this.cafeListTab.visible = this.infoTab.visible = true;
            this.restrictedListTab.visible = this.modifyTab.visible = this.messageTab.visible = this.passwordTab.visible = this.orderTab.visible = false;
         }
         if(this.musicTab)
         {
            this.musicTab.visible = isOwner;
         }
         if(this.musicListTab)
         {
            this.musicListTab.visible = isOwner;
         }
         if(this.contestTab)
         {
            this.contestTab.visible = isOwner;
         }
      }
      
      private function onListResponse(param1:Object) : void
      {
         trace("orderListUpdated");
         Connectr.instance.serviceModel.removeRequestData("orderlist",this.onListResponse);
         Connectr.instance.orderModel.orderList = param1.orders;
         this.updateOrderCount();
      }
      
      protected function messageTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.SEND_BUSINESS_MESSAGE);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      protected function restrictedListTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.OPEN_RESTRICTED_LIST_PANEL);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      protected function modifyTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.OPEN_ROOM_DESIGN);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      protected function roomInfoTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.OPEN_ROOM_INFO);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      protected function cafeListTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.OPEN_ROOM_LIST_PANEL);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      protected function musicTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.OPEN_MUSIC_ADD);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      protected function musicListTabClicked(param1:MouseEvent) : void
      {
         this.outEvent = new HudEvent(HudEvent.OPEN_MUSIC_LIST);
         Dispatcher.dispatchEvent(this.outEvent);
      }
      
      override public function removed() : void
      {
         Connectr.instance.toolTipModel.removeTip(this.cafeListTab);
         Connectr.instance.toolTipModel.removeTip(this.modifyTab);
         Connectr.instance.toolTipModel.removeTip(this.messageTab);
         Connectr.instance.toolTipModel.removeTip(this.restrictedListTab);
         Connectr.instance.toolTipModel.removeTip(this.infoTab);
         Connectr.instance.toolTipModel.removeTip(this.passwordTab);
         Connectr.instance.toolTipModel.removeTip(this.orderTab);
         Dispatcher.removeEventListener(OrderEvent.NEW_ORDER,this.updateOrderCount);
         Dispatcher.removeEventListener(OrderEvent.TIMEDOUT,this.updateOrderCount);
         Dispatcher.removeEventListener(OrderEvent.DELIVERED,this.updateOrderCount);
         Dispatcher.removeEventListener(OrderEvent.CANCELLED,this.updateOrderCount);
         this.cafeListTab.removeEventListener(MouseEvent.CLICK,this.cafeListTabClicked);
         this.modifyTab.removeEventListener(MouseEvent.CLICK,this.modifyTabClicked);
         this.messageTab.removeEventListener(MouseEvent.CLICK,this.messageTabClicked);
         this.infoTab.removeEventListener(MouseEvent.CLICK,this.infoTabClicked);
         this.passwordTab.removeEventListener(MouseEvent.CLICK,this.passwordTabClicked);
         this.restrictedListTab.removeEventListener(MouseEvent.CLICK,this.restrictedListTabClicked);
         this.orderTab.removeEventListener(MouseEvent.CLICK,this.orderTabClicked);
         if(this.musicTab)
         {
            Connectr.instance.toolTipModel.removeTip(this.musicTab);
            this.musicTab.removeEventListener(MouseEvent.CLICK,this.musicTabClicked);
         }
         if(this.musicListTab)
         {
            Connectr.instance.toolTipModel.removeTip(this.musicListTab);
            this.musicListTab.removeEventListener(MouseEvent.CLICK,this.musicListTabClicked);
         }
         if(this.contestTab)
         {
            Connectr.instance.toolTipModel.removeTip(this.contestTab);
            this.contestTab.removeEventListener(MouseEvent.CLICK,this.contestTabClicked);
         }
         this.removeContestPanel();
      }
   }
}

