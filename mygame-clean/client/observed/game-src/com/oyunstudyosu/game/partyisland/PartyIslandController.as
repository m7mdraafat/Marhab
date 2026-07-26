package com.oyunstudyosu.game.partyisland
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.alert.AlertEvent;
   import com.oyunstudyosu.alert.AlertVo;
   import com.oyunstudyosu.events.Dispatcher;
   
   public class PartyIslandController
   {
      
      public function PartyIslandController()
      {
         super();
         CaptureRuntime.sanalikaInstance.serviceModel.listenExtension("continuePartyIslandGame",continuePartyIslandGame);
      }
      
      private function continuePartyIslandGame(param1:Object) : void
      {
         var _loc2_:AlertVo = new AlertVo();
         _loc2_.alertType = "tooltip";
         _loc2_.description = CaptureRuntime.sanalikaInstance.localizationModel.translate("continuePartyIslandGame");
         Dispatcher.dispatchEvent(new AlertEvent(_loc2_));
      }
   }
}

