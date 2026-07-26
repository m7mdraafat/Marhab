package com.oyunstudyosu.model
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class WalkModel
   {
      
      private var walkTimeout:uint = 0;
      
      public function WalkModel()
      {
         super();
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("walkrequest",onWalkStart);
      }
      
      private function onWalkStart(param1:Object) : void
      {
         if(param1.delay != null)
         {
            clearTimeout(walkTimeout);
            walkTimeout = setTimeout(walkTimerComplete,parseInt(param1.delay));
         }
      }
      
      private function walkTimerComplete() : void
      {
         CaptureRuntime.sanalikaInstance.serviceModel.requestData("walkfinalrequest",{},null);
      }
   }
}

