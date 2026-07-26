package feathers.utils
{
   import feathers.utils._ScreenDensityScaleCalculator.ScreenDensityBucket;
   import flash.Boot;
   import flash.errors.IllegalOperationError;
   
   public class ScreenDensityScaleCalculator
   {
      
      public var _buckets:Array;
      
      public function ScreenDensityScaleCalculator()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _buckets = [];
      }
      
      public function removeScaleForDensity(param1:Number) : void
      {
         var _loc4_:* = null as ScreenDensityBucket;
         var _loc2_:int = 0;
         var _loc3_:Array = _buckets;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            if(_loc4_.density == param1)
            {
               _buckets.remove(_loc4_);
               return;
            }
         }
      }
      
      public function getScale(param1:Number) : Number
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         if(int(_buckets.length) == 0)
         {
            throw new IllegalOperationError("Cannot choose scale because none have been added");
         }
         var _loc2_:ScreenDensityBucket = _buckets[0];
         if(param1 <= _loc2_.density)
         {
            return _loc2_.scale;
         }
         var _loc3_:ScreenDensityBucket = _loc2_;
         var _loc4_:int = 1;
         var _loc5_:int = int(_buckets.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc2_ = _buckets[_loc6_];
            if(param1 <= _loc2_.density)
            {
               _loc7_ = (_loc2_.density + _loc3_.density) / 2;
               if(param1 < _loc7_)
               {
                  return _loc3_.scale;
               }
               return _loc2_.scale;
            }
            _loc3_ = _loc2_;
         }
         return _loc2_.scale;
      }
      
      public function addScaleForDensity(param1:Number, param2:Number) : void
      {
         var _loc6_:* = null as ScreenDensityBucket;
         var _loc3_:int = int(_buckets.length);
         var _loc4_:int = 0;
         var _loc5_:Array = _buckets;
         while(_loc4_ < int(_loc5_.length))
         {
            _loc6_ = _loc5_[_loc4_];
            _loc4_++;
            if(_loc6_.density > param1)
            {
               break;
            }
            if(_loc6_.density == param1)
            {
               throw new ArgumentError("Screen density cannot be added more than once: " + param1);
            }
         }
         _buckets.insert(_loc3_,new ScreenDensityBucket(param1,param2));
      }
   }
}

