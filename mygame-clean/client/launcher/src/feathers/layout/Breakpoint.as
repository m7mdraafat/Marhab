package feathers.layout
{
   import flash.Boot;
   
   public final class Breakpoint
   {
      
      public static const __isenum:Boolean = true;
      
      public static var LG:Breakpoint = new Breakpoint("LG",3,null);
      
      public static var MD:Breakpoint = new Breakpoint("MD",2,null);
      
      public static var SM:Breakpoint = new Breakpoint("SM",1,null);
      
      public static var XL:Breakpoint = new Breakpoint("XL",4,null);
      
      public static var XS:Breakpoint = new Breakpoint("XS",0,null);
      
      public static var XXL:Breakpoint = new Breakpoint("XXL",5,null);
      
      public static var __constructs__:Array = ["XS","SM","MD","LG","XL","XXL"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function Breakpoint(param1:String, param2:int, param3:Array)
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

