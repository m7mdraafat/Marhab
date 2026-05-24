package haxe.ds
{
   import flash.Boot;
   import flash.utils.Dictionary;
   import haxe.IMap;
   import haxe.ds._ObjectMap.NativePropertyIterator;
   import haxe.ds._ObjectMap.NativeValueIterator;
   
   public dynamic class ObjectMap extends Dictionary implements IMap
   {
      
      public function ObjectMap()
      {
         super(false);
         if(Boot.skip_constructor)
         {
            return;
         }
      }
      
      public function remove(param1:Object) : Boolean
      {
         var _loc2_:Object = param1;
         var _loc3_:Boolean = this[_loc2_] != null;
         delete this[_loc2_];
         return _loc3_;
      }
      
      public function keys() : Object
      {
         var _loc1_:NativePropertyIterator = new NativePropertyIterator();
         _loc1_.collection = this;
         return _loc1_;
      }
      
      public function iterator() : Object
      {
         var _loc1_:NativeValueIterator = new NativeValueIterator();
         _loc1_.collection = this;
         return _loc1_;
      }
      
      public function get(param1:Object) : Object
      {
         var _loc2_:Object = param1;
         return this[_loc2_];
      }
   }
}

