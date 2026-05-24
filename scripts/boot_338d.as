package
{
   import com.oyunstudyosu.air.embed.EmbedConfigData;
   import com.oyunstudyosu.air.progress.ProgressVo;
   import feathers.core.FocusManager;
   import feathers.core.PopUpManager;
   import feathers.core.ToolTipManager;
   import feathers.core.ValidationQueue;
   import feathers.events.FeathersEvent;
   import feathers.events.StyleProviderEvent;
   import feathers.events.TriggerEvent;
   import flash.Boot;
   import flash.Lib;
   import flash.display.MovieClip;
   import flash.display._CapsStyle.CapsStyle_Impl_;
   import flash.display._GradientType.GradientType_Impl_;
   import flash.display._InterpolationMethod.InterpolationMethod_Impl_;
   import flash.display._JointStyle.JointStyle_Impl_;
   import flash.display._LineScaleMode.LineScaleMode_Impl_;
   import flash.display._SpreadMethod.SpreadMethod_Impl_;
   import flash.events.EventDispatcher;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.ui._KeyLocation.KeyLocation_Impl_;
   import flash.ui._MouseCursor.MouseCursor_Impl_;
   import flash.utils.Dictionary;
   import flash.utils._Endian.Endian_Impl_;
   import haxe.IMap;
   import haxe.Unserializer;
   import haxe._Unserializer.DefaultResolver;
   import haxe.crypto.Base64;
   import haxe.ds.IntMap;
   import haxe.ds.ObjectMap;
   import haxe.ds.StringMap;
   import haxe.io.Bytes;
   import lime._internal.format.Base64;
   import lime.app._Event_Void_Void;
   import lime.app._Event_lime_ui_Gamepad_Void;
   import lime.app._Event_lime_ui_Joystick_Void;
   import lime.app._Event_lime_ui_Touch_Void;
   import lime.graphics._WebGL2RenderContext.WebGL2RenderContext_Impl_;
   import lime.math.Matrix3;
   import lime.system.System;
   import lime.ui.Gamepad;
   import lime.ui.Joystick;
   import lime.ui.Touch;
   import lime.ui._GamepadAxis.GamepadAxis_Impl_;
   import lime.ui._GamepadButton.GamepadButton_Impl_;
   import lime.ui._JoystickHatPosition.JoystickHatPosition_Impl_;
   import lime.ui._KeyCode.KeyCode_Impl_;
   import lime.ui._KeyModifier.KeyModifier_Impl_;
   import lime.ui._ScanCode.ScanCode_Impl_;
   import lime.utils.AssetCache;
   import lime.utils.Assets;
   import lime.utils.BytePointerData;
   import lime.utils._LogLevel.LogLevel_Impl_;
   import openfl.Lib;
   import openfl._internal.Lib;
   import openfl.display._internal.FlashGraphics;
   import openfl.utils.AssetCache;
   import openfl.utils.Assets;
   import openfl.utils.IAssetCache;
   import openfl.utils._ByteArray.ByteArray_Impl_;
   import openfl.utils._Dictionary.Dictionary_Impl_;
   
   public class boot_338d extends Boot
   {
      
      public function boot_338d()
      {
         super();
         Boot.__rebuildLog("boot_338d.constructor");
         if(Boot.skip_constructor)
         {
            return;
         }
         if(flash.Lib.current == null)
         {
            flash.Lib.current = this;
         }
         start();
      }
      
      override public function init() : void
      {
         Boot.__rebuildLog("boot_338d.init.start");
         var _loc1_:* = null as IMap;
         var _loc2_:* = null as Array;
         var _loc3_:int = 0;
         var _loc4_:* = null as Array;
         var _loc5_:* = null as String;
         var _loc6_:int = 0;
         var _loc7_:* = null as Array;
         var _loc8_:* = null as String;
         var _loc9_:* = null as Bytes;
         var _loc10_:* = null as BytePointerData;
         Math.NaN = Number(Number.NaN);
         Math.NEGATIVE_INFINITY = Number(Number.NEGATIVE_INFINITY);
         Math.POSITIVE_INFINITY = Number(Number.POSITIVE_INFINITY);
         Math.isFinite = function(param1:Number):Boolean
         {
            return isFinite(param1);
         };
         Math.isNaN = function(param1:Number):Boolean
         {
            return isNaN(param1);
         };
         if(!EmbedConfigData.init__)
         {
            EmbedConfigData.init__ = true;
            _loc1_ = new StringMap();
            if("turkey" in StringMap.reserved)
            {
               _loc1_.setReserved("turkey","Turkey");
            }
            else
            {
               _loc1_.h["turkey"] = "Turkey";
            }
            if("marhab" in StringMap.reserved)
            {
               _loc1_.setReserved("marhab","Marhab");
            }
            else
            {
               _loc1_.h["marhab"] = "Marhab";
            }
            if("egypt" in StringMap.reserved)
            {
               _loc1_.setReserved("egypt","Egypt");
            }
            else
            {
               _loc1_.h["egypt"] = "Egypt";
            }
            if("spain" in StringMap.reserved)
            {
               _loc1_.setReserved("spain","Spain");
            }
            else
            {
               _loc1_.h["spain"] = "Spain";
            }
            if("russia" in StringMap.reserved)
            {
               _loc1_.setReserved("russia","Russia");
            }
            else
            {
               _loc1_.h["russia"] = "Russia";
            }
            if("global" in StringMap.reserved)
            {
               _loc1_.setReserved("global","Global");
            }
            else
            {
               _loc1_.h["global"] = "Global";
            }
            EmbedConfigData.instances = _loc1_;
         }
         if(!ProgressVo.init__)
         {
            ProgressVo.init__ = true;
            ProgressVo.CONNECTING = new ProgressVo(0,"CONNECTING");
            ProgressVo.LANG_FILE_READY = new ProgressVo(10,"LANG_FILE_READY");
            ProgressVo.CONNECTED = new ProgressVo(20,"CONNECTED");
            ProgressVo.CONNECTION_FAIL = new ProgressVo(0,"CONNECTION_FAIL");
            ProgressVo.CONNECTION_RETRY = new ProgressVo(20,"CONNECTION_RETRY");
            ProgressVo.LOGINED = new ProgressVo(30,"LOGINED");
            ProgressVo.CONFIG_READY = new ProgressVo(40,"CONFIG_READY");
            ProgressVo.INFO_FILE_READY = new ProgressVo(50,"INFO_FILE_READY");
            ProgressVo.GAME_EXTENSIONS_LOADED = new ProgressVo(60,"GAME_EXTENSIONS_LOADED");
            ProgressVo.INIT_READY = new ProgressVo(70,"INIT_READY");
            ProgressVo.GAME_READY = new ProgressVo(80,"GAME_READY");
            ProgressVo.PROGRESS_FULL = new ProgressVo(100,"PROGRESS_FULL");
            ProgressVo.LOADING = new ProgressVo(0,"LOADING");
            ProgressVo.ROOM_FILES = new ProgressVo(0,"ROOM_FILES");
            ProgressVo.LOAD_DESIGNER = new ProgressVo(10,"LOAD_DESIGNER");
            ProgressVo.LOAD_PLAYBACK_PLAYER = new ProgressVo(10,"LOAD_PLAYBACK_PLAYER");
            ProgressVo.DESIGNER_LOADED = new ProgressVo(100,"DESIGNER_LOADED");
            ProgressVo.JOINING_USER_ROOM = new ProgressVo(0,"JOINING_USER_ROOM");
         }
         if(!FocusManager.init__)
         {
            FocusManager.init__ = true;
            FocusManager.stageToManager = new ObjectMap();
            FocusManager._focusManagerFactory = FocusManager.defaultFocusManagerFactory;
         }
         if(!PopUpManager.init__)
         {
            PopUpManager.init__ = true;
            PopUpManager.stageToManager = new ObjectMap();
         }
         if(!ToolTipManager.init__)
         {
            ToolTipManager.init__ = true;
            ToolTipManager._toolTipManagerFactory = ToolTipManager.defaultToolTipManagerFactory;
            ToolTipManager.stageToManager = new ObjectMap();
         }
         if(!ValidationQueue.init__)
         {
            ValidationQueue.init__ = true;
            ValidationQueue.STAGE_TO_VALIDATION_QUEUE = new ObjectMap();
         }
         if(!FeathersEvent.init__)
         {
            FeathersEvent.init__ = true;
            FeathersEvent.INITIALIZE = "initialize";
            FeathersEvent.CREATION_COMPLETE = "creationComplete";
            FeathersEvent.LAYOUT_DATA_CHANGE = "layoutDataChange";
            FeathersEvent.STATE_CHANGE = "stateChange";
            FeathersEvent.OPENING = "opening";
            FeathersEvent.CLOSING = "closing";
            FeathersEvent.ENABLE = "enable";
            FeathersEvent.DISABLE = "disable";
         }
         if(!StyleProviderEvent.init__)
         {
            StyleProviderEvent.init__ = true;
            StyleProviderEvent.STYLES_CHANGE = "stylesChange";
         }
         if(!TriggerEvent.init__)
         {
            TriggerEvent.init__ = true;
            TriggerEvent.TRIGGER = "trigger";
         }
         if(!CapsStyle_Impl_.init__)
         {
            CapsStyle_Impl_.init__ = true;
            CapsStyle_Impl_.NONE = "none";
            CapsStyle_Impl_.ROUND = "round";
            CapsStyle_Impl_.SQUARE = "square";
         }
         if(!GradientType_Impl_.init__)
         {
            GradientType_Impl_.init__ = true;
            GradientType_Impl_.LINEAR = "linear";
            GradientType_Impl_.RADIAL = "radial";
         }
         if(!InterpolationMethod_Impl_.init__)
         {
            InterpolationMethod_Impl_.init__ = true;
            InterpolationMethod_Impl_.LINEAR_RGB = "linearRGB";
            InterpolationMethod_Impl_.RGB = "rgb";
         }
         if(!JointStyle_Impl_.init__)
         {
            JointStyle_Impl_.init__ = true;
            JointStyle_Impl_.MITER = "miter";
            JointStyle_Impl_.ROUND = "round";
            JointStyle_Impl_.BEVEL = "bevel";
         }
         if(!LineScaleMode_Impl_.init__)
         {
            LineScaleMode_Impl_.init__ = true;
            LineScaleMode_Impl_.HORIZONTAL = "horizontal";
            LineScaleMode_Impl_.NONE = "none";
            LineScaleMode_Impl_.NORMAL = "normal";
            LineScaleMode_Impl_.VERTICAL = "vertical";
         }
         if(!SpreadMethod_Impl_.init__)
         {
            SpreadMethod_Impl_.init__ = true;
            SpreadMethod_Impl_.PAD = "pad";
            SpreadMethod_Impl_.REFLECT = "reflect";
            SpreadMethod_Impl_.REPEAT = "repeat";
         }
         if(!KeyLocation_Impl_.init__)
         {
            KeyLocation_Impl_.init__ = true;
            KeyLocation_Impl_.LEFT = 1;
            KeyLocation_Impl_.NUM_PAD = 3;
            KeyLocation_Impl_.RIGHT = 2;
            KeyLocation_Impl_.STANDARD = 0;
         }
         if(!MouseCursor_Impl_.init__)
         {
            MouseCursor_Impl_.init__ = true;
            MouseCursor_Impl_.ARROW = "arrow";
            MouseCursor_Impl_.AUTO = "auto";
            MouseCursor_Impl_.BUTTON = "button";
            MouseCursor_Impl_.HAND = "hand";
            MouseCursor_Impl_.IBEAM = "ibeam";
         }
         if(!Endian_Impl_.init__)
         {
            Endian_Impl_.init__ = true;
            Endian_Impl_.BIG_ENDIAN = "bigEndian";
            Endian_Impl_.LITTLE_ENDIAN = "littleEndian";
         }
         if(!Unserializer.init__)
         {
            Unserializer.init__ = true;
            Unserializer.DEFAULT_RESOLVER = new DefaultResolver();
         }
         if(!haxe.crypto.Base64.init__)
         {
            haxe.crypto.Base64.init__ = true;
            haxe.crypto.Base64.BYTES = Bytes.ofString(haxe.crypto.Base64.CHARS);
         }
         if(!lime._internal.format.Base64.init__)
         {
            lime._internal.format.Base64.init__ = true;
            lime._internal.format.Base64.DICTIONARY = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".split("");
            _loc2_ = [];
            _loc3_ = 0;
            _loc4_ = lime._internal.format.Base64.DICTIONARY;
            while(_loc3_ < int(_loc4_.length))
            {
               _loc5_ = _loc4_[_loc3_];
               _loc3_++;
               _loc6_ = 0;
               _loc7_ = lime._internal.format.Base64.DICTIONARY;
               while(_loc6_ < int(_loc7_.length))
               {
                  _loc8_ = _loc7_[_loc6_];
                  _loc6_++;
                  _loc2_.push(_loc5_ + _loc8_);
               }
            }
            lime._internal.format.Base64.EXTENDED_DICTIONARY = _loc2_;
         }
         if(!WebGL2RenderContext_Impl_.init__)
         {
            WebGL2RenderContext_Impl_.init__ = true;
            var _temp_1:* = WebGL2RenderContext_Impl_;
            _loc9_ = null;
            _loc10_ = new BytePointerData(_loc9_,0);
            _temp_1.__tempPointer = _loc10_;
         }
         if(!Matrix3.init__)
         {
            Matrix3.init__ = true;
            Matrix3.__identity = new Matrix3();
         }
         if(!System.init__)
         {
            System.init__ = true;
            System.__directories = new IntMap();
         }
         if(!Gamepad.init__)
         {
            Gamepad.init__ = true;
            Gamepad.devices = new IntMap();
            Gamepad.onConnect = new _Event_lime_ui_Gamepad_Void();
         }
         if(!GamepadAxis_Impl_.init__)
         {
            GamepadAxis_Impl_.init__ = true;
            GamepadAxis_Impl_.LEFT_X = 0;
            GamepadAxis_Impl_.LEFT_Y = 1;
            GamepadAxis_Impl_.RIGHT_X = 2;
            GamepadAxis_Impl_.RIGHT_Y = 3;
            GamepadAxis_Impl_.TRIGGER_LEFT = 4;
            GamepadAxis_Impl_.TRIGGER_RIGHT = 5;
         }
         if(!GamepadButton_Impl_.init__)
         {
            GamepadButton_Impl_.init__ = true;
            GamepadButton_Impl_.A = 0;
            GamepadButton_Impl_.B = 1;
            GamepadButton_Impl_.X = 2;
            GamepadButton_Impl_.Y = 3;
            GamepadButton_Impl_.BACK = 4;
            GamepadButton_Impl_.GUIDE = 5;
            GamepadButton_Impl_.START = 6;
            GamepadButton_Impl_.LEFT_STICK = 7;
            GamepadButton_Impl_.RIGHT_STICK = 8;
            GamepadButton_Impl_.LEFT_SHOULDER = 9;
            GamepadButton_Impl_.RIGHT_SHOULDER = 10;
            GamepadButton_Impl_.DPAD_UP = 11;
            GamepadButton_Impl_.DPAD_DOWN = 12;
            GamepadButton_Impl_.DPAD_LEFT = 13;
            GamepadButton_Impl_.DPAD_RIGHT = 14;
         }
         if(!Joystick.init__)
         {
            Joystick.init__ = true;
            Joystick.devices = new IntMap();
            Joystick.onConnect = new _Event_lime_ui_Joystick_Void();
         }
         if(!JoystickHatPosition_Impl_.init__)
         {
            JoystickHatPosition_Impl_.init__ = true;
            JoystickHatPosition_Impl_.CENTER = 0;
            JoystickHatPosition_Impl_.DOWN = 4;
            JoystickHatPosition_Impl_.LEFT = 8;
            JoystickHatPosition_Impl_.RIGHT = 2;
            JoystickHatPosition_Impl_.UP = 1;
            JoystickHatPosition_Impl_.DOWN_LEFT = 12;
            JoystickHatPosition_Impl_.DOWN_RIGHT = 6;
            JoystickHatPosition_Impl_.UP_LEFT = 9;
            JoystickHatPosition_Impl_.UP_RIGHT = 3;
         }
         if(!KeyCode_Impl_.init__)
         {
            KeyCode_Impl_.init__ = true;
            KeyCode_Impl_.UNKNOWN = 0;
            KeyCode_Impl_.BACKSPACE = 8;
            KeyCode_Impl_.TAB = 9;
            KeyCode_Impl_.RETURN = 13;
            KeyCode_Impl_.ESCAPE = 27;
            KeyCode_Impl_.SPACE = 32;
            KeyCode_Impl_.EXCLAMATION = 33;
            KeyCode_Impl_.QUOTE = 34;
            KeyCode_Impl_.HASH = 35;
            KeyCode_Impl_.DOLLAR = 36;
            KeyCode_Impl_.PERCENT = 37;
            KeyCode_Impl_.AMPERSAND = 38;
            KeyCode_Impl_.SINGLE_QUOTE = 39;
            KeyCode_Impl_.LEFT_PARENTHESIS = 40;
            KeyCode_Impl_.RIGHT_PARENTHESIS = 41;
            KeyCode_Impl_.ASTERISK = 42;
            KeyCode_Impl_.PLUS = 43;
            KeyCode_Impl_.COMMA = 44;
            KeyCode_Impl_.MINUS = 45;
            KeyCode_Impl_.PERIOD = 46;
            KeyCode_Impl_.SLASH = 47;
            KeyCode_Impl_.NUMBER_0 = 48;
            KeyCode_Impl_.NUMBER_1 = 49;
            KeyCode_Impl_.NUMBER_2 = 50;
            KeyCode_Impl_.NUMBER_3 = 51;
            KeyCode_Impl_.NUMBER_4 = 52;
            KeyCode_Impl_.NUMBER_5 = 53;
            KeyCode_Impl_.NUMBER_6 = 54;
            KeyCode_Impl_.NUMBER_7 = 55;
            KeyCode_Impl_.NUMBER_8 = 56;
            KeyCode_Impl_.NUMBER_9 = 57;
            KeyCode_Impl_.COLON = 58;
            KeyCode_Impl_.SEMICOLON = 59;
            KeyCode_Impl_.LESS_THAN = 60;
            KeyCode_Impl_.EQUALS = 61;
            KeyCode_Impl_.GREATER_THAN = 62;
            KeyCode_Impl_.QUESTION = 63;
            KeyCode_Impl_.AT = 64;
            KeyCode_Impl_.LEFT_BRACKET = 91;
            KeyCode_Impl_.BACKSLASH = 92;
            KeyCode_Impl_.RIGHT_BRACKET = 93;
            KeyCode_Impl_.CARET = 94;
            KeyCode_Impl_.UNDERSCORE = 95;
            KeyCode_Impl_.GRAVE = 96;
            KeyCode_Impl_.A = 97;
            KeyCode_Impl_.B = 98;
            KeyCode_Impl_.C = 99;
            KeyCode_Impl_.D = 100;
            KeyCode_Impl_.E = 101;
            KeyCode_Impl_.F = 102;
            KeyCode_Impl_.G = 103;
            KeyCode_Impl_.H = 104;
            KeyCode_Impl_.I = 105;
            KeyCode_Impl_.J = 106;
            KeyCode_Impl_.K = 107;
            KeyCode_Impl_.L = 108;
            KeyCode_Impl_.M = 109;
            KeyCode_Impl_.N = 110;
            KeyCode_Impl_.O = 111;
            KeyCode_Impl_.P = 112;
            KeyCode_Impl_.Q = 113;
            KeyCode_Impl_.R = 114;
            KeyCode_Impl_.S = 115;
            KeyCode_Impl_.T = 116;
            KeyCode_Impl_.U = 117;
            KeyCode_Impl_.V = 118;
            KeyCode_Impl_.W = 119;
            KeyCode_Impl_.X = 120;
            KeyCode_Impl_.Y = 121;
            KeyCode_Impl_.Z = 122;
            KeyCode_Impl_.DELETE = 127;
            KeyCode_Impl_.CAPS_LOCK = 1073741881;
            KeyCode_Impl_.F1 = 1073741882;
            KeyCode_Impl_.F2 = 1073741883;
            KeyCode_Impl_.F3 = 1073741884;
            KeyCode_Impl_.F4 = 1073741885;
            KeyCode_Impl_.F5 = 1073741886;
            KeyCode_Impl_.F6 = 1073741887;
            KeyCode_Impl_.F7 = 1073741888;
            KeyCode_Impl_.F8 = 1073741889;
            KeyCode_Impl_.F9 = 1073741890;
            KeyCode_Impl_.F10 = 1073741891;
            KeyCode_Impl_.F11 = 1073741892;
            KeyCode_Impl_.F12 = 1073741893;
            KeyCode_Impl_.PRINT_SCREEN = 1073741894;
            KeyCode_Impl_.SCROLL_LOCK = 1073741895;
            KeyCode_Impl_.PAUSE = 1073741896;
            KeyCode_Impl_.INSERT = 1073741897;
            KeyCode_Impl_.HOME = 1073741898;
            KeyCode_Impl_.PAGE_UP = 1073741899;
            KeyCode_Impl_.END = 1073741901;
            KeyCode_Impl_.PAGE_DOWN = 1073741902;
            KeyCode_Impl_.RIGHT = 1073741903;
            KeyCode_Impl_.LEFT = 1073741904;
            KeyCode_Impl_.DOWN = 1073741905;
            KeyCode_Impl_.UP = 1073741906;
            KeyCode_Impl_.NUM_LOCK = 1073741907;
            KeyCode_Impl_.NUMPAD_DIVIDE = 1073741908;
            KeyCode_Impl_.NUMPAD_MULTIPLY = 1073741909;
            KeyCode_Impl_.NUMPAD_MINUS = 1073741910;
            KeyCode_Impl_.NUMPAD_PLUS = 1073741911;
            KeyCode_Impl_.NUMPAD_ENTER = 1073741912;
            KeyCode_Impl_.NUMPAD_1 = 1073741913;
            KeyCode_Impl_.NUMPAD_2 = 1073741914;
            KeyCode_Impl_.NUMPAD_3 = 1073741915;
            KeyCode_Impl_.NUMPAD_4 = 1073741916;
            KeyCode_Impl_.NUMPAD_5 = 1073741917;
            KeyCode_Impl_.NUMPAD_6 = 1073741918;
            KeyCode_Impl_.NUMPAD_7 = 1073741919;
            KeyCode_Impl_.NUMPAD_8 = 1073741920;
            KeyCode_Impl_.NUMPAD_9 = 1073741921;
            KeyCode_Impl_.NUMPAD_0 = 1073741922;
            KeyCode_Impl_.NUMPAD_PERIOD = 1073741923;
            KeyCode_Impl_.APPLICATION = 1073741925;
            KeyCode_Impl_.POWER = 1073741926;
            KeyCode_Impl_.NUMPAD_EQUALS = 1073741927;
            KeyCode_Impl_.F13 = 1073741928;
            KeyCode_Impl_.F14 = 1073741929;
            KeyCode_Impl_.F15 = 1073741930;
            KeyCode_Impl_.F16 = 1073741931;
            KeyCode_Impl_.F17 = 1073741932;
            KeyCode_Impl_.F18 = 1073741933;
            KeyCode_Impl_.F19 = 1073741934;
            KeyCode_Impl_.F20 = 1073741935;
            KeyCode_Impl_.F21 = 1073741936;
            KeyCode_Impl_.F22 = 1073741937;
            KeyCode_Impl_.F23 = 1073741938;
            KeyCode_Impl_.F24 = 1073741939;
            KeyCode_Impl_.EXECUTE = 1073741940;
            KeyCode_Impl_.HELP = 1073741941;
            KeyCode_Impl_.MENU = 1073741942;
            KeyCode_Impl_.SELECT = 1073741943;
            KeyCode_Impl_.STOP = 1073741944;
            KeyCode_Impl_.AGAIN = 1073741945;
            KeyCode_Impl_.UNDO = 1073741946;
            KeyCode_Impl_.CUT = 1073741947;
            KeyCode_Impl_.COPY = 1073741948;
            KeyCode_Impl_.PASTE = 1073741949;
            KeyCode_Impl_.FIND = 1073741950;
            KeyCode_Impl_.MUTE = 1073741951;
            KeyCode_Impl_.VOLUME_UP = 1073741952;
            KeyCode_Impl_.VOLUME_DOWN = 1073741953;
            KeyCode_Impl_.NUMPAD_COMMA = 1073741957;
            KeyCode_Impl_.ALT_ERASE = 1073741977;
            KeyCode_Impl_.SYSTEM_REQUEST = 1073741978;
            KeyCode_Impl_.CANCEL = 1073741979;
            KeyCode_Impl_.CLEAR = 1073741980;
            KeyCode_Impl_.PRIOR = 1073741981;
            KeyCode_Impl_.RETURN2 = 1073741982;
            KeyCode_Impl_.SEPARATOR = 1073741983;
            KeyCode_Impl_.OUT = 1073741984;
            KeyCode_Impl_.OPER = 1073741985;
            KeyCode_Impl_.CLEAR_AGAIN = 1073741986;
            KeyCode_Impl_.CRSEL = 1073741987;
            KeyCode_Impl_.EXSEL = 1073741988;
            KeyCode_Impl_.NUMPAD_00 = 1073742000;
            KeyCode_Impl_.NUMPAD_000 = 1073742001;
            KeyCode_Impl_.THOUSAND_SEPARATOR = 1073742002;
            KeyCode_Impl_.DECIMAL_SEPARATOR = 1073742003;
            KeyCode_Impl_.CURRENCY_UNIT = 1073742004;
            KeyCode_Impl_.CURRENCY_SUBUNIT = 1073742005;
            KeyCode_Impl_.NUMPAD_LEFT_PARENTHESIS = 1073742006;
            KeyCode_Impl_.NUMPAD_RIGHT_PARENTHESIS = 1073742007;
            KeyCode_Impl_.NUMPAD_LEFT_BRACE = 1073742008;
            KeyCode_Impl_.NUMPAD_RIGHT_BRACE = 1073742009;
            KeyCode_Impl_.NUMPAD_TAB = 1073742010;
            KeyCode_Impl_.NUMPAD_BACKSPACE = 1073742011;
            KeyCode_Impl_.NUMPAD_A = 1073742012;
            KeyCode_Impl_.NUMPAD_B = 1073742013;
            KeyCode_Impl_.NUMPAD_C = 1073742014;
            KeyCode_Impl_.NUMPAD_D = 1073742015;
            KeyCode_Impl_.NUMPAD_E = 1073742016;
            KeyCode_Impl_.NUMPAD_F = 1073742017;
            KeyCode_Impl_.NUMPAD_XOR = 1073742018;
            KeyCode_Impl_.NUMPAD_POWER = 1073742019;
            KeyCode_Impl_.NUMPAD_PERCENT = 1073742020;
            KeyCode_Impl_.NUMPAD_LESS_THAN = 1073742021;
            KeyCode_Impl_.NUMPAD_GREATER_THAN = 1073742022;
            KeyCode_Impl_.NUMPAD_AMPERSAND = 1073742023;
            KeyCode_Impl_.NUMPAD_DOUBLE_AMPERSAND = 1073742024;
            KeyCode_Impl_.NUMPAD_VERTICAL_BAR = 1073742025;
            KeyCode_Impl_.NUMPAD_DOUBLE_VERTICAL_BAR = 1073742026;
            KeyCode_Impl_.NUMPAD_COLON = 1073742027;
            KeyCode_Impl_.NUMPAD_HASH = 1073742028;
            KeyCode_Impl_.NUMPAD_SPACE = 1073742029;
            KeyCode_Impl_.NUMPAD_AT = 1073742030;
            KeyCode_Impl_.NUMPAD_EXCLAMATION = 1073742031;
            KeyCode_Impl_.NUMPAD_MEM_STORE = 1073742032;
            KeyCode_Impl_.NUMPAD_MEM_RECALL = 1073742033;
            KeyCode_Impl_.NUMPAD_MEM_CLEAR = 1073742034;
            KeyCode_Impl_.NUMPAD_MEM_ADD = 1073742035;
            KeyCode_Impl_.NUMPAD_MEM_SUBTRACT = 1073742036;
            KeyCode_Impl_.NUMPAD_MEM_MULTIPLY = 1073742037;
            KeyCode_Impl_.NUMPAD_MEM_DIVIDE = 1073742038;
            KeyCode_Impl_.NUMPAD_PLUS_MINUS = 1073742039;
            KeyCode_Impl_.NUMPAD_CLEAR = 1073742040;
            KeyCode_Impl_.NUMPAD_CLEAR_ENTRY = 1073742041;
            KeyCode_Impl_.NUMPAD_BINARY = 1073742042;
            KeyCode_Impl_.NUMPAD_OCTAL = 1073742043;
            KeyCode_Impl_.NUMPAD_DECIMAL = 1073742044;
            KeyCode_Impl_.NUMPAD_HEXADECIMAL = 1073742045;
            KeyCode_Impl_.LEFT_CTRL = 1073742048;
            KeyCode_Impl_.LEFT_SHIFT = 1073742049;
            KeyCode_Impl_.LEFT_ALT = 1073742050;
            KeyCode_Impl_.LEFT_META = 1073742051;
            KeyCode_Impl_.RIGHT_CTRL = 1073742052;
            KeyCode_Impl_.RIGHT_SHIFT = 1073742053;
            KeyCode_Impl_.RIGHT_ALT = 1073742054;
            KeyCode_Impl_.RIGHT_META = 1073742055;
            KeyCode_Impl_.MODE = 1073742081;
            KeyCode_Impl_.AUDIO_NEXT = 1073742082;
            KeyCode_Impl_.AUDIO_PREVIOUS = 1073742083;
            KeyCode_Impl_.AUDIO_STOP = 1073742084;
            KeyCode_Impl_.AUDIO_PLAY = 1073742085;
            KeyCode_Impl_.AUDIO_MUTE = 1073742086;
            KeyCode_Impl_.MEDIA_SELECT = 1073742087;
            KeyCode_Impl_.WWW = 1073742088;
            KeyCode_Impl_.MAIL = 1073742089;
            KeyCode_Impl_.CALCULATOR = 1073742090;
            KeyCode_Impl_.COMPUTER = 1073742091;
            KeyCode_Impl_.APP_CONTROL_SEARCH = 1073742092;
            KeyCode_Impl_.APP_CONTROL_HOME = 1073742093;
            KeyCode_Impl_.APP_CONTROL_BACK = 1073742094;
            KeyCode_Impl_.APP_CONTROL_FORWARD = 1073742095;
            KeyCode_Impl_.APP_CONTROL_STOP = 1073742096;
            KeyCode_Impl_.APP_CONTROL_REFRESH = 1073742097;
            KeyCode_Impl_.APP_CONTROL_BOOKMARKS = 1073742098;
            KeyCode_Impl_.BRIGHTNESS_DOWN = 1073742099;
            KeyCode_Impl_.BRIGHTNESS_UP = 1073742100;
            KeyCode_Impl_.DISPLAY_SWITCH = 1073742101;
            KeyCode_Impl_.BACKLIGHT_TOGGLE = 1073742102;
            KeyCode_Impl_.BACKLIGHT_DOWN = 1073742103;
            KeyCode_Impl_.BACKLIGHT_UP = 1073742104;
            KeyCode_Impl_.EJECT = 1073742105;
            KeyCode_Impl_.SLEEP = 1073742106;
         }
         if(!KeyModifier_Impl_.init__)
         {
            KeyModifier_Impl_.init__ = true;
            KeyModifier_Impl_.NONE = 0;
            KeyModifier_Impl_.LEFT_SHIFT = 1;
            KeyModifier_Impl_.RIGHT_SHIFT = 2;
            KeyModifier_Impl_.LEFT_CTRL = 64;
            KeyModifier_Impl_.RIGHT_CTRL = 128;
            KeyModifier_Impl_.LEFT_ALT = 256;
            KeyModifier_Impl_.RIGHT_ALT = 512;
            KeyModifier_Impl_.LEFT_META = 1024;
            KeyModifier_Impl_.RIGHT_META = 2048;
            KeyModifier_Impl_.NUM_LOCK = 4096;
            KeyModifier_Impl_.CAPS_LOCK = 8192;
            KeyModifier_Impl_.MODE = 16384;
            KeyModifier_Impl_.CTRL = 192;
            KeyModifier_Impl_.SHIFT = 3;
            KeyModifier_Impl_.ALT = 768;
            KeyModifier_Impl_.META = 3072;
         }
         if(!ScanCode_Impl_.init__)
         {
            ScanCode_Impl_.init__ = true;
            ScanCode_Impl_.UNKNOWN = 0;
            ScanCode_Impl_.BACKSPACE = 42;
            ScanCode_Impl_.TAB = 43;
            ScanCode_Impl_.RETURN = 40;
            ScanCode_Impl_.ESCAPE = 41;
            ScanCode_Impl_.SPACE = 44;
            ScanCode_Impl_.SINGLE_QUOTE = 52;
            ScanCode_Impl_.COMMA = 54;
            ScanCode_Impl_.MINUS = 45;
            ScanCode_Impl_.PERIOD = 55;
            ScanCode_Impl_.SLASH = 56;
            ScanCode_Impl_.NUMBER_0 = 39;
            ScanCode_Impl_.NUMBER_1 = 30;
            ScanCode_Impl_.NUMBER_2 = 31;
            ScanCode_Impl_.NUMBER_3 = 32;
            ScanCode_Impl_.NUMBER_4 = 33;
            ScanCode_Impl_.NUMBER_5 = 34;
            ScanCode_Impl_.NUMBER_6 = 35;
            ScanCode_Impl_.NUMBER_7 = 36;
            ScanCode_Impl_.NUMBER_8 = 37;
            ScanCode_Impl_.NUMBER_9 = 38;
            ScanCode_Impl_.SEMICOLON = 51;
            ScanCode_Impl_.EQUALS = 46;
            ScanCode_Impl_.LEFT_BRACKET = 47;
            ScanCode_Impl_.BACKSLASH = 49;
            ScanCode_Impl_.RIGHT_BRACKET = 48;
            ScanCode_Impl_.GRAVE = 53;
            ScanCode_Impl_.A = 4;
            ScanCode_Impl_.B = 5;
            ScanCode_Impl_.C = 6;
            ScanCode_Impl_.D = 7;
            ScanCode_Impl_.E = 8;
            ScanCode_Impl_.F = 9;
            ScanCode_Impl_.G = 10;
            ScanCode_Impl_.H = 11;
            ScanCode_Impl_.I = 12;
            ScanCode_Impl_.J = 13;
            ScanCode_Impl_.K = 14;
            ScanCode_Impl_.L = 15;
            ScanCode_Impl_.M = 16;
            ScanCode_Impl_.N = 17;
            ScanCode_Impl_.O = 18;
            ScanCode_Impl_.P = 19;
            ScanCode_Impl_.Q = 20;
            ScanCode_Impl_.R = 21;
            ScanCode_Impl_.S = 22;
            ScanCode_Impl_.T = 23;
            ScanCode_Impl_.U = 24;
            ScanCode_Impl_.V = 25;
            ScanCode_Impl_.W = 26;
            ScanCode_Impl_.X = 27;
            ScanCode_Impl_.Y = 28;
            ScanCode_Impl_.Z = 29;
            ScanCode_Impl_.DELETE = 76;
            ScanCode_Impl_.CAPS_LOCK = 57;
            ScanCode_Impl_.F1 = 58;
            ScanCode_Impl_.F2 = 59;
            ScanCode_Impl_.F3 = 60;
            ScanCode_Impl_.F4 = 61;
            ScanCode_Impl_.F5 = 62;
            ScanCode_Impl_.F6 = 63;
            ScanCode_Impl_.F7 = 64;
            ScanCode_Impl_.F8 = 65;
            ScanCode_Impl_.F9 = 66;
            ScanCode_Impl_.F10 = 67;
            ScanCode_Impl_.F11 = 68;
            ScanCode_Impl_.F12 = 69;
            ScanCode_Impl_.PRINT_SCREEN = 70;
            ScanCode_Impl_.SCROLL_LOCK = 71;
            ScanCode_Impl_.PAUSE = 72;
            ScanCode_Impl_.INSERT = 73;
            ScanCode_Impl_.HOME = 74;
            ScanCode_Impl_.PAGE_UP = 75;
            ScanCode_Impl_.END = 77;
            ScanCode_Impl_.PAGE_DOWN = 78;
            ScanCode_Impl_.RIGHT = 79;
            ScanCode_Impl_.LEFT = 80;
            ScanCode_Impl_.DOWN = 81;
            ScanCode_Impl_.UP = 82;
            ScanCode_Impl_.NUM_LOCK = 83;
            ScanCode_Impl_.NUMPAD_DIVIDE = 84;
            ScanCode_Impl_.NUMPAD_MULTIPLY = 85;
            ScanCode_Impl_.NUMPAD_MINUS = 86;
            ScanCode_Impl_.NUMPAD_PLUS = 87;
            ScanCode_Impl_.NUMPAD_ENTER = 88;
            ScanCode_Impl_.NUMPAD_1 = 89;
            ScanCode_Impl_.NUMPAD_2 = 90;
            ScanCode_Impl_.NUMPAD_3 = 91;
            ScanCode_Impl_.NUMPAD_4 = 92;
            ScanCode_Impl_.NUMPAD_5 = 93;
            ScanCode_Impl_.NUMPAD_6 = 94;
            ScanCode_Impl_.NUMPAD_7 = 95;
            ScanCode_Impl_.NUMPAD_8 = 96;
            ScanCode_Impl_.NUMPAD_9 = 97;
            ScanCode_Impl_.NUMPAD_0 = 98;
            ScanCode_Impl_.NUMPAD_PERIOD = 99;
            ScanCode_Impl_.APPLICATION = 101;
            ScanCode_Impl_.POWER = 102;
            ScanCode_Impl_.NUMPAD_EQUALS = 103;
            ScanCode_Impl_.F13 = 104;
            ScanCode_Impl_.F14 = 105;
            ScanCode_Impl_.F15 = 106;
            ScanCode_Impl_.F16 = 107;
            ScanCode_Impl_.F17 = 108;
            ScanCode_Impl_.F18 = 109;
            ScanCode_Impl_.F19 = 110;
            ScanCode_Impl_.F20 = 111;
            ScanCode_Impl_.F21 = 112;
            ScanCode_Impl_.F22 = 113;
            ScanCode_Impl_.F23 = 114;
            ScanCode_Impl_.F24 = 115;
            ScanCode_Impl_.EXECUTE = 116;
            ScanCode_Impl_.HELP = 117;
            ScanCode_Impl_.MENU = 118;
            ScanCode_Impl_.SELECT = 119;
            ScanCode_Impl_.STOP = 120;
            ScanCode_Impl_.AGAIN = 121;
            ScanCode_Impl_.UNDO = 122;
            ScanCode_Impl_.CUT = 123;
            ScanCode_Impl_.COPY = 124;
            ScanCode_Impl_.PASTE = 125;
            ScanCode_Impl_.FIND = 126;
            ScanCode_Impl_.MUTE = 127;
            ScanCode_Impl_.VOLUME_UP = 128;
            ScanCode_Impl_.VOLUME_DOWN = 129;
            ScanCode_Impl_.NUMPAD_COMMA = 133;
            ScanCode_Impl_.ALT_ERASE = 153;
            ScanCode_Impl_.SYSTEM_REQUEST = 154;
            ScanCode_Impl_.CANCEL = 155;
            ScanCode_Impl_.CLEAR = 156;
            ScanCode_Impl_.PRIOR = 157;
            ScanCode_Impl_.RETURN2 = 158;
            ScanCode_Impl_.SEPARATOR = 159;
            ScanCode_Impl_.OUT = 160;
            ScanCode_Impl_.OPER = 161;
            ScanCode_Impl_.CLEAR_AGAIN = 162;
            ScanCode_Impl_.CRSEL = 163;
            ScanCode_Impl_.EXSEL = 164;
            ScanCode_Impl_.NUMPAD_00 = 176;
            ScanCode_Impl_.NUMPAD_000 = 177;
            ScanCode_Impl_.THOUSAND_SEPARATOR = 178;
            ScanCode_Impl_.DECIMAL_SEPARATOR = 179;
            ScanCode_Impl_.CURRENCY_UNIT = 180;
            ScanCode_Impl_.CURRENCY_SUBUNIT = 181;
            ScanCode_Impl_.NUMPAD_LEFT_PARENTHESIS = 182;
            ScanCode_Impl_.NUMPAD_RIGHT_PARENTHESIS = 183;
            ScanCode_Impl_.NUMPAD_LEFT_BRACE = 184;
            ScanCode_Impl_.NUMPAD_RIGHT_BRACE = 185;
            ScanCode_Impl_.NUMPAD_TAB = 186;
            ScanCode_Impl_.NUMPAD_BACKSPACE = 187;
            ScanCode_Impl_.NUMPAD_A = 188;
            ScanCode_Impl_.NUMPAD_B = 189;
            ScanCode_Impl_.NUMPAD_C = 190;
            ScanCode_Impl_.NUMPAD_D = 191;
            ScanCode_Impl_.NUMPAD_E = 192;
            ScanCode_Impl_.NUMPAD_F = 193;
            ScanCode_Impl_.NUMPAD_XOR = 194;
            ScanCode_Impl_.NUMPAD_POWER = 195;
            ScanCode_Impl_.NUMPAD_PERCENT = 196;
            ScanCode_Impl_.NUMPAD_LESS_THAN = 197;
            ScanCode_Impl_.NUMPAD_GREATER_THAN = 198;
            ScanCode_Impl_.NUMPAD_AMPERSAND = 199;
            ScanCode_Impl_.NUMPAD_DOUBLE_AMPERSAND = 200;
            ScanCode_Impl_.NUMPAD_VERTICAL_BAR = 201;
            ScanCode_Impl_.NUMPAD_DOUBLE_VERTICAL_BAR = 202;
            ScanCode_Impl_.NUMPAD_COLON = 203;
            ScanCode_Impl_.NUMPAD_HASH = 204;
            ScanCode_Impl_.NUMPAD_SPACE = 205;
            ScanCode_Impl_.NUMPAD_AT = 206;
            ScanCode_Impl_.NUMPAD_EXCLAMATION = 207;
            ScanCode_Impl_.NUMPAD_MEM_STORE = 208;
            ScanCode_Impl_.NUMPAD_MEM_RECALL = 209;
            ScanCode_Impl_.NUMPAD_MEM_CLEAR = 210;
            ScanCode_Impl_.NUMPAD_MEM_ADD = 211;
            ScanCode_Impl_.NUMPAD_MEM_SUBTRACT = 212;
            ScanCode_Impl_.NUMPAD_MEM_MULTIPLY = 213;
            ScanCode_Impl_.NUMPAD_MEM_DIVIDE = 214;
            ScanCode_Impl_.NUMPAD_PLUS_MINUS = 215;
            ScanCode_Impl_.NUMPAD_CLEAR = 216;
            ScanCode_Impl_.NUMPAD_CLEAR_ENTRY = 217;
            ScanCode_Impl_.NUMPAD_BINARY = 218;
            ScanCode_Impl_.NUMPAD_OCTAL = 219;
            ScanCode_Impl_.NUMPAD_DECIMAL = 220;
            ScanCode_Impl_.NUMPAD_HEXADECIMAL = 221;
            ScanCode_Impl_.LEFT_CTRL = 224;
            ScanCode_Impl_.LEFT_SHIFT = 225;
            ScanCode_Impl_.LEFT_ALT = 226;
            ScanCode_Impl_.LEFT_META = 227;
            ScanCode_Impl_.RIGHT_CTRL = 228;
            ScanCode_Impl_.RIGHT_SHIFT = 229;
            ScanCode_Impl_.RIGHT_ALT = 230;
            ScanCode_Impl_.RIGHT_META = 231;
            ScanCode_Impl_.MODE = 257;
            ScanCode_Impl_.AUDIO_NEXT = 258;
            ScanCode_Impl_.AUDIO_PREVIOUS = 259;
            ScanCode_Impl_.AUDIO_STOP = 260;
            ScanCode_Impl_.AUDIO_PLAY = 261;
            ScanCode_Impl_.AUDIO_MUTE = 262;
            ScanCode_Impl_.MEDIA_SELECT = 263;
            ScanCode_Impl_.WWW = 264;
            ScanCode_Impl_.MAIL = 265;
            ScanCode_Impl_.CALCULATOR = 266;
            ScanCode_Impl_.COMPUTER = 267;
            ScanCode_Impl_.APP_CONTROL_SEARCH = 268;
            ScanCode_Impl_.APP_CONTROL_HOME = 269;
            ScanCode_Impl_.APP_CONTROL_BACK = 270;
            ScanCode_Impl_.APP_CONTROL_FORWARD = 271;
            ScanCode_Impl_.APP_CONTROL_STOP = 272;
            ScanCode_Impl_.APP_CONTROL_REFRESH = 273;
            ScanCode_Impl_.APP_CONTROL_BOOKMARKS = 274;
            ScanCode_Impl_.BRIGHTNESS_DOWN = 275;
            ScanCode_Impl_.BRIGHTNESS_UP = 276;
            ScanCode_Impl_.DISPLAY_SWITCH = 277;
            ScanCode_Impl_.BACKLIGHT_TOGGLE = 278;
            ScanCode_Impl_.BACKLIGHT_DOWN = 279;
            ScanCode_Impl_.BACKLIGHT_UP = 280;
            ScanCode_Impl_.EJECT = 281;
            ScanCode_Impl_.SLEEP = 282;
         }
         if(!Touch.init__)
         {
            Touch.init__ = true;
            Touch.onCancel = new _Event_lime_ui_Touch_Void();
            Touch.onEnd = new _Event_lime_ui_Touch_Void();
            Touch.onMove = new _Event_lime_ui_Touch_Void();
            Touch.onStart = new _Event_lime_ui_Touch_Void();
         }
         if(!lime.utils.Assets.init__)
         {
            lime.utils.Assets.init__ = true;
            lime.utils.Assets.cache = new lime.utils.AssetCache();
            lime.utils.Assets.onChange = new _Event_Void_Void();
            lime.utils.Assets.bundlePaths = new StringMap();
            lime.utils.Assets.libraries = new StringMap();
            lime.utils.Assets.libraryPaths = new StringMap();
         }
         if(!LogLevel_Impl_.init__)
         {
            LogLevel_Impl_.init__ = true;
            LogLevel_Impl_.NONE = 0;
            LogLevel_Impl_.ERROR = 1;
            LogLevel_Impl_.WARN = 2;
            LogLevel_Impl_.INFO = 3;
            LogLevel_Impl_.DEBUG = 4;
            LogLevel_Impl_.VERBOSE = 5;
         }
         if(!openfl.Lib.init__)
         {
            openfl.Lib.init__ = true;
            openfl.Lib.__sentWarnings = new StringMap();
            openfl.Lib.__timers = new IntMap();
         }
         if(!openfl._internal.Lib.init__)
         {
            openfl._internal.Lib.init__ = true;
            openfl._internal.Lib.current = flash.Lib.current;
            openfl._internal.Lib.__sentWarnings = new StringMap();
         }
         if(!FlashGraphics.init__)
         {
            FlashGraphics.init__ = true;
            FlashGraphics.bitmapFill = Dictionary_Impl_._new(true);
            FlashGraphics.tileRect = new Rectangle();
            FlashGraphics.tileTransform = new Matrix();
         }
         if(!openfl.utils.Assets.init__)
         {
            openfl.utils.Assets.init__ = true;
            openfl.utils.Assets.cache = new openfl.utils.AssetCache();
            openfl.utils.Assets.dispatcher = new EventDispatcher();
         }
         if(!ByteArray_Impl_.init__)
         {
            ByteArray_Impl_.init__ = true;
            var _temp_2:* = ByteArray_Impl_;
            _loc9_ = null;
            _loc10_ = new BytePointerData(_loc9_,0);
            _temp_2.__bytePointer = _loc10_;
         }
         Boot.__rebuildLog("boot_338d.before ApplicationMain.main");
         ApplicationMain.main();
      }
   }
}

