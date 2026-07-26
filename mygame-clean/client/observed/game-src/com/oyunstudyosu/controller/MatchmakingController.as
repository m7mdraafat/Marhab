package com.oyunstudyosu.controller
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.HudEvent;
   
   public class MatchmakingController
   {
      
      public function MatchmakingController()
      {
         super();
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("matchmakingStart",onStartMatchmaking);
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("matchmakingCancel",onCancelMatchmaking);
      }
      
      private function onStartMatchmaking(param1:Object) : void
      {
         var _loc2_:HudEvent = new HudEvent("HudEvent.SHOW_MATCHMAKING");
         Dispatcher.dispatchEvent(_loc2_);
         CaptureRuntime.sanalikaInstance.matchmakingModel.isMatchmaking = true;
      }
      
      private function onCancelMatchmaking(param1:Object) : void
      {
         var _loc2_:HudEvent = new HudEvent("HudEvent.HIDE_MATCHMAKING");
         Dispatcher.dispatchEvent(_loc2_);
         CaptureRuntime.sanalikaInstance.matchmakingModel.isMatchmaking = false;
      }
   }
}

