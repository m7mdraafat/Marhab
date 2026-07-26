package com.oyunstudyosu.engine.scene.components
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.engine.IScene;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.HudEvent;
   
   public class SceneZoomComponent extends BaseSceneComponent
   {
      
      public function SceneZoomComponent(param1:IScene)
      {
         super(param1);
         Dispatcher.addEventListener("HudEvent.ZOOM_IN",onGestureZoom);
         Dispatcher.addEventListener("HudEvent.ZOOM_OUT",onGestureZoom);
      }
      
      private function onGestureZoom(param1:HudEvent) : void
      {
         if(CaptureRuntime.sanalikaInstance.scaleModel.enabled)
         {
            if(CaptureRuntime.sanalikaInstance.scaleModel.isLandscape)
            {
            }
            if(param1.type == "HudEvent.ZOOM_OUT")
            {
               if(CaptureRuntime.sanalikaInstance.airModel.isMobile())
               {
                  CaptureRuntime.sanalikaInstance.scaleModel.currentScale -= 0.5;
               }
               else
               {
                  CaptureRuntime.sanalikaInstance.scaleModel.currentScale -= 0.1;
               }
            }
            else if(CaptureRuntime.sanalikaInstance.airModel.isMobile())
            {
               CaptureRuntime.sanalikaInstance.scaleModel.currentScale += 0.5;
            }
            else
            {
               CaptureRuntime.sanalikaInstance.scaleModel.currentScale += 0.1;
            }
         }
      }
      
      override public function dispose() : void
      {
         isDisposed = true;
         Dispatcher.removeEventListener("HudEvent.ZOOM_IN",onGestureZoom);
         Dispatcher.removeEventListener("HudEvent.ZOOM_OUT",onGestureZoom);
      }
   }
}

