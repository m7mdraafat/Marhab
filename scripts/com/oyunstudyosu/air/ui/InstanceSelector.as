package com.oyunstudyosu.air.ui
{
   import com.greensock.TweenMax;
   import com.oyunstudyosu.air.embed.EmbedConfigData;
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.GameEvent;
   import feathers.controls.LayoutGroup;
   import feathers.layout.HorizontalAlign;
   import feathers.layout.TiledRowsLayout;
   import feathers.layout.VerticalAlign;
   import flash.Boot;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import haxe.ds.StringMap;
   import openfl.Lib;
   import openfl.utils.Assets;
   
   public class InstanceSelector extends Sprite
   {
      
      public var container:LayoutGroup;
      
      public function InstanceSelector()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         container = new LayoutGroup();
         var _loc1_:TiledRowsLayout = new TiledRowsLayout();
         _loc1_.set_requestedColumnCount(3);
         _loc1_.set_paddingLeft(_loc1_.set_paddingRight(50));
         _loc1_.set_horizontalAlign(HorizontalAlign.CENTER);
         _loc1_.set_verticalAlign(VerticalAlign.MIDDLE);
         _loc1_.set_horizontalGap(40);
         container.set_layout(_loc1_);
         addChild(container);
      }
      
      public function onResize(param1:Event = undefined) : void
      {
         container.width = Lib.get_current().stage.stageWidth;
         container.height = Lib.get_current().stage.stageHeight;
         container.validateNow();
      }
      
      public function onChangeInstance(param1:MouseEvent) : void
      {
         var _loc2_:InstanceItem = param1.currentTarget;
         var _loc3_:GameEvent = new GameEvent("INSTANCE_SELECTED");
         _loc3_.data = _loc2_.name;
         Dispatcher.dispatchEvent(_loc3_);
      }
      
      public function instanceItemOver(param1:MouseEvent) : void
      {
         TweenMax.to(param1.currentTarget,0,{"glowFilter":{
            "color":16776960,
            "alpha":1,
            "blurX":2,
            "blurY":2,
            "strength":4
         }});
      }
      
      public function instanceItemOut(param1:MouseEvent) : void
      {
         TweenMax.to(param1.currentTarget,0,{"glowFilter":{
            "color":16777215,
            "alpha":0,
            "blurX":0,
            "blurY":0,
            "strength":0
         }});
      }
      
      public function init() : void
      {
         var _loc3_:* = null as String;
         var _loc4_:* = null as StringMap;
         var _loc5_:* = null as InstanceItem;
         Lib.get_current().stage.addEventListener(Event.RESIZE,onResize);
         var _loc1_:int = 0;
         var _loc2_:Array = EmbedConfigData.orderedInstances;
         while(_loc1_ < int(_loc2_.length))
         {
            _loc3_ = _loc2_[_loc1_];
            _loc1_++;
            _loc4_ = EmbedConfigData.instances;
            _loc5_ = createInstanceItem(_loc3_,_loc3_ in StringMap.reserved ? _loc4_.getReserved(_loc3_) : _loc4_.h[_loc3_]);
            container.addChild(_loc5_);
         }
         onResize();
      }
      
      public function dispose() : void
      {
         var _loc3_:int = 0;
         Lib.get_current().stage.removeEventListener(Event.RESIZE,onResize);
         var _loc1_:int = 0;
         var _loc2_:int = container.numChildren;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            container.getChildAt(_loc3_).removeEventListener(MouseEvent.CLICK,onChangeInstance);
            container.getChildAt(_loc3_).removeEventListener(MouseEvent.ROLL_OVER,instanceItemOver);
            container.getChildAt(_loc3_).removeEventListener(MouseEvent.ROLL_OUT,instanceItemOut);
         }
      }
      
      public function createInstanceItem(param1:String, param2:String) : InstanceItem
      {
         var _loc4_:* = null as Bitmap;
         var _loc3_:InstanceItem = new InstanceItem();
         _loc3_.name = param1;
         _loc3_.title.text = param2;
         if(Assets.exists("assets/flags/" + param1 + ".png"))
         {
            _loc4_ = new Bitmap(Assets.getBitmapData("assets/flags/" + param1 + ".png"));
            _loc3_.image.addChild(_loc4_);
         }
         else
         {
            _loc4_ = new Bitmap(Assets.getBitmapData("assets/flags/unknown.png"));
            _loc3_.image.addChild(_loc4_);
         }
         _loc3_.addEventListener(MouseEvent.CLICK,onChangeInstance);
         _loc3_.addEventListener(MouseEvent.ROLL_OVER,instanceItemOver);
         _loc3_.addEventListener(MouseEvent.ROLL_OUT,instanceItemOut);
         return _loc3_;
      }
   }
}

