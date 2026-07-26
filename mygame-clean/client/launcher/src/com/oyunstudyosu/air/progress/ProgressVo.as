package com.oyunstudyosu.air.progress
{
   import flash.Boot;
   
   public class ProgressVo
   {
      
      public static var init__:Boolean;
      
      public static var CONNECTING:ProgressVo;
      
      public static var LANG_FILE_READY:ProgressVo;
      
      public static var CONNECTED:ProgressVo;
      
      public static var CONNECTION_FAIL:ProgressVo;
      
      public static var CONNECTION_RETRY:ProgressVo;
      
      public static var LOGINED:ProgressVo;
      
      public static var CONFIG_READY:ProgressVo;
      
      public static var INFO_FILE_READY:ProgressVo;
      
      public static var GAME_EXTENSIONS_LOADED:ProgressVo;
      
      public static var INIT_READY:ProgressVo;
      
      public static var GAME_READY:ProgressVo;
      
      public static var PROGRESS_FULL:ProgressVo;
      
      public static var LOADING:ProgressVo;
      
      public static var ROOM_FILES:ProgressVo;
      
      public static var LOAD_DESIGNER:ProgressVo;
      
      public static var LOAD_PLAYBACK_PLAYER:ProgressVo;
      
      public static var DESIGNER_LOADED:ProgressVo;
      
      public static var JOINING_USER_ROOM:ProgressVo;
      
      public var percent:int;
      
      public var description:String;
      
      public var args:*;
      
      public function ProgressVo(param1:int = 0, param2:String = undefined, ... rest)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         percent = param1;
         description = param2;
         args = rest;
      }
   }
}

