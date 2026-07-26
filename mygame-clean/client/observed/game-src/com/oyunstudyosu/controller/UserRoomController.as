package com.oyunstudyosu.controller
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.events.BusinessMessageEvent;
   import com.oyunstudyosu.events.Dispatcher;
   import flash.display.DisplayObject;
   import org.oyunstudyosu.business.BusinessMessage;
   
   public class UserRoomController
   {
      
      private var view:BusinessMessage;
      
      private var outEvent:BusinessMessageEvent;
      
      public function UserRoomController()
      {
         super();
         Dispatcher.addEventListener("BusinessMessageEvent.ADD_BUSINESS_MESSAGE",addRoomMessage);
         Dispatcher.addEventListener("BusinessMessageEvent.REMOVE_BUSINESS_MESSAGE",removeRoomMessage);
      }
      
      private function addRoomMessage(param1:BusinessMessageEvent) : void
      {
         CaptureRuntime.sanalikaInstance.layerModel.businessMessageLayer.addChild(param1.view);
         setMessagesIndex();
      }
      
      private function setMessagesIndex() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc3_:int = 0;
         var _loc2_:int = CaptureRuntime.sanalikaInstance.layerModel.businessMessageLayer.numChildren;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = CaptureRuntime.sanalikaInstance.layerModel.businessMessageLayer.getChildAt(_loc3_);
            if(_loc1_ is BusinessMessage)
            {
               _loc1_.x = -(_loc1_.width / 2) + _loc3_ * 10;
               _loc1_.y = -(_loc1_.height / 2) + _loc3_ * 10;
            }
            _loc3_++;
         }
      }
      
      private function removeRoomMessage(param1:BusinessMessageEvent) : void
      {
         if(CaptureRuntime.sanalikaInstance.layerModel.businessMessageLayer.contains(param1.view))
         {
            CaptureRuntime.sanalikaInstance.layerModel.businessMessageLayer.removeChild(param1.view);
            setMessagesIndex();
         }
      }
   }
}

