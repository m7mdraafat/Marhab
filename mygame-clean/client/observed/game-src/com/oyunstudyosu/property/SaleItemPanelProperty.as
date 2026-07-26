package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.panel.PanelVO;
   
   public class SaleItemPanelProperty extends PanelProperty
   {
      
      public function SaleItemPanelProperty()
      {
         super();
      }
      
      override public function execute(param1:String = "") : void
      {
         var _loc2_:PanelVO = new PanelVO("SaleItemPanel");
         _loc2_.type = "static";
         _loc2_.params = data;
         _loc2_.params.botKey = param1;
         CaptureRuntime.sanalikaInstance.panelModel.openPanel(_loc2_);
      }
   }
}

