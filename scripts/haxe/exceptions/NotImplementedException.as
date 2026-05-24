package haxe.exceptions
{
   import flash.Boot;
   import haxe.Exception;
   
   public class NotImplementedException extends PosException
   {
      
      public function NotImplementedException(param1:String = undefined, param2:Exception = undefined, param3:Object = undefined)
      {
         if(param1 == null)
         {
            param1 = "Not implemented";
         }
         super(param1,param2,param3);
         if(Boot.skip_constructor)
         {
            return;
         }
      }
   }
}

