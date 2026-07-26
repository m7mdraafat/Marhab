package feathers.utils
{
   import feathers.core.IFocusContainer;
   import feathers.core.IFocusExtras;
   import feathers.core.IFocusObject;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   
   public class FocusUtil
   {
      
      public function FocusUtil()
      {
      }
      
      public static function findAllFocusableObjects(param1:DisplayObject, param2:Array = undefined) : Array
      {
         var _loc3_:* = null as IFocusObject;
         var _loc4_:* = null as IFocusExtras;
         var _loc5_:* = null as Array;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:* = null as DisplayObject;
         var _loc10_:* = null as DisplayObjectContainer;
         if(param2 == null)
         {
            param2 = [];
         }
         if(param1 is IFocusObject)
         {
            _loc3_ = param1;
            if(_loc3_.get_focusEnabled())
            {
               param2.push(_loc3_);
            }
         }
         if(param1 is IFocusExtras)
         {
            _loc4_ = param1;
            _loc5_ = _loc4_.get_focusExtrasBefore();
            if(_loc5_ != null)
            {
               _loc6_ = 0;
               _loc7_ = int(_loc5_.length);
               while(_loc6_ < _loc7_)
               {
                  _loc8_ = _loc6_++;
                  _loc9_ = _loc5_[_loc8_];
                  FocusUtil.findAllFocusableObjects(_loc9_,param2);
               }
            }
         }
         if(param1 is IFocusObject)
         {
            if(param1 is IFocusContainer && param1.get_childFocusEnabled())
            {
               _loc10_ = param1;
               _loc6_ = 0;
               _loc7_ = _loc10_.numChildren;
               while(_loc6_ < _loc7_)
               {
                  _loc8_ = _loc6_++;
                  _loc9_ = _loc10_.getChildAt(_loc8_);
                  FocusUtil.findAllFocusableObjects(_loc9_,param2);
               }
            }
         }
         else if(param1 is DisplayObjectContainer)
         {
            _loc10_ = param1;
            _loc6_ = 0;
            _loc7_ = _loc10_.numChildren;
            while(_loc6_ < _loc7_)
            {
               _loc8_ = _loc6_++;
               _loc9_ = _loc10_.getChildAt(_loc8_);
               FocusUtil.findAllFocusableObjects(_loc9_,param2);
            }
         }
         if(param1 is IFocusExtras)
         {
            _loc4_ = param1;
            _loc5_ = _loc4_.get_focusExtrasAfter();
            if(_loc5_ != null)
            {
               _loc6_ = 0;
               _loc7_ = int(_loc5_.length);
               while(_loc6_ < _loc7_)
               {
                  _loc8_ = _loc6_++;
                  _loc9_ = _loc5_[_loc8_];
                  FocusUtil.findAllFocusableObjects(_loc9_,param2);
               }
            }
         }
         return param2;
      }
   }
}

