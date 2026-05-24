package lime.system._ThreadPool
{
   import flash.Boot;
   
   public class ThreadPoolMessage
   {
      
      public var type:ThreadPoolMessageType;
      
      public var state:*;
      
      public function ThreadPoolMessage(param1:ThreadPoolMessageType = undefined, param2:* = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         type = param1;
         state = param2;
      }
   }
}

