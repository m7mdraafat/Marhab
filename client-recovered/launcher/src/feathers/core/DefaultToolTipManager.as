package feathers.core
{
   import feathers.controls.Label;
   import feathers.style.IVariantStyleObject;
   import feathers.themes.steel.components.SteelToolTipStyles;
   import flash.Boot;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import openfl.Lib;
   
   public class DefaultToolTipManager implements IToolTipManager
   {
      
      public static var CHILD_VARIANT_TOOL_TIP:String = "toolTip";
      
      public var _toolTipStageY:Number;
      
      public var _toolTipStageX:Number;
      
      public var _toolTip:ITextControl;
      
      public var _target:IUIControl;
      
      public var _root:DisplayObject;
      
      public var _offsetY:Number;
      
      public var _offsetX:Number;
      
      public var _hideTime:int;
      
      public var _delayTimeoutID:Object;
      
      public var _delay:Number;
      
      public function DefaultToolTipManager(param1:DisplayObject = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _offsetY = 0;
         _offsetX = 0;
         _hideTime = -1;
         _delay = 0.5;
         _delayTimeoutID = null;
         initializeToolTipStyles();
         _root = param1;
         _root.addEventListener(MouseEvent.MOUSE_MOVE,defaultToolTipManager_root_mouseMoveHandler,false,0,true);
      }
      
      public function initializeToolTipStyles() : void
      {
         SteelToolTipStyles.initialize();
      }
      
      public function hoverDelayCallback() : void
      {
         var _loc1_:* = null as Label;
         var _loc2_:* = null as IVariantStyleObject;
         _delayTimeoutID = null;
         if(_target.get_toolTip() == null)
         {
            return;
         }
         if(_toolTip == null)
         {
            _loc1_ = new Label();
            _loc1_.set_variant(DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP);
            _toolTip = _loc1_;
         }
         if(_toolTip is InteractiveObject)
         {
            _toolTip.mouseEnabled = false;
            _toolTip.tabEnabled = false;
         }
         if(_toolTip is DisplayObjectContainer)
         {
            _toolTip.mouseChildren = false;
         }
         if(_toolTip is IVariantStyleObject)
         {
            _loc2_ = _toolTip;
            if(_loc2_.get_variant() == null)
            {
               _loc2_.set_variant(DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP);
            }
         }
         _toolTip.set_text(_target.get_toolTip());
         if(_toolTip is IValidating)
         {
            _toolTip.validateNow();
         }
         var _loc3_:Stage = _target.stage;
         var _loc4_:IPopUpManager = PopUpManager.forStage(_loc3_);
         var _loc5_:Point = _loc4_.get_root().globalToLocal(new Point(_toolTipStageX,_toolTipStageY));
         var _loc6_:Point = _loc4_.get_root().globalToLocal(new Point(_loc3_.stageWidth,_loc3_.stageHeight));
         var _loc7_:Number = _loc5_.x + _offsetX;
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         else if(_loc7_ + Number(_toolTip.width) > _loc6_.x)
         {
            _loc7_ = _loc6_.x - Number(_toolTip.width);
         }
         var _loc8_:Number = _loc5_.y - Number(_toolTip.height) + _offsetY;
         if(_loc8_ < 0)
         {
            _loc8_ = 0;
         }
         else if(_loc8_ + Number(_toolTip.height) > _loc6_.y)
         {
            _loc8_ = _loc6_.y - Number(_toolTip.height);
         }
         _toolTip.x = _loc7_;
         _toolTip.y = _loc8_;
         PopUpManager.addPopUp(_toolTip,_target,false,false);
      }
      
      public function hideToolTip() : void
      {
         if(_delayTimeoutID != null)
         {
            Lib.clearTimeout(_delayTimeoutID);
            _delayTimeoutID = null;
         }
         if(_toolTip != null && _toolTip.parent != null)
         {
            PopUpManager.removePopUp(_toolTip);
            _hideTime = Lib.getTimer();
         }
      }
      
      public function get_root() : DisplayObject
      {
         return _root;
      }
      
      public function dispose() : void
      {
         clearTarget();
         if(_root != null)
         {
            _root.removeEventListener(MouseEvent.MOUSE_MOVE,defaultToolTipManager_root_mouseMoveHandler);
            _root = null;
         }
      }
      
      public function defaultToolTipManager_target_rollOutHandler(param1:MouseEvent) : void
      {
         clearTarget();
      }
      
      public function defaultToolTipManager_target_rightMouseDownHandler(param1:MouseEvent) : void
      {
         hideToolTip();
      }
      
      public function defaultToolTipManager_target_removedFromStageHandler(param1:Event) : void
      {
         clearTarget();
      }
      
      public function defaultToolTipManager_target_mouseDownHandler(param1:MouseEvent) : void
      {
         hideToolTip();
      }
      
      public function defaultToolTipManager_target_middleMouseDownHandler(param1:MouseEvent) : void
      {
         hideToolTip();
      }
      
      public function defaultToolTipManager_root_mouseMoveHandler(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         var _loc2_:DisplayObject = param1.target;
         while(_loc2_ != null && !(_loc2_ is IUIControl))
         {
            _loc2_ = _loc2_.parent;
         }
         if(!(_loc2_ is IUIControl))
         {
            clearTarget();
            return;
         }
         var _loc3_:IUIControl = _loc2_;
         if(_target == _loc3_)
         {
            _toolTipStageX = param1.stageX;
            _toolTipStageY = param1.stageY;
            return;
         }
         clearTarget();
         _target = _loc3_;
         if(_target.get_toolTip() == null)
         {
            _target = null;
            return;
         }
         _target.addEventListener(MouseEvent.MOUSE_DOWN,defaultToolTipManager_target_mouseDownHandler,false,0,true);
         _target.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,defaultToolTipManager_target_rightMouseDownHandler,false,0,true);
         _target.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN,defaultToolTipManager_target_middleMouseDownHandler,false,0,true);
         _target.addEventListener(MouseEvent.ROLL_OUT,defaultToolTipManager_target_rollOutHandler,false,0,true);
         _target.addEventListener(Event.REMOVED_FROM_STAGE,defaultToolTipManager_target_removedFromStageHandler,false,0,true);
         _toolTipStageX = param1.stageX;
         _toolTipStageY = param1.stageY;
         _delayTimeoutID = Lib.setTimeout(hoverDelayCallback,int(_delay * 1000));
      }
      
      public function clearTarget() : void
      {
         hideToolTip();
         if(_target != null)
         {
            _target.removeEventListener(MouseEvent.MOUSE_DOWN,defaultToolTipManager_target_mouseDownHandler);
            _target.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN,defaultToolTipManager_target_rightMouseDownHandler);
            _target.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN,defaultToolTipManager_target_middleMouseDownHandler);
            _target.removeEventListener(MouseEvent.ROLL_OUT,defaultToolTipManager_target_rollOutHandler);
            _target.removeEventListener(Event.REMOVED_FROM_STAGE,defaultToolTipManager_target_removedFromStageHandler);
            _target = null;
         }
      }
   }
}

