package com.oyunstudyosu.air.events
{
   import com.oyunstudyosu.air.progress.ProgressVo;
   import flash.Boot;
   import flash.events.Event;
   
   public class OSProgressEvent extends Event
   {
      
      public static var INIT_PROGRESS:String = "INIT_PROGRESS";
      
      public static var LOADING_PROGRESS:String = "LOADING_PROGRESS";
      
      public static var HIDE_PROGRESS:String = "HIDE_PROGRESS";
      
      public var vo:ProgressVo;
      
      public function OSProgressEvent(param1:String = undefined, param2:ProgressVo = undefined)
      {
         super(param1,true,false);
         if(Boot.skip_constructor)
         {
            return;
         }
         vo = param2;
      }
      
      override public function clone() : Event
      {
         return new OSProgressEvent(type,vo);
      }
   }
}

