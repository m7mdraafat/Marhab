package com.oyunstudyosu.game.partyisland.components
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.engine.IScene;
   import com.oyunstudyosu.engine.scene.components.BaseSceneComponent;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.game.partyisland.PartyPlayerVo;
   import com.smartfoxserver.v2.entities.Room;
   import org.oyunstudyosu.game.partyisland.LobbyUI;
   import org.oyunstudyosu.game.partyisland.LobbyUIItem;
   
   public class IslandLobbyComponent extends BaseSceneComponent
   {
      
      public var initialized:Boolean = false;
      
      public var lobbyUI:LobbyUI;
      
      public function IslandLobbyComponent(param1:IScene)
      {
         super(param1);
         Dispatcher.addEventListener("SCENE_LOADED",sceneLoaded);
      }
      
      public function sceneLoaded(param1:GameEvent) : void
      {
         initialized = true;
         lobbyUI = new LobbyUI();
         lobbyUI.maxUsers = CaptureRuntime.sanalikaInstance.roomModel.currentRoom.maxUsers;
         CaptureRuntime.sanalikaInstance.layerModel.hudLayer.addChildAt(lobbyUI,0);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("partyIsland.startGameTimer",onStartGameTimer);
         CaptureRuntime.sanalikaInstance.serviceModel.listenRoomVariable("isGameStarted",onGameStarted);
         Dispatcher.addEventListener("UI_SCALE_CHANGED",onUpdateUI);
         Dispatcher.addEventListener("RESIZE",onUpdateUI);
         onUpdateUI();
         checkGameStarted();
      }
      
      private function onUpdateUI(param1:Object = null) : void
      {
         lobbyUI.scaleX = lobbyUI.scaleY = CaptureRuntime.sanalikaInstance.scaleModel.uiScale;
         lobbyUI.x = CaptureRuntime.sanalikaInstance.layerModel.canvasWidth / 2 - lobbyUI.container.width * CaptureRuntime.sanalikaInstance.scaleModel.uiScale / 2;
         lobbyUI.y = CaptureRuntime.sanalikaInstance.layerModel.canvasHeight / 2 - lobbyUI.container.height * CaptureRuntime.sanalikaInstance.scaleModel.uiScale / 2;
         trace("lobbyUI.x: " + lobbyUI.x);
         trace("lobbyUI.y: " + lobbyUI.y);
      }
      
      private function onGameStarted(param1:Room) : void
      {
         checkGameStarted();
      }
      
      private function checkGameStarted() : void
      {
         var _loc1_:IslandServiceComponent = scene.getComponent(IslandServiceComponent) as IslandServiceComponent;
         if(_loc1_ != null && _loc1_.isGameStarted())
         {
            dispose();
         }
      }
      
      private function onStartGameTimer(param1:Object) : void
      {
         lobbyUI.setTimer(param1.timeout);
      }
      
      public function add(param1:PartyPlayerVo) : void
      {
         if(isDisposed)
         {
            return;
         }
         lobbyUI.setTimer(0);
         var _loc2_:LobbyUIItem = new LobbyUIItem();
         _loc2_.name = param1.character.id;
         _loc2_.init(param1);
         lobbyUI.add(_loc2_);
      }
      
      public function remove(param1:PartyPlayerVo) : void
      {
         if(isDisposed)
         {
            return;
         }
         lobbyUI.setTimer(0);
         var _loc2_:LobbyUIItem = lobbyUI.container.getChildByName(param1.character.id) as LobbyUIItem;
         if(_loc2_ != null)
         {
            lobbyUI.remove(_loc2_);
         }
      }
      
      public function setJoinStatus(param1:Object) : void
      {
         if(!initialized)
         {
            return;
         }
         var _loc3_:Array = param1.players;
         for each(var _loc2_ in _loc3_)
         {
            lobbyUI.updateStatus(_loc2_.avatarId,_loc2_.isJoinComplete);
         }
      }
      
      override public function dispose() : void
      {
         if(isDisposed)
         {
            return;
         }
         CaptureRuntime.sanalikaInstance.serviceModel.removeExtension("partyIsland.startGameTimer",onStartGameTimer);
         CaptureRuntime.sanalikaInstance.serviceModel.removeRoomVariable("isGameStarted",onGameStarted);
         Dispatcher.removeEventListener("UI_SCALE_CHANGED",onUpdateUI);
         Dispatcher.removeEventListener("RESIZE",onUpdateUI);
         Dispatcher.removeEventListener("SCENE_LOADED",sceneLoaded);
         CaptureRuntime.sanalikaInstance.layerModel.hudLayer.removeChild(lobbyUI);
         isDisposed = true;
      }
   }
}

