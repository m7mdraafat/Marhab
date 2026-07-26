package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.achievements.Achievement;
   import com.distriqt.extension.gameservices.achievements.Achievements;
   import com.distriqt.extension.gameservices.events.AchievementEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _AchievementsImpl extends EventDispatcher implements Achievements
   {
      
      private var _extContext:ExtensionContext = null;
      
      public function _AchievementsImpl(param1:ExtensionContext)
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
         return _extContext.call("achievements_isSupported") as Boolean;
      }
      
      public function loadAchievements(param1:Boolean = false) : void
      {
         try
         {
            _extContext.call("achievements_loadAchievements",param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function get canResetAchievements() : Boolean
      {
         try
         {
            return _extContext.call("achievements_canResetAchievements") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function resetAchievements() : void
      {
         try
         {
            _extContext.call("achievements_resetAchievements");
         }
         catch(e:Error)
         {
         }
      }
      
      public function achievementReveal(param1:String) : void
      {
         _extContext.call("achievements_achievementReveal",param1);
      }
      
      public function achievementUnlock(param1:String) : void
      {
         _extContext.call("achievements_achievementUnlock",param1);
      }
      
      public function achievementStepsSet(param1:String, param2:int) : void
      {
         _extContext.call("achievements_achievementStepsSet",param1,param2);
      }
      
      public function achievementStepsIncrement(param1:String, param2:int) : void
      {
         _extContext.call("achievements_achievementStepsIncrement",param1,param2);
      }
      
      public function displayAchievementsUI() : void
      {
         _extContext.call("achievements_displayAchievementsUI");
      }
      
      private function extension_statusHandler(param1:StatusEvent) : void
      {
         var _loc4_:Object = null;
         var _loc3_:Array = null;
         var _loc2_:Object = null;
         try
         {
            switch(param1.code)
            {
               case "achievements:loaded":
                  _loc3_ = [];
                  _loc2_ = JSON.parse(param1.level);
                  for each(var _loc5_ in _loc2_.achievements)
                  {
                     _loc3_.push(Achievement.fromObject(_loc5_));
                  }
                  dispatchEvent(new AchievementEvent("achievements:loaded",null,_loc3_));
                  break;
               case "achievements:reset:error":
               case "achievements:error":
                  _loc4_ = JSON.parse(param1.level);
                  dispatchEvent(new AchievementEvent(param1.code,null,_loc4_));
                  break;
               case "achievements:reset:complete":
                  dispatchEvent(new AchievementEvent(param1.code,null,null));
                  break;
               case "achievements:ui:closed":
                  dispatchEvent(new AchievementEvent("achievements:ui:closed",null,null));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

