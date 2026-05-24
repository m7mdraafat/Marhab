package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.events.PlayerEventEvent;
   import com.distriqt.extension.gameservices.events.QuestEvent;
   import com.distriqt.extension.gameservices.quests.PlayerEvent;
   import com.distriqt.extension.gameservices.quests.Quest;
   import com.distriqt.extension.gameservices.quests.Quests;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _QuestsImpl extends EventDispatcher implements Quests
   {
      
      private var _extContext:ExtensionContext;
      
      public function _QuestsImpl(param1:ExtensionContext)
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
            _extContext = null;
         }
      }
      
      public function get isSupported() : Boolean
      {
         try
         {
            return _extContext.call("quests_isSupported") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function loadQuests(param1:Boolean = false) : Boolean
      {
         try
         {
            return _extContext.call("quests_loadQuests",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function accept(param1:String) : Boolean
      {
         try
         {
            return _extContext.call("quests_accept",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function claim(param1:String, param2:String) : Boolean
      {
         try
         {
            return _extContext.call("quests_claim",param1,param2) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function displayUI() : Boolean
      {
         try
         {
            return _extContext.call("quests_displayUI") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function listenForCompletion() : Boolean
      {
         try
         {
            return _extContext.call("quests_listenForCompletion") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function loadEvents(param1:Boolean = false) : Boolean
      {
         try
         {
            return _extContext.call("quests_loadEvents",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function incrementEvent(param1:String, param2:int = 1) : Boolean
      {
         try
         {
            return _extContext.call("quests_incrementEvent",param1,param2) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function extContext_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         var _loc4_:* = undefined;
         var _loc5_:Quest = null;
         var _loc6_:* = undefined;
         try
         {
            switch(param1.code)
            {
               case "quests:ui:closed":
                  dispatchEvent(new QuestEvent("quests:ui:closed"));
                  break;
               case "quests:load:success":
                  _loc2_ = JSON.parse(param1.level);
                  _loc4_ = new Vector.<Quest>();
                  if(_loc2_.quests)
                  {
                     for each(var _loc3_ in _loc2_.quests)
                     {
                        trace(JSON.stringify(_loc3_));
                        _loc4_.push(Quest.fromObject(_loc3_));
                     }
                  }
                  dispatchEvent(new QuestEvent("quests:load:success",_loc4_));
                  break;
               case "quests:load:error":
               case "quests:quest:accept:error":
               case "quests:quest:claim:error":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new QuestEvent(param1.code,null,_loc2_.message,_loc2_.code));
                  break;
               case "quests:quest:completed":
               case "quests:quest:accept:success":
               case "quests:quest:claim:success":
                  _loc2_ = JSON.parse(param1.level);
                  _loc5_ = Quest.fromObject(_loc2_.quest);
                  dispatchEvent(new QuestEvent(param1.code,new <Quest>[_loc5_]));
                  break;
               case "events:load:success":
                  _loc2_ = JSON.parse(param1.level);
                  _loc6_ = new Vector.<PlayerEvent>();
                  if(_loc2_.events)
                  {
                     for each(var _loc7_ in _loc2_.events)
                     {
                        trace(JSON.stringify(_loc7_));
                        _loc6_.push(PlayerEvent.fromObject(_loc7_));
                     }
                  }
                  dispatchEvent(new PlayerEventEvent("events:load:success",_loc6_));
                  break;
               case "events:load:error":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new PlayerEventEvent("events:load:error",null,_loc2_.message,_loc2_.code));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

