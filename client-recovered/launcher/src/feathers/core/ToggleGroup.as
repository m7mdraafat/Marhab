package feathers.core
{
   import feathers.controls.IGroupedToggle;
   import feathers.controls.IToggle;
   import feathers.events.FeathersEvent;
   import flash.Boot;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class ToggleGroup extends EventDispatcher implements IDataSelector, IIndexSelector
   {
      
      public var _selectedIndex:int;
      
      public var _requireSelection:Boolean;
      
      public var _items:Array;
      
      public var _ignoreChanges:Boolean;
      
      public function ToggleGroup()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         _requireSelection = true;
         _selectedIndex = -1;
         _ignoreChanges = false;
         _items = [];

      }
      
      public function set_selectedItem(param1:*) : *
      {
         set_selectedIndex(_items.indexOf(param1));
         return get_selectedItem();
      }
      
      public function set_selectedIndex(param1:int) : int
      {
         var _loc7_:int = 0;
         var _loc8_:* = null as IToggle;
         var _loc2_:int = int(_items.length);
         if(param1 < -1 || param1 > _loc2_)
         {
            throw new RangeError("Index " + param1 + " is out of range " + _loc2_ + " for ToggleGroup.");
         }
         var _loc3_:Boolean = _selectedIndex != param1;
         _selectedIndex = param1;
         var _loc4_:Boolean = _ignoreChanges;
         _ignoreChanges = true;
         var _loc5_:int = 0;
         var _loc6_:int = int(_items.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            _loc8_ = _items[_loc7_];
            _loc8_.set_selected(_loc7_ == param1);
         }
         _ignoreChanges = _loc4_;
         if(_loc3_)
         {
            FeathersEvent.dispatch(this,Event.CHANGE);
         }
         return _selectedIndex;
      }
      
      public function set_requireSelection(param1:Boolean) : Boolean
      {
         if(_requireSelection == param1)
         {
            return _requireSelection;
         }
         _requireSelection = param1;
         if(_requireSelection && _selectedIndex == -1 && int(_items.length) > 0)
         {
            set_selectedIndex(0);
         }
         return _requireSelection;
      }
      
      public function setItemIndex(param1:IToggle, param2:int) : void
      {
         var _loc3_:int = _items.indexOf(param1);
         if(_loc3_ < 0)
         {
            throw new ArgumentError("Attempting to set index of an item that has not been added to this ToggleGroup.");
         }
         if(_loc3_ == param2)
         {
            return;
         }
         _items.remove(param1);
         _items.insert(param2,param1);
         if(_selectedIndex >= 0)
         {
            if(_selectedIndex == _loc3_)
            {
               set_selectedIndex(param2);
            }
            else if(_loc3_ < _selectedIndex && param2 > _selectedIndex)
            {
               set_selectedIndex(get_selectedIndex() - 1);
            }
            else if(_loc3_ > _selectedIndex && param2 < _selectedIndex)
            {
               set_selectedIndex(get_selectedIndex() + 1);
            }
         }
      }
      
      public function removeItem(param1:IToggle) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = _items.indexOf(param1);
         if(_loc2_ == -1)
         {
            return;
         }
         _items.remove(param1);
         param1.removeEventListener(Event.CHANGE,item_changeHandler);
         if(param1 is IGroupedToggle)
         {
            param1.set_toggleGroup(null);
         }
         if(_selectedIndex > _loc2_)
         {
            set_selectedIndex(get_selectedIndex() - 1);
         }
         else if(get_selectedIndex() == _loc2_)
         {
            if(_requireSelection)
            {
               _loc3_ = int(_items.length) - 1;
               if(_selectedIndex > _loc3_)
               {
                  set_selectedIndex(_loc3_);
               }
               else
               {
                  FeathersEvent.dispatch(this,Event.CHANGE);
               }
            }
            else
            {
               set_selectedIndex(-1);
            }
         }
      }
      
      public function removeAllItems() : void
      {
         var _loc3_:* = null as IToggle;
         var _loc1_:int = 0;
         var _loc2_:Array = _items;
         while(_loc1_ < int(_loc2_.length))
         {
            _loc3_ = _loc2_[_loc1_];
            _loc1_++;
            _loc3_.removeEventListener(Event.CHANGE,item_changeHandler);
            if(_loc3_ is IGroupedToggle)
            {
               _loc3_.set_toggleGroup(null);
            }
         }
         _items.resize(0);
         set_selectedIndex(-1);
      }
      
      public function item_changeHandler(param1:Event) : void
      {
         if(_ignoreChanges)
         {
            return;
         }
         var _loc2_:IToggle = param1.currentTarget;
         var _loc3_:int = _items.indexOf(_loc2_);
         if(_loc2_.get_selected() || _requireSelection && _selectedIndex == _loc3_)
         {
            set_selectedIndex(_loc3_);
         }
         else if(!_loc2_.get_selected())
         {
            set_selectedIndex(-1);
         }
      }
      
      public function hasItem(param1:IToggle) : Boolean
      {
         return _items.indexOf(param1) != -1;
      }
      
      public function get_selectedItem() : *
      {
         if(_selectedIndex == -1)
         {
            return null;
         }
         return _items[_selectedIndex];
      }
      
      public function get_selectedIndex() : int
      {
         return _selectedIndex;
      }
      
      public function get_requireSelection() : Boolean
      {
         return _requireSelection;
      }
      
      public function get_numItems() : int
      {
         return int(_items.length);
      }
      
      public function get_maxSelectedIndex() : int
      {
         return int(_items.length) - 1;
      }
      
      public function getItemIndex(param1:IToggle) : int
      {
         return _items.indexOf(param1);
      }
      
      public function getItemAt(param1:int) : IToggle
      {
         if(param1 < 0 || param1 >= int(_items.length))
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         return _items[param1];
      }
      
      public function addItem(param1:IToggle) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError("IToggle passed to ToggleGroup addItem() must not be null.");
         }
         var _loc2_:int = _items.indexOf(param1);
         if(_loc2_ != -1)
         {
            throw new IllegalOperationError("Cannot add an item to a ToggleGroup more than once.");
         }
         _items.push(param1);
         if(param1.get_selected())
         {
            set_selectedItem(param1);
         }
         else if(_selectedIndex < 0 && _requireSelection)
         {
            set_selectedItem(param1);
         }
         else
         {
            param1.set_selected(false);
         }
         param1.addEventListener(Event.CHANGE,item_changeHandler,false,0,true);
         if(param1 is IGroupedToggle)
         {
            param1.set_toggleGroup(this);
         }
      }
   }
}

