package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.accesspoint.AccessPoint;
   import com.distriqt.extension.gameservices.achievements.Achievements;
   import com.distriqt.extension.gameservices.auth.AuthUtil;
   import com.distriqt.extension.gameservices.events.GameServicesEvent;
   import com.distriqt.extension.gameservices.events.MultiplayerEvent;
   import com.distriqt.extension.gameservices.events.PlayerEvent;
   import com.distriqt.extension.gameservices.events.PlayerIconEvent;
   import com.distriqt.extension.gameservices.leaderboards.Leaderboards;
   import com.distriqt.extension.gameservices.multiplayer.Invitation;
   import com.distriqt.extension.gameservices.players.Players;
   import com.distriqt.extension.gameservices.quests.Quests;
   import com.distriqt.extension.gameservices.recording.ScreenRecording;
   import com.distriqt.extension.gameservices.savedgames.SavedGames;
   import com.distriqt.extension.gameservices.turnbasedmultiplayer.TurnBasedMultiplayer;
   import com.distriqt.extension.gameservices.utils.Base64;
   import flash.desktop.NativeApplication;
   import flash.display.BitmapData;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   [Event(name="initialised",type="com.distriqt.extension.gameservices.events.GameServicesEvent")]
   [Event(name="signin:success",type="com.distriqt.extension.gameservices.events.GameServicesEvent")]
   [Event(name="signin:failed",type="com.distriqt.extension.gameservices.events.GameServicesEvent")]
   [Event(name="signout:success",type="com.distriqt.extension.gameservices.events.GameServicesEvent")]
   [Event(name="multiplayer:invitation:received",type="com.distriqt.extension.gameservices.events.MultiplayerEvent")]
   [Event(name="multiplayer:invitation:removed",type="com.distriqt.extension.gameservices.events.MultiplayerEvent")]
   [Event(name="multiplayer:loadinvites:success",type="com.distriqt.extension.gameservices.events.MultiplayerEvent")]
   [Event(name="multiplayer:loadinvites:failed",type="com.distriqt.extension.gameservices.events.MultiplayerEvent")]
   [Event(name="multiplayer:loadinvites:notsupported",type="com.distriqt.extension.gameservices.events.MultiplayerEvent")]
   [Event(name="player:icon:loaded",type="com.distriqt.extension.gameservices.events.PlayerIconEvent")]
   [Event(name="player:icon:error",type="com.distriqt.extension.gameservices.events.PlayerIconEvent")]
   public final class GameServices extends EventDispatcher
   {
      
      public static const EXT_CONTEXT_ID:String = "com.distriqt.GameServices";
      
      private static const EXT_ID_NUMBER:int = 38;
      
      public static const VERSION:String = "7.2.7";
      
      private static const VERSION_DEFAULT:String = "0";
      
      private static const IMPLEMENTATION_DEFAULT:String = "unknown";
      
      private static const ERROR_CREATION:String = "The native extension context could not be created";
      
      private static const ERROR_SINGLETON:String = "The singleton has already been created. Use GameServices.service to access the functionality";
      
      private static var _instance:GameServices;
      
      private static var _shouldCreateInstance:Boolean = false;
      
      private static var _extContext:ExtensionContext = null;
      
      private var _extensionId:String = "";
      
      private var _extensionIdNumber:int = -1;
      
      private var _hasSignedInSuccessfully:Boolean = false;
      
      private var _players:Players;
      
      private var _leaderboards:Leaderboards;
      
      private var _achievements:Achievements;
      
      private var _savedGames:SavedGames;
      
      private var _turnBasedMultiplayer:TurnBasedMultiplayer;
      
      private var _authUtil:AuthUtil;
      
      private var _quests:Quests;
      
      private var _recording:ScreenRecording;
      
      private var _accessPoint:AccessPoint;
      
      private var _autoSignInTimer:int;
      
      public function GameServices()
      {
         super();
         if(_shouldCreateInstance)
         {
            try
            {
               _extensionId = "com.distriqt.GameServices";
               _extensionIdNumber = 38;
               _extContext = ExtensionContext.createExtensionContext("com.distriqt.GameServices",null);
               _extContext.addEventListener("status",extension_statusHandler);
               _hasSignedInSuccessfully = false;
               NativeApplication.nativeApplication.addEventListener("activate",application_activateHandler);
            }
            catch(e:Error)
            {
               throw new Error("The native extension context could not be created");
            }
            return;
         }
         throw new Error("The singleton has already been created. Use GameServices.service to access the functionality");
      }
      
      public static function get service() : GameServices
      {
         createInstance();
         return _instance;
      }
      
      private static function createInstance() : void
      {
         if(_instance == null)
         {
            _shouldCreateInstance = true;
            _instance = new GameServices();
            _shouldCreateInstance = false;
         }
      }
      
      [Deprecated(message="You no longer need to use an application key")]
      public static function init(param1:String = "") : void
      {
         createInstance();
      }
      
      public static function get isSupported() : Boolean
      {
         createInstance();
         return _extContext.call("isSupported");
      }
      
      public function dispose() : void
      {
         NativeApplication.nativeApplication.removeEventListener("activate",application_activateHandler);
         if(_players)
         {
            _PlayersImpl(_players).dispose();
            _players = null;
         }
         if(_leaderboards)
         {
            _LeaderboardsImpl(_leaderboards).dispose();
            _leaderboards = null;
         }
         if(_achievements)
         {
            _AchievementsImpl(_achievements).dispose();
            _achievements = null;
         }
         if(_savedGames)
         {
            _SavedGamesImpl(_savedGames).dispose();
            _savedGames = null;
         }
         if(_turnBasedMultiplayer)
         {
            _TurnBasedMultiplayerImpl(_turnBasedMultiplayer).dispose();
            _turnBasedMultiplayer = null;
         }
         if(_authUtil)
         {
            _AuthUtilImpl(_authUtil).dispose();
            _authUtil = null;
         }
         if(_quests)
         {
            _QuestsImpl(_quests).dispose();
            _quests = null;
         }
         if(_recording)
         {
            _ScreenRecordingImpl(_recording).dispose();
            _recording = null;
         }
         if(_extContext)
         {
            _extContext.removeEventListener("status",extension_statusHandler);
            _extContext.dispose();
            _extContext = null;
         }
         _instance = null;
      }
      
      public function get version() : String
      {
         return "7.2.7";
      }
      
      public function get nativeVersion() : String
      {
         try
         {
            return _extContext.call("version") as String;
         }
         catch(e:Error)
         {
         }
         return "0";
      }
      
      public function get implementation() : String
      {
         try
         {
            return _extContext.call("implementation") as String;
         }
         catch(e:Error)
         {
         }
         return "unknown";
      }
      
      public function get isGooglePlayGamesInstalled() : Boolean
      {
         try
         {
            return _extContext.call("isGooglePlayGamesInstalled") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function isServiceSupported(param1:String) : Boolean
      {
         try
         {
            return _extContext.call("isServiceSupported",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function initialiseService(param1:Service) : Boolean
      {
         if(isServiceSupported(param1.service))
         {
            try
            {
               return _extContext.call("initialiseService",param1) as Boolean;
            }
            catch(e:Error)
            {
            }
         }
         return false;
      }
      
      public function isSignedIn() : Boolean
      {
         try
         {
            return _extContext.call("isSignedIn") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function signIn(param1:Boolean = false) : Boolean
      {
         try
         {
            return _extContext.call("signIn",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function signOut() : Boolean
      {
         try
         {
            _hasSignedInSuccessfully = false;
            return _extContext.call("signOut") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      [Deprecated(message="Player retrieval is now asynchronous. This will only return the previous asynchronously retrieved value")]
      public function getPlayer() : Player
      {
         var _loc1_:Object = null;
         var _loc2_:* = null;
         try
         {
            _loc1_ = _extContext.call("getPlayer") as Object;
            return new Player(_loc1_);
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function loadPlayer() : Boolean
      {
         try
         {
            return _extContext.call("loadPlayer") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function loadPlayerIcon(param1:Player) : Boolean
      {
         try
         {
            return _extContext.call("loadPlayerIcon",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function disconnect() : Boolean
      {
         try
         {
            return _extContext.call("disconnect") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function showUI(param1:String = "default") : Boolean
      {
         try
         {
            return _extContext.call("showUI",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function get players() : Players
      {
         if(_players == null)
         {
            _players = new _PlayersImpl(_extContext);
         }
         return _players;
      }
      
      public function register() : Boolean
      {
         try
         {
            return _extContext.call("multiplayer_register") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function loadInvites() : void
      {
         try
         {
            _extContext.call("multiplayer_loadInvites");
         }
         catch(e:Error)
         {
         }
      }
      
      public function get leaderboards() : Leaderboards
      {
         if(_leaderboards == null)
         {
            _leaderboards = new _LeaderboardsImpl(_extContext);
         }
         return _leaderboards;
      }
      
      public function get achievements() : Achievements
      {
         if(_achievements == null)
         {
            _achievements = new _AchievementsImpl(_extContext);
         }
         return _achievements;
      }
      
      public function get savedGames() : SavedGames
      {
         if(_savedGames == null)
         {
            _savedGames = new _SavedGamesImpl(_extContext);
         }
         return _savedGames;
      }
      
      public function get turnBasedMultiplayer() : TurnBasedMultiplayer
      {
         if(_turnBasedMultiplayer == null)
         {
            _turnBasedMultiplayer = new _TurnBasedMultiplayerImpl(_extContext);
         }
         return _turnBasedMultiplayer;
      }
      
      public function get authUtil() : AuthUtil
      {
         if(_authUtil == null)
         {
            _authUtil = new _AuthUtilImpl(_extContext);
         }
         return _authUtil;
      }
      
      public function get quests() : Quests
      {
         if(_quests == null)
         {
            _quests = new _QuestsImpl(_extContext);
         }
         return _quests;
      }
      
      public function get recording() : ScreenRecording
      {
         if(_recording == null)
         {
            _recording = new _ScreenRecordingImpl(_extContext);
         }
         return _recording;
      }
      
      public function get accessPoint() : AccessPoint
      {
         if(_accessPoint == null)
         {
            _accessPoint = new _AccessPointImpl(_extContext);
         }
         return _accessPoint;
      }
      
      private function autoSignIn() : void
      {
      }
      
      private function application_activateHandler(param1:Event) : void
      {
         autoSignIn();
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         var _loc4_:Array = null;
         var _loc6_:Boolean = false;
         var _loc3_:BitmapData = null;
         var _loc7_:ByteArray = null;
         try
         {
            switch(param1.code)
            {
               case "extension:error":
                  dispatchEvent(new ErrorEvent("error",false,false,param1.level));
                  break;
               case "initialised":
               case "ui:closed":
                  dispatchEvent(new GameServicesEvent(param1.code));
                  break;
               case "signin:success":
                  _hasSignedInSuccessfully = true;
                  dispatchEvent(new GameServicesEvent("signin:success"));
                  break;
               case "signin:failed":
                  try
                  {
                     _loc2_ = JSON.parse(param1.level);
                     dispatchEvent(new GameServicesEvent("signin:failed",_loc2_.message,_loc2_.code));
                  }
                  catch(e:Error)
                  {
                     dispatchEvent(new GameServicesEvent("signin:failed"));
                  }
                  break;
               case "signout:success":
                  _hasSignedInSuccessfully = false;
                  dispatchEvent(new GameServicesEvent("signout:success"));
                  break;
               case "multiplayer:invitation:received":
                  dispatchEvent(new MultiplayerEvent("multiplayer:invitation:received",Invitation.fromObject(JSON.parse(param1.level))));
                  break;
               case "multiplayer:invitation:removed":
                  dispatchEvent(new MultiplayerEvent("multiplayer:invitation:removed",param1.level));
                  break;
               case "multiplayer:loadinvites:success":
                  _loc4_ = [];
                  _loc2_ = JSON.parse(param1.level);
                  for each(var _loc5_ in _loc2_.invitations)
                  {
                     _loc4_.push(Invitation.fromObject(_loc5_));
                  }
                  dispatchEvent(new MultiplayerEvent("multiplayer:loadinvites:success",_loc4_));
                  break;
               case "multiplayer:loadinvites:failed":
               case "multiplayer:loadinvites:notsupported":
                  dispatchEvent(new MultiplayerEvent(param1.code,null,param1.level));
                  break;
               case "player:error":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new PlayerEvent("player:error",false,false,null,_loc2_.error.message));
                  break;
               case "player:loaded":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new PlayerEvent("player:loaded",false,false,Player.fromObject(_loc2_.player)));
                  break;
               case "player:icon:error":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new PlayerIconEvent("player:icon:error",false,false,Player.fromObject(_loc2_.player),null,_loc2_.error.message));
                  break;
               case "player:icon:loaded":
                  _loc6_ = false;
                  try
                  {
                     _loc2_ = JSON.parse(param1.level);
                     if(_loc2_.player && _loc2_.icon && _loc2_.icon.width && _loc2_.icon.height && _loc2_.icon.data)
                     {
                        if(_loc2_.icon.width > 0 && _loc2_.icon.height > 0)
                        {
                           _loc3_ = new BitmapData(_loc2_.icon.width,_loc2_.icon.height);
                           _loc7_ = Base64.decodeToByteArray(_loc2_.icon.data);
                           _loc3_.setPixels(new Rectangle(0,0,_loc3_.width,_loc3_.height),_loc7_);
                           dispatchEvent(new PlayerIconEvent("player:icon:loaded",false,false,Player.fromObject(_loc2_.player),_loc3_));
                           _loc6_ = true;
                        }
                     }
                  }
                  catch(e:Error)
                  {
                     trace(e);
                  }
                  if(!_loc6_)
                  {
                     dispatchEvent(new PlayerIconEvent("player:icon:error",false,false,Player.fromObject(_loc2_.player),null,"Error processing image data"));
                  }
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

