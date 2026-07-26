package com.oyunstudyosu.progress
{
   import com.greensock.TweenMax;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.events.OSProgressEvent;
   import com.oyunstudyosu.local.LocalInstanceConfig;
   import com.oyunstudyosu.local.LocalTranslation;
   import com.oyunstudyosu.utils.NumberUtils;
   import com.oyunstudyosu.utils.STextField;
   import com.oyunstudyosu.utils.TextFieldManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   import org.oyunstudyosu.assets.clips.ProgressUI;
   
   public class ProgressView extends Sprite
   {
      
      private var view:ProgressUI;
      
      private var currentPercent:int;
      
      private var initProgress:int;
      
      private var progressText:Dictionary;
      
      public var stxtTitle:STextField;
      
      private var neonBar:Sprite;
      
      private var neonBarBg:Sprite;
      
      private var logoText:TextField;
      
      private var percentText:TextField;
      
      private var statusText:TextField;
      
      public function ProgressView()
      {
         super();
         progressText = new Dictionary();
         var _loc1_:int = Math.random() * 5;
         switch(_loc1_)
         {
            case 0:
               progressText["LOADING"] = "°j°m";
               break;
            case 1:
               progressText["LOADING"] = "><((((\'>";
               break;
            case 2:
               progressText["LOADING"] = "\'-\'_@_";
               break;
            case 3:
               progressText["LOADING"] = "(,,,)=(^.^)=(,,,)";
               break;
            case 4:
               progressText["LOADING"] = "—-{,_,";
               break;
            case 5:
               progressText["LOADING"] = "~~~~~~~~*o/~~~~~/*~~~~~~~";
         }
         view = new ProgressUI();
         addChild(view);
         view.visible = false;
         setupModernUI();
         Dispatcher.addEventListener("INIT_PROGRESS",onInitProgress);
         Dispatcher.addEventListener("LOADING_PROGRESS",onLoadingProgress);
         Dispatcher.addEventListener("INITCOMMAND",onInitCommand);
      }
      
      private function setupModernUI() : void
      {
         logoText = new TextField();
         logoText.width = 300;
         logoText.height = 50;
         logoText.selectable = false;
         var logoFormat:TextFormat = new TextFormat();
         logoFormat.font = "Arial";
         logoFormat.size = 36;
         logoFormat.color = 16766720;
         logoFormat.bold = true;
         logoFormat.align = TextFormatAlign.CENTER;
         logoFormat.letterSpacing = 5;
         logoText.defaultTextFormat = logoFormat;
         logoText.text = "MARHAB";
         logoText.x = -150;
         logoText.y = -70;
         var logoGlow:GlowFilter = new GlowFilter(16753920,0.8,12,12,2,1);
         var logoShadow:DropShadowFilter = new DropShadowFilter(2,45,0,0.5,4,4);
         logoText.filters = [logoGlow,logoShadow];
         addChild(logoText);
         neonBarBg = new Sprite();
         neonBarBg.graphics.beginFill(1710638,1);
         neonBarBg.graphics.drawRoundRect(-150,-6,300,12,6);
         neonBarBg.graphics.endFill();
         neonBarBg.graphics.lineStyle(1,3355477,1);
         neonBarBg.graphics.drawRoundRect(-150,-6,300,12,6);
         addChild(neonBarBg);
         neonBar = new Sprite();
         neonBar.graphics.beginFill(16766720);
         neonBar.graphics.drawRoundRect(-150,-6,300,12,6);
         neonBar.graphics.endFill();
         neonBar.scaleX = 0;
         var barGlow:GlowFilter = new GlowFilter(16753920,0.6,10,10,2,1);
         neonBar.filters = [barGlow];
         addChild(neonBar);
         percentText = new TextField();
         percentText.width = 100;
         percentText.height = 25;
         percentText.selectable = false;
         var percentFormat:TextFormat = new TextFormat();
         percentFormat.font = "Arial";
         percentFormat.size = 14;
         percentFormat.color = 16766720;
         percentFormat.bold = true;
         percentFormat.align = TextFormatAlign.CENTER;
         percentText.defaultTextFormat = percentFormat;
         percentText.text = "0%";
         percentText.x = -50;
         percentText.y = 15;
         addChild(percentText);
         statusText = new TextField();
         statusText.width = 300;
         statusText.height = 20;
         statusText.selectable = false;
         var statusFormat:TextFormat = new TextFormat();
         statusFormat.font = "Arial";
         statusFormat.size = 11;
         statusFormat.color = 8947865;
         statusFormat.align = TextFormatAlign.CENTER;
         statusText.defaultTextFormat = statusFormat;
         statusText.text = "Loading...";
         statusText.x = -150;
         statusText.y = 38;
         addChild(statusText);
         addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
      }
      
      private function onAddedToStage(event:Event) : void
      {
         updatePosition();
      }
      
      private function updatePosition() : void
      {
         neonBarBg.x = 0;
         neonBarBg.y = 0;
         neonBar.x = 0;
         neonBar.y = 0;
      }
      
      private function onInitCommand(param1:GameEvent) : void
      {
         if(!view || !view.bar || !view.bar.loadingText || view.bar.loadingText is STextField)
         {
            return;
         }
         if(LocalInstanceConfig.get("LANGUAGE") == "ar")
         {
            view.bar.loadingText = TextFieldManager.convertAsArabicTextField(view.bar.loadingText,view.bar.loadingText.multiline,false);
         }
      }
      
      private function translateProcess(param1:String, ... rest) : String
      {
         var _loc4_:* = undefined;
         param1 = "PROGRESS_" + param1;
         if(LocalTranslation.exists(param1))
         {
            _loc4_ = [];
            _loc4_.push(param1);
            for each(var _loc3_ in rest)
            {
               _loc4_.push(_loc3_);
            }
            return LocalTranslation.translate.apply(this,_loc4_);
         }
         return param1;
      }
      
      private function changeAnimation() : void
      {
         if(!view || !view.bar || !view.bar.animation)
         {
            return;
         }
         TweenMax.killDelayedCallsTo(changeAnimation);
         var _loc1_:int = NumberUtils.randRange(1,view.bar.animation.totalFrames);
         view.bar.animation.gotoAndStop(_loc1_);
         TweenMax.delayedCall(20,changeAnimation);
      }
      
      private function onProgressCompleted() : void
      {
         initProgress = 0;
         currentPercent = 0;
         this.visible = false;
      }
      
      private function onLoadingProgress(param1:OSProgressEvent) : void
      {
         currentPercent = initProgress + (100 - initProgress) * param1.vo.percent / 100;
         this.visible = true;
         var _loc3_:Array = [];
         _loc3_.push(param1.vo.description);
         for each(var _loc2_ in param1.vo.args)
         {
            _loc3_.push(_loc2_);
         }
         var desc:String = translateProcess.apply(this,_loc3_);
         if(view && view.bar && view.bar.loadingText)
         {
            view.bar.loadingText.text = desc;
         }
         if(statusText)
         {
            statusText.text = desc;
         }
         if(percentText)
         {
            percentText.text = Math.round(currentPercent) + "%";
         }
         TweenMax.to(neonBar,0.5,{"scaleX":currentPercent / 100});
         updatePosition();
         if(currentPercent >= 100)
         {
            onProgressCompleted();
         }
      }
      
      private function onInitProgress(param1:OSProgressEvent) : void
      {
         initProgress = param1.vo.percent;
         var _loc3_:Array = [];
         _loc3_.push(param1.vo.description);
         for each(var _loc2_ in param1.vo.args)
         {
            _loc3_.push(_loc2_);
         }
         var desc:String = translateProcess.apply(this,_loc3_);
         if(view && view.bar && view.bar.loadingText)
         {
            view.bar.loadingText.text = desc;
         }
         if(statusText)
         {
            statusText.text = desc;
         }
         if(percentText)
         {
            percentText.text = Math.round(initProgress) + "%";
         }
         TweenMax.to(neonBar,0.5,{"scaleX":initProgress / 100});
         updatePosition();
         this.visible = true;
         if(initProgress >= 100)
         {
            onProgressCompleted();
         }
      }
      
      public function dispose() : void
      {
         TweenMax.killDelayedCallsTo(changeAnimation);
         Dispatcher.removeEventListener("INIT_PROGRESS",onInitProgress);
         Dispatcher.removeEventListener("LOADING_PROGRESS",onLoadingProgress);
         Dispatcher.removeEventListener("INITCOMMAND",onInitCommand);
      }
   }
}

