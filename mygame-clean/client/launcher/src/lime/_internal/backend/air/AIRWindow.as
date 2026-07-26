package lime._internal.backend.air
{
   import flash.Boot;
   import flash.Lib;
   import flash.desktop.NotificationType;
   import flash.display.NativeWindow;
   import flash.display.NativeWindowInitOptions;
   import flash.display.NativeWindowRenderMode;
   import flash.display.NativeWindowSystemChrome;
   import flash.events.Event;
   import flash.events.NativeWindowBoundsEvent;
   import flash.html.HTMLLoader;
   import lime._internal.backend.flash.FlashApplication;
   import lime._internal.backend.flash.FlashWindow;
   import lime.ui.Window;
   
   public class AIRWindow extends FlashWindow
   {
      
      public var nativeWindow:NativeWindow;
      
      public var closing:Boolean;
      
      public function AIRWindow(param1:Window = undefined)
      {
         super(param1);
         if(Boot.skip_constructor)
         {
            return;
         }
      }
      
      override public function setTitle(param1:String) : String
      {
         if(nativeWindow != null)
         {
            nativeWindow.title = param1;
         }
         return param1;
      }
      
      override public function setMinimized(param1:Boolean) : Boolean
      {
         if(nativeWindow != null)
         {
            if(param1)
            {
               nativeWindow.minimize();
            }
            else
            {
               nativeWindow.restore();
            }
         }
         return param1;
      }
      
      override public function setMaximized(param1:Boolean) : Boolean
      {
         if(nativeWindow != null)
         {
            if(param1)
            {
               nativeWindow.maximize();
            }
            else
            {
               nativeWindow.restore();
            }
         }
         return param1;
      }
      
      override public function resize(param1:int, param2:int) : void
      {
         if(nativeWindow != null)
         {
            nativeWindow.width = param1;
            nativeWindow.height = param2;
         }
      }
      
      override public function move(param1:int, param2:int) : void
      {
         if(nativeWindow != null)
         {
            nativeWindow.x = param1;
            nativeWindow.y = param2;
         }
      }
      
      public function handleNativeWindowEvent(param1:Event) : void
      {
         var _loc2_:String = param1.type;
         if(_loc2_ == Event.CLOSE)
         {
            closing = true;
            parent.onClose.dispatch();
         }
         else if(_loc2_ == Event.CLOSING)
         {
            parent.close();
            if(parent.onClose.canceled)
            {
               param1.preventDefault();
               param1.stopImmediatePropagation();
            }
         }
         else if(_loc2_ == NativeWindowBoundsEvent.MOVE)
         {
            parent.onMove.dispatch(nativeWindow.x,nativeWindow.y);
         }
      }
      
      override public function focus() : void
      {
         if(nativeWindow != null && Boolean(nativeWindow.visible))
         {
            nativeWindow.activate();
         }
      }
      
      override public function create() : void
      {
         var _loc14_:* = null as NativeWindowInitOptions;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc1_:String = parent.__title != null && parent.__title != "" ? parent.__title : "Sanalika";
         var _loc2_:* = parent.__attributes;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Number = 60;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         if(Reflect.hasField(_loc2_,"alwaysOnTop") && Boolean(_loc2_.alwaysOnTop))
         {
            _loc3_ = true;
         }
         if(Reflect.hasField(_loc2_,"borderless") && Boolean(_loc2_.borderless))
         {
            _loc4_ = true;
         }
         if(Reflect.hasField(_loc2_,"fullscreen") && Boolean(_loc2_.fullscreen))
         {
            _loc5_ = true;
         }
         if(Reflect.hasField(_loc2_,"context") && Reflect.hasField(_loc2_.context,"hardware") && Boolean(_loc2_.context.hardware))
         {
            _loc6_ = true;
         }
         if(Reflect.hasField(_loc2_,"hidden") && Boolean(_loc2_.hidden))
         {
            _loc7_ = true;
         }
         if(Reflect.hasField(_loc2_,"maximized") && Boolean(_loc2_.maximized))
         {
            _loc8_ = true;
         }
         if(Reflect.hasField(_loc2_,"minimized") && Boolean(_loc2_.minimized))
         {
            _loc9_ = true;
         }
         if(Reflect.hasField(_loc2_,"resizable") && Boolean(_loc2_.resizable))
         {
            _loc10_ = true;
         }
         if(Reflect.hasField(_loc2_,"frameRate"))
         {
            _loc11_ = Number(_loc2_.frameRate);
         }
         if(Reflect.hasField(_loc2_,"width"))
         {
            _loc12_ = int(_loc2_.width);
         }
         if(Reflect.hasField(_loc2_,"height"))
         {
            _loc13_ = int(_loc2_.height);
         }
         if(FlashApplication.createFirstWindow)
         {
            nativeWindow = Lib.current.stage.nativeWindow;
         }
         else
         {
            _loc14_ = new NativeWindowInitOptions();
            _loc14_.systemChrome = _loc4_ ? NativeWindowSystemChrome.NONE : NativeWindowSystemChrome.STANDARD;
            _loc14_.renderMode = _loc6_ ? NativeWindowRenderMode.DIRECT : NativeWindowRenderMode.CPU;
            _loc14_.transparent = false;
            _loc14_.maximizable = _loc8_;
            _loc14_.minimizable = _loc9_;
            _loc14_.resizable = _loc10_;
            nativeWindow = new NativeWindow(_loc14_);
            nativeWindow.stage.frameRate = _loc11_;
            if(_loc12_ > 0)
            {
               nativeWindow.width = _loc12_;
            }
            if(_loc13_ > 0)
            {
               nativeWindow.height = _loc13_;
            }
         }
         if(nativeWindow != null)
         {
            parent.stage = nativeWindow.stage;
            nativeWindow.addEventListener(Event.CLOSING,handleNativeWindowEvent);
            nativeWindow.addEventListener(Event.CLOSE,handleNativeWindowEvent);
            nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE,handleNativeWindowEvent);
            if(_loc7_)
            {
               nativeWindow.visible = false;
            }
            nativeWindow.alwaysInFront = _loc3_;
            nativeWindow.title = _loc1_;
            if(_loc8_)
            {
               nativeWindow.maximize();
            }
            else if(_loc9_)
            {
               nativeWindow.minimize();
            }
         }
         if(_loc5_)
         {
            setFullscreen(true);
         }
         if(nativeWindow != null)
         {
            _loc15_ = int(nativeWindow.width);
            parent.__width = _loc15_;
            _loc16_ = int(nativeWindow.height);
            parent.__height = _loc16_;
            parent.__x = int(Math.round(nativeWindow.x));
            parent.__y = int(Math.round(nativeWindow.y));
            parent.stage = nativeWindow.stage;
         }
         super.create();
         if(_loc6_)
         {
            parent.context.attributes.hardware = true;
            parent.context.attributes.depth = true;
            parent.context.attributes.stencil = true;
         }
      }
      
      override public function close() : void
      {
         if(!closing)
         {
            closing = true;
            parent.onClose.dispatch();
            if(!parent.onClose.canceled)
            {
               nativeWindow.close();
            }
            else
            {
               closing = false;
            }
         }
      }
      
      override public function alert(param1:String, param2:String) : void
      {
         var _loc3_:* = null as HTMLLoader;
         if(nativeWindow != null)
         {
            nativeWindow.notifyUser(NotificationType.INFORMATIONAL);
            if(param1 != null)
            {
               _loc3_ = new HTMLLoader();
               _loc3_.loadString("<!DOCTYPE html><html lang=\'en\'><head><meta charset=\'utf-8\'><title></title><script></script></head><body></body></html>");
               _loc3_.window.alert(param1);
            }
         }
      }
   }
}

