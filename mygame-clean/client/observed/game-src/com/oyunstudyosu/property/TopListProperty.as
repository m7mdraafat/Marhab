package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.panel.PanelVO;
   
   public class TopListProperty extends Property
   {
      
      public function TopListProperty()
      {
         super();
      }
      
      override public function execute(param1:String = "") : void
      {
         trace("TopListProperty");
         var _loc2_:PanelVO = new PanelVO();
         _loc2_.name = "TopListPanel";
         _loc2_.params = data;
         CaptureRuntime.sanalikaInstance.panelModel.openPanel(_loc2_);
      }
   }
}

