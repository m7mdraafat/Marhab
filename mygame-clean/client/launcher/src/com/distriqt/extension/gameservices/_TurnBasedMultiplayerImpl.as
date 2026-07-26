package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.events.TurnBasedMatchEvent;
   import com.distriqt.extension.gameservices.events.TurnBasedMultiplayerEvent;
   import com.distriqt.extension.gameservices.multiplayer.Invitation;
   import com.distriqt.extension.gameservices.multiplayer.PlayerSelectionOptions;
   import com.distriqt.extension.gameservices.turnbasedmultiplayer.TurnBasedMatch;
   import com.distriqt.extension.gameservices.turnbasedmultiplayer.TurnBasedMatchConfig;
   import com.distriqt.extension.gameservices.turnbasedmultiplayer.TurnBasedMatchStatus;
   import com.distriqt.extension.gameservices.turnbasedmultiplayer.TurnBasedMultiplayer;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _TurnBasedMultiplayerImpl extends EventDispatcher implements TurnBasedMultiplayer
   {
      
      private var _extContext:ExtensionContext = null;
      
      public function _TurnBasedMultiplayerImpl(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
         _extContext.addEventListener("status",extension_statusHandler,false,0,true);
      }
      
      public function dispose() : void
      {
         _extContext.removeEventListener("status",extension_statusHandler);
         _extContext = null;
      }
      
      public function get isSupported() : Boolean
      {
         return _extContext.call("turnBasedMultiplayer_isSupported") as Boolean;
      }
      
      public function loadMatches(param1:Array = null) : void
      {
         _extContext.call("turnBasedMultiplayer_loadMatches",param1 == null ? TurnBasedMatchStatus.ALL_TURN_STATUSES : param1);
      }
      
      public function loadMatch(param1:String) : void
      {
         _extContext.call("turnBasedMultiplayer_loadMatch",param1);
      }
      
      public function displayCreateMatchUI(param1:PlayerSelectionOptions) : void
      {
         _extContext.call("turnBasedMultiplayer_displayCreateMatchUI",param1);
      }
      
      public function createMatch(param1:TurnBasedMatchConfig) : void
      {
         _extContext.call("turnBasedMultiplayer_createMatch",param1);
      }
      
      public function acceptInvitation(param1:Invitation) : void
      {
         _extContext.call("turnBasedMultiplayer_acceptInvitation",param1);
      }
      
      public function declineInvitation(param1:Invitation) : void
      {
         _extContext.call("turnBasedMultiplayer_declineInvitation",param1);
      }
      
      public function dismissInvitation(param1:Invitation) : void
      {
         _extContext.call("turnBasedMultiplayer_dismissInvitation",param1);
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc7_:TurnBasedMatchConfig = null;
         var _loc8_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:_TurnBasedMatchImpl = null;
         var _loc4_:_TurnBasedMatchImpl = null;
         var _loc3_:_TurnBasedMatchImpl = null;
         var _loc9_:_TurnBasedMatchImpl = null;
         switch(param1.code)
         {
            case "turnbasedmultiplayer:creatematchui:success":
               _loc7_ = TurnBasedMatchConfig.fromObject(JSON.parse(param1.level));
               dispatchEvent(new TurnBasedMultiplayerEvent("turnbasedmultiplayer:creatematchui:success",_loc7_));
               break;
            case "turnbasedmultiplayer:creatematchui:error":
               dispatchEvent(new TurnBasedMultiplayerEvent("turnbasedmultiplayer:creatematchui:error",param1.level));
               break;
            case "turnbasedmultiplayer:creatematchui:cancel":
               dispatchEvent(new TurnBasedMultiplayerEvent("turnbasedmultiplayer:creatematchui:cancel",null));
               break;
            case "turnbasedmultiplayer:loadmatches:success":
               _loc8_ = [];
               _loc5_ = JSON.parse(param1.level);
               for each(var _loc2_ in _loc5_.matches)
               {
                  _loc8_.push(TurnBasedMatch(_TurnBasedMatchImpl.fromObject(_extContext,_loc2_)));
               }
               dispatchEvent(new TurnBasedMultiplayerEvent("turnbasedmultiplayer:loadmatches:success",_loc8_));
               break;
            case "turnbasedmultiplayer:loadmatches:failed":
               dispatchEvent(new TurnBasedMultiplayerEvent("turnbasedmultiplayer:loadmatches:failed",null));
               break;
            case "turnbasedmultiplayer:match:loadmatch:success":
               _loc6_ = _TurnBasedMatchImpl.fromObject(_extContext,JSON.parse(param1.level));
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:loadmatch:success",_loc6_));
               break;
            case "turnbasedmultiplayer:match:loadmatch:failed":
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:loadmatch:failed",null,param1.level));
               break;
            case "turnbasedmultiplayer:match:create:success":
               _loc4_ = _TurnBasedMatchImpl.fromObject(_extContext,JSON.parse(param1.level));
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:create:success",_loc4_));
               break;
            case "turnbasedmultiplayer:match:create:failed":
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:create:failed",null,param1.level));
               break;
            case "turnbasedmultiplayer:match:updated":
               _loc3_ = _TurnBasedMatchImpl.fromObject(_extContext,JSON.parse(param1.level));
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:updated",_loc3_));
               break;
            case "turnbasedmultiplayer:match:removed":
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:removed",null,param1.level));
               break;
            case "turnbasedmultiplayer:acceptinvitation:success":
               _loc9_ = _TurnBasedMatchImpl.fromObject(_extContext,JSON.parse(param1.level));
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:acceptinvitation:success",_loc9_));
               break;
            case "turnbasedmultiplayer:acceptinvitation:failed":
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:acceptinvitation:failed",null,param1.level));
         }
      }
   }
}

