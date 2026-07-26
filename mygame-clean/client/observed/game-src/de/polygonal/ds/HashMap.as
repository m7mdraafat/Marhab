package de.polygonal.ds
{
   import flash.utils.Dictionary;

   public class HashMap implements Map
   {
      public var reuseIterator:Boolean = false;
      public var maxSize:int = -1;
      public var key:int = 0;
      public var _weak:Boolean;
      public var _size:int = 0;
      public var _map:Dictionary;

      public function HashMap(param1:Boolean = false, param2:int = -1)
      {
         _weak = param1;
         maxSize = param2;
         _map = new Dictionary(_weak);
      }

      public function set(param1:Object, param2:Object) : Boolean
      {
         if(_map[param1] !== undefined)
         {
            return false;
         }
         _map[param1] = param2;
         _size++;
         return true;
      }

      public function remap(param1:Object, param2:Object) : Boolean
      {
         if(_map[param1] === undefined)
         {
            return false;
         }
         _map[param1] = param2;
         return true;
      }

      public function get(param1:Object) : Object
      {
         return _map[param1];
      }

      public function hasKey(param1:Object) : Boolean
      {
         return _map[param1] !== undefined;
      }

      public function has(param1:Object) : Boolean
      {
         return contains(param1);
      }

      public function contains(param1:Object) : Boolean
      {
         for each(var value:Object in _map)
         {
            if(value === param1)
            {
               return true;
            }
         }
         return false;
      }

      public function clr(param1:Object) : Boolean
      {
         if(_map[param1] === undefined)
         {
            return false;
         }
         delete _map[param1];
         _size--;
         return true;
      }

      public function remove(param1:Object) : Boolean
      {
         for(var keyObject:Object in _map)
         {
            if(_map[keyObject] === param1)
            {
               delete _map[keyObject];
               _size--;
               return true;
            }
         }
         return false;
      }

      public function keys() : Itr
      {
         return new HashMapKeyIterator(this);
      }

      public function iterator() : Itr
      {
         return new HashMapValIterator(this);
      }

      public function toKeyArray() : Array
      {
         var result:Array = [];
         for(var keyObject:Object in _map)
         {
            result.push(keyObject);
         }
         return result;
      }

      public function toArray() : Array
      {
         var result:Array = [];
         for each(var value:Object in _map)
         {
            result.push(value);
         }
         return result;
      }

      public function size() : int
      {
         return _size;
      }

      public function isEmpty() : Boolean
      {
         return _size == 0;
      }

      public function clear(param1:Boolean = false) : void
      {
         _map = new Dictionary(_weak);
         _size = 0;
      }

      public function free() : void
      {
         clear();
      }

      public function clone(param1:Boolean = false, param2:Function = null) : Collection
      {
         var copy:HashMap = new HashMap(_weak,maxSize);
         for(var keyObject:Object in _map)
         {
            copy.set(keyObject,param2 != null ? param2(_map[keyObject]) : _map[keyObject]);
         }
         return copy;
      }

      public function toValSet() : Set
      {
         return null;
      }

      public function toKeySet() : Set
      {
         return null;
      }

      public function toKeyDA() : DA
      {
         return null;
      }

      public function toDA() : DA
      {
         return null;
      }

      public function toString() : String
      {
         return "{HashMap, size: " + _size + "}";
      }
   }
}