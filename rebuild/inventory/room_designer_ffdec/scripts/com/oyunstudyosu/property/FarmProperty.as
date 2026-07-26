package com.oyunstudyosu.property
{
   import com.oyunstudyosu.alert.AlertEvent;
   import com.oyunstudyosu.alert.AlertVo;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.interactive.IEntryVo;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.service.IServiceModel;
   import com.oyunstudyosu.utils.StringUtil;
   import de.polygonal.core.fmt.Sprintf;
   
   public class FarmProperty extends Property
   {
      
      private var serviceModel:IServiceModel;
      
      private var obj:IEntryVo;
      
      private var isStarted:int = 0;
      
      private var alertvo:AlertVo;
      
      public function FarmProperty()
      {
         super();
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc3_:Object = null;
         super.data = param1;
         trace("SETDATA");
         for(var _loc2_ in super.data)
         {
            _loc3_ = super.data[_loc2_];
            trace(_loc2_ + " = " + _loc3_);
         }
         if(data.status)
         {
            if(data.status.leftTime > -data.status.productionTime / 2)
            {
               Sanalika.instance.updateModel.getGroup(1000).addFunction(updateTime);
            }
         }
         else
         {
            data.status = {
               "leftTime":0,
               "productionTime":0,
               "state":"IDLE"
            };
         }
      }
      
      private function updateTime(param1:uint, param2:uint) : void
      {
         var _loc3_:String = null;
         data.status.leftTime--;
         if(data.status.leftTime <= data.status.productionTime / 4 * -1)
         {
            _loc3_ = "DRY";
            Sanalika.instance.updateModel.getGroup(1000).removeFunction(updateTime);
         }
         else if(data.status.leftTime <= 0)
         {
            _loc3_ = "PRODUCT";
         }
         else if(data.status.leftTime <= data.status.productionTime / 2)
         {
            _loc3_ = "SEEDLING";
         }
         else if(data.status.leftTime <= data.status.productionTime)
         {
            _loc3_ = "PLANTED";
         }
         else
         {
            _loc3_ = "IDLE";
         }
         if(_loc3_ != data.status.state)
         {
            if(!obj)
            {
               obj = Sanalika.instance.entryModel.getObjectById(data.metaKey);
            }
            trace("client FrameChanged!!!!!!!!!!!!!!!!!!!!!!!!",data.item.clip + _loc3_);
            data.status.state = _loc3_;
            try
            {
               obj.gotoFrameLabel(data.item.clip + _loc3_);
               if(Sanalika.instance.roomModel.ownerId == Sanalika.instance.avatarModel.avatarId && _loc3_ == "PRODUCT")
               {
                  alertvo = new AlertVo();
                  alertvo.alertType = "tooltip";
                  alertvo.description = $("farmHARVESTREADY") + " | " + $("pro_" + data.item.clip);
                  Dispatcher.dispatchEvent(new AlertEvent(alertvo));
               }
            }
            catch(e:Error)
            {
               trace(e.message);
               trace(e.getStackTrace());
            }
         }
      }
      
      override public function execute(param1:String = "") : void
      {
         trace("FarmPropertyExecute");
         trace("isStarted",isStarted);
         if(isStarted == 1)
         {
            return;
         }
         obj = Sanalika.instance.entryModel.getObjectById(data.metaKey);
         if(Sanalika.instance.roomModel.ownerId == Sanalika.instance.avatarModel.avatarId)
         {
            if(data && data.status)
            {
               trace(JSON.stringify(data.status));
               if(data.status.state == "PRODUCT")
               {
                  alertvo = new AlertVo();
                  alertvo.alertType = "tooltip";
                  alertvo.description = $("farmHARVEST");
                  Dispatcher.dispatchEvent(new AlertEvent(alertvo));
                  Sanalika.instance.serviceModel.requestData("farmgather",{"id":data.metaKey},onHarvestStart);
                  isStarted = 1;
               }
               if(data.status.state == "DRY")
               {
                  Sanalika.instance.serviceModel.requestData("farmclean",{"id":data.metaKey},onCleanStart);
                  isStarted = 1;
               }
               if(data.status.state == "IDLE")
               {
                  alertvo = new AlertVo();
                  alertvo.alertType = "tooltip";
                  alertvo.description = $("farm" + data.status.state);
                  Dispatcher.dispatchEvent(new AlertEvent(alertvo));
               }
               if(data.status.state == "PLANTED" || data.status.state == "SEEDLING")
               {
                  alertvo = new AlertVo();
                  alertvo.alertType = "tooltip";
                  alertvo.description = $("farm" + data.status.state) + " | " + $("pro_" + data.item.clip) + " | " + Sprintf.format($("leftTime"),[StringUtil.secondToString(data.status.leftTime)]);
                  Dispatcher.dispatchEvent(new AlertEvent(alertvo));
               }
            }
            else
            {
               alertvo = new AlertVo();
               alertvo.alertType = "tooltip";
               alertvo.description = $("farmState???");
               Dispatcher.dispatchEvent(new AlertEvent(alertvo));
            }
         }
         else
         {
            alertvo = new AlertVo();
            alertvo.alertType = "tooltip";
            alertvo.description = $("FarmNA");
            Dispatcher.dispatchEvent(new AlertEvent(alertvo));
         }
      }
      
      private function onCleanStart(param1:Object) : void
      {
         var _loc2_:AlertVo = null;
         Sanalika.instance.serviceModel.removeRequestData("farmclean",onCleanStart);
         if(param1.errorCode)
         {
            _loc2_ = new AlertVo();
            _loc2_.alertType = "tooltip";
            _loc2_.description = $(param1.errorCode);
            Dispatcher.dispatchEvent(new AlertEvent(_loc2_));
         }
         isStarted = 0;
      }
      
      private function onHarvestStart(param1:Object) : void
      {
         Sanalika.instance.serviceModel.removeRequestData("farmgather",onHarvestStart);
         isStarted = 0;
      }
      
      override public function dispose() : void
      {
         Sanalika.instance.updateModel.getGroup(1000).removeFunction(updateTime);
         super.dispose();
      }
   }
}

