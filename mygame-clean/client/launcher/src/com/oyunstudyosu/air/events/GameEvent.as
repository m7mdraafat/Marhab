package com.oyunstudyosu.air.events
{
   import flash.Boot;
   import flash.events.Event;
   
   public class GameEvent extends Event
   {
      
      public static var INSTANCE_SELECTED:String = "INSTANCE_SELECTED";
      
      public static var INITIALIZE:String = "INITIALIZE";
      
      public static var INSTANCE_DETECTED:String = "INSTANCE_DETECTED";
      
      public static var NO_INSTANCE_DETECTED:String = "NO_INSTANCE_DETECTED";
      
      public static var NO_CONTAINER_DETECTED:String = "NO_CONTAINER_DETECTED";
      
      public static var INVALID_DOMAIN_DETECTED:String = "INVALID_DOMAIN_DETECTED";
      
      public static var EXTENSIONS_LOADED:String = "EXTENSIONS_LOADED";
      
      public static var ITEM_INFO_FILE_LOADED:String = "ITEM_INFO_FILE_LOADED";
      
      public static var VERSION_FILE_LOADED:String = "VERSION_FILE_LOADED";
      
      public static var LOGOUT_COMPLETE:String = "LOGOUT_COMPLETE";
      
      public static var INITCOMMAND:String = "INITCOMMAND";
      
      public static var SCENE_LOADED:String = "SCENE_LOADED";
      
      public static var SCENE_DATA_LOADED:String = "SCENE_DATA_LOADED";
      
      public static var TERMINATE_PROVISION:String = "TERMINATE_PROVISION";
      
      public static var TERMINATE_SCENE:String = "TERMINATE_SCENE";
      
      public static var TERMINATE_GAME:String = "TERMINATE_GAME";
      
      public static var STOP_RAIN:String = "STOP_RAIN";
      
      public static var RESIZE:String = "RESIZE";
      
      public static var RELOAD:String = "RELOAD";
      
      public static var USER_LEAVE_ROOM:String = "USER_LEAVE_ROOM";
      
      public static var USER_ENTER_ROOM:String = "USER_ENTER_ROOM";
      
      public static var USER_POSITION_UPDATED:String = "USER_POSITION_UPDATED";
      
      public static var TRANSITION_IN:String = "TRANSITION_IN";
      
      public static var TRANSITION_IN_COMPLETE:String = "TRANSITION_IN_COMPLETE";
      
      public static var TRANSITION_OUT:String = "TRANSITION_OUT";
      
      public static var TRANSITION_OUT_COMPLETE:String = "TRANSITION_OUT_COMPLETE";
      
      public static var TRANSFER_ITEM:String = "TRANSFER_ITEM";
      
      public static var ACTIVE_GRID_CHANGED:String = "ACTIVE_GRID_CHANGED";
      
      public static var SAVE_AVATAR_IMAGE:String = "SAVE_AVATAR_IMAGE";
      
      public static var SAVE_ROOM_IMAGE:String = "SAVE_ROOM_IMAGE";
      
      public static var SAVE_TEMP_IMAGE:String = "SAVE_TEMP_IMAGE";
      
      public static var SS_IMAGE:String = "SS_IMAGE";
      
      public static var STAGE_IMAGE:String = "STAGE_IMAGE";
      
      public static var PLAYBACK_ALLOW:String = "PLAYBACK_ALLOW";
      
      public static var ROOM_IMAGE_SAVED:String = "ROOM_IMAGE_SAVED";
      
      public static var ROOM_MAP_INITIALIZED:String = "ROOM_MAP_INITIALIZED";
      
      public static var PREVIOUS_ROOM:String = "PREVIOUS_ROOM";
      
      public static var CANVAS_HEIGHT_CHANGED:String = "CANVAS_HEIGHT_CHANGED";
      
      public static var FACEBOOK_AUTHENTICATION:String = "FACEBOOK_AUTHENTICATION";
      
      public static var GOOGLE_AUTHENTICATION:String = "GOOGLE_AUTHENTICATION";
      
      public var lang:String;
      
      public var id:String;
      
      public var data:*;
      
      public function GameEvent(param1:String = undefined)
      {
         super(param1,true,false);
         if(Boot.skip_constructor)
         {
            return;
         }
      }
      
      override public function clone() : Event
      {
         var _loc1_:GameEvent = new GameEvent(type);
         _loc1_.id = id;
         _loc1_.data = data;
         return _loc1_;
      }
   }
}

