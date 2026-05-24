package com.oyunstudyosu.air.alert
{
   import flash.Boot;
   
   public final class AlertResponse
   {
      
      public static const __isenum:Boolean = true;
      
      public static var CANCEL:AlertResponse = new AlertResponse("CANCEL",3,null);
      
      public static var CLOSE:AlertResponse = new AlertResponse("CLOSE",4,null);
      
      public static var NO:AlertResponse = new AlertResponse("NO",0,null);
      
      public static var OK:AlertResponse = new AlertResponse("OK",2,null);
      
      public static var YES:AlertResponse = new AlertResponse("YES",1,null);
      
      public static var __constructs__:Array = ["NO","YES","OK","CANCEL","CLOSE"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function AlertResponse(param1:String, param2:int, param3:Array)
      {
         tag = param1;
         index = param2;
         params = param3;
      }
      
      final public function toString() : String
      {
         return Boot.enum_to_string(this);
      }
   }
}

