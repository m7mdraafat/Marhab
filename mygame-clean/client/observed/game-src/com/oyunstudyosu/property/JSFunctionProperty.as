package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import flash.external.ExternalInterface;
   
   public class JSFunctionProperty extends Property
   {
      
      public function JSFunctionProperty()
      {
         super();
      }
      
      override public function execute(param1:String = "") : void
      {
         trace("ExternalInterface:" + data.functionName + " : " + data.params);
         if(ExternalInterface.available)
         {
            ExternalInterface.call(data.functionName,data.params);
            if(CaptureRuntime.sanalikaInstance.layerModel.stage.displayState == "fullScreen" || CaptureRuntime.sanalikaInstance.layerModel.stage.displayState == "fullScreenInteractive")
            {
               CaptureRuntime.sanalikaInstance.layerModel.stage.displayState = "normal";
            }
         }
      }
   }
}

