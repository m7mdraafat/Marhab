package de.polygonal.ds
{
   public class HashMapKeyIterator implements Itr
   {
      private var _f:HashMap;
      private var _keys:Array;
      private var _i:int;

      public function HashMapKeyIterator(param1:HashMap)
      {
         _f = param1;
         reset();
      }

      public function reset() : Itr
      {
         _keys = _f.toKeyArray();
         _i = 0;
         return this;
      }

      public function remove() : void
      {
         if(_i > 0)
         {
            _f.clr(_keys[_i - 1]);
         }
      }

      public function next() : Object
      {
         return _keys[_i++];
      }

      public function hasNext() : Boolean
      {
         return _i < _keys.length;
      }
   }
}