package com.oyunstudyosu.controller
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.engine.Shake;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import flash.events.Event;
   
   public class ScreenShakeController
   {
      
      private var xShake:Shake;
      
      private var yShake:Shake;
      
      private var amplitude:int;
      
      public function ScreenShakeController()
      {
         super();
         Dispatcher.addEventListener("TERMINATE_SCENE",onTerminateScene);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("funShake",onShake);
         CaptureRuntime.sanalikaInstance.stage.addEventListener("enterFrame",onEnterFrame);
      }
      
      private function onTerminateScene(param1:GameEvent) : void
      {
         CaptureRuntime.sanalikaInstance.layerModel.masterLayer.x = 0;
         CaptureRuntime.sanalikaInstance.layerModel.masterLayer.y = 0;
      }
      
      private function onShake(param1:Object) : void
      {
         CaptureRuntime.sanalikaInstance.layerModel.masterLayer.x = 0;
         CaptureRuntime.sanalikaInstance.layerModel.masterLayer.y = 0;
         this.amplitude = param1.amplitude;
         xShake = new Shake(param1.duration,param1.frequency);
         xShake.start();
         yShake = new Shake(param1.duration,param1.frequency);
         yShake.start();
      }
      
      public function onEnterFrame(param1:Event) : void
      {
         if(xShake == null || yShake == null || !xShake.isShaking && !yShake.isShaking)
         {
            return;
         }
         xShake.update();
         yShake.update();
         var _loc3_:Number = xShake.amplitude() * amplitude;
         var _loc2_:Number = yShake.amplitude() * amplitude;
         CaptureRuntime.sanalikaInstance.layerModel.masterLayer.x = _loc3_;
         CaptureRuntime.sanalikaInstance.layerModel.masterLayer.y = _loc2_;
      }
   }
}

