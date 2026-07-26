package org.oyunstudyosu.business
{
   import com.oyunstudyosu.alert.AlertEvent;
   import com.oyunstudyosu.alert.AlertType;
   import com.oyunstudyosu.alert.AlertVo;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.panel.Panel;
   import com.oyunstudyosu.panel.PanelType;
   import com.oyunstudyosu.panel.PanelVO;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import org.oyunstudyosu.alert.buttons.RedButton;
   import org.oyunstudyosu.alert.buttons.YellowButton;
   import org.oyunstudyosu.alert.views.InfoView;
   
   public class MusicListView extends Panel
   {
      
      private var chrome:InfoView;
      
      private var contentContainer:Sprite;
      
      private var contentMask:Shape;
      
      private var isOwner:Boolean;
      
      private var activeButtons:Array;
      
      private var isActionPending:Boolean;
      
      private var scrollY:Number;
      
      private var songCount:int;
      
      private var btnRefresh:YellowButton;
      
      private var autoRefreshTimer:Timer;
      
      private var isRefreshing:Boolean;
      
      public function MusicListView()
      {
         super();
         this.isOwner = Connectr.instance.roomModel.ownerId == Connectr.instance.avatarModel.avatarId;
         this.activeButtons = [];
         this.isActionPending = false;
         this.scrollY = 0;
         this.songCount = 0;
         this.isRefreshing = false;
      }
      
      override public function init() : void
      {
         this.chrome = new InfoView();
         addChild(this.chrome);
         this.chrome.background.height = 300;
         this.panelWidth = int(this.chrome.background.width);
         this.panelHeight = 300;
         var vo:PanelVO = new PanelVO("MusicListView",PanelType.HUD);
         this.data = vo;
         super.init();
         this.buildPanel();
         this.fetchList();
         this.show();
      }
      
      private function buildPanel() : void
      {
         this.chrome.lbl_Title.text = $("Music Queue");
         this.chrome.btnClose.addEventListener(MouseEvent.CLICK,this.onCloseClicked);
         this.chrome.btnOk.visible = false;
         this.chrome.lblMsg.visible = false;
         this.dragHandler = this.chrome.mcDragger;
         var contentX:int = 12;
         var contentY:int = 38;
         var contentW:int = this.panelWidth - 24;
         var contentH:int = this.panelHeight - 80;
         var bg:Shape = new Shape();
         bg.graphics.beginFill(16777215);
         bg.graphics.drawRect(0,0,contentW,contentH + 42);
         bg.graphics.endFill();
         bg.x = contentX;
         bg.y = contentY;
         addChild(bg);
         this.contentContainer = new Sprite();
         this.contentContainer.x = contentX;
         this.contentContainer.y = contentY;
         addChild(this.contentContainer);
         this.contentMask = new Shape();
         this.contentMask.graphics.beginFill(16711680);
         this.contentMask.graphics.drawRect(0,0,contentW,contentH);
         this.contentMask.graphics.endFill();
         this.contentMask.x = contentX;
         this.contentMask.y = contentY;
         addChild(this.contentMask);
         this.contentContainer.mask = this.contentMask;
         this.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         this.btnRefresh = new YellowButton();
         this.btnRefresh.setText($("Refresh"));
         this.btnRefresh.x = (this.panelWidth - this.btnRefresh.width) / 2;
         this.btnRefresh.y = this.panelHeight - 30;
         this.btnRefresh.addEventListener(MouseEvent.CLICK,this.onRefresh);
         addChild(this.btnRefresh);
         Connectr.instance.serviceModel.listenExtension("mediaevent",this.onMediaEvent);
         this.autoRefreshTimer = new Timer(10000);
         this.autoRefreshTimer.addEventListener(TimerEvent.TIMER,this.onAutoRefresh);
         this.autoRefreshTimer.start();
      }
      
      private function fetchList() : void
      {
         this.showLoading();
         this.scrollY = 0;
         Connectr.instance.serviceModel.requestExtension("musicList",{},this.onListResponse);
      }
      
      private function silentRefresh() : void
      {
         if(this.isRefreshing)
         {
            return;
         }
         this.isRefreshing = true;
         Connectr.instance.serviceModel.requestExtension("musicList",{},this.onSilentListResponse);
      }
      
      private function onSilentListResponse(param1:Object) : void
      {
         this.isRefreshing = false;
         Connectr.instance.serviceModel.removeRequestExtension("musicList",this.onSilentListResponse);
         this.clearContent();
         if(param1.errorCode)
         {
            this.showEmptyState($(param1.message));
            return;
         }
         var songs:Array = param1.songs as Array;
         if(songs == null || songs.length == 0)
         {
            this.showEmptyState($("No music in queue"));
            return;
         }
         this.songCount = songs.length;
         this.renderSongs(songs);
      }
      
      private function onMediaEvent(param1:Object) : void
      {
         this.silentRefresh();
      }
      
      private function onAutoRefresh(param1:TimerEvent) : void
      {
         this.silentRefresh();
      }
      
      private function showLoading() : void
      {
         this.clearContent();
         var tf:TextField = new TextField();
         var fmt:TextFormat = new TextFormat();
         fmt.font = "Arial";
         fmt.size = 12;
         fmt.color = 8947848;
         fmt.align = TextFormatAlign.CENTER;
         tf.defaultTextFormat = fmt;
         tf.text = $("Loading...");
         tf.selectable = false;
         tf.mouseEnabled = false;
         tf.width = this.panelWidth - 24;
         tf.height = 24;
         tf.y = 70;
         this.contentContainer.addChild(tf);
      }
      
      private function onListResponse(param1:Object) : void
      {
         Connectr.instance.serviceModel.removeRequestExtension("musicList",this.onListResponse);
         this.clearContent();
         if(param1.errorCode)
         {
            this.showEmptyState($(param1.message));
            return;
         }
         var songs:Array = param1.songs as Array;
         if(songs == null || songs.length == 0)
         {
            this.showEmptyState($("No music in queue"));
            return;
         }
         this.songCount = songs.length;
         this.renderSongs(songs);
      }
      
      private function clearContent() : void
      {
         var i:int = 0;
         while(i < this.activeButtons.length)
         {
            var btn:Sprite = this.activeButtons[i] as Sprite;
            if(btn)
            {
               btn.removeEventListener(MouseEvent.CLICK,this.onSkipClick);
            }
            i++;
         }
         this.activeButtons = [];
         while(this.contentContainer.numChildren > 0)
         {
            this.contentContainer.removeChildAt(0);
         }
         this.contentContainer.y = 38;
      }
      
      private function showEmptyState(msg:String) : void
      {
         var tf:TextField = new TextField();
         var fmt:TextFormat = new TextFormat();
         fmt.font = "Arial";
         fmt.size = 12;
         fmt.color = 8947848;
         fmt.align = TextFormatAlign.CENTER;
         tf.defaultTextFormat = fmt;
         tf.text = msg;
         tf.selectable = false;
         tf.mouseEnabled = false;
         tf.width = this.panelWidth - 24;
         tf.height = 24;
         tf.y = 70;
         this.contentContainer.addChild(tf);
      }
      
      private function renderSongs(songs:Array) : void
      {
         var rowHeight:int = 42;
         var listWidth:int = this.panelWidth - 24;
         var count:int = int(songs.length);
         var i:int = 0;
         while(i < count)
         {
            var song:Object = songs[i];
            var row:Sprite = new Sprite();
            var rg:Graphics = row.graphics;
            var playing:Boolean = Boolean(song.isPlaying);
            if(playing)
            {
               rg.beginFill(9159498,0.15);
               rg.drawRect(0,0,listWidth,rowHeight);
               rg.endFill();
               rg.beginFill(5025616);
               rg.drawRect(0,0,3,rowHeight);
               rg.endFill();
            }
            else
            {
               rg.beginFill(0,i % 2 == 0 ? 0.03 : 0);
               rg.drawRect(0,0,listWidth,rowHeight);
               rg.endFill();
            }
            rg.beginFill(13421772,0.5);
            rg.drawRect(0,rowHeight - 1,listWidth,1);
            rg.endFill();
            if(playing)
            {
               var playIcon:Shape = new Shape();
               playIcon.graphics.beginFill(5025616);
               playIcon.graphics.moveTo(0,0);
               playIcon.graphics.lineTo(0,10);
               playIcon.graphics.lineTo(8,5);
               playIcon.graphics.lineTo(0,0);
               playIcon.graphics.endFill();
               playIcon.x = 8;
               playIcon.y = 16;
               row.addChild(playIcon);
            }
            else
            {
               var numTf:TextField = new TextField();
               var numFmt:TextFormat = new TextFormat();
               numFmt.font = "Arial";
               numFmt.size = 11;
               numFmt.bold = true;
               numFmt.color = 11184810;
               numFmt.align = TextFormatAlign.CENTER;
               numTf.defaultTextFormat = numFmt;
               numTf.text = String(i + 1);
               numTf.selectable = false;
               numTf.mouseEnabled = false;
               numTf.width = 22;
               numTf.height = 18;
               numTf.x = 4;
               numTf.y = 12;
               row.addChild(numTf);
            }
            var titleTf:TextField = new TextField();
            var titleFmt:TextFormat = new TextFormat();
            titleFmt.font = "Arial";
            titleFmt.size = 11;
            titleFmt.color = playing ? 3355443 : 5592405;
            titleFmt.bold = playing;
            titleTf.defaultTextFormat = titleFmt;
            titleTf.text = song.title ? String(song.title) : String(song.url);
            titleTf.selectable = false;
            titleTf.mouseEnabled = false;
            titleTf.width = this.isOwner && playing ? listWidth - 95 : listWidth - 30;
            titleTf.height = 16;
            titleTf.x = 26;
            titleTf.y = 4;
            row.addChild(titleTf);
            var byTf:TextField = new TextField();
            var byFmt:TextFormat = new TextFormat();
            byFmt.font = "Arial";
            byFmt.size = 9;
            byFmt.color = 10066329;
            byTf.defaultTextFormat = byFmt;
            byTf.text = song.addedBy ? String(song.addedBy) : "";
            byTf.selectable = false;
            byTf.mouseEnabled = false;
            byTf.width = this.isOwner && playing ? listWidth - 95 : listWidth - 30;
            byTf.height = 14;
            byTf.x = 26;
            byTf.y = 22;
            row.addChild(byTf);
            if(this.isOwner && playing)
            {
               var actionBtn:RedButton = new RedButton();
               actionBtn.setText(count > 1 ? $("Skip") : $("Stop"));
               actionBtn.scaleX = 0.7;
               actionBtn.scaleY = 0.7;
               actionBtn.x = listWidth - actionBtn.width - 4;
               actionBtn.y = (rowHeight - actionBtn.height) / 2;
               actionBtn.name = "skip_" + String(song.id);
               actionBtn.addEventListener(MouseEvent.CLICK,this.onSkipClick);
               row.addChild(actionBtn);
               this.activeButtons.push(actionBtn);
            }
            row.y = i * rowHeight;
            this.contentContainer.addChild(row);
            i++;
         }
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         var scrollAmount:Number = param1.delta * 12;
         var contentHeight:Number = this.songCount * 42;
         var visibleHeight:Number = this.panelHeight - 80;
         this.scrollY += scrollAmount;
         var minY:Number = -(contentHeight - visibleHeight);
         if(minY > 0)
         {
            minY = 0;
         }
         if(this.scrollY < minY)
         {
            this.scrollY = minY;
         }
         if(this.scrollY > 0)
         {
            this.scrollY = 0;
         }
         this.contentContainer.y = 38 + this.scrollY;
      }
      
      private function onSkipClick(param1:MouseEvent) : void
      {
         if(this.isActionPending)
         {
            return;
         }
         this.isActionPending = true;
         this.showLoading();
         var target:Sprite = param1.currentTarget as Sprite;
         var id:String = target.name.substr(5);
         Connectr.instance.serviceModel.requestExtension("skipMusic",{"id":id},this.onActionResponse);
      }
      
      private function onActionResponse(param1:Object) : void
      {
         this.isActionPending = false;
         Connectr.instance.serviceModel.removeRequestExtension("skipMusic",this.onActionResponse);
         var vo:AlertVo = new AlertVo();
         vo.alertType = AlertType.TOOLTIP;
         vo.description = $(param1.message);
         Dispatcher.dispatchEvent(new AlertEvent(vo));
         this.fetchList();
      }
      
      private function onRefresh(param1:MouseEvent) : void
      {
         this.fetchList();
      }
      
      private function onCloseClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override public function dispose() : void
      {
         this.clearContent();
         this.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         if(this.autoRefreshTimer)
         {
            this.autoRefreshTimer.stop();
            this.autoRefreshTimer.removeEventListener(TimerEvent.TIMER,this.onAutoRefresh);
            this.autoRefreshTimer = null;
         }
         Connectr.instance.serviceModel.removeExtension("mediaevent",this.onMediaEvent);
         if(this.btnRefresh)
         {
            this.btnRefresh.removeEventListener(MouseEvent.CLICK,this.onRefresh);
         }
         if(this.chrome)
         {
            this.chrome.btnClose.removeEventListener(MouseEvent.CLICK,this.onCloseClicked);
         }
         super.dispose();
      }
   }
}

