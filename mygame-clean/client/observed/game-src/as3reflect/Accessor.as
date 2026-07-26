package as3reflect
{
   public class Accessor extends Field
   {
      
      private var _access:AccessorAccess;
      
      public function Accessor(param1:String, param2:AccessorAccess, param3:as3reflect.Type, param4:as3reflect.Type, param5:Boolean, param6:Array = null)
      {
         super(param1,param3,param4,param5,param6);
         this._access = param2;
      }
      
      public function get access() : AccessorAccess
      {
         return this._access;
      }
   }
}

