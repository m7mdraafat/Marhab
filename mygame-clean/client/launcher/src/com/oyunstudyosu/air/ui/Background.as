package com.oyunstudyosu.air.ui
{
   import flash.Boot;
   import flash.Lib;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import openfl.utils.Assets;
   
   public class Background extends Bitmap
   {
      
      public function Background()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         bitmapData = Assets.getBitmapData("assets:assets/background.png");
         addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
      }
      
      public function resizeEvents() : void
      {
         var _loc1_:Number = Lib.current.stage.stageWidth / (width / scaleX);
         var _loc2_:Number = Lib.current.stage.stageHeight / (height / scaleY);
         if(_loc1_ > _loc2_)
         {
            _loc2_ = _loc1_;
         }
         else if(_loc2_ > _loc1_)
         {
            _loc1_ = _loc2_;
         }
         scaleX = _loc1_;
         scaleY = _loc2_;
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
      
      public function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
         stage.addEventListener(Event.RESIZE,onResize);
         resizeEvents();
      }
   }
}

