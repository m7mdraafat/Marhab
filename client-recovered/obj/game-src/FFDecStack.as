package
{
   public class FFDecStack
   {
      private static var stack:Array = [];

      public function FFDecStack()
      {
      }

      public static function push(value:*) : *
      {
         stack.push(value);
         return value;
      }

      public static function pop() : *
      {
         return stack.length == 0 ? null : stack.pop();
      }

      public static function findproperty(value:*) : *
      {
         return value;
      }
   }
}