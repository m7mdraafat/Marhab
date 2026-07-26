package com.distriqt.extension.facebook.appevents
{
   public class AppPurchaseEvent
   {
      
      public var purchaseAmount:Number = 0;
      
      public var currency:String;
      
      private var _params:Object;
      
      public function AppPurchaseEvent(param1:Number, param2:String)
      {
         super();
         this.purchaseAmount = param1;
         this.currency = param2;
         _params = {};
      }
      
      public function get parameters() : Object
      {
         return _params;
      }
      
      public function setPurchaseAmount(param1:Number) : AppPurchaseEvent
      {
         this.purchaseAmount = param1;
         return this;
      }
      
      public function setCurrency(param1:String) : AppPurchaseEvent
      {
         this.currency = param1;
         return this;
      }
      
      public function setParameter(param1:String, param2:*) : AppPurchaseEvent
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
      
      public function removeParameter(param1:String) : AppPurchaseEvent
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
            "purchaseAmount":this.purchaseAmount,
            "currency":this.currency,
            "parameters":this.parameters
         };
      }
   }
}

