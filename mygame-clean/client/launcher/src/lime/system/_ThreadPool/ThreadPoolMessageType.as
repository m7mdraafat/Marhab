package lime.system._ThreadPool
{
   import flash.Boot;
   
   public final class ThreadPoolMessageType
   {
      
      public static const __isenum:Boolean = true;
      
      public static var COMPLETE:ThreadPoolMessageType = new ThreadPoolMessageType("COMPLETE",0,null);
      
      public static var ERROR:ThreadPoolMessageType = new ThreadPoolMessageType("ERROR",1,null);
      
      public static var EXIT:ThreadPoolMessageType = new ThreadPoolMessageType("EXIT",2,null);
      
      public static var PROGRESS:ThreadPoolMessageType = new ThreadPoolMessageType("PROGRESS",3,null);
      
      public static var WORK:ThreadPoolMessageType = new ThreadPoolMessageType("WORK",4,null);
      
      public static var __constructs__:Array = ["COMPLETE","ERROR","EXIT","PROGRESS","WORK"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function ThreadPoolMessageType(param1:String, param2:int, param3:Array)
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

