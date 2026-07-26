package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
public class PassageProperty extends Property
   {
      
      public function PassageProperty()
      {
         super();
      }
      
      override public function execute(param1:String = "") : void
      {
         if(data.type == "door")
         {
            return;
         }
         CaptureRuntime.sanalikaInstance.roomModel.doorModel.busy = true;
         CaptureRuntime.sanalikaInstance.roomModel.mapInitalized = false;
         CaptureRuntime.sanalikaInstance.serviceModel.requestData("usedoor",{
            "key":param1,
            "type":data.type
         },null);
      }
   }
}

