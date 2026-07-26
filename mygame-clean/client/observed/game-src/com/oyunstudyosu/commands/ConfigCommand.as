package com.oyunstudyosu.commands
{
   import com.oyunstudyosu.capture.CaptureLog;
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.OSProgressEvent;
   import com.oyunstudyosu.progress.ProgressVo;
   import com.oyunstudyosu.service.IServiceModel;
   import com.oyunstudyosu.service.ServiceErrorCode;
   
   public class ConfigCommand extends Command
   {
      
      private var serviceModel:IServiceModel;
      
      public function ConfigCommand()
      {
         super();
         serviceModel = CaptureRuntime.sanalikaInstance.serviceModel;
      }
      
      override public function execute() : void
      {
         serviceModel.requestData("config",{},responseFunction);
      }
      
      private function responseFunction(param1:Object) : void
      {
         trace("data: " + param1);
         trace("string: " + JSON.stringify(param1));
         trace("0");
         CaptureRuntime.sanalikaInstance.buddyModel.moods = param1.moods;
         trace("1");
         CaptureRuntime.sanalikaInstance.chatBalloonModel.activeBalloons = param1.chatBaloons;
         trace("2");
         CaptureRuntime.sanalikaInstance.gameModel.itemInfoFile = "/static/" + param1.itemFile;
         CaptureRuntime.sanalikaInstance.gameModel.versionFile = "/static/" + param1.versionFile;
         CaptureRuntime.sanalikaInstance.gameModel.languageFileVersion = "/static/" + param1.langFile + ".mo";
         var _captureFileServer:String = String(param1.fileServer[0]);
         while(_captureFileServer.indexOf("http://") == 0)
         {
            _captureFileServer = _captureFileServer.substr(7);
         }
         while(_captureFileServer.indexOf("https://") == 0)
         {
            _captureFileServer = _captureFileServer.substr(8);
         }
         CaptureRuntime.sanalikaInstance.gameModel.fileServer = _captureFileServer + "/global";
         var _captureConfigFileServer:Object = new Object();
         _captureConfigFileServer.rawFileServer = String(param1.fileServer[0]);
         _captureConfigFileServer.protocol = String(CaptureRuntime.sanalikaInstance.gameModel.protocol);
         _captureConfigFileServer.storedFileServer = _captureFileServer + "/global";
         _captureConfigFileServer.fileServer = CaptureRuntime.sanalikaInstance.gameModel.fileServer;
         _captureConfigFileServer.itemInfoFile = CaptureRuntime.sanalikaInstance.gameModel.itemInfoFile;
         _captureConfigFileServer.versionFile = CaptureRuntime.sanalikaInstance.gameModel.versionFile;
         _captureConfigFileServer.languageFileVersion = CaptureRuntime.sanalikaInstance.gameModel.languageFileVersion;
         CaptureLog.write("config.fileServer",_captureConfigFileServer);
         CaptureRuntime.sanalikaInstance.gameModel.webServer = param1.webServer;
         CaptureRuntime.sanalikaInstance.gameModel.firewall = "ACTIVE";
         CaptureRuntime.sanalikaInstance.gameModel.language = param1.language;
         trace("3");
         CaptureRuntime.sanalikaInstance.gameModel.farmCleaningCost = param1.farmCleaningCost;
         CaptureRuntime.sanalikaInstance.gameModel.farmMaxPlantedItemSize = param1.farmMaxPlantedItemSize;
         CaptureRuntime.sanalikaInstance.gameModel.avatarOrderLifeTime = param1.order.avatarOrderLifeTime;
         CaptureRuntime.sanalikaInstance.gameModel.orderLifeTime = param1.order.orderLifeTime;
         CaptureRuntime.sanalikaInstance.gameModel.prepareLifeTime = param1.order.prepareLifeTime;
         trace("4");
         if(param1.roomTheme)
         {
            CaptureRuntime.sanalikaInstance.gameModel.roomTheme = param1.roomTheme;
         }
         trace("devam 1");
         ServiceErrorCode.setData(param1.masterRoles);
         trace("devam 2");
         CaptureLog.write("config.ready",{});
         complete();
         try
         {
            Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.CONFIG_READY));
         }
         catch(_captureProgressError:*)
         {
            CaptureLog.write("config.progress.error",{"message":String(_captureProgressError)});
         }
         serviceModel = null;
      }
   }
}

