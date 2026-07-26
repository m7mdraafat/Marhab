package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.events.SavedGamesEvent;
   import com.distriqt.extension.gameservices.savedgames.SavedGame;
   import com.distriqt.extension.gameservices.savedgames.SavedGames;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _SavedGamesImpl extends EventDispatcher implements SavedGames
   {
      
      private var _extContext:ExtensionContext = null;
      
      public function _SavedGamesImpl(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
         _extContext.addEventListener("status",extension_statusHandler,false,0,true);
      }
      
      public function dispose() : void
      {
         if(_extContext)
         {
            _extContext.removeEventListener("status",extension_statusHandler);
            _extContext = null;
         }
      }
      
      public function get isSupported() : Boolean
      {
         try
         {
            return _extContext.call("savedGames_isSupported") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function displaySavedGamesUI(param1:String, param2:Boolean = false, param3:Boolean = false, param4:int = -1) : Boolean
      {
         try
         {
            return _extContext.call("savedGames_displaySavedGamesUI",param1,param2,param3,param4) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function loadSavedGames(param1:Boolean = false) : void
      {
         _extContext.call("savedGames_loadSavedGames",param1);
      }
      
      public function createGame(param1:String) : void
      {
         try
         {
            _extContext.call("savedGames_createGame",param1);
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
      
      public function openGame(param1:SavedGame) : void
      {
         if(param1 == null)
         {
            dispatchEvent(new SavedGamesEvent("savedgames:open:error","SavedGame cannot be null"));
            return;
         }
         try
         {
            _extContext.call("savedGames_openGame",param1);
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
      
      public function saveGame(param1:SavedGame) : void
      {
         if(param1 == null)
         {
            dispatchEvent(new SavedGamesEvent("savedgames:save:error","SavedGame cannot be null"));
            return;
         }
         try
         {
            _extContext.call("savedGames_saveGame",param1);
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
      
      public function deleteGame(param1:SavedGame) : void
      {
         if(param1 == null)
         {
            dispatchEvent(new SavedGamesEvent("savedgames:delete:error","SavedGame cannot be null"));
            return;
         }
         try
         {
            _extContext.call("savedGames_deleteGame",param1);
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
      
      public function resolveConflict(param1:String, param2:SavedGame) : void
      {
         if(param2 == null)
         {
            dispatchEvent(new SavedGamesEvent("savedgames:conflict:resolve:error","SavedGame cannot be null",param1));
            return;
         }
         try
         {
            _extContext.call("savedGames_resolveConflict",param1,param2);
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
      
      private function savedGamesFromObject(param1:Object) : Array
      {
         var _loc3_:Array = [];
         for each(var _loc2_ in param1.savedgames)
         {
            _loc3_.push(SavedGame.fromObject(_loc2_));
         }
         return _loc3_;
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         switch(param1.code)
         {
            case "savedgames:load:success":
               dispatchEvent(new SavedGamesEvent("savedgames:load:success",savedGamesFromObject(JSON.parse(param1.level))));
               break;
            case "savedgames:load:error":
               dispatchEvent(new SavedGamesEvent("savedgames:load:error",param1.level));
               break;
            case "savedgames:ui:select":
               dispatchEvent(new SavedGamesEvent("savedgames:ui:select",savedGamesFromObject(JSON.parse(param1.level))));
               break;
            case "savedgames:ui:new":
               dispatchEvent(new SavedGamesEvent("savedgames:ui:new"));
               break;
            case "savedgames:ui:closed":
               dispatchEvent(new SavedGamesEvent("savedgames:ui:closed"));
               break;
            case "savedgames:conflict":
               _loc2_ = JSON.parse(param1.level);
               dispatchEvent(new SavedGamesEvent("savedgames:conflict",savedGamesFromObject(_loc2_),_loc2_.conflictId));
               break;
            case "savedgames:conflict:resolve:error":
               dispatchEvent(new SavedGamesEvent("savedgames:conflict:resolve:error",param1.level));
               break;
            case "savedgames:conflict:resolve:success":
               _loc3_ = JSON.parse(param1.level);
               dispatchEvent(new SavedGamesEvent("savedgames:conflict:resolve:success",savedGamesFromObject(_loc3_),_loc3_.conflictId));
               break;
            case "savedgames:create:success":
               dispatchEvent(new SavedGamesEvent("savedgames:create:success",savedGamesFromObject(JSON.parse(param1.level))));
               break;
            case "savedgames:create:failed":
               dispatchEvent(new SavedGamesEvent("savedgames:create:failed",param1.level));
               break;
            case "savedgames:create:error":
               dispatchEvent(new SavedGamesEvent("savedgames:create:error",param1.level));
               break;
            case "savedgames:open:success":
               dispatchEvent(new SavedGamesEvent("savedgames:open:success",savedGamesFromObject(JSON.parse(param1.level))));
               break;
            case "savedgames:open:notfound":
               dispatchEvent(new SavedGamesEvent("savedgames:open:notfound"));
               break;
            case "savedgames:open:failed":
               dispatchEvent(new SavedGamesEvent("savedgames:open:failed",param1.level));
               break;
            case "savedgames:open:error":
               dispatchEvent(new SavedGamesEvent("savedgames:open:error",param1.level));
               break;
            case "savedgames:save:success":
               dispatchEvent(new SavedGamesEvent("savedgames:save:success",savedGamesFromObject(JSON.parse(param1.level))));
               break;
            case "savedgames:save:error":
               dispatchEvent(new SavedGamesEvent("savedgames:save:error",param1.level));
               break;
            case "savedgames:delete:success":
               dispatchEvent(new SavedGamesEvent("savedgames:delete:success",param1.level));
               break;
            case "savedgames:delete:error":
               dispatchEvent(new SavedGamesEvent("savedgames:delete:error",param1.level));
         }
      }
   }
}

