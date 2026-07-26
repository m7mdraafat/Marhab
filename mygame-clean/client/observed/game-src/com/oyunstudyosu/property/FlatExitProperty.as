package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
public class FlatExitProperty extends Property
   {
      
      public function FlatExitProperty()
      {
         super();
      }
      
      override public function execute(param1:String = "") : void
      {
         CaptureRuntime.sanalikaInstance.roomModel.doorModel.busy = true;
         CaptureRuntime.sanalikaInstance.roomModel.mapInitalized = false;
         CaptureRuntime.sanalikaInstance.serviceModel.requestData("usedoor",{
            "key":param1,
            "type":data.type
         },null);
      }
   }
}

