package com.distriqt.extension.facebook.appevents
{
   public class AppEvent
   {
      
      public var eventName:String = "";
      
      public var valueToSum:Number = 0;
      
      private var _params:Object;
      
      public function AppEvent(param1:String = "", param2:Number = 0)
      {
         super();
         this.eventName = param1;
         this.valueToSum = param2;
         _params = {};
      }
      
      public function get parameters() : Object
      {
         return _params;
      }
      
      public function setEventName(param1:String) : AppEvent
      {
         this.eventName = param1;
         return this;
      }
      
      public function setValueToSum(param1:Number) : AppEvent
      {
         this.valueToSum = param1;
         return this;
      }
      
      public function setParameter(param1:String, param2:*) : AppEvent
      {
         if(param2 is Number || param2 is int)
         {
            _params[param1] = param2;
         }
         else
         {
            _params[param1] = String(param2);
         }
         return this;
      }
      
      public function removeParameter(param1:String) : AppEvent
      {
         if(_params[param1])
         {
            delete _params[param1];
         }
         return this;
      }
      
      public function toObject() : Object
      {
         return {
            "eventName":this.eventName,
            "valueToSum":this.valueToSum,
            "parameters":this.parameters
         };
      }
   }
}

