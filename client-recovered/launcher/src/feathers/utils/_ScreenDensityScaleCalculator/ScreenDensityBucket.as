package feathers.utils._ScreenDensityScaleCalculator
{
   import flash.Boot;
   
   public class ScreenDensityBucket
   {
      
      public var scale:Number;
      
      public var density:Number;
      
      public function ScreenDensityBucket(param1:Number = 0, param2:Number = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         density = param1;
         scale = param2;
      }
   }
}

