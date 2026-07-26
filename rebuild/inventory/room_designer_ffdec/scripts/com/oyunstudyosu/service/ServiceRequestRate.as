package com.oyunstudyosu.service
{
   import flash.utils.getTimer;
   
   public class ServiceRequestRate
   {
      
      private static var lastRequests:Array = [];
      
      private static var requestRateLimits:Array = [];
      
      public function ServiceRequestRate()
      {
         super();
      }
      
      public static function check(param1:String) : Boolean
      {
         if(requestRateLimits[param1] == null || lastRequests[param1] == null)
         {
            return true;
         }
         var _loc2_:int = int(requestRateLimits[param1]);
         var _loc3_:int = int(lastRequests[param1]);
         if(getTimer() - _loc3_ < _loc2_)
         {
            return false;
         }
         lastRequests[param1] = getTimer();
         return true;
      }
      
      public static function create(param1:String, param2:int = 0) : void
      {
         if(param2 == 0)
         {
            return;
         }
         requestRateLimits[param1] = param2;
         lastRequests[param1] = getTimer();
      }
      
      public static function reset() : void
      {
         lastRequests = [];
         requestRateLimits = [];
      }
   }
}

