package com.oyunstudyosu.map.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.alert.AlertEvent;
   import com.oyunstudyosu.alert.AlertVo;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.events.YouTubePlayerEvent;
   import com.oyunstudyosu.timer.SyncTimer;
   import com.smartfoxserver.v2.entities.Room;
   import com.smartfoxserver.v2.entities.data.ISFSObject;
   import feathers.controls.Button;
   import feathers.controls.Label;
   import feathers.controls.LayoutGroup;
   import feathers.controls.Panel;
   import feathers.controls.TextInput;
   import feathers.core.PopUpManager;
   import feathers.events.TriggerEvent;
   import feathers.layout.AnchorLayout;
   import feathers.layout.AnchorLayoutData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class YoutubeScreenProperty extends MapProperty
   {
      
      private var lastRoomVideoData:Object;
      
      public var youtubeLinkButton:Sprite;
      
      public function YoutubeScreenProperty()
      {
         super();
         trace("YoutubeSceenProperty::new");
      }
      
      override public function execute() : void
      {
         trace("YoutubeSceenPropert:executey");
         Dispatcher.addEventListener("SCENE_LOADED",onSceneLoaded);
      }
      
      private function onSceneLoaded(param1:GameEvent) : void
      {
         var alertvo:AlertVo;
         var room:Room;
         var e:GameEvent = param1;
         trace("YoutubeSceenProperty:onSceneLoaded");
         alertvo = new AlertVo();
         alertvo.alertType = "tooltip";
         alertvo.description = "YouTube feature may not work properly in this version of sanalika, if you want to view youtube feature, access the game from sanalika.com";
         alertvo.callBack = function(param1:*):*
         {
            navigateToURL(new URLRequest(CaptureRuntime.sanalikaInstance.gameModel.webServer),"_blank");
         };
         alertvo.sound = true;
         Dispatcher.dispatchEvent(new AlertEvent(alertvo));
         youtubeLinkButton = new Sprite();
         youtubeLinkButton.graphics.beginFill(16711680);
         youtubeLinkButton.graphics.drawRect(0,0,35,35);
         youtubeLinkButton.graphics.endFill();
         youtubeLinkButton.visible = CaptureRuntime.sanalikaInstance.roomModel.ownerId == CaptureRuntime.sanalikaInstance.avatarModel.avatarId;
         youtubeLinkButton.addEventListener("click",onYoutubeLinkButtonClick);
         CaptureRuntime.sanalikaInstance.layerModel.gameLayer.addChildAt(youtubeLinkButton,1);
         Dispatcher.addEventListener("ready",onYouTubePlayerReady);
         CaptureRuntime.sanalikaInstance.serviceModel.listenRoomVariable("roomVideoData",onRoomVideoData);
         room = CaptureRuntime.sanalikaInstance.roomModel.currentRoom;
         onRoomVideoData(room);
         if(CaptureRuntime.sanalikaInstance.youtubeModel.isReady == true)
         {
            processPlayerLocation();
         }
         CaptureRuntime.sanalikaInstance.stage.addEventListener("enterFrame",onEnterFrame);
      }
      
      private function onYoutubeLinkButtonClick(param1:MouseEvent) : void
      {
         var header:LayoutGroup;
         var message:Label;
         var footer:LayoutGroup;
         var textInput:TextInput;
         var watchButton:Button;
         var closeButton:Button;
         var e:MouseEvent = param1;
         var popUp:Panel = new Panel();
         popUp.layout = new AnchorLayout();
         header = new LayoutGroup();
         header.variant = LayoutGroup.VARIANT_TOOL_BAR;
         popUp.header = header;
         message = new Label();
         message.text = CaptureRuntime.sanalikaInstance.localizationModel.translate("Youtube Video Player");
         message.layoutData = AnchorLayoutData.center();
         header.addChild(message);
         footer = new LayoutGroup();
         footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
         popUp.footer = footer;
         textInput = new TextInput();
         textInput.prompt = CaptureRuntime.sanalikaInstance.localizationModel.translate("Enter a YouTube video");
         footer.addChild(textInput);
         watchButton = new Button();
         watchButton.text = "Watch";
         watchButton.addEventListener(TriggerEvent.TRIGGER,function(param1:TriggerEvent):*
         {
            CaptureRuntime.sanalikaInstance.serviceModel.requestData("startroomvideo",{"videoUrl":textInput.text},null);
            PopUpManager.removePopUp(popUp);
         });
         footer.addChild(watchButton);
         closeButton = new Button();
         closeButton.text = "Close";
         closeButton.addEventListener(TriggerEvent.TRIGGER,function(param1:TriggerEvent):*
         {
            PopUpManager.removePopUp(popUp);
         });
         footer.addChild(closeButton);
         PopUpManager.addPopUp(popUp,CaptureRuntime.sanalikaInstance);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:int = this.entry.width;
         var _loc4_:Number = this.entry.height;
         var _loc5_:int = this.entry.x;
         var _loc3_:int = this.entry.y;
         youtubeLinkButton.x = (_loc5_ + _loc2_) * CaptureRuntime.sanalikaInstance.scaleModel.currentScale;
         youtubeLinkButton.y = (_loc3_ + _loc4_ + 10) * CaptureRuntime.sanalikaInstance.scaleModel.currentScale;
      }
      
      private function onYouTubePlayerReady(param1:YouTubePlayerEvent) : void
      {
         processPlayerLocation();
         processVideoData();
      }
      
      private function onRoomVideoData(param1:Room) : void
      {
         var _loc2_:ISFSObject = null;
         if(param1.containsVariable("roomVideoData") == false)
         {
            lastRoomVideoData = null;
            processVideoData();
         }
         else
         {
            _loc2_ = param1.getVariable("roomVideoData").getSFSObjectValue();
            lastRoomVideoData = _loc2_.toObject();
            processVideoData();
         }
      }
      
      private function processPlayerLocation() : void
      {
         var _loc1_:int = this.entry.width;
         var _loc3_:Number = this.entry.height;
         var _loc4_:int = this.entry.x;
         var _loc2_:int = this.entry.y;
         CaptureRuntime.sanalikaInstance.youtubeModel.player.superWidth = _loc1_;
         CaptureRuntime.sanalikaInstance.youtubeModel.player.superHeight = _loc3_;
         CaptureRuntime.sanalikaInstance.youtubeModel.player.superX = _loc4_;
         CaptureRuntime.sanalikaInstance.youtubeModel.player.superY = _loc2_;
         CaptureRuntime.sanalikaInstance.youtubeModel.player.visible = true;
      }
      
      private function processVideoData(param1:Boolean = true) : void
      {
         if(CaptureRuntime.sanalikaInstance.youtubeModel.isReady == false)
         {
            return;
         }
         if(lastRoomVideoData == null)
         {
            clearVideo();
         }
         else
         {
            CaptureRuntime.sanalikaInstance.youtubeModel.player.loadVideoById(lastRoomVideoData.videoId,SyncTimer.timestamp - lastRoomVideoData.videoStartTimestamp,"default");
         }
      }
      
      private function clearVideo() : void
      {
         if(CaptureRuntime.sanalikaInstance.youtubeModel.isReady == true)
         {
            CaptureRuntime.sanalikaInstance.youtubeModel.player.loadVideoById("",0,"default");
            CaptureRuntime.sanalikaInstance.youtubeModel.player.stopVideo();
         }
      }
      
      override public function dispose() : void
      {
         if(youtubeLinkButton != null)
         {
            CaptureRuntime.sanalikaInstance.layerModel.gameLayer.removeChild(youtubeLinkButton);
         }
         Dispatcher.removeEventListener("SCENE_LOADED",onSceneLoaded);
         Dispatcher.removeEventListener("ready",onYouTubePlayerReady);
         if(CaptureRuntime.sanalikaInstance.youtubeModel.isReady == true)
         {
            lastRoomVideoData = null;
            processVideoData();
            CaptureRuntime.sanalikaInstance.youtubeModel.player.visible = false;
         }
         CaptureRuntime.sanalikaInstance.serviceModel.removeRoomVariable("roomVideoData",onRoomVideoData);
         CaptureRuntime.sanalikaInstance.stage.removeEventListener("enterFrame",onEnterFrame);
         super.dispose();
      }
   }
}

