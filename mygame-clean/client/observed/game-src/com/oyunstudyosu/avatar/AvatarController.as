package com.oyunstudyosu.avatar
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.greensock.TweenMax;
   import com.oyunstudyosu.alert.AlertEvent;
   import com.oyunstudyosu.alert.AlertVo;
   import com.oyunstudyosu.door.IDoorVO;
   import com.oyunstudyosu.door.IProperty;
   import com.oyunstudyosu.engine.ICharacter;
   import com.oyunstudyosu.engine.core.Cell;
   import com.oyunstudyosu.engine.pool.GamePool;
   import com.oyunstudyosu.engine.scene.components.SceneCharacterComponent;
   import com.oyunstudyosu.engine.scene.components.SceneDoorComponent;
   import com.oyunstudyosu.events.CharacterEvent;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.events.OrderEvent;
   import com.oyunstudyosu.events.ProfileEvent;
   import com.oyunstudyosu.events.WalkEvent;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.panel.PanelVO;
   import com.oyunstudyosu.property.ThrowProperty;
   import com.smartfoxserver.v2.entities.User;
   import com.smartfoxserver.v2.entities.variables.UserVariable;
   import extensions.admin.Teleportation;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.getDefinitionByName;
   import flash.utils.setInterval;
   
   public class AvatarController
   {
      
      private var handItemProperty:IProperty;
      
      private var stickerPicker:Sprite;
      
      private var _stickerPickerW:int = 0;
      
      private var _stickerPickerH:int = 0;
      
      public function AvatarController()
      {
         super();
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("smiley",onSmileyUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("clothes",onClothesUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("avatarSize",onAvatarSizeUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("avatarName",onUserNameUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("gender",onGenderUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("hand",onHandItemUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("direction",onDirectionUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("position",onPositionUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("speed",onSpeedUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("roles",onAvatarRoleUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("status",onStatusUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("poolVars",onPoolVarsUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("target",onTargetPositionUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("universeKey",currentUniverseUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("fbPermissions",onFbPermission);
         CaptureRuntime.sanalikaInstance.serviceModel.listenUserVariable("tp",onTypingUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("updateWallet",updateWallet);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("avatarLikeUpdated",avatarLikeUpdated);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("roles",onRoleUpdate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("moderatorNotice",onModeratorNotice);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("teleport",onTeleport);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("usehanditem",onHandItem);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("throwItem",onThrow);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("throwHit",onHitNotice);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("treasure",onTreasure);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("reLocate",onReLocate);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("stickerShow",onStickerShow);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("stickerlist",onStickerList);
         Dispatcher.addEventListener("openStickerPicker",onOpenStickerPicker);
         Dispatcher.addEventListener("AvatarProfileEvent.SHOW_PROFILE",showProfilePanel);
         Dispatcher.addEventListener("AvatarProfileEvent.BLOCK",blockUser);
         Dispatcher.addEventListener("AvatarProfileEvent.UNBLOCK",unBlockUser);
         Dispatcher.addEventListener("AvatarProfileEvent.DISLIKED",dislikeUser);
         Dispatcher.addEventListener("AvatarProfileEvent.LIKED",likeUser);
         Dispatcher.addEventListener("AvatarProfileEvent.LIKEREMOVED",likeremovedUser);
         Dispatcher.addEventListener("OrderEvent.OPEN_ORDER",openGameOrderRequestPanel);
         Dispatcher.addEventListener("CharacterEvent.CHAR_SIT",onSit);
         Dispatcher.addEventListener("updateWalk",onWalkComplete);
         CaptureRuntime.sanalikaInstance.avatarModel.stepCount = 0;
         CaptureRuntime.sanalikaInstance.avatarModel.giftCount = 0;
         setInterval(ping,60000);
         ThrowProperty;
      }
      
      private function ping() : void
      {
         CaptureRuntime.sanalikaInstance.serviceModel.requestData("ping",{},null);
      }
      
      public function removeHandItemProperty() : void
      {
         if(handItemProperty)
         {
            handItemProperty.dispose();
            handItemProperty = null;
         }
      }
      
      private function onHandItem(param1:Object) : void
      {
         var _loc2_:Class = null;
         if(param1.property)
         {
            try
            {
               _loc2_ = getDefinitionByName("com.oyunstudyosu.property." + param1.property.cn) as Class;
            }
            catch(error:Error)
            {
               trace("No class found named" + param1.property.cn);
               return;
            }
            handItemProperty = new _loc2_();
            handItemProperty.execute();
         }
         else
         {
            removeHandItemProperty();
         }
      }
      
      private function onTeleport(param1:Object) : void
      {
         if(param1.errorCode != undefined)
         {
            CaptureRuntime.sanalikaInstance.roomModel.doorModel.busy = false;
            return;
         }
         CaptureRuntime.sanalikaInstance.roomModel.checkMap(param1);
      }
      
      private function onWalkComplete(param1:WalkEvent = null) : void
      {
         CaptureRuntime.sanalikaInstance.avatarModel.stepCount += int(param1.stepCount * (Math.random() * 5));
         CaptureRuntime.sanalikaInstance.hudModel.setQuestIndicator(CaptureRuntime.sanalikaInstance.avatarModel.stepCount);
      }
      
      protected function onSit(param1:CharacterEvent) : void
      {
         if(CaptureRuntime.sanalikaInstance.roomModel.ownerId != CaptureRuntime.sanalikaInstance.avatarModel.avatarId && CaptureRuntime.sanalikaInstance.roomModel.roomName != null && (CaptureRuntime.sanalikaInstance.roomModel.type == "CAFE" || CaptureRuntime.sanalikaInstance.roomModel.type == "GARAGE"))
         {
            if(CaptureRuntime.sanalikaInstance.orderModel.orderRequest)
            {
               if(CaptureRuntime.sanalikaInstance.orderModel.orderRequest.status != "DELIVERED")
               {
                  Dispatcher.dispatchEvent(new OrderEvent("OrderEvent.OPEN_ORDER"));
               }
            }
         }
      }
      
      protected function openGameOrderRequestPanel(param1:OrderEvent) : void
      {
         var _loc2_:PanelVO = new PanelVO();
         _loc2_.name = "GameOrderRequestPanel";
         _loc2_.params = {};
         _loc2_.params.avatarId = param1.avatarID;
         CaptureRuntime.sanalikaInstance.panelModel.openPanel(_loc2_);
      }
      
      private function updateWallet(param1:Object) : void
      {
         CaptureRuntime.sanalikaInstance.avatarModel.reasonWallet(param1.reason);
         CaptureRuntime.sanalikaInstance.avatarModel.updateWallet(param1.wallet);
      }
      
      private function avatarLikeUpdated(param1:Object) : void
      {
         var _loc2_:ProfileEvent = null;
         if(param1.status == 1)
         {
            _loc2_ = new ProfileEvent("AvatarProfileEvent.LIKED");
            _loc2_.avatarID = param1.avatarID.toString();
            _loc2_.status = param1.status;
            Dispatcher.dispatchEvent(_loc2_);
         }
         else if(param1.status == 0)
         {
            _loc2_ = new ProfileEvent("AvatarProfileEvent.DISLIKED");
            _loc2_.avatarID = param1.avatarID.toString();
            _loc2_.status = param1.status;
            Dispatcher.dispatchEvent(_loc2_);
         }
         else
         {
            _loc2_ = new ProfileEvent("AvatarProfileEvent.LIKEREMOVED");
            _loc2_.avatarID = param1.avatarID.toString();
            _loc2_.status = param1.status;
            Dispatcher.dispatchEvent(_loc2_);
         }
      }
      
      private function blockUser(param1:ProfileEvent) : void
      {
         CaptureRuntime.sanalikaInstance.avatarModel.blockUser(param1.avatarID);
      }
      
      private function unBlockUser(param1:ProfileEvent) : void
      {
         CaptureRuntime.sanalikaInstance.avatarModel.removeBlock(param1.avatarID);
      }
      
      private function dislikeUser(param1:ProfileEvent) : void
      {
         CaptureRuntime.sanalikaInstance.avatarModel.dislikeUser(param1.avatarID);
      }
      
      private function likeUser(param1:ProfileEvent) : void
      {
         CaptureRuntime.sanalikaInstance.avatarModel.likeUser(param1.avatarID);
      }
      
      private function likeremovedUser(param1:ProfileEvent) : void
      {
         CaptureRuntime.sanalikaInstance.avatarModel.likeremovedUser(param1.avatarID);
      }
      
      private function onRoleUpdate(param1:Object) : void
      {
         if(CaptureRuntime.sanalikaInstance.avatarModel.permission.value == param1.roles)
         {
            return;
         }
         CaptureRuntime.sanalikaInstance.avatarModel.permission.value = param1.roles;
         if(CaptureRuntime.sanalikaInstance.avatarModel.permission.check(20))
         {
            new Teleportation("CTRL+SHIFT+Y");
            trace("--------------------TELEPORT--------------------------");
         }
      }
      
      protected function onAvatarRoleUpdate(param1:Object) : void
      {
         var _loc4_:User = param1 as User;
         if(_loc4_ == null)
         {
            return;
         }
         if(CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc3_:ICharacter = _loc2_.getAvatarById(_loc4_.name);
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_.setRoles(_loc4_.getVariable("roles").getStringValue());
      }
      
      protected function onThrow(param1:Object) : void
      {
         trace("movie" + param1.yTarget);
         trace("movie" + param1.xTarget);
         trace("movie" + param1.x);
         trace("movie" + param1.y);
      }
      
      protected function onHitNotice(param1:Object) : void
      {
         var _loc2_:AlertVo = new AlertVo();
         _loc2_.alertType = "tooltip";
         _loc2_.description = "Hit! " + param1.avatarID;
         Dispatcher.dispatchEvent(new AlertEvent(_loc2_));
      }
      
      protected function onTreasure(param1:Object) : void
      {
         var _loc2_:AlertVo = new AlertVo();
         _loc2_.alertType = "tooltip";
         _loc2_.description = "Treasure Found! " + param1.avatarID;
         if(param1.giftType == "OBJECT")
         {
            _loc2_.description = $("Treasure Found!") + " " + param1.avatarName + " | " + $("pro_" + param1.clip) + " | " + param1.universe + "@" + param1.room;
         }
         else
         {
            _loc2_.description = $("Treasure Found!") + " " + param1.avatarName + " | " + param1.amount + " " + param1.giftType + " | " + param1.universe + "@" + param1.room;
         }
         Dispatcher.dispatchEvent(new AlertEvent(_loc2_));
      }
      
      protected function onReLocate(param1:Object) : void
      {
         var _loc2_:SceneCharacterComponent = null;
         var _loc4_:ICharacter = null;
         var _loc3_:String = param1.avatarId.toString();
         if(CaptureRuntime.sanalikaInstance.engine.scene != null && CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            _loc2_ = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
            _loc4_ = _loc2_.getAvatarById(_loc3_);
            if(_loc4_ != null)
            {
               _loc4_.reLocate(param1.x,param1.y,param1.direction);
            }
         }
      }
      
      protected function onModeratorNotice(param1:Object) : void
      {
         var _loc2_:AlertVo = new AlertVo();
         _loc2_.alertType = "Warning";
         _loc2_.title = "!!! " + $("Warning") + " !!!";
         _loc2_.description = $(param1.message) + "<br> REPID:" + param1.reporterID;
         Dispatcher.dispatchEvent(new AlertEvent(_loc2_));
      }
      
      private function check(param1:User) : ICharacter
      {
         if(param1 == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return null;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         if(param1.isItMe)
         {
            return null;
         }
         return _loc2_.getAvatarById(param1.name);
      }
      
      private function checkAll(param1:User) : ICharacter
      {
         if(param1 == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return null;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         return _loc2_.getAvatarById(param1.name);
      }
      
      protected function onFbPermission(param1:Object) : void
      {
         var _loc2_:User = param1 as User;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.isItMe)
         {
            CaptureRuntime.sanalikaInstance.avatarModel.fbPermission = _loc2_.getVariable("fbPermissions").getStringValue();
         }
      }
      
      protected function currentUniverseUpdate(param1:Object) : void
      {
         var _loc2_:User = param1 as User;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.isItMe)
         {
            CaptureRuntime.sanalikaInstance.avatarModel.universe = _loc2_.getVariable("universeKey").getStringValue();
         }
      }
      
      protected function onTargetPositionUpdate(param1:Object) : void
      {
         var _loc12_:Array = null;
         var _loc11_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:Cell = null;
         var _loc9_:IDoorVO = null;
         var _loc13_:SceneDoorComponent = null;
         var _loc10_:* = null;
         var _loc14_:User = param1 as User;
         if(_loc14_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc3_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc4_:ICharacter = _loc3_.getAvatarById(_loc14_.name);
         if(_loc4_ == null)
         {
            return;
         }
         var _loc7_:UserVariable = _loc14_.getVariable("speed");
         if(_loc7_ != null)
         {
            _loc4_.speed = _loc7_.getDoubleValue();
         }
         var _loc5_:UserVariable = _loc14_.getVariable("target");
         if(_loc5_ != null)
         {
            _loc12_ = _loc5_.getStringValue().split(",");
            if(_loc12_.length == 2)
            {
               _loc11_ = int(parseInt(_loc12_[0]));
               _loc8_ = int(parseInt(_loc12_[1]));
               if(_loc14_.isItMe)
               {
                  trace("onTargetPositionUpdate: " + _loc11_ + "," + _loc8_);
                  _loc6_ = CaptureRuntime.sanalikaInstance.engine.scene.getCellAt(_loc11_,0,_loc8_);
                  _loc9_ = CaptureRuntime.sanalikaInstance.roomModel.doorModel.getDoor(_loc11_,_loc8_);
                  if(_loc9_ != null)
                  {
                     _loc13_ = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneDoorComponent) as SceneDoorComponent;
                     _loc10_ = null;
                     if(_loc13_ != null)
                     {
                        for each(var _loc2_ in _loc13_.doorList)
                        {
                           if(_loc2_.name == _loc9_.key)
                           {
                              _loc10_ = _loc2_;
                           }
                        }
                     }
                     _loc4_.walk(_loc11_,_loc8_,_loc10_);
                  }
                  else
                  {
                     _loc4_.walk(_loc11_,_loc8_);
                  }
               }
               else
               {
                  _loc4_.walk(_loc11_,_loc8_);
               }
            }
         }
      }
      
      protected function onPoolVarsUpdate(param1:Object) : void
      {
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc2_:GamePool = null;
         var _loc6_:User = param1 as User;
         var _loc3_:ICharacter = check(_loc6_);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:UserVariable = _loc6_.getVariable("poolVars");
         if(_loc4_)
         {
            _loc5_ = _loc4_.getStringValue();
            if(_loc5_ != null)
            {
               _loc7_ = _loc5_.split(",")[0];
               _loc2_ = CaptureRuntime.sanalikaInstance.engine.scene.elementsContainer.getChildByName(_loc7_) as GamePool;
               if(_loc2_ != null)
               {
                  _loc2_.updateItem(_loc6_.name,_loc5_);
               }
            }
         }
      }
      
      protected function onStatusUpdate(param1:Object) : void
      {
         var _loc4_:User = param1 as User;
         if(CaptureRuntime.sanalikaInstance.engine.scene == null)
         {
            return;
         }
         var _loc2_:ICharacter = checkAll(_loc4_);
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.action = null;
         var _loc3_:UserVariable = _loc4_.getVariable("status");
         if(_loc3_ != null)
         {
            trace("setDance");
            _loc2_.setAction(_loc3_.getStringValue());
         }
         else
         {
            _loc2_.setAction(null);
         }
      }
      
      protected function onSpeedUpdate(param1:Object) : void
      {
         var _loc5_:User = param1 as User;
         if(_loc5_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc3_:ICharacter = _loc2_.getAvatarById(_loc5_.name);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:UserVariable = _loc5_.getVariable("speed");
         if(_loc4_ != null)
         {
         }
      }
      
      protected function onPositionUpdate(param1:Object) : void
      {
         var _loc4_:GameEvent = null;
         var _loc2_:Array = null;
         var _loc7_:User = param1 as User;
         if(_loc7_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc3_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc5_:ICharacter = _loc3_.getAvatarById(_loc7_.name);
         if(_loc5_ == null)
         {
            return;
         }
         if(_loc7_.isItMe)
         {
            _loc4_ = new GameEvent("USER_POSITION_UPDATED");
            _loc4_.id = _loc7_.name;
            Dispatcher.dispatchEvent(_loc4_);
         }
         var _loc6_:UserVariable = _loc7_.getVariable("position");
         if(_loc6_ != null)
         {
            _loc2_ = _loc6_.getStringValue().split(",");
            if(_loc2_.length == 2)
            {
            }
         }
      }
      
      protected function onDirectionUpdate(param1:Object) : void
      {
         var _loc5_:User = param1 as User;
         if(_loc5_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc3_:ICharacter = _loc2_.getAvatarById(_loc5_.name);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:UserVariable = _loc5_.getVariable("direction");
         if(_loc4_ != null && (_loc3_.status == "i" || _loc3_.status == "ac"))
         {
            _loc3_.direction = _loc4_.getIntValue();
            _loc3_.setStatus(_loc3_.status,_loc3_.direction);
         }
      }
      
      protected function onHandItemUpdate(param1:Object) : void
      {
         var _loc5_:User = param1 as User;
         if(_loc5_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc3_:ICharacter = _loc2_.getAvatarById(_loc5_.name);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:UserVariable = _loc5_.getVariable("hand");
         if(_loc4_ != null)
         {
            _loc3_.useHandItem(_loc4_.getStringValue());
         }
         else
         {
            _loc3_.useHandItem("0");
         }
      }
      
      protected function onGenderUpdate(param1:Object) : void
      {
         var _loc2_:User = param1 as User;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.isItMe)
         {
            CaptureRuntime.sanalikaInstance.avatarModel.gender = _loc2_.getVariable("gender").getStringValue();
         }
      }
      
      protected function onOpenStickerPicker(param1:Event) : void
      {
         CaptureRuntime.sanalikaInstance.serviceModel.requestData("stickerlist",{},null);
      }
      
      protected function onStickerList(param1:Object) : void
      {
         var raw:*;
         var _loc2_:Array;
         var n:int;
         var _si_:int;
         var emptyVo:AlertVo;
         var bg:Sprite;
         var cols:int;
         var cell:int;
         var pad:int;
         var rows:int;
         var w:int;
         var h:int;
         var closeBtn:Sprite;
         var baseUrl:String;
         var _loc3_:int;
         var entry:Object;
         var stickerIdStr:String;
         var fname:String;
         var slot:Sprite;
         var ldr:Loader;
         var ctx:LoaderContext;
         if(param1.errorCode != null)
         {
            return;
         }
         raw = param1.stickers;
         if(raw is Array)
         {
            _loc2_ = raw as Array;
         }
         else if(raw != null && raw.hasOwnProperty("size") && raw.hasOwnProperty("getSFSObject"))
         {
            _loc2_ = [];
            n = int(raw.size());
            _si_ = 0;
            while(_si_ < n)
            {
               _loc2_.push(raw.getSFSObject(_si_).toObject());
               _si_++;
            }
         }
         else
         {
            _loc2_ = null;
         }
         if(_loc2_ == null || _loc2_.length == 0)
         {
            emptyVo = new AlertVo();
            emptyVo.alertType = "tooltip";
            emptyVo.description = $("No stickers available yet.");
            Dispatcher.dispatchEvent(new AlertEvent(emptyVo));
            return;
         }
         try
         {
            if(this.stickerPicker != null && this.stickerPicker.parent != null)
            {
               this.stickerPicker.parent.removeChild(this.stickerPicker);
            }
            this.stickerPicker = new Sprite();
            bg = new Sprite();
            cols = 5;
            cell = 56;
            pad = 8;
            rows = int(Math.ceil(_loc2_.length / cols));
            if(rows < 1)
            {
               rows = 1;
            }
            w = cols * cell + pad * 2;
            h = rows * cell + pad * 2 + 24;
            bg.graphics.beginFill(16119285,0.96);
            bg.graphics.drawRoundRect(0,0,w,h,14);
            bg.graphics.endFill();
            this.stickerPicker.addChild(bg);
            closeBtn = new Sprite();
            closeBtn.graphics.beginFill(15277667);
            closeBtn.graphics.drawCircle(0,0,10);
            closeBtn.graphics.endFill();
            closeBtn.x = w - 14;
            closeBtn.y = 14;
            closeBtn.buttonMode = true;
            closeBtn.addEventListener(MouseEvent.CLICK,onStickerPickerClose);
            this.stickerPicker.addChild(closeBtn);
            baseUrl = CaptureRuntime.sanalikaInstance.gameModel.fileServer + "/static/items/Stickers/";
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               entry = _loc2_[_loc3_];
               stickerIdStr = String(entry.id);
               fname = String(entry.filename);
               slot = new Sprite();
               slot.name = "sticker_" + stickerIdStr;
               slot.x = pad + _loc3_ % cols * cell;
               slot.y = pad + 24 + int(_loc3_ / cols) * cell;
               slot.buttonMode = true;
               slot.graphics.beginFill(16777215,0.001);
               slot.graphics.drawRect(0,0,cell,cell);
               slot.graphics.endFill();
               slot.addEventListener(MouseEvent.CLICK,onStickerPicked);
               ldr = new Loader();
               ctx = new LoaderContext();
               ctx.checkPolicyFile = true;
               ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,(function(loader:Loader):Function
               {
                  return function(e:Event):void
                  {
                     try
                     {
                        loader.width = cell - 8;
                        loader.height = cell - 8;
                        loader.x = 4;
                        loader.y = 4;
                     }
                     catch(e2:Error)
                     {
                     }
                  };
               })(ldr));
               ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void
               {
               });
               ldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function(e:SecurityErrorEvent):void
               {
               });
               try
               {
                  ldr.load(new URLRequest(baseUrl + fname),ctx);
               }
               catch(eL:Error)
               {
               }
               slot.addChild(ldr);
               this.stickerPicker.addChild(slot);
               _loc3_++;
            }
            if(CaptureRuntime.sanalikaInstance.layerModel == null || CaptureRuntime.sanalikaInstance.layerModel.panelLayer == null)
            {
               return;
            }
            CaptureRuntime.sanalikaInstance.layerModel.panelLayer.addChild(this.stickerPicker);
            this._stickerPickerW = w;
            this._stickerPickerH = h;
            this.layoutStickerPicker();
            Dispatcher.addEventListener("RESIZE",onStickerPickerResize);
         }
         catch(eBuild:Error)
         {
         }
      }
      
      private function layoutStickerPicker() : void
      {
         if(this.stickerPicker == null)
         {
            return;
         }
         var sw:Number = CaptureRuntime.sanalikaInstance.layerModel.stage.stageWidth;
         var sh:Number = CaptureRuntime.sanalikaInstance.layerModel.stage.stageHeight;
         var s:Number = CaptureRuntime.sanalikaInstance.scaleModel != null ? Number(CaptureRuntime.sanalikaInstance.scaleModel.uiScale) : 1;
         if(isNaN(s) || s <= 0)
         {
            s = 1;
         }
         var maxScaleW:Number = sw * 0.9 / this._stickerPickerW;
         var maxScaleH:Number = sh * 0.9 / this._stickerPickerH;
         var maxScale:Number = maxScaleW < maxScaleH ? maxScaleW : maxScaleH;
         if(s > maxScale)
         {
            s = maxScale;
         }
         if(s < 0.4)
         {
            s = 0.4;
         }
         this.stickerPicker.scaleX = s;
         this.stickerPicker.scaleY = s;
         this.stickerPicker.x = (sw - this._stickerPickerW * s) / 2;
         this.stickerPicker.y = (sh - this._stickerPickerH * s) / 2;
      }
      
      private function onStickerPickerResize(param1:Event) : void
      {
         this.layoutStickerPicker();
      }
      
      private function onStickerPickerClose(param1:MouseEvent) : void
      {
         Dispatcher.removeEventListener("RESIZE",onStickerPickerResize);
         if(this.stickerPicker != null && this.stickerPicker.parent != null)
         {
            this.stickerPicker.parent.removeChild(this.stickerPicker);
         }
         this.stickerPicker = null;
      }
      
      private function onStickerPicked(param1:MouseEvent) : void
      {
         var slot:Sprite = param1.currentTarget as Sprite;
         if(slot == null)
         {
            return;
         }
         var n:String = slot.name;
         var id:int = 0;
         if(n != null && n.length > 8)
         {
            id = int(n.substr(8));
         }
         if(id <= 0)
         {
            return;
         }
         CaptureRuntime.sanalikaInstance.serviceModel.requestData("usesticker",{"id":id},null);
         this.onStickerPickerClose(null);
      }
      
      protected function onStickerShow(param1:Object) : void
      {
         var senderID:String;
         var filename:String;
         var comp:SceneCharacterComponent;
         var ch:ICharacter;
         var baseUrl:String;
         var ldr:Loader;
         var ctx:LoaderContext;
         var targetCh:ICharacter;
         if(param1.errorCode != null)
         {
            return;
         }
         if(CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         senderID = param1.sender;
         filename = param1.filename;
         if(senderID == null || filename == null)
         {
            return;
         }
         comp = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         ch = comp.getAvatarById(senderID);
         if(ch == null || ch.container == null)
         {
            return;
         }
         baseUrl = CaptureRuntime.sanalikaInstance.gameModel.fileServer + "/static/items/Stickers/";
         ldr = new Loader();
         ctx = new LoaderContext();
         ctx.checkPolicyFile = true;
         targetCh = ch;
         ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void
         {
            ldr.width = 42;
            ldr.height = 42;
            ldr.x = -21;
            ldr.y = -110;
            ldr.alpha = 0;
            if(targetCh != null && targetCh.container != null)
            {
               targetCh.container.addChild(ldr);
               TweenMax.to(ldr,0.25,{"alpha":1});
               TweenMax.delayedCall(2.5,function():void
               {
                  TweenMax.to(ldr,0.5,{
                     "alpha":0,
                     "onComplete":function():void
                     {
                        if(targetCh != null && targetCh.container != null && targetCh.container.contains(ldr))
                        {
                           targetCh.container.removeChild(ldr);
                        }
                     }
                  });
               });
            }
         });
         ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void
         {
         });
         ldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function(e:SecurityErrorEvent):void
         {
         });
         try
         {
            ldr.load(new URLRequest(baseUrl + filename),ctx);
         }
         catch(e:Error)
         {
         }
      }
      
      protected function showProfilePanel(param1:ProfileEvent) : void
      {
         var _loc2_:PanelVO = new PanelVO();
         _loc2_.name = "ProfilePanel";
         _loc2_.type = "hud";
         _loc2_.params = {};
         _loc2_.params.avatarId = param1.avatarID;
         CaptureRuntime.sanalikaInstance.panelModel.openPanel(_loc2_);
      }
      
      protected function onAvatarSizeUpdate(param1:Object) : void
      {
         var _loc4_:User = param1 as User;
         if(_loc4_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         if(_loc4_.isItMe)
         {
            CaptureRuntime.sanalikaInstance.avatarModel.avatarSize = _loc4_.getVariable("avatarSize").getDoubleValue();
         }
         var _loc3_:ICharacter = _loc2_.getAvatarById(_loc4_.name);
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_.avatarSize = _loc4_.getVariable("avatarSize").getDoubleValue();
      }
      
      protected function onUserNameUpdate(param1:Object) : void
      {
         var _loc3_:User = param1 as User;
         var _loc2_:ICharacter = check(_loc3_);
         if(_loc3_.isItMe)
         {
            CaptureRuntime.sanalikaInstance.avatarModel.avatarName = _loc3_.getVariable("avatarName").getStringValue();
         }
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.avatarName = _loc3_.getVariable("avatarName").getStringValue();
      }
      
      protected function onSmileyUpdate(param1:Object) : void
      {
         var _loc4_:User = param1 as User;
         if(_loc4_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc3_:ICharacter = _loc2_.getAvatarById(_loc4_.name);
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc4_.isItMe)
         {
            CaptureRuntime.sanalikaInstance.avatarModel.smileyKey = _loc4_.getVariable("smiley").getStringValue();
         }
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_.setSmiley(_loc4_.getVariable("smiley").getStringValue());
      }
      
      protected function onTypingUpdate(param1:Object) : void
      {
         var _loc4_:User = param1 as User;
         if(_loc4_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc3_:ICharacter = _loc2_.getAvatarById(_loc4_.name);
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc4_.isItMe)
         {
            CaptureRuntime.sanalikaInstance.avatarModel.tp = _loc4_.getVariable("tp").getValue();
         }
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc4_.getVariable("tp").getValue() == 1)
         {
            _loc3_.tp = 1;
         }
         else
         {
            _loc3_.tp = 0;
         }
      }
      
      protected function onClothesUpdate(param1:Object) : void
      {
         var _loc6_:* = null;
         var _loc7_:User = param1 as User;
         if(_loc7_ == null || CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc4_:ICharacter = _loc2_.getAvatarById(_loc7_.name);
         if(_loc4_ == null)
         {
            return;
         }
         var _loc5_:UserVariable = _loc7_.getVariable("clothes");
         var _loc3_:Array = JSON.parse(_loc5_.getStringValue()) as Array;
         _loc4_.setAccesory(_loc3_);
         if(_loc7_.isItMe)
         {
            CaptureRuntime.sanalikaInstance.avatarModel.clothesOn = _loc3_;
         }
      }
   }
}

