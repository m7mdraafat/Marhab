package feathers.utils
{
   import feathers.layout.RelativePosition;
   import flash.display.DisplayObject;
   import flash.geom.Rectangle;
   
   public class DPadFocusUtil
   {
      
      public function DPadFocusUtil()
      {
      }
      
      public static function isBetterFocusForRelativePosition(param1:DisplayObject, param2:DisplayObject, param3:Rectangle, param4:RelativePosition) : Boolean
      {
         var _loc5_:Rectangle = param1.getBounds(param1.stage);
         var _loc6_:Number = DPadFocusUtil.calculateMinPrimaryAxisDistanceForRelativePosition(param3,_loc5_,param4);
         if(_loc6_ == Number(Math.POSITIVE_INFINITY))
         {
            return false;
         }
         var _loc7_:Number = DPadFocusUtil.calculateMaxPrimaryAxisDistanceForRelativePosition(param3,_loc5_,param4);
         var _loc8_:Number = DPadFocusUtil.calculateSecondaryAxisDistanceForRelativePosition(param3,_loc5_,param4);
         var _loc9_:Boolean = DPadFocusUtil.itemsAreOnSameAxis(param3,_loc5_,param4);
         var _loc10_:Number = Number(Math.POSITIVE_INFINITY);
         var _loc11_:Number = Number(Math.POSITIVE_INFINITY);
         var _loc12_:Number = Number(Math.POSITIVE_INFINITY);
         var _loc13_:Boolean = false;
         if(param2 != null)
         {
            _loc5_ = param2.getBounds(param2.stage);
            _loc10_ = DPadFocusUtil.calculateMinPrimaryAxisDistanceForRelativePosition(param3,_loc5_,param4);
            _loc11_ = DPadFocusUtil.calculateMaxPrimaryAxisDistanceForRelativePosition(param3,_loc5_,param4);
            _loc12_ = DPadFocusUtil.calculateSecondaryAxisDistanceForRelativePosition(param3,_loc5_,param4);
            _loc13_ = DPadFocusUtil.itemsAreOnSameAxis(param3,_loc5_,param4);
         }
         if(_loc9_ && _loc13_)
         {
            if(_loc6_ > 0)
            {
               return _loc6_ < _loc10_;
            }
            return false;
         }
         var _loc14_:Boolean = param4 == RelativePosition.TOP || param4 == RelativePosition.BOTTOM;
         if(_loc9_)
         {
            if(!_loc14_)
            {
               return true;
            }
            if(_loc6_ > 0 && _loc6_ < _loc11_)
            {
               return true;
            }
         }
         else if(_loc13_)
         {
            if(!_loc14_)
            {
               return false;
            }
            if(_loc10_ > 0 && _loc10_ < _loc7_)
            {
               return false;
            }
         }
         var _loc15_:Number = 13 * _loc6_ * _loc6_ + _loc8_ * _loc8_;
         var _loc16_:Number = 13 * _loc10_ * _loc10_ + _loc12_ * _loc12_;
         return _loc15_ < _loc16_;
      }
      
      public static function calculateSecondaryAxisDistanceForRelativePosition(param1:Rectangle, param2:Rectangle, param3:RelativePosition) : Number
      {
         if(param3 == RelativePosition.TOP || param3 == RelativePosition.BOTTOM)
         {
            return Math.abs(param1.x + param1.width / 2 - (param2.x + param2.width / 2));
         }
         return Math.abs(param1.y + param1.height / 2 - (param2.y + param2.height / 2));
      }
      
      public static function calculateMaxPrimaryAxisDistanceForRelativePosition(param1:Rectangle, param2:Rectangle, param3:RelativePosition) : Number
      {
         var _loc4_:Number = NaN;
         switch(param3.index)
         {
            case 0:
               if(param1.bottom > param2.bottom || param1.y >= param2.bottom)
               {
                  _loc4_ = param1.bottom - param2.y;
                  if(_loc4_ > 0)
                  {
                     return _loc4_;
                  }
               }
               break;
            case 1:
               if(param1.x < param2.x || param1.right <= param2.x)
               {
                  _loc4_ = param2.right - param1.x;
                  if(_loc4_ > 0)
                  {
                     return _loc4_;
                  }
               }
               break;
            case 2:
               if(param1.y < param2.y || param1.bottom <= param2.y)
               {
                  _loc4_ = param2.bottom - param1.y;
                  if(_loc4_ > 0)
                  {
                     return _loc4_;
                  }
               }
               break;
            case 3:
               if(param1.right > param2.right || param1.x >= param2.right)
               {
                  _loc4_ = param1.right - param2.x;
                  if(_loc4_ > 0)
                  {
                     return _loc4_;
                  }
               }
         }
         return Number(Math.POSITIVE_INFINITY);
      }
      
      public static function calculateMinPrimaryAxisDistanceForRelativePosition(param1:Rectangle, param2:Rectangle, param3:RelativePosition) : Number
      {
         var _loc4_:Number = NaN;
         switch(param3.index)
         {
            case 0:
               if(param1.bottom > param2.bottom || param1.y >= param2.bottom)
               {
                  _loc4_ = param1.bottom - param2.bottom;
                  if(_loc4_ > 0)
                  {
                     return _loc4_;
                  }
               }
               break;
            case 1:
               if(param1.x < param2.x || param1.right <= param2.x)
               {
                  _loc4_ = param2.x - param1.x;
                  if(_loc4_ > 0)
                  {
                     return _loc4_;
                  }
               }
               break;
            case 2:
               if(param1.y < param2.y || param1.bottom <= param2.y)
               {
                  _loc4_ = param2.y - param1.y;
                  if(_loc4_ > 0)
                  {
                     return _loc4_;
                  }
               }
               break;
            case 3:
               if(param1.right > param2.right || param1.x >= param2.right)
               {
                  _loc4_ = param1.right - param2.right;
                  if(_loc4_ > 0)
                  {
                     return _loc4_;
                  }
               }
         }
         return Number(Math.POSITIVE_INFINITY);
      }
      
      public static function itemsAreOnSameAxis(param1:Rectangle, param2:Rectangle, param3:RelativePosition) : Boolean
      {
         if(param3 == RelativePosition.TOP || param3 == RelativePosition.BOTTOM)
         {
            if(param1.x <= param2.right)
            {
               return param2.x <= param1.right;
            }
            return false;
         }
         if(param1.y <= param2.bottom)
         {
            return param2.y <= param1.bottom;
         }
         return false;
      }
   }
}

