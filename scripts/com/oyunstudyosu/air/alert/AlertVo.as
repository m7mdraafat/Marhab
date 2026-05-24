package com.oyunstudyosu.air.alert
{
   import flash.Boot;
   
   public class AlertVo
   {
      
      public var value:String;
      
      public var title:String;
      
      public var stepperComment:String;
      
      public var stepSize:int;
      
      public var sound:Boolean;
      
      public var secretSession:String;
      
      public var response:AlertResponse;
      
      public var panelType:String;
      
      public var minQuantity:int;
      
      public var maxQuantity:int;
      
      public var isTransfer:Boolean;
      
      public var description:String;
      
      public var defaultInputMessage:String;
      
      public var data:*;
      
      public var callBack:Function;
      
      public var alertType:String;
      
      public function AlertVo()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         sound = false;
         isTransfer = false;
         description = "";
         stepperComment = "";
         minQuantity = 1;
         maxQuantity = 100;
         stepSize = 1;
      }
      
      public function getIntValue() : Object
      {
         return Std.parseInt(value);
      }
      
      public function getFloatValue() : Number
      {
         return Std.parseFloat(value);
      }
      
      public function dispose() : void
      {
         description = null;
         secretSession = null;
         callBack = null;
         defaultInputMessage = null;
      }
   }
}

