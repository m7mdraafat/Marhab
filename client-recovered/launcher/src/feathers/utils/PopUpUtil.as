package feathers.utils
{
   import feathers.core.IPopUpManager;
   import feathers.core.PopUpManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   
   public class PopUpUtil
   {
      
      public function PopUpUtil()
      {
      }
      
      public static function isTopLevelPopUpOrIsContainedByTopLevelPopUp(param1:DisplayObject) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:* = null as DisplayObject;
         var _loc7_:* = null as DisplayObjectContainer;
         if(param1.stage == null)
         {
            return false;
         }
         var _loc2_:IPopUpManager = PopUpManager.forStage(param1.stage);
         var _loc3_:int = _loc2_.get_popUpCount() - _loc2_.get_topLevelPopUpCount();
         var _loc4_:int = _loc2_.get_popUpCount();
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            _loc6_ = _loc2_.getPopUpAt(_loc5_);
            if(param1 == _loc6_)
            {
               return true;
            }
            if(_loc6_ is DisplayObjectContainer)
            {
               _loc7_ = _loc6_;
               if(_loc7_.contains(param1))
               {
                  return true;
               }
            }
         }
         return false;
      }
   }
}

