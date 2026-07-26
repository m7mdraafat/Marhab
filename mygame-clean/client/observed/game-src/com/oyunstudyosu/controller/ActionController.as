package com.oyunstudyosu.controller
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.engine.scene.components.SceneCharacterComponent;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.HudEvent;
   
   public class ActionController
   {
      
      public function ActionController()
      {
         super();
         Dispatcher.addEventListener("actionFrame",startAction);
         Dispatcher.addEventListener("danceFrame",startDance);
         Dispatcher.addEventListener("idleFrame",startIdle);
      }
      
      private function startIdle(param1:HudEvent) : void
      {
         if(!CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         if(_loc2_.myChar != null)
         {
            CaptureRuntime.sanalikaInstance.serviceModel.setUserVariable(["status"],["i"]);
         }
      }
      
      private function startDance(param1:HudEvent) : void
      {
         if(!CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         if(_loc2_.myChar != null)
         {
            CaptureRuntime.sanalikaInstance.serviceModel.setUserVariable(["status"],["d"]);
         }
      }
      
      private function startAction(param1:HudEvent) : void
      {
         if(!CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc2_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         if(_loc2_.myChar != null)
         {
            CaptureRuntime.sanalikaInstance.serviceModel.setUserVariable(["status"],["a1"]);
         }
      }
   }
}

