package feathers.core
{
   import feathers.events.FeathersEvent;
   import feathers.utils.DeviceUtil;
   import feathers.utils.MathUtil;
   import feathers.utils.ScreenDensityScaleCalculator;
   import flash.Boot;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   
   public class ScreenDensityScaleManager extends EventDispatcher implements IScaleManager
   {
      
      public var _target:DisplayObject;
      
      public var _scaler:ScreenDensityScaleCalculator;
      
      public function ScreenDensityScaleManager(param1:ScreenDensityScaleCalculator = undefined)
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         _scaler = param1;
      }
      
      public function set_target(param1:DisplayObject) : DisplayObject
      {
         if(_target == param1)
         {
            return _target;
         }
         if(_target != null)
         {
            removeTargetStageListeners();
            _target.removeEventListener(Event.ADDED_TO_STAGE,screenDensityScaleManager_target_addedToStageHandler);
            _target.removeEventListener(Event.REMOVED_FROM_STAGE,screenDensityScaleManager_target_removedFromStageHandler);
         }
         _target = param1;
         if(_target != null)
         {
            _target.addEventListener(Event.ADDED_TO_STAGE,screenDensityScaleManager_target_addedToStageHandler,false,0,true);
            _target.addEventListener(Event.REMOVED_FROM_STAGE,screenDensityScaleManager_target_removedFromStageHandler,false,0,true);
            addTargetStageListeners();
         }
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _target;
      }
      
      public function set_scaler(param1:ScreenDensityScaleCalculator) : ScreenDensityScaleCalculator
      {
         if(_scaler == param1)
         {
            return _scaler;
         }
         _scaler = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _scaler;
      }
      
      public function screenDensityScaleManager_target_removedFromStageHandler(param1:Event) : void
      {
         removeTargetStageListeners();
      }
      
      public function screenDensityScaleManager_target_addedToStageHandler(param1:Event) : void
      {
         addTargetStageListeners();
      }
      
      public function screenDensityScaleManager_stage_resizeHandler(param1:Event) : void
      {
         FeathersEvent.dispatch(this,Event.CHANGE);
      }
      
      public function removeTargetStageListeners() : void
      {
         if(_target == null || _target.stage == null)
         {
            return;
         }
         _target.stage.removeEventListener(Event.RESIZE,screenDensityScaleManager_stage_resizeHandler);
      }
      
      public function get_target() : DisplayObject
      {
         return _target;
      }
      
      public function get_scaler() : ScreenDensityScaleCalculator
      {
         return _scaler;
      }
      
      public function getScale() : Number
      {
         var _loc1_:Number = 1;
         if(_target == null)
         {
            return _loc1_;
         }
         if(!DeviceUtil.isDesktop())
         {
            if(_scaler == null)
            {
               _scaler = new ScreenDensityScaleCalculator();
               _scaler.addScaleForDensity(120,0.75);
               _scaler.addScaleForDensity(160,1);
               _scaler.addScaleForDensity(240,1.5);
               _scaler.addScaleForDensity(320,2);
               _scaler.addScaleForDensity(480,3);
               _scaler.addScaleForDensity(640,4);
            }
            _loc1_ = _scaler.getScale(Capabilities.screenDPI);
         }
         return _loc1_;
      }
      
      public function getBounds() : Rectangle
      {
         var _loc1_:Rectangle = new Rectangle();
         if(_target == null)
         {
            return _loc1_;
         }
         var _loc2_:Stage = _target.stage;
         if(_loc2_ == null)
         {
            return _loc1_;
         }
         var _loc3_:Boolean = Math.floor(_target.scaleX) != _target.scaleX;
         var _loc4_:Number = Math.floor(_loc2_.stageWidth);
         if(_loc3_)
         {
            _loc4_ = MathUtil.roundDownToNearest(_loc4_,2);
         }
         _loc1_.width = _loc4_;
         var _loc5_:Number = Math.floor(_loc2_.stageHeight);
         if(_loc3_)
         {
            _loc5_ = MathUtil.roundDownToNearest(_loc5_,2);
         }
         _loc1_.height = _loc5_;
         return _loc1_;
      }
      
      public function addTargetStageListeners() : void
      {
         if(_target == null || _target.stage == null)
         {
            return;
         }
         _target.stage.addEventListener(Event.RESIZE,screenDensityScaleManager_stage_resizeHandler,false,0,true);
      }
   }
}

