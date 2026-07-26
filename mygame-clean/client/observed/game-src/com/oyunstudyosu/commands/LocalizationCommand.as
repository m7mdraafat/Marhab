package com.oyunstudyosu.commands
{
   import com.oyunstudyosu.capture.CaptureLog;
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.OSProgressEvent;
   import com.oyunstudyosu.local.LocalizationModel;
   import com.oyunstudyosu.model.ToolTipModel;
   import com.oyunstudyosu.progress.ProgressVo;
   import flash.events.Event;
   
   public class LocalizationCommand extends Command
   {
      
      public function LocalizationCommand()
      {
         super();
      }
      
      override public function execute() : void
      {
         CaptureLog.write("startup.localization.execute",{});
         CaptureRuntime.sanalikaInstance.localizationModel = new LocalizationModel();
         CaptureRuntime.sanalikaInstance.toolTipModel = new ToolTipModel();
         Dispatcher.addEventListener("LOCALIZATION_DATA_READY",onComplete);
         var _loc1_:Object = {};
         _loc1_.stage = CaptureRuntime.sanalikaInstance.layerModel.stage;
         _loc1_.toolTipModel = CaptureRuntime.sanalikaInstance.toolTipModel;
         _loc1_.language = CaptureRuntime.sanalikaInstance.gameModel.language;
         _loc1_.fileServer = CaptureRuntime.sanalikaInstance.gameModel.fileServer;
         _loc1_.version = CaptureRuntime.sanalikaInstance.gameModel.languageFileVersion;
         CaptureLog.write("startup.localization.start",{"language":_loc1_.language,"fileServer":_loc1_.fileServer,"version":_loc1_.version});
         CaptureRuntime.sanalikaInstance.localizationModel.init(_loc1_);
      }
      
      public function onComplete(param1:Event) : void
      {
         CaptureLog.write("startup.localization.complete",{});
         complete();
         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.LANG_FILE_READY));
      }
   }
}

