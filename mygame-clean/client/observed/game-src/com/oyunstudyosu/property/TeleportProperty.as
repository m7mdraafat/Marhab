package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
public class TeleportProperty extends Property
   {
      
      public function TeleportProperty()
      {
         super();
      }
      
      override public function execute(param1:String = "") : void
      {
         CaptureRuntime.sanalikaInstance.serviceModel.requestData("teleport",{"roomKey":data.roomKey},null);
         CaptureRuntime.sanalikaInstance.roomModel.doorModel.busy = true;
         CaptureRuntime.sanalikaInstance.roomModel.mapInitalized = false;
      }
   }
}

