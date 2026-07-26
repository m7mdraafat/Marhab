package com.oyunstudyosu.property
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.interactive.IEntryVo;
   
   public class FlatEnterProperty extends Property
   {
      
      private var obj:IEntryVo;
      
      private var dataCount:int;
      
      private var mapData:Array;
      
      private var busy:Boolean;
      
      public function FlatEnterProperty()
      {
         super();
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
      }
      
      override public function execute(param1:String = "") : void
      {
         trace("FlatEnterPropertyExecute");
         dataCount = 0;
         mapData = [];
         CaptureRuntime.sanalikaInstance.roomModel.buildingData = data;
         CaptureRuntime.sanalikaInstance.roomModel.mapInitalized = false;
         busy = true;
         CaptureRuntime.sanalikaInstance.serviceModel.requestData("useobjectdoor",{"id":data.metaKey},onChange);
      }
      
      private function onChange(param1:Object) : void
      {
         CaptureRuntime.sanalikaInstance.serviceModel.removeRequestData("useobjectdoor",onChange);
         CaptureRuntime.sanalikaInstance.roomModel.checkMap(param1);
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
   }
}

