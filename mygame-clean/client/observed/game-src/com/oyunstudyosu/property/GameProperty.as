package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.alert.AlertVo;
   import com.oyunstudyosu.panel.PanelVO;
   
   public class GameProperty extends Property
   {
      
      private var vo:AlertVo;
      
      public function GameProperty()
      {
         super();
      }
      
      override public function execute(param1:String = "") : void
      {
         trace("GameProperty");
         var _loc2_:PanelVO = new PanelVO();
         _loc2_.name = "GamePanel";
         _loc2_.params = data;
         CaptureRuntime.sanalikaInstance.panelModel.openPanel(_loc2_);
      }
   }
}

