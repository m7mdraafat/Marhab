package feathers.core
{
   import feathers.controls.IGroupedToggle;
   import feathers.controls.supportClasses.IViewPort;
   import feathers.core._DefaultFocusManager.FocusResult;
   import feathers.events.FeathersEvent;
   import feathers.layout.RelativePosition;
   import feathers.utils.DPadFocusUtil;
   import feathers.utils.FocusUtil;
   import feathers.utils.PopUpUtil;
   import flash.Boot;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.text.TextField;
   
   public class DefaultFocusManager extends EventDispatcher implements IFocusManager
   {
      
      public static var WRAP_OBJECT_HIGH_TAB_INDEX:int = 2147483647;
      
      public var _wrapObject:InteractiveObject;
      
      public var _showFocusIndicator:Boolean;
      
      public var _root:DisplayObject;
      
      public var _focusToRestore:IFocusObject;
      
      public var _focusPane:DisplayObjectContainer;
      
      public var _enabled:Boolean;
      
      public function DefaultFocusManager(param1:DisplayObject = undefined)
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         _showFocusIndicator = false;
         _focusPane = null;
         _root = null;
         _enabled = true;

         set_root(param1);
      }
      
      public function shouldBeManaged(param1:DisplayObject) : Boolean
      {
         var _loc5_:* = null;
         var _loc6_:* = null as IFocusExtras;
         var _loc7_:int = 0;
         var _loc8_:* = null as Array;
         var _loc9_:* = null as DisplayObject;
         if(param1 == _root)
         {
            return true;
         }
         var _loc3_:DisplayObjectContainer = param1.parent;
         var _loc4_:Boolean = false;
         try
         {
            _loc4_ = _loc3_.getChildIndex(param1) != -1;
         }
         catch(_loc_e_:*)
         {
            if(_loc4_ && _loc3_ is IViewPort && !(_loc3_ is IFocusContainer))
            {
               _loc3_ = _loc3_.parent;
            }
            else if(!_loc4_ && _loc3_ is IFocusExtras)
            {
               _loc6_ = _loc3_;
               if(_loc6_.get_focusExtrasBefore() != null)
               {
                  _loc7_ = 0;
                  _loc8_ = _loc6_.get_focusExtrasBefore();
                  while(_loc7_ < int(_loc8_.length))
                  {
                     _loc9_ = _loc8_[_loc7_];
                     _loc7_++;
                     if(_loc9_ == param1)
                     {
                        _loc4_ = true;
                        break;
                     }
                     if(_loc9_ is DisplayObjectContainer)
                     {
                        _loc4_ = _loc9_.contains(_loc9_);
                        if(_loc4_)
                        {
                           break;
                        }
                     }
                  }
               }
               if(!_loc4_ && _loc6_.get_focusExtrasAfter() != null)
               {
                  _loc7_ = 0;
                  _loc8_ = _loc6_.get_focusExtrasAfter();
                  while(_loc7_ < int(_loc8_.length))
                  {
                     _loc9_ = _loc8_[_loc7_];
                     _loc7_++;
                     if(_loc9_ == param1)
                     {
                        _loc4_ = true;
                        break;
                     }
                     if(_loc9_ is DisplayObjectContainer)
                     {
                        _loc4_ = _loc9_.contains(_loc9_);
                        if(_loc4_)
                        {
                           break;
                        }
                     }
                  }
               }
            }
            if(!_loc4_)
            {
               return false;
            }
            if(_loc3_ != null && _loc3_ != _root)
            {
               return shouldBeManaged(_loc3_);
            }
            return true;
         }
      }
      
      public function set_root(param1:DisplayObject) : DisplayObject
      {
         if(_root == param1)
         {
            return _root;
         }
         if(_root != null)
         {
            clearFocusManager(_root);
            _root.removeEventListener(Event.ADDED_TO_STAGE,defaultFocusManager_root_addedToStageHandler);
            _root.removeEventListener(Event.REMOVED_FROM_STAGE,defaultFocusManager_root_removedFromStageHandler);
            _root.removeEventListener(Event.ADDED,defaultFocusManager_root_addedHandler);
            _root.removeEventListener(Event.REMOVED,defaultFocusManager_root_removedHandler);
            _root.removeEventListener(MouseEvent.MOUSE_DOWN,defaultFocusManager_root_mouseDownCaptureHandler,true);
            _root.removeEventListener(FocusEvent.FOCUS_IN,defaultFocusManager_root_focusInCaptureHandler,true);
            _root.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,defaultFocusManager_root_mouseFocusChangeHandler);
            _root.removeEventListener(Event.ACTIVATE,defaultFocusManager_root_activateHandler);
            _root.removeEventListener(Event.DEACTIVATE,defaultFocusManager_root_deactivateHandler);
            handleRootRemovedFromStage(_root.stage);
         }
         _root = param1;
         if(_root != null)
         {
            handleRootAddedToStage(_root);
            setFocusManager(_root);
            _root.addEventListener(Event.ADDED_TO_STAGE,defaultFocusManager_root_addedToStageHandler,false,0,true);
            _root.addEventListener(Event.REMOVED_FROM_STAGE,defaultFocusManager_root_removedFromStageHandler,false,0,true);
            _root.addEventListener(Event.ADDED,defaultFocusManager_root_addedHandler,false,0,true);
            _root.addEventListener(Event.REMOVED,defaultFocusManager_root_removedHandler,false,0,true);
            _root.addEventListener(MouseEvent.MOUSE_DOWN,defaultFocusManager_root_mouseDownCaptureHandler,true,0,true);
            _root.addEventListener(FocusEvent.FOCUS_IN,defaultFocusManager_root_focusInCaptureHandler,true,0,true);
            _root.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,defaultFocusManager_root_mouseFocusChangeHandler,false,0,true);
            _root.addEventListener(Event.ACTIVATE,defaultFocusManager_root_activateHandler,false,0,true);
            _root.addEventListener(Event.DEACTIVATE,defaultFocusManager_root_deactivateHandler,false,0,true);
         }
         return _root;
      }
      
      public function set_focus(param1:IFocusObject) : IFocusObject
      {
         var _loc2_:* = null as IFocusObject;
         if(_enabled && _root.stage != null)
         {
            _loc2_ = findFocusForDisplayObject(_root.stage.focus);
            if(_loc2_ == param1)
            {
               setStageFocus(param1);
               return get_focus();
            }
         }
         if(param1 != null && param1.get_focusManager() != this)
         {
            throw new ArgumentError("Failed to change focus. Object is not managed by this focus manager: " + Std.string(param1));
         }
         if(_enabled && _root.stage != null)
         {
            setStageFocus(param1);
         }
         return get_focus();
      }
      
      public function set_enabled(param1:Boolean) : Boolean
      {
         if(_enabled == param1)
         {
            return _enabled;
         }
         if(param1 && _root == null)
         {
            throw new IllegalOperationError("Cannot enable focus manager without a root container.");
         }
         _enabled = param1;
         if(_root.stage != null)
         {
            if(_enabled)
            {
               restoreFocus();
            }
            else
            {
               set_focus(null);
            }
         }
         return _enabled;
      }
      
      public function setStageFocus(param1:InteractiveObject) : void
      {
         var _loc2_:* = null as InteractiveObject;
         while(param1 is IStageFocusDelegate)
         {
            _loc2_ = param1.get_stageFocusTarget();
            if(_loc2_ == null)
            {
               break;
            }
            param1 = _loc2_;
         }
         if(param1 == null)
         {
            param1 = _root.stage;
         }
         if(_root.stage.focus != param1)
         {
            _root.stage.focus = param1;
         }
      }
      
      public function setFocusManager(param1:DisplayObject) : void
      {
         var _loc2_:* = null as IFocusManagerAware;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:* = null as DisplayObject;
         var _loc8_:* = null as IFocusExtras;
         var _loc9_:* = null as Array;
         if(param1 is IFocusManagerAware)
         {
            _loc2_ = param1;
            _loc2_.set_focusManager(this);
         }
         var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            _loc5_ = _loc3_.numChildren;
            while(_loc4_ < _loc5_)
            {
               _loc6_ = _loc4_++;
               _loc7_ = _loc3_.getChildAt(_loc6_);
               setFocusManager(_loc7_);
            }
            if(_loc3_ is IFocusExtras)
            {
               _loc8_ = _loc3_;
               _loc9_ = _loc8_.get_focusExtrasBefore();
               if(_loc9_ != null)
               {
                  _loc4_ = 0;
                  while(_loc4_ < int(_loc9_.length))
                  {
                     _loc7_ = _loc9_[_loc4_];
                     _loc4_++;
                     setFocusManager(_loc7_);
                  }
               }
               _loc9_ = _loc8_.get_focusExtrasAfter();
               if(_loc9_ != null)
               {
                  _loc4_ = 0;
                  while(_loc4_ < int(_loc9_.length))
                  {
                     _loc7_ = _loc9_[_loc4_];
                     _loc4_++;
                     setFocusManager(_loc7_);
                  }
               }
            }
         }
      }
      
      public function restoreFocus() : void
      {
         if(_root.stage == null || _focusToRestore == null || !isValidFocus(_focusToRestore))
         {
            return;
         }
         set_focus(_focusToRestore);
      }
      
      public function isValidFocusWithKeyboard(param1:IFocusObject) : Boolean
      {
         if(param1 is InteractiveObject && !param1.tabEnabled)
         {
            return false;
         }
         return isValidFocus(param1);
      }
      
      public function isValidFocus(param1:IFocusObject, param2:Boolean = false) : Boolean
      {
         var _loc3_:* = null as IUIControl;
         var _loc4_:* = null as IPopUpManager;
         var _loc5_:* = null as DisplayObject;
         if(param1 == null || param1.stage == null || param1.get_focusManager() != this || !param1.get_focusEnabled() || !Boolean(param1.visible))
         {
            return false;
         }
         if(param1 is IUIControl)
         {
            _loc3_ = param1;
            if(!_loc3_.get_enabled())
            {
               return false;
            }
         }
         if(!param2)
         {
            _loc4_ = PopUpManager.forStage(_root.stage);
            if(_loc4_.hasModalPopUps())
            {
               _loc5_ = param1;
               if(!PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(_loc5_))
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function handleRootRemovedFromStage(param1:DisplayObject) : void
      {
         set_focus(null);
         var _loc2_:Stage = _root.stage;
         if(_loc2_ == null)
         {
            return;
         }
         _root.removeEventListener(KeyboardEvent.KEY_DOWN,defaultFocusManager_root_keyDownHandler);
         _root.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,defaultFocusManager_root_keyFocusChangeHandler);
      }
      
      public function handleRootAddedToStage(param1:DisplayObject) : void
      {
         var _loc2_:Stage = _root.stage;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.stageFocusRect = false;
         if(_enabled && _loc2_.focus == null)
         {
            _loc2_.focus = _loc2_;
         }
         _root.addEventListener(KeyboardEvent.KEY_DOWN,defaultFocusManager_root_keyDownHandler,false,0,true);
         _root.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,defaultFocusManager_root_keyFocusChangeHandler,false,0,true);
      }
      
      public function handleKeyDownFocusWrapping(param1:KeyboardEvent) : void
      {
         if(Capabilities.playerType == "StandAlone" || Capabilities.playerType == "Desktop")
         {
            return;
         }
         if(!_enabled || param1.isDefaultPrevented())
         {
            return;
         }
         if(param1.keyCode != 9 && param1.keyCode != 0)
         {
            return;
         }
         if(_wrapObject != null)
         {
            if(_wrapObject.tabIndex == DefaultFocusManager.WRAP_OBJECT_HIGH_TAB_INDEX)
            {
               _wrapObject.tabIndex = -1;
            }
            _wrapObject = null;
         }
         var _loc2_:FocusResult = findNextFocusInternal(param1.shiftKey);
         if(_loc2_.wrapped)
         {
            _wrapObject = _root.stage.focus;
            if(_wrapObject != null && _wrapObject.tabIndex == -1)
            {
               _wrapObject.tabIndex = param1.shiftKey ? 0 : DefaultFocusManager.WRAP_OBJECT_HIGH_TAB_INDEX;
            }
            return;
         }
      }
      
      public function handleDPadArrowKeys(param1:KeyboardEvent) : void
      {
         if(param1.keyLocation != 4)
         {
            return;
         }
         if(param1.keyCode != 38 && param1.keyCode != 40 && param1.keyCode != 37 && param1.keyCode != 39)
         {
            return;
         }
         if(param1.isDefaultPrevented())
         {
            return;
         }
         _showFocusIndicator = true;
         var _loc2_:FocusResult = findNextRelativeFocusInternal(param1.keyCode);
         set_focus(_loc2_.newFocus);
      }
      
      public function get_showFocusIndicator() : Boolean
      {
         return _showFocusIndicator;
      }
      
      public function get_root() : DisplayObject
      {
         return _root;
      }
      
      public function get_focusPane() : DisplayObjectContainer
      {
         if(_focusPane == null)
         {
            _focusPane = new Sprite();
            _focusPane.mouseEnabled = false;
            _focusPane.mouseChildren = false;
            _focusPane.tabEnabled = false;
            _focusPane.tabChildren = false;
            PopUpManager.forStage(_root.stage).addPopUp(_focusPane,false,false);
         }
         return _focusPane;
      }
      
      public function get_focus() : IFocusObject
      {
         if(_root.stage == null)
         {
            return null;
         }
         return findFocusForDisplayObject(_root.stage.focus);
      }
      
      public function get_enabled() : Boolean
      {
         return _enabled;
      }
      
      public function findPreviousContainerFocus(param1:DisplayObjectContainer, param2:DisplayObject, param3:Boolean) : IFocusObject
      {
         var _loc7_:* = null as IFocusExtras;
         var _loc8_:* = null as Array;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:* = null as DisplayObject;
         var _loc12_:* = null as IFocusObject;
         var _loc13_:* = null;
         var _loc14_:int = 0;
         var _loc5_:DisplayObjectContainer = param1;
         if(param1 is IViewPort && !(param1 is IFocusContainer))
         {
            _loc5_ = param1.parent;
         }
         var _loc6_:Boolean = param2 == null;
         if(_loc5_ is IFocusExtras)
         {
            _loc7_ = _loc5_;
            _loc8_ = _loc7_.get_focusExtrasAfter();
            if(_loc8_ != null)
            {
               _loc9_ = int(_loc8_.length) - 1;
               if(!_loc6_)
               {
                  _loc10_ = _loc8_.indexOf(param2);
                  if(_loc10_ != -1)
                  {
                     _loc9_ = _loc10_ - 1;
                     _loc6_ = true;
                  }
               }
               if(_loc6_)
               {
                  _loc10_ = _loc9_;
                  while(_loc10_ >= 0)
                  {
                     _loc11_ = _loc8_[_loc10_];
                     _loc12_ = findPreviousChildFocus(_loc11_);
                     if(_loc12_ != null)
                     {
                        return _loc12_;
                     }
                     _loc10_--;
                  }
               }
            }
         }
         _loc9_ = param1.numChildren - 1;
         if(!_loc6_)
         {
            _loc10_ = -1;
            try
            {
               _loc10_ = param1.getChildIndex(param2);
            }
            catch(_loc_e_:*)
            {
               if(_loc10_ != -1)
               {
                  _loc9_ = _loc10_ - 1;
                  _loc6_ = true;
               }
            }
         }
         if(_loc6_)
         {
            _loc10_ = _loc9_;
            while(_loc10_ >= 0)
            {
               _loc11_ = param1.getChildAt(_loc10_);
               _loc12_ = findPreviousChildFocus(_loc11_);
               if(_loc12_ != null)
               {
                  return _loc12_;
               }
               _loc10_--;
            }
         }
         if(_loc5_ is IFocusExtras)
         {
            _loc7_ = _loc5_;
            _loc8_ = _loc7_.get_focusExtrasBefore();
            if(_loc8_ != null)
            {
               _loc10_ = int(_loc8_.length) - 1;
               if(!_loc6_)
               {
                  _loc14_ = _loc8_.indexOf(param2);
                  if(_loc14_ != -1)
                  {
                     _loc10_ = _loc14_ - 1;
                     _loc6_ = true;
                  }
               }
               if(_loc6_)
               {
                  _loc14_ = _loc10_;
                  while(_loc14_ >= 0)
                  {
                     _loc11_ = _loc8_[_loc14_];
                     _loc12_ = findPreviousChildFocus(_loc11_);
                     if(_loc12_ != null)
                     {
                        return _loc12_;
                     }
                     _loc14_--;
                  }
               }
            }
         }
         if(param3 && _loc5_ != _root)
         {
            if(_loc5_ is IFocusObject)
            {
               _loc12_ = _loc5_;
               if(isValidFocusWithKeyboard(_loc12_))
               {
                  return _loc12_;
               }
            }
            return findPreviousContainerFocus(_loc5_.parent,_loc5_,true);
         }
         return null;
      }
      
      public function findPreviousChildFocus(param1:DisplayObject) : IFocusObject
      {
         var _loc3_:Boolean = false;
         var _loc4_:* = null as IFocusContainer;
         var _loc5_:* = null as IFocusObject;
         var _loc6_:* = null as ToggleGroup;
         var _loc7_:* = null as IFocusObject;
         var _loc2_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            _loc3_ = !(_loc2_ is IFocusObject);
            if(!_loc3_ && _loc2_ is IFocusContainer)
            {
               _loc4_ = _loc2_;
               _loc3_ = _loc4_.get_childFocusEnabled();
            }
            if(_loc3_)
            {
               _loc5_ = findPreviousContainerFocus(_loc2_,null,false);
               if(_loc5_ != null)
               {
                  return _loc5_;
               }
            }
         }
         if(param1 is IFocusObject)
         {
            _loc5_ = param1;
            if(isValidFocusWithKeyboard(_loc5_))
            {
               if(!(_loc5_ is IGroupedToggle))
               {
                  return _loc5_;
               }
               _loc6_ = _loc5_.get_toggleGroup();
               if(_loc6_ == null)
               {
                  return _loc5_;
               }
               if(_loc6_.get_selectedItem() is IFocusObject)
               {
                  _loc7_ = _loc6_.get_selectedItem();
                  if(get_focus() != _loc7_)
                  {
                     return _loc7_;
                  }
               }
            }
         }
         return null;
      }
      
      public function findNextRelativeFocusInternal(param1:int) : FocusResult
      {
         var _loc2_:* = null as RelativePosition;
         var _loc8_:* = null as IFocusObject;
         switch(param1)
         {
            case 37:
               _loc2_ = RelativePosition.LEFT;
               break;
            case 38:
               _loc2_ = RelativePosition.TOP;
               break;
            case 39:
               _loc2_ = RelativePosition.RIGHT;
               break;
            case 40:
               _loc2_ = RelativePosition.BOTTOM;
               break;
            default:
               return new FocusResult(null,false);
         }
         var _loc3_:IFocusObject = get_focus();
         var _loc4_:Array = FocusUtil.findAllFocusableObjects(_root);
         if(_loc3_ == null)
         {
            if(int(_loc4_.length) > 0)
            {
               return new FocusResult(_loc4_[0],false);
            }
            return new FocusResult(null,false);
         }
         var _loc5_:IFocusObject = _loc3_;
         var _loc6_:Rectangle = _loc3_.getBounds(_loc3_.stage);
         var _loc7_:int = 0;
         while(_loc7_ < int(_loc4_.length))
         {
            _loc8_ = _loc4_[_loc7_];
            _loc7_++;
            if(_loc8_ != _loc3_)
            {
               if(isValidFocus(_loc8_))
               {
                  if(DPadFocusUtil.isBetterFocusForRelativePosition(_loc8_,_loc5_,_loc6_,_loc2_))
                  {
                     _loc5_ = _loc8_;
                  }
               }
            }
         }
         return new FocusResult(_loc5_,false);
      }
      
      public function findNextFocusInternal(param1:Boolean = false) : FocusResult
      {
         var _loc5_:* = null as IFocusObject;
         var _loc2_:IFocusObject = null;
         var _loc3_:Boolean = false;
         var _loc4_:IFocusObject = get_focus();
         if(_loc4_ != null && _loc4_.get_focusOwner() != null)
         {
            _loc5_ = _loc4_.get_focusOwner();
            if(_loc5_ != null && _loc5_.get_focusManager() != this)
            {
               _loc5_ = null;
            }
            if(_loc5_ != null)
            {
               _loc2_ = _loc5_;
            }
         }
         else if(param1)
         {
            if(_loc4_ != null && _loc4_.parent != null)
            {
               _loc2_ = findPreviousContainerFocus(_loc4_.parent,_loc4_,true);
            }
            if(_loc2_ == null)
            {
               _loc2_ = findPreviousChildFocus(_root);
               _loc3_ = _loc4_ != null;
            }
         }
         else
         {
            if(_loc4_ != null)
            {
               if(_loc4_ is IFocusContainer && _loc4_.get_childFocusEnabled())
               {
                  _loc2_ = findNextContainerFocus(_loc4_,null,true);
               }
               else if(_loc4_.parent != null)
               {
                  _loc2_ = findNextContainerFocus(_loc4_.parent,_loc4_,true);
               }
            }
            if(_loc2_ == null)
            {
               _loc2_ = findNextChildFocus(_root);
               _loc3_ = _loc4_ != null;
            }
         }
         return new FocusResult(_loc2_,_loc3_);
      }
      
      public function findNextFocus(param1:Boolean = false) : IFocusObject
      {
         var _loc2_:FocusResult = findNextFocusInternal(param1);
         return _loc2_.newFocus;
      }
      
      public function findNextContainerFocus(param1:DisplayObjectContainer, param2:DisplayObject, param3:Boolean) : IFocusObject
      {
         var _loc8_:* = null as IFocusExtras;
         var _loc9_:* = null as Array;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:* = null as DisplayObject;
         var _loc15_:* = null as IFocusObject;
         var _loc16_:* = null;
         var _loc17_:int = 0;
         var _loc5_:DisplayObjectContainer = param1;
         if(param1 is IViewPort && !(param1 is IFocusContainer))
         {
            _loc5_ = param1.parent;
         }
         var _loc6_:Boolean = param2 == null;
         var _loc7_:Array = null;
         if(_loc5_ is IFocusExclusions)
         {
            _loc7_ = _loc5_.get_focusExclusions();
         }
         if(_loc5_ is IFocusExtras)
         {
            _loc8_ = _loc5_;
            _loc9_ = _loc8_.get_focusExtrasBefore();
            if(_loc9_ != null)
            {
               _loc10_ = 0;
               if(!_loc6_)
               {
                  _loc11_ = _loc9_.indexOf(param2);
                  if(_loc11_ != -1)
                  {
                     _loc10_ = _loc11_ + 1;
                     _loc6_ = true;
                  }
               }
               if(_loc6_)
               {
                  _loc11_ = _loc10_;
                  _loc12_ = int(_loc9_.length);
                  while(_loc11_ < _loc12_)
                  {
                     _loc13_ = _loc11_++;
                     _loc14_ = _loc9_[_loc13_];
                     if(!(_loc7_ != null && _loc7_.indexOf(_loc14_) != -1))
                     {
                        _loc15_ = findNextChildFocus(_loc14_);
                        if(_loc15_ != null)
                        {
                           return _loc15_;
                        }
                     }
                  }
               }
            }
         }
         _loc10_ = 0;
         if(!_loc6_)
         {
            _loc11_ = -1;
            try
            {
               _loc11_ = param1.getChildIndex(param2);
            }
            catch(_loc_e_:*)
            {
               if(_loc11_ != -1)
               {
                  _loc10_ = _loc11_ + 1;
                  _loc6_ = true;
               }
            }
         }
         if(_loc6_)
         {
            _loc11_ = _loc10_;
            _loc12_ = param1.numChildren;
            while(_loc11_ < _loc12_)
            {
               _loc13_ = _loc11_++;
               _loc14_ = param1.getChildAt(_loc13_);
               if(!(_loc7_ != null && _loc7_.indexOf(_loc14_) != -1))
               {
                  _loc15_ = findNextChildFocus(_loc14_);
                  if(_loc15_ != null)
                  {
                     return _loc15_;
                  }
               }
            }
         }
         if(_loc5_ is IFocusExtras)
         {
            _loc8_ = _loc5_;
            _loc9_ = _loc8_.get_focusExtrasAfter();
            if(_loc9_ != null)
            {
               _loc11_ = 0;
               if(!_loc6_)
               {
                  _loc12_ = _loc9_.indexOf(param2);
                  if(_loc12_ != -1)
                  {
                     _loc11_ = _loc12_ + 1;
                     _loc6_ = true;
                  }
               }
               if(_loc6_)
               {
                  _loc12_ = _loc11_;
                  _loc13_ = int(_loc9_.length);
                  while(_loc12_ < _loc13_)
                  {
                     _loc17_ = _loc12_++;
                     _loc14_ = _loc9_[_loc17_];
                     if(!(_loc7_ != null && _loc7_.indexOf(_loc14_) != -1))
                     {
                        _loc15_ = findNextChildFocus(_loc14_);
                        if(_loc15_ != null)
                        {
                           return _loc15_;
                        }
                     }
                  }
               }
            }
         }
         if(param3 && _loc5_ != _root && _loc5_.parent != null)
         {
            _loc15_ = findNextContainerFocus(_loc5_.parent,_loc5_,true);
            if(_loc15_ != null)
            {
               return _loc15_;
            }
         }
         return null;
      }
      
      public function findNextChildFocus(param1:DisplayObject) : IFocusObject
      {
         var _loc2_:* = null as IFocusObject;
         var _loc3_:* = null as ToggleGroup;
         var _loc4_:* = null as IFocusObject;
         var _loc6_:Boolean = false;
         var _loc7_:* = null as IFocusContainer;
         if(param1 is IFocusObject)
         {
            _loc2_ = param1;
            if(isValidFocusWithKeyboard(_loc2_))
            {
               if(!(_loc2_ is IGroupedToggle))
               {
                  return _loc2_;
               }
               _loc3_ = _loc2_.get_toggleGroup();
               if(_loc3_ == null)
               {
                  return _loc2_;
               }
               if(_loc3_.get_selectedItem() is IFocusObject)
               {
                  _loc4_ = _loc3_.get_selectedItem();
                  if(get_focus() != _loc4_)
                  {
                     return _loc4_;
                  }
               }
            }
         }
         var _loc5_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc5_ != null)
         {
            _loc6_ = !(_loc5_ is IFocusObject);
            if(!_loc6_ && _loc5_ is IFocusContainer)
            {
               _loc7_ = _loc5_;
               _loc6_ = _loc7_.get_childFocusEnabled();
            }
            if(_loc6_)
            {
               _loc2_ = findNextContainerFocus(_loc5_,null,false);
               if(_loc2_ != null)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      public function findFocusForDisplayObject(param1:DisplayObject, param2:Boolean = false) : IFocusObject
      {
         var _loc4_:* = null as IFocusObject;
         if(param1 == null)
         {
            return null;
         }
         var _loc3_:IFocusObject = null;
         while(true)
         {
            if(param1 is IFocusObject)
            {
               _loc4_ = param1;
               if(isValidFocus(_loc4_,param2))
               {
                  if(_loc3_ == null || !(_loc4_ is IFocusContainer) || !_loc4_.get_childFocusEnabled())
                  {
                     _loc3_ = _loc4_;
                  }
               }
               else if(_loc4_.get_focusOwner() != null && isValidFocus(_loc4_.get_focusOwner(),param2))
               {
                  _loc3_ = _loc4_.get_focusOwner();
                  param1 = _loc4_;
               }
            }
            if(param1 == _root)
            {
               break;
            }
            param1 = param1.parent;
            if(param1 == null)
            {
               break;
            }
         }
         return _loc3_;
      }
      
      public function dispose() : void
      {
         if(get_focus() != null)
         {
            set_focus(null);
         }
         if(_focusPane != null)
         {
            if(_focusPane.parent != null)
            {
               _focusPane.parent.removeChild(_focusPane);
            }
            _focusPane = null;
         }
         var _loc1_:DisplayObject = _root;
         set_root(null);
         _root = _loc1_;
         FeathersEvent.dispatch(this,Event.CLEAR);
         _root = null;
      }
      
      public function defaultFocusManager_root_removedHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target;
         clearFocusManager(_loc2_);
      }
      
      public function defaultFocusManager_root_removedFromStageHandler(param1:Event) : void
      {
         handleRootRemovedFromStage(param1.currentTarget);
      }
      
      public function defaultFocusManager_root_mouseFocusChangeHandler(param1:FocusEvent) : void
      {
         var _loc4_:* = null as DisplayObject;
         var _loc5_:* = null as InteractiveObject;
         if(param1.isDefaultPrevented())
         {
            return;
         }
         if(!_enabled)
         {
            return;
         }
         var _loc2_:InteractiveObject = param1.relatedObject;
         var _loc3_:TextField = _loc2_ as TextField;
         if(_loc3_ != null)
         {
            if(_loc3_.type == "input" || _loc3_.selectable)
            {
               return;
            }
            _loc4_ = findFocusForDisplayObject(_loc3_);
            while(_loc4_ is IStageFocusDelegate)
            {
               _loc5_ = _loc4_.get_stageFocusTarget();
               if(_loc5_ == null)
               {
                  break;
               }
               _loc4_ = _loc5_;
            }
            if(_loc3_ == _loc4_)
            {
               return;
            }
         }
         param1.preventDefault();
      }
      
      public function defaultFocusManager_root_mouseDownCaptureHandler(param1:MouseEvent) : void
      {
         _showFocusIndicator = false;
         if(!_enabled)
         {
            return;
         }
         var _loc2_:* = param1.target;
         var _loc3_:IFocusObject = findFocusForDisplayObject(_loc2_);
         set_focus(_loc3_);
      }
      
      public function defaultFocusManager_root_keyFocusChangeHandler(param1:FocusEvent) : void
      {
         if(!_enabled || param1.isDefaultPrevented())
         {
            return;
         }
         if(param1.keyCode != 9 && param1.keyCode != 0)
         {
            return;
         }
         _showFocusIndicator = true;
         var _loc2_:FocusResult = findNextFocusInternal(param1.shiftKey);
         set_focus(_loc2_.newFocus);
         if(_wrapObject == null)
         {
            param1.preventDefault();
         }
         else if(_wrapObject is TextField && _wrapObject.type == "input")
         {
            param1.preventDefault();
         }
      }
      
      public function defaultFocusManager_root_keyDownHandler(param1:KeyboardEvent) : void
      {
         handleKeyDownFocusWrapping(param1);
         handleDPadArrowKeys(param1);
      }
      
      public function defaultFocusManager_root_focusInCaptureHandler(param1:FocusEvent) : void
      {
         if(!_enabled)
         {
            return;
         }
         _focusToRestore = findFocusForDisplayObject(param1.target);
      }
      
      public function defaultFocusManager_root_deactivateHandler(param1:Event) : void
      {
         if(!_enabled)
         {
            return;
         }
         set_focus(null);
      }
      
      public function defaultFocusManager_root_addedToStageHandler(param1:Event) : void
      {
         handleRootAddedToStage(param1.currentTarget);
      }
      
      public function defaultFocusManager_root_addedHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target;
         if(_focusPane != null)
         {
            if(_focusPane == _loc2_ || _focusPane.contains(_loc2_))
            {
               PopUpManager.forStage(_root.stage).addPopUp(_focusPane,false,false);
               return;
            }
         }
         if(shouldBeManaged(_loc2_))
         {
            setFocusManager(_loc2_);
         }
         var _loc3_:IFocusObject = null;
         if(_root.stage != null)
         {
            _loc3_ = findFocusForDisplayObject(_root.stage.focus,true);
         }
         if(_loc3_ != null && !isValidFocus(_loc3_))
         {
            set_focus(null);
         }
      }
      
      public function defaultFocusManager_root_activateHandler(param1:Event) : void
      {
         if(!_enabled)
         {
            return;
         }
         restoreFocus();
      }
      
      public function clearFocusManager(param1:DisplayObject) : void
      {
         var _loc2_:* = null as IFocusManagerAware;
         var _loc3_:* = null as IFocusObject;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:* = null as DisplayObject;
         var _loc9_:* = null as IFocusExtras;
         var _loc10_:* = null as Array;
         if(param1 is IFocusManagerAware)
         {
            _loc2_ = param1;
            if(_loc2_.get_focusManager() == this)
            {
               if(_loc2_ == _focusToRestore)
               {
                  _focusToRestore = null;
               }
               if(get_focus() == _loc2_)
               {
                  _loc3_ = null;
                  if(param1 is IFocusObject)
                  {
                     _loc3_ = _loc2_.get_focusOwner();
                  }
                  if(_loc3_ != null && _loc3_.get_focusManager() != this)
                  {
                     _loc3_ = null;
                  }
                  set_focus(_loc3_);
               }
               _loc2_.set_focusManager(null);
            }
         }
         var _loc4_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc4_ != null)
         {
            _loc5_ = 0;
            _loc6_ = _loc4_.numChildren;
            while(_loc5_ < _loc6_)
            {
               _loc7_ = _loc5_++;
               _loc8_ = _loc4_.getChildAt(_loc7_);
               clearFocusManager(_loc8_);
            }
            if(_loc4_ is IFocusExtras)
            {
               _loc9_ = _loc4_;
               _loc10_ = _loc9_.get_focusExtrasBefore();
               if(_loc10_ != null)
               {
                  _loc5_ = 0;
                  while(_loc5_ < int(_loc10_.length))
                  {
                     _loc8_ = _loc10_[_loc5_];
                     _loc5_++;
                     clearFocusManager(_loc8_);
                  }
               }
               _loc10_ = _loc9_.get_focusExtrasAfter();
               if(_loc10_ != null)
               {
                  _loc5_ = 0;
                  while(_loc5_ < int(_loc10_.length))
                  {
                     _loc8_ = _loc10_[_loc5_];
                     _loc5_++;
                     clearFocusManager(_loc8_);
                  }
               }
            }
         }
      }
   }
}

