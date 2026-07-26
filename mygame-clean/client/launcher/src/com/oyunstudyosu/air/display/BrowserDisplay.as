package com.oyunstudyosu.air.display
{
   import flash.Boot;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.LocationChangeEvent;
   import flash.geom.Rectangle;
   import flash.media.StageWebView;
   import openfl.Lib;
   
   public class BrowserDisplay extends MovieClip
   {
      
      public var viewPort:Rectangle;
      
      public var stageWebView:StageWebView;
      
      public var lastViewPort:Rectangle;
      
      public var initialURL:String;
      
      public function BrowserDisplay()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         stageWebView = new StageWebView();
         stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGE,onLocationChange);
         stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGING,onLocationChanging);
         lastViewPort = new Rectangle();
         viewPort = new Rectangle();
         addEventListener(Event.ADDED_TO_STAGE,onAdded);
         addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
         addEventListener(Event.ENTER_FRAME,onEnterFrame);
         Lib.get_current().stage.addEventListener(Event.RESIZE,onResize);
      }
      
      public function updateUI() : void
      {
      }
      
      public function onResize(param1:Event) : void
      {
      }
      
      public function onRemoved(param1:Event) : void
      {
         stageWebView.stage = null;
      }
      
      public function onLocationChanging(param1:LocationChangeEvent) : void
      {
      }
      
      public function onLocationChange(param1:LocationChangeEvent) : void
      {
      }
      
      public function onEnterFrame(param1:Event) : void
      {
         if(viewPort.equals(lastViewPort))
         {
            return;
         }
         lastViewPort.copyFrom(viewPort);
         stageWebView.viewPort = viewPort.clone();
         updateUI();
      }
      
      public function onAdded(param1:Event) : void
      {
         stageWebView.stage = stage;
      }
      
      public function loadURL(param1:String) : void
      {
         initialURL = param1;
         stageWebView.loadURL(param1);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         stageWebView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE,onLocationChange);
         stageWebView.removeEventListener(LocationChangeEvent.LOCATION_CHANGING,onLocationChanging);
         removeEventListener(Event.ADDED_TO_STAGE,onAdded);
         removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
         removeEventListener(Event.ENTER_FRAME,onEnterFrame);
         Lib.get_current().removeEventListener(Event.RESIZE,onResize);
         stageWebView.dispose();
      }
   }
}

