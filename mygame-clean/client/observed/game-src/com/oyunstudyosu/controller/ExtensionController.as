package com.oyunstudyosu.controller
{
      import com.oyunstudyosu.capture.CaptureRuntime;
public class ExtensionController
   {
      
      public function ExtensionController()
      {
         super();
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("startextension",onStartExtension);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("stopextension",onStopExtension);
      }
      
      protected function onStartExtension(param1:Object) : void
      {
         trace("startextension:" + JSON.stringify(param1));
         if(CaptureRuntime.sanalikaInstance.extensionModel.getExtensionByName(param1.key))
         {
            trace("Extension already loaded!");
            CaptureRuntime.sanalikaInstance.extensionModel.removeExtension(param1.key);
         }
         CaptureRuntime.sanalikaInstance.extensionModel.loadExtension(param1.key,param1.property,0);
      }
      
      protected function onStopExtension(param1:Object) : void
      {
         trace("onStopExtension");
         CaptureRuntime.sanalikaInstance.extensionModel.removeExtension(param1.key);
      }
   }
}

