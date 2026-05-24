package haxe
{
   import flash.utils.ByteArray;
   import flash.utils.getDefinitionByName;
   import haxe.io.Bytes;
   
   public class Resource
   {
      
      public static var content:Array = [{"name":"swf:SanalikaAirUI.swf"}];
      
      public function Resource()
      {
      }
      
      public static function getBytes(param1:String) : Bytes
      {
         var _loc2_:ByteArray = Resource.resolve(param1);
         if(_loc2_ == null)
         {
            return null;
         }
         return Bytes.ofData(_loc2_);
      }
      
      public static function resolve(param1:String) : ByteArray
      {
         var _loc3_:* = null;
         try
         {
            _loc3_ = getDefinitionByName("_res._" + param1.split(".").join("_")) as Class;
            return new _loc3_();
         }
         catch(_loc_e_:*)
         {
         }
      }
   }
}

