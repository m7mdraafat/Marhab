package lime.utils
{
   import haxe.io.Bytes;

   public class BytePointerData
   {
      public var bytes:Bytes;
      public var offset:int;

      public function BytePointerData(param1:Bytes = null, param2:int = 0)
      {
         bytes = param1;
         offset = param2;
      }
   }
}