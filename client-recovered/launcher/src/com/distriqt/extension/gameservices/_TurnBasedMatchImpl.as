package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.events.TurnBasedMatchEvent;
   import com.distriqt.extension.gameservices.multiplayer.Participant;
   import com.distriqt.extension.gameservices.turnbasedmultiplayer.TurnBasedMatch;
   import com.distriqt.extension.gameservices.utils.Base64;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.utils.ByteArray;
   
   internal class _TurnBasedMatchImpl extends EventDispatcher implements TurnBasedMatch
   {
      
      private var _extContext:ExtensionContext = null;
      
      private var _matchId:String = "";
      
      private var _status:int;
      
      private var _turnStatus:int;
      
      private var _variant:int;
      
      private var _created:int;
      
      private var _canRematch:Boolean = false;
      
      private var _participants:Array;
      
      private var _data:ByteArray;
      
      private var _dataMaxSize:uint;
      
      public function _TurnBasedMatchImpl(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
         _extContext.addEventListener("status",extension_statusHandler,false,0,true);
         _participants = [];
      }
      
      public static function fromObject(param1:ExtensionContext, param2:Object) : _TurnBasedMatchImpl
      {
         var _loc3_:_TurnBasedMatchImpl = new _TurnBasedMatchImpl(param1);
         _loc3_.updateFromObject(param2);
         return _loc3_;
      }
      
      public function dispose() : void
      {
         _extContext.removeEventListener("status",extension_statusHandler);
         _extContext = null;
      }
      
      public function updateFromObject(param1:Object) : void
      {
         var _loc2_:Participant = null;
         _matchId = param1.matchId;
         _status = param1.status;
         _turnStatus = param1.turnStatus;
         _variant = param1.variant;
         _created = param1.created;
         _canRematch = param1.canRematch == 1;
         for each(var _loc3_ in param1.participants)
         {
            _loc2_ = findParticipant(_loc3_.participantId);
            if(_loc2_ == null)
            {
               _participants.push(Participant.fromObject(_loc3_));
            }
            else
            {
               _loc2_.updateFromObject(_loc3_);
            }
         }
         var _loc4_:String = param1.data.replace(/[\s\r\n]+/gim,"");
         _data = Base64.decodeToByteArray(_loc4_);
         _dataMaxSize = param1.dataMaxSize;
      }
      
      private function findParticipant(param1:String) : Participant
      {
         for each(var _loc2_ in participants)
         {
            if(_loc2_.participantId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function get matchId() : String
      {
         return _matchId;
      }
      
      public function set matchId(param1:String) : void
      {
         _matchId = param1;
      }
      
      public function get status() : int
      {
         return _status;
      }
      
      public function set status(param1:int) : void
      {
         _status = param1;
      }
      
      public function get turnStatus() : int
      {
         return _turnStatus;
      }
      
      public function set turnStatus(param1:int) : void
      {
         _turnStatus = param1;
      }
      
      public function get variant() : int
      {
         return _variant;
      }
      
      public function set variant(param1:int) : void
      {
         _variant = param1;
      }
      
      public function get created() : int
      {
         return _created;
      }
      
      public function set created(param1:int) : void
      {
         _created = param1;
      }
      
      public function get canRematch() : Boolean
      {
         return _canRematch;
      }
      
      public function set canRematch(param1:Boolean) : void
      {
         _canRematch = param1;
      }
      
      public function get participants() : Array
      {
         return _participants;
      }
      
      public function set participants(param1:Array) : void
      {
         _participants = param1;
      }
      
      public function get data() : ByteArray
      {
         return _data;
      }
      
      public function set data(param1:ByteArray) : void
      {
         _data = param1;
      }
      
      public function get dataMaxSize() : uint
      {
         return _dataMaxSize;
      }
      
      public function set dataMaxSize(param1:uint) : void
      {
         _dataMaxSize = param1;
      }
      
      public function takeTurn(param1:Participant) : void
      {
         _extContext.call("turnBasedMultiplayer_match_takeTurn",this,param1);
      }
      
      public function finishMatch(param1:Array) : void
      {
         _extContext.call("turnBasedMultiplayer_match_finishMatch",this,param1);
      }
      
      public function cancelMatch() : void
      {
         _extContext.call("turnBasedMultiplayer_match_cancelMatch",this);
      }
      
      public function dismissMatch() : void
      {
         _extContext.call("turnBasedMultiplayer_match_dismissMatch",this);
      }
      
      public function leaveMatch() : void
      {
         _extContext.call("turnBasedMultiplayer_match_leaveMatch",this);
      }
      
      public function leaveMatchDuringTurn(param1:Participant) : void
      {
         _extContext.call("turnBasedMultiplayer_match_leaveMatchDuringTurn",this,param1);
      }
      
      public function rematch() : void
      {
         _extContext.call("turnBasedMultiplayer_match_rematch",this);
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:_TurnBasedMatchImpl = null;
         switch(param1.code)
         {
            case "turnbasedmultiplayer:match:updated":
               _loc2_ = JSON.parse(param1.level);
               if(_matchId != _loc2_.matchId)
               {
                  return;
               }
               this.updateFromObject(_loc2_);
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:updated",this));
               break;
            case "turnbasedmultiplayer:match:removed":
               _loc2_ = JSON.parse(param1.level);
               if(_matchId != _loc2_.matchId)
               {
                  return;
               }
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:removed",null));
               break;
            case "turnbasedmultiplayer:match:rematch:success":
               _loc2_ = JSON.parse(param1.level);
               if(_matchId != _loc2_.existingMatchId)
               {
                  return;
               }
               _loc3_ = new _TurnBasedMatchImpl(_extContext);
               _loc3_.updateFromObject(_loc2_);
               dispatchEvent(new TurnBasedMatchEvent(param1.code,_loc3_));
               break;
            case "turnbasedmultiplayer:match:taketurn:success":
            case "turnbasedmultiplayer:match:finishMatch:success":
            case "turnbasedmultiplayer:match:leaveMatch:success":
               _loc2_ = JSON.parse(param1.level);
               if(_matchId != _loc2_.matchId)
               {
                  return;
               }
               this.updateFromObject(_loc2_);
               dispatchEvent(new TurnBasedMatchEvent(param1.code,this));
               break;
            case "turnbasedmultiplayer:match:taketurn:failed":
            case "turnbasedmultiplayer:match:finishMatch:failed":
            case "turnbasedmultiplayer:match:leaveMatch:failed":
            case "turnbasedmultiplayer:match:rematch:failed":
            case "turnbasedmultiplayer:match:cancelMatch:failed":
               _loc2_ = JSON.parse(param1.level);
               if(_matchId != _loc2_.matchId)
               {
                  return;
               }
               dispatchEvent(new TurnBasedMatchEvent(param1.code,this,_loc2_.message));
               break;
            case "turnbasedmultiplayer:match:cancelMatch:success":
               _loc2_ = JSON.parse(param1.level);
               if(_matchId != _loc2_.matchId)
               {
                  return;
               }
               dispatchEvent(new TurnBasedMatchEvent("turnbasedmultiplayer:match:cancelMatch:success",this,_loc2_.message));
         }
      }
   }
}

