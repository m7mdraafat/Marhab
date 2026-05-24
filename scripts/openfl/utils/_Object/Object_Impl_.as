package openfl.utils._Object
{
   import haxe.iterators.ArrayIterator;
   import haxe.lang.Iterable;
   
   public final class Object_Impl_
   {
      
      public static var __meta__:* = {"statics":{
         "iterator":{"SuppressWarnings":["checkstyle:FieldDocComment"]},
         "__get":{"SuppressWarnings":["checkstyle:FieldDocComment"]},
         "__set":{"SuppressWarnings":["checkstyle:FieldDocComment"]}
      }};
      
      public function Object_Impl_()
      {
      }
      
      public static function _new() : Object
      {
         return {};
      }
      
      public static function hasOwnProperty(param1:Object, param2:String) : Boolean
      {
         if(param1 != null)
         {
            return Reflect.hasField(param1,param2);
         }
         return false;
      }
      
      public static function isPrototypeOf(param1:Object, param2:Class) : Boolean
      {
         var _loc3_:Class = Type.getClass(param1);
         while(_loc3_ != null)
         {
            if(_loc3_ == param2)
            {
               return true;
            }
            _loc3_ = Type.getSuperClass(_loc3_);
         }
         return false;
      }
      
      public static function iterator(param1:Object) : Object
      {
         var _loc2_:Array = Reflect.fields(param1);
         if(_loc2_ == null)
         {
            _loc2_ = [];
         }
         return new ArrayIterator(_loc2_);
      }
      
      public static function propertyIsEnumerable(param1:Object, param2:String) : Boolean
      {
         if(param1 != null && Reflect.hasField(param1,param2))
         {
            return Reflect.field(param1,param2) is Iterable;
         }
         return false;
      }
      
      public static function toLocaleString(param1:Object) : String
      {
         return Std.string(param1);
      }
      
      public static function toString(param1:Object) : String
      {
         return Std.string(param1);
      }
      
      public static function valueOf(param1:Object) : Object
      {
         return param1;
      }
      
      public static function __get(param1:Object, param2:String) : *
      {
         return Reflect.field(param1,param2);
      }
      
      public static function __set(param1:Object, param2:String, param3:*) : *
      {
         param1[param2] = param3;
         return param3;
      }
   }
}

