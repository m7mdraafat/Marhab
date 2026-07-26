package com.oyunstudyosu.air.progress
{
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.OSProgressEvent;
   import flash.Boot;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import haxe.IMap;
   import haxe.ds.StringMap;
   import openfl.Lib;
   import org.oyunstudyosu.air.assets.clips.ProgressUI;
   
   public class ProgressView extends Sprite
   {
      
      public var view:*;
      
      public var stxtTitle:TextField;
      
      public var progressText:IMap;
      
      public var initProgress:int;
      
      public var changeAnimationInterval:int;
      
      public function ProgressView()
      {
         super();
         var _loc2_:* = null as StringMap;
         if(Boot.skip_constructor)
         {
            return;
         }
         changeAnimationInterval = -1;

         progressText = new StringMap();
         var _loc1_:int = int(Math.random() * 5);
         switch(_loc1_)
         {
            case 0:
               _loc2_ = progressText;
               if("LOADING" in StringMap.reserved)
               {
                  _loc2_.setReserved("LOADING","°j°m");
               }
               else
               {
                  _loc2_.h["LOADING"] = "°j°m";
               }
               break;
            case 1:
               _loc2_ = progressText;
               if("LOADING" in StringMap.reserved)
               {
                  _loc2_.setReserved("LOADING","><((((‘>");
               }
               else
               {
                  _loc2_.h["LOADING"] = "><((((‘>";
               }
               break;
            case 2:
               _loc2_ = progressText;
               if("LOADING" in StringMap.reserved)
               {
                  _loc2_.setReserved("LOADING","‘-‘_@_");
               }
               else
               {
                  _loc2_.h["LOADING"] = "‘-‘_@_";
               }
               break;
            case 3:
               _loc2_ = progressText;
               if("LOADING" in StringMap.reserved)
               {
                  _loc2_.setReserved("LOADING","(,,,)=(^.^)=(,,,)");
               }
               else
               {
                  _loc2_.h["LOADING"] = "(,,,)=(^.^)=(,,,)";
               }
               break;
            case 4:
               _loc2_ = progressText;
               if("LOADING" in StringMap.reserved)
               {
                  _loc2_.setReserved("LOADING","—-{,_,”>");
               }
               else
               {
                  _loc2_.h["LOADING"] = "—-{,_,”>";
               }
               break;
            case 5:
               _loc2_ = progressText;
               if("LOADING" in StringMap.reserved)
               {
                  _loc2_.setReserved("LOADING","~~~~~~~~*\\o/~~~~~/\\*~~~~~~~");
                  break;
               }
               _loc2_.h["LOADING"] = "~~~~~~~~*\\o/~~~~~/\\*~~~~~~~";
         }
         view = new ProgressUI();
         // ProgressUI is a decompiler stub: its `bar` MovieClip child only exists
         // when instantiated from the SanalikaAirUI.swf library, not from this code.
         // Guard every access so missing FLA symbols don't crash the boot.
         if(view.bar != null && view.bar.loadingText != null)
         {
            view.bar.loadingText.multiline = true;
            view.bar.loadingText.wordWrap = true;
            view.bar.loadingText.autoSize = "center";
         }
         if(view.bar != null && view.bar.animation != null)
         {
            view.bar.animation.gotoAndStop(0);
         }
         addChild(view);
         Dispatcher.addEventListener("INIT_PROGRESS",onInitProgress);
         Dispatcher.addEventListener("LOADING_PROGRESS",onLoadingProgress);
         Dispatcher.addEventListener("HIDE_PROGRESS",onHideProgress);
         Lib.get_current().stage.addEventListener(Event.RESIZE,onResize);
         onResize(null);
         changeAnimation();
      }
      
      public function translateProcess(param1:String, ... rest) : String
      {
         return param1;
      }
      
      public function onResize(param1:Event) : void
      {
         x = Lib.get_current().stage.stageWidth / 2;
         y = Lib.get_current().stage.stageHeight / 2;
      }
      
      public function onLoadingProgress(param1:OSProgressEvent) : void
      {
         addChild(view);
         if(view != null && view.bar != null && view.bar.loadingText != null)
         {
            view.bar.loadingText.text = param1.vo.description + "\n%" + param1.vo.percent;
         }
      }
      
      public function onInitProgress(param1:OSProgressEvent) : void
      {
         initProgress = param1.vo.percent;
         if(view != null && view.bar != null && view.bar.loadingText != null)
         {
            view.bar.loadingText.text = param1.vo.description;
         }
         addChild(view);
      }
      
      public function onHideProgress(param1:OSProgressEvent) : void
      {
         visible = false;
      }
      
      public function dispose() : void
      {
         if(changeAnimationInterval != -1)
         {
            Lib.clearTimeout(changeAnimationInterval);
         }
         Lib.get_current().stage.removeEventListener(Event.RESIZE,onResize);
         Dispatcher.removeEventListener("INIT_PROGRESS",onInitProgress);
         Dispatcher.removeEventListener("LOADING_PROGRESS",onLoadingProgress);
      }
      
      public function changeAnimation() : void
      {
         if(changeAnimationInterval != -1)
         {
            Lib.clearTimeout(changeAnimationInterval);
         }
         var _loc1_:int = int(int(Math.floor(Math.random() * 5)) + 1);
         if(view != null && view.bar != null && view.bar.animation != null)
         {
            view.bar.animation.gotoAndStop(_loc1_);
         }
         changeAnimationInterval = Lib.setTimeout(changeAnimation,20000);
      }
   }
}

