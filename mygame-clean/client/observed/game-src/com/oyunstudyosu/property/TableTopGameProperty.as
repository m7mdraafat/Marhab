package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.panel.PanelVO;
   
   public class TableTopGameProperty extends Property
   {
      
      public function TableTopGameProperty()
      {
         super();
      }
      
      override public function execute(param1:String = "") : void
      {
         trace("TableTopGameProperty");
         var _loc2_:PanelVO = new PanelVO("GamePanel");
         _loc2_.type = "room";
         _loc2_.params = data;
         _loc2_.params.typeKey = param1;
         CaptureRuntime.sanalikaInstance.panelModel.openPanel(_loc2_);
      }
   }
}

