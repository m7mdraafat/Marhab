package com.oyunstudyosu.commands
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.hurlant.util.Base64;
   import com.oyunstudyosu.assets.AssetModel;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.local.LocalInstanceConfig;
   import com.oyunstudyosu.local.LocalTranslation;
   import flash.display.Stage;
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   
   public class InitParamsCommand extends Command
   {
      
      private var _params:Object;
      
      private var _stage:Stage;
      
      private var _sanalika:Sanalika;
      
      public function InitParamsCommand(param1:Stage, param2:Sanalika)
      {
         super();
         _params = param2.loaderInfo.parameters;
         _sanalika = param2;
         _stage = param1;
         ExternalInterface;
      }
      
      override public function execute() : void
      {
         setParams();
      }
      
      private function setParams() : void
      {
         var _loc1_:String = null;
         var _loc2_:Object = null;
         var _loc3_:String = null;
         trace("RELEASE");
         _loc1_ = _params.d;
         if(Capabilities.playerType == "Desktop" || Capabilities.manufacturer == "Android Linux")
         {
            _loc2_ = _params;
         }
         else
         {
            _loc3_ = CaptureRuntime.sanalikaInstance.stage.loaderInfo.parameters.data;
            if(_loc3_ == null)
            {
               if(ExternalInterface.available)
               {
                  _loc3_ = ExternalInterface.call("Sanalika.getPRM");
               }
            }
            _loc2_ = JSON.parse(Base64.decode(_loc3_));
         }
         CaptureRuntime.sanalikaInstance.gameModel.serverName = _loc2_.serverName;
         CaptureRuntime.sanalikaInstance.gameModel.chatServer = _loc2_.chatServer;
         CaptureRuntime.sanalikaInstance.gameModel.fileServer = _loc2_.fileServer;
         CaptureRuntime.sanalikaInstance.gameModel.webServer = _loc2_.webServer;
         CaptureRuntime.sanalikaInstance.gameModel.firewall = _loc2_.firewall;
         if(_loc2_.protocol)
         {
            CaptureRuntime.sanalikaInstance.gameModel.protocol = _loc2_.protocol;
         }
         CaptureRuntime.sanalikaInstance.gameModel.language = _loc2_.lang;
         if(_loc2_.ad)
         {
            CaptureRuntime.sanalikaInstance.gameModel.agentData = _loc2_.ad;
         }
         CaptureRuntime.sanalikaInstance.avatarModel.accessToken = _loc2_.at;
         CaptureRuntime.sanalikaInstance.avatarModel.avatarId = _loc2_.aId;
         CaptureRuntime.sanalikaInstance.avatarModel.playerId = _loc2_.pId;
         CaptureRuntime.sanalikaInstance.avatarModel.location = _loc2_.location;
         CaptureRuntime.sanalikaInstance.avatarModel.fbToken = _loc2_.fbToken;
         CaptureRuntime.sanalikaInstance.gameModel.itemInfoFile = _loc2_.item;
         CaptureRuntime.sanalikaInstance.gameModel.versionFile = _loc2_.version;
         CaptureRuntime.sanalikaInstance.gameModel.languageFileVersion = _loc2_.locale;
         if(CaptureRuntime.sanalikaInstance.airModel.isAndroid())
         {
            CaptureRuntime.sanalikaInstance.avatarModel.platform = "android";
         }
         else
         {
            CaptureRuntime.sanalikaInstance.avatarModel.platform = "app";
         }
         CaptureRuntime.sanalikaInstance.assetModel = new AssetModel(_stage);
         LocalInstanceConfig.setInstance(CaptureRuntime.sanalikaInstance.gameModel.serverName);
         LocalTranslation.setLanguage(LocalInstanceConfig.get("LANGUAGE"));
         Dispatcher.dispatchEvent(new GameEvent("INITCOMMAND"));
         complete();
      }
   }
}

