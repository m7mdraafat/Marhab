package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.events.PlayersEvent;
   import com.distriqt.extension.gameservices.players.Players;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal final class _PlayersImpl extends EventDispatcher implements Players
   {
      
      private var _extContext:ExtensionContext;
      
      public function _PlayersImpl(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
         _extContext.addEventListener("status",extContext_statusHandler);
      }
      
      public function dispose() : void
      {
         if(_extContext)
         {
            _extContext.removeEventListener("status",extContext_statusHandler);
         }
      }
      
      public function get isSupported() : Boolean
      {
         try
         {
            return _extContext.call("players_isSupported") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function loadPlayerFriends() : Boolean
      {
         try
         {
            return _extContext.call("players_loadPlayerFriends") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function extContext_statusHandler(param1:StatusEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         try
         {
            switch(param1.code)
            {
               case "players:loadPlayerFriends:error":
                  _loc3_ = JSON.parse(param1.level);
                  dispatchEvent(new PlayersEvent("players:loadPlayerFriends:error",null,_loc3_.error,_loc3_.errorCode));
                  break;
               case "players:loadPlayerFriends:success":
                  _loc3_ = JSON.parse(param1.level);
                  _loc4_ = [];
                  for each(var _loc2_ in _loc3_.players)
                  {
                     _loc4_.push(Player.fromObject(_loc2_));
                  }
                  dispatchEvent(new PlayersEvent("players:loadPlayerFriends:success",_loc4_));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

