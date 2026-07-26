package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.events.LeaderboardEvent;
   import com.distriqt.extension.gameservices.leaderboards.Leaderboard;
   import com.distriqt.extension.gameservices.leaderboards.LeaderboardScore;
   import com.distriqt.extension.gameservices.leaderboards.Leaderboards;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _LeaderboardsImpl extends EventDispatcher implements Leaderboards
   {
      
      private var _extContext:ExtensionContext = null;
      
      public function _LeaderboardsImpl(param1:ExtensionContext)
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
         return _extContext.call("leaderboards_isSupported") as Boolean;
      }
      
      public function loadLeaderboards(param1:Boolean = false) : void
      {
         _extContext.call("leaderboards_loadLeaderboards",param1);
      }
      
      public function loadTopScores(param1:String, param2:int = 10, param3:String = "alltime", param4:String = "public", param5:Boolean = false) : void
      {
         _extContext.call("leaderboards_loadTopScores",param1,param2,param3,param4,param5);
      }
      
      public function loadScores(param1:String, param2:int, param3:int = 10, param4:String = "alltime", param5:String = "public", param6:Boolean = false) : void
      {
         _extContext.call("leaderboards_loadScores",param1,param2,param3,param4,param5,param6);
      }
      
      public function loadPlayerCenteredScores(param1:String, param2:int = 10, param3:String = "alltime", param4:String = "public", param5:Boolean = false) : void
      {
         _extContext.call("leaderboards_loadPlayerCenteredScores",param1,param2,param3,param4,param5);
      }
      
      public function loadPlayerScore(param1:String, param2:String = "alltime", param3:String = "public") : void
      {
         _extContext.call("leaderboards_loadPlayerScore",param1,param2,param3);
      }
      
      public function submitScore(param1:String, param2:int, param3:String = "") : void
      {
         _extContext.call("leaderboards_submitScore",param1,param2,param3);
      }
      
      public function displayLeaderboardUI(param1:String = "") : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         _extContext.call("leaderboards_displayLeaderboardUI",param1);
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc3_:Object = null;
         var _loc7_:Leaderboard = null;
         var _loc5_:Array = null;
         var _loc4_:Array = null;
         try
         {
            switch(param1.code)
            {
               case "leaderboards:loaded":
                  _loc3_ = JSON.parse(param1.level);
                  _loc5_ = [];
                  if(_loc3_.hasOwnProperty("leaderboards"))
                  {
                     for each(var _loc2_ in _loc3_.leaderboards)
                     {
                        _loc5_.push(Leaderboard.fromObject(_loc2_));
                     }
                  }
                  dispatchEvent(new LeaderboardEvent("leaderboards:loaded",null,_loc5_));
                  break;
               case "leaderboards:error":
                  dispatchEvent(new LeaderboardEvent("leaderboards:error",null,param1.level));
                  break;
               case "leaderboard:topscores:loaded":
               case "leaderboard:scores:loaded":
               case "leaderboard:playercenteredscores:loaded":
               case "leaderboard:playerscore:loaded":
                  _loc3_ = JSON.parse(param1.level);
                  _loc7_ = Leaderboard.fromObject(_loc3_.leaderboard);
                  _loc4_ = [];
                  for each(var _loc6_ in _loc3_.scores)
                  {
                     _loc4_.push(LeaderboardScore.fromObject(_loc6_));
                  }
                  dispatchEvent(new LeaderboardEvent(param1.code,_loc7_,_loc4_));
                  break;
               case "leaderboard:topscores:error":
               case "leaderboard:scores:error":
               case "leaderboard:playercenteredscores:error":
               case "leaderboard:playerscore:error":
                  dispatchEvent(new LeaderboardEvent(param1.code,null,param1.level));
                  break;
               case "leaderboard:submitscore:success":
                  dispatchEvent(new LeaderboardEvent("leaderboard:submitscore:success",null,null));
                  break;
               case "leaderboard:submitscore:error":
                  dispatchEvent(new LeaderboardEvent("leaderboard:submitscore:error",null,param1.level));
                  break;
               case "leaderboard:ui:closed":
                  dispatchEvent(new LeaderboardEvent("leaderboard:ui:closed",null,null));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

