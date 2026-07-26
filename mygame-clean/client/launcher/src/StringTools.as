package
{
   public class StringTools
   {
      
      public function StringTools()
      {
      }
      
      public static function startsWith(param1:String, param2:String) : Boolean
      {
         if(param1.length >= param2.length)
         {
            return param1.lastIndexOf(param2,0) == 0;
         }
         return false;
      }
      
      public static function endsWith(param1:String, param2:String) : Boolean
      {
         var _loc3_:int = param2.length;
         var _loc4_:int = param1.length;
         if(_loc4_ >= _loc3_)
         {
            return param1.indexOf(param2,_loc4_ - _loc3_) == _loc4_ - _loc3_;
         }
         return false;
      }
      
      public static function replace(param1:String, param2:String, param3:String) : String
      {
         return param1.split(param2).join(param3);
      }
   }
}

