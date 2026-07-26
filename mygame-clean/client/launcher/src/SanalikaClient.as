package
{
   import com.oyunstudyosu.air.commands.ClearCredentialsCommand;
   import com.oyunstudyosu.air.commands.ProcessUpdateCommandConfig;
   import com.oyunstudyosu.air.commands.RemoteConfigCommand;
   import com.oyunstudyosu.air.commands.SelectInstanceCommand;
   import com.oyunstudyosu.air.commands.SerialCommand;
   import com.oyunstudyosu.air.commands.StartGameCommand;
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.OSProgressEvent;
   import com.oyunstudyosu.air.model.AirModel;
   import com.oyunstudyosu.air.model.BrowserModel;
   import com.oyunstudyosu.air.model.CacheModel;
   import com.oyunstudyosu.air.model.LoaderModel;
   import com.oyunstudyosu.air.model.LocalizationModel;
   import com.oyunstudyosu.air.model.ScaleModel;
   import com.oyunstudyosu.air.native.NativeExtensionModel;
   import com.oyunstudyosu.air.progress.ProgressView;
   import com.oyunstudyosu.air.progress.ProgressVo;
   import com.oyunstudyosu.air.ui.Background;
   import com.oyunstudyosu.air.RebuildLog;
   import com.oyunstudyosu.air.RLog;
   import flash.Boot;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.Security;
   import flash.utils.Timer;
   
   public class SanalikaClient extends Sprite
   {
      
      public static var instance:SanalikaClient;
      
      public var scaleModel:ScaleModel;
      
      public var progresView:ProgressView;
      
      public var nativeExtensionModel:NativeExtensionModel;
      
      public var localizationModel:LocalizationModel;
      
      public var loaderModel:LoaderModel;
      
      public var config:Object;
      
      public var cacheModel:CacheModel;
      
      public var browserModel:BrowserModel;
      
      public var background:Background;
      
      public var airModel:AirModel;
      
      public function SanalikaClient()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         SanalikaClient.instance = this;
         // Stage may be null here because DocumentClass calls super() before
         // attaching this Sprite. Defer all stage.* setup to onAddedToStage.
         if(stage != null)
         {
            applyStageSettings();
         }
         addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
      }

      private function applyStageSettings() : void
      {
         stage.frameRate = 24;
         stage.quality = "best";
         stage.scaleMode = "noScale";
      }

      public function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
         RLog.start("clean-original-loader");
         RLog.write("launcher.addedToStage",{"stageWidth":stage.stageWidth,"stageHeight":stage.stageHeight});
         RebuildLog.write("SanalikaClient.onAddedToStage start");
         applyStageSettings();
         // Preload the asset host's Flash policy file. AIR application sandbox
         // doesn't need this, but the inner game SWF (loaded via Loader.loadBytes
         // with a child ApplicationDomain) appears to silently drop URLLoader
         // calls until a policy is registered.
         try {
             Security.loadPolicyFile("http://127.0.0.1:8080/crossdomain.xml");
             RLog.write("launcher.policy.loaded",{"url":"http://127.0.0.1:8080/crossdomain.xml"});
             RebuildLog.write("[POLICY] loadPolicyFile done");
         } catch (e:Error) {
             RLog.write("launcher.policy.error",e);
             RebuildLog.write("[POLICY] failed: " + e.message);
         }
         airModel = new AirModel(stage);
         scaleModel = new ScaleModel(stage);
         background = new Background();
         addChild(background);
         progresView = new ProgressView();
         addChild(progresView);
         localizationModel = new LocalizationModel();
         var _loc2_:ProgressVo = new ProgressVo(0,localizationModel.translate("Initializing..."));
         Dispatcher.dispatchEvent(new OSProgressEvent("LOADING_PROGRESS",_loc2_));
         browserModel = new BrowserModel(stage);
         nativeExtensionModel = new NativeExtensionModel(stage);
         loaderModel = new LoaderModel(stage);
         cacheModel = new CacheModel();
         RebuildLog.write("SanalikaClient about to build SerialCommand chain");
         RLog.write("launcher.commandChain.create",{});
         var _loc3_:SerialCommand = new SerialCommand();
         _loc3_.addCommand(new ClearCredentialsCommand());
         _loc3_.addCommand(new RemoteConfigCommand());
         _loc3_.addCommand(new ProcessUpdateCommandConfig());
         _loc3_.addCommand(new SelectInstanceCommand(stage));
         _loc3_.addCommand(new StartGameCommand());
         _loc3_.addEventListener(Event.COMPLETE,initCommandsCompleted);
         RebuildLog.write("SanalikaClient.SerialCommand.execute()");
         RLog.write("launcher.commandChain.execute",{});
         _loc3_.execute();
      }
      
      public function initCommandsCompleted(param1:Event) : void
      {
         RebuildLog.write("SanalikaClient.initCommandsCompleted");
         RLog.write("launcher.commandChain.complete",{"sessionPath":RLog.currentSessionPath});
         removeChild(background);
         setupWindowTitleEnforcer();
         setupUncaughtErrorSink();
      }

      /**
       * The inner game SWF reassigns stage.nativeWindow.title to its own value
       * once it boots, undoing whatever the AIR descriptor said. Re-assert our
       * title once per second so ours stays visible.
       */
      private function setupWindowTitleEnforcer() : void
      {
         try
         {
            if(stage != null && stage.nativeWindow != null)
            {
               stage.nativeWindow.title = "MyGame";
            }
         }
         catch(_loc_e_:*) {}

         var _t:Timer = new Timer(1000);
         _t.addEventListener(TimerEvent.TIMER,function(e:TimerEvent):void
         {
            try
            {
               if(stage != null && stage.nativeWindow != null && stage.nativeWindow.title != "MyGame")
               {
                  stage.nativeWindow.title = "MyGame";
               }
            }
            catch(_loc_e_:*) {}
         });
         _t.start();
      }

      /**
       * The inner game SWF has known decompile artifacts that throw uncaught
       * exceptions (dya68_ ReferenceError, YoutubePlayer Invalid BitmapData).
       * They're benign but pop a dialog under adl. Swallow them to keep the
       * window clean; still log to the rebuild trace.
       */
      private function setupUncaughtErrorSink() : void
      {
         try
         {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent):void
            {
               try
               {
                  RebuildLog.write("[uncaught-suppressed] " + e.error);
                  RLog.write("launcher.uncaught.suppressed",{"error":e.error});
               }
               catch(_loc_e_:*) {}
               e.preventDefault();
            });
         }
         catch(_loc_e_:*) {}
      }
   }
}

