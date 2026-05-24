package feathers.controls
{
   import feathers.core.FocusManager;
   import feathers.core.IFocusManager;
   import feathers.core.IFocusManagerAware;
   import feathers.core.IPopUpManager;
   import feathers.core.IScaleManager;
   import feathers.core.IToolTipManager;
   import feathers.core.InvalidationFlag;
   import feathers.core.PopUpManager;
   import feathers.core.ToolTipManager;
   import feathers.themes.steel.components.SteelApplicationStyles;
   import flash.Boot;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class Application extends LayoutGroup implements IFocusManagerAware
   {
      
      public static var _topLevelApplication:Application;
      
      public var popUpContainerFactory:Function;
      
      public var _scaleFactor:Number;
      
      public var _currentScaleManager:IScaleManager;
      
      public var _applicationToolTipManager:IToolTipManager;
      
      public var _applicationPopUpContainer:DisplayObjectContainer;
      
      public var _applicationFocusManager:IFocusManager;
      
      public var __scaleManager:IScaleManager;
      
      public function Application()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         __scaleManager = null;
         _scaleFactor = 1;
         if(Application._topLevelApplication == null)
         {
            Application._topLevelApplication = this;
         }
         initializeApplicationTheme();

         if(stage != null && root == this)
         {
            stage.scaleMode = "noScale";
            stage.align = "topLeft";
         }
         addEventListener(Event.ADDED_TO_STAGE,application_addedToStageHandler,false,100);
      }
      
      public static function get_topLevelApplication() : Application
      {
         return Application._topLevelApplication;
      }
      
      public static function defaultPopUpContainerFactory() : DisplayObjectContainer
      {
         return new Sprite();
      }
      
      override public function update() : void
      {
         var _loc1_:Boolean = isInvalid(InvalidationFlag.SIZE);
         var _loc2_:Boolean = isInvalid(InvalidationFlag.STYLES);
         if(_loc1_ || _loc2_)
         {
            refreshScaleManager();
         }
         super.update();
      }
      
      public function set_scaleManager(param1:IScaleManager) : IScaleManager
      {
         if(__scaleManager == param1)
         {
            return __scaleManager;
         }
         if(!setStyle("scaleManager"))
         {
            return __scaleManager;
         }
         _previousClearStyle = clearStyle_scaleManager;
         __scaleManager = param1;
         setInvalid(InvalidationFlag.STYLES);
         return __scaleManager;
      }
      
      public function set scaleManager(param1:IScaleManager) : void
      {
         set_scaleManager(param1);
      }
      
      public function refreshScaleManager() : void
      {
         var _loc1_:IScaleManager = _currentScaleManager;
         _currentScaleManager = get_scaleManager();
         if(_currentScaleManager == _loc1_)
         {
            return;
         }
         if(_loc1_ != null)
         {
            _loc1_.removeEventListener(Event.CHANGE,application_scaleManager_changeHandler);
            _loc1_.set_target(null);
         }
         if(_currentScaleManager != null)
         {
            _currentScaleManager.addEventListener(Event.CHANGE,application_scaleManager_changeHandler,false,0,true);
            _currentScaleManager.set_target(this);
         }
      }
      
      public function refreshDimensions() : void
      {
         if(_currentScaleManager == null)
         {
            return;
         }
         _scaleFactor = _currentScaleManager.getScale();
         scaleX = _scaleFactor;
         scaleY = _scaleFactor;
         var _loc1_:Rectangle = _currentScaleManager.getBounds();
         x = _loc1_.x;
         y = _loc1_.y;
         width = _loc1_.width;
         height = _loc1_.height;
         if(_applicationPopUpContainer != null)
         {
            _applicationPopUpContainer.scaleX = _scaleFactor;
            _applicationPopUpContainer.scaleY = _scaleFactor;
         }
      }
      
      public function prepareToolTipManager() : void
      {
         if(!ToolTipManager.hasRoot(stage))
         {
            _applicationToolTipManager = ToolTipManager.addRoot(stage);
         }
      }
      
      public function preparePopUpManager() : void
      {
         var _loc1_:* = null as Function;
         if(_applicationPopUpContainer == null)
         {
            _loc1_ = popUpContainerFactory;
            if(_loc1_ == null)
            {
               _loc1_ = Application.defaultPopUpContainerFactory;
            }
            _applicationPopUpContainer = _loc1_();
         }
         _applicationPopUpContainer.scaleX = _scaleFactor;
         _applicationPopUpContainer.scaleY = _scaleFactor;
         stage.addChild(_applicationPopUpContainer);
         var _loc2_:IPopUpManager = PopUpManager.forStage(stage);
         _loc2_.set_root(_applicationPopUpContainer);
      }
      
      public function prepareFocusManager() : void
      {
         if(!FocusManager.hasRoot(stage))
         {
            _applicationFocusManager = FocusManager.addRoot(stage);
         }
      }
      
      public function initializeApplicationTheme() : void
      {
         SteelApplicationStyles.initialize();
      }
      
      override public function get_styleContext() : Class
      {
         return Application;
      }
      
      public function get_scaleManager() : IScaleManager
      {
         return __scaleManager;
      }
      
      public function get scaleManager() : IScaleManager
      {
         return get_scaleManager();
      }
      
      public function get_scaleFactor() : Number
      {
         return _scaleFactor;
      }
      
      public function clearStyle_scaleManager() : IScaleManager
      {
         set_scaleManager(null);
         return get_scaleManager();
      }
      
      public function cleanupToolTipManager() : void
      {
         if(_applicationToolTipManager != null)
         {
            _applicationToolTipManager = null;
            ToolTipManager.removeRoot(stage);
         }
      }
      
      public function cleanupPopUpManager() : void
      {
         var _loc1_:IPopUpManager = PopUpManager.forStage(stage);
         if(_loc1_.get_root() == _applicationPopUpContainer)
         {
            _loc1_.set_root(stage);
         }
         stage.removeChild(_applicationPopUpContainer);
         _applicationPopUpContainer = null;
      }
      
      public function cleanupFocusManager() : void
      {
         if(_applicationFocusManager != null)
         {
            _applicationFocusManager = null;
            FocusManager.removeRoot(stage);
         }
      }
      
      public function application_scaleManager_changeHandler(param1:Event) : void
      {
         refreshDimensions();
      }
      
      public function application_removedFromStageHandler(param1:Event) : void
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,application_removedFromStageHandler);
         cleanupToolTipManager();
         cleanupPopUpManager();
         cleanupFocusManager();
      }
      
      public function application_addedToStageHandler(param1:Event) : void
      {
         var _loc2_:* = null;
         if(Reflect.hasField(stage,"nativeWindow"))
         {
            _loc2_ = Reflect.field(stage,"nativeWindow");
            if(_loc2_ != null)
            {
               Reflect.setProperty(_loc2_,"visible",true);
            }
         }
         addEventListener(Event.REMOVED_FROM_STAGE,application_removedFromStageHandler);
         prepareFocusManager();
         preparePopUpManager();
         prepareToolTipManager();
      }
   }
}

