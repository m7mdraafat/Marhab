package com.oyunstudyosu.air.commands
{
   import com.junkbyte.console.Cc;
   import com.oyunstudyosu.air.RebuildLog;
   import com.oyunstudyosu.air.controller.DataStorageController;
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.GameEvent;
   import com.oyunstudyosu.air.ui.InstanceSelector;
   import flash.Boot;
   import flash.display.Stage;
   import flash.filesystem.File;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class SelectInstanceCommand extends Command
   {
      
      public var stage:Stage;
      
      public var instanceSelector:InstanceSelector;
      
      public function SelectInstanceCommand(param1:Stage = undefined)
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         stage = param1;
      }
      
      public function onInstanceSelected(param1:GameEvent) : void
      {
         Dispatcher.removeEventListener("INSTANCE_SELECTED",onInstanceSelected);
         SanalikaClient.instance.loaderModel.setInstance(param1.data);
         complete();
      }
      
      override public function execute() : void
      {
         var _loc3_:* = null as GameEvent;
         var _loc5_:* = null;
         var _loc6_:URLLoader = null;
         Cc.info("SelectInstanceCommand.execute()");
         SanalikaClient.instance.progresView.visible = false;
         Dispatcher.addEventListener("INSTANCE_SELECTED",onInstanceSelected);
         var _loc1_:String = DataStorageController.get("instance","");
         var _loc2_:String = DataStorageController.get("token","");
         var _loc4_:File = File.applicationDirectory.resolvePath("runtime/c.local.json");
         if(_loc4_.exists && (_loc1_ == "" || _loc2_ == ""))
         {
            _loc5_ = SanalikaClient.instance.config != null && SanalikaClient.instance.config.serverName != null ? SanalikaClient.instance.config.serverName : "local";
            RebuildLog.write("local runtime auto-select instance=" + _loc5_);
            _loc3_ = new GameEvent("INSTANCE_SELECTED");
            _loc3_.data = _loc5_;
            Dispatcher.dispatchEvent(_loc3_);
            return;
         }
         if(_loc1_ == "" || _loc2_ == "")
         {
            DataStorageController.set("instance","");
            DataStorageController.set("token","");
            instanceSelector = new InstanceSelector();
            instanceSelector.init();
            SanalikaClient.instance.addChild(instanceSelector);
            instanceSelector.onResize();
         }
         else
         {
            RebuildLog.write("stored instance selected instance=" + _loc1_);
            _loc3_ = new GameEvent("INSTANCE_SELECTED");
            _loc3_.data = _loc1_;
            Dispatcher.dispatchEvent(_loc3_);
         }
      }
      
      override public function dispose() : void
      {
         SanalikaClient.instance.progresView.visible = true;
         if(instanceSelector != null)
         {
            instanceSelector.dispose();
            SanalikaClient.instance.removeChild(instanceSelector);
         }
         super.dispose();
      }
   }
}

