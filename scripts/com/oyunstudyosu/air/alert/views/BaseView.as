package com.oyunstudyosu.air.alert.views
{
   import flash.Boot;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import openfl.Lib;
   
   public class BaseView extends Sprite
   {
      
      public function BaseView()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
         addEventListener("closeClicked",onCloseClicked);
      }
      
      public function resizeEvents() : void
      {
         x = (Lib.get_current().stage.stageWidth - width) / 2;
         y = (Lib.get_current().stage.stageHeight - height) / 2;
         scaleX = scaleY = SanalikaClient.instance.scaleModel.getRecommendedScaleRate();
      }
      
      public function onResize(param1:Event) : void
      {
         resizeEvents();
      }
      
      public function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
         stage.removeEventListener(Event.RESIZE,onResize);
      }
      
      public function onCloseClicked(param1:Event) : void
      {
         parent.removeChild(this);
      }
      
      public function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
         stage.addEventListener(Event.RESIZE,onResize);
         resizeEvents();
      }
      
      public function init() : void
      {
         resizeEvents();
      }
   }
}

