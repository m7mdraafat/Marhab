package com.oyunstudyosu.air.model
{
   import com.oyunstudyosu.air.controller.DataStorageController;
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.OSProgressEvent;
   import com.oyunstudyosu.air.RebuildLog;
   import com.oyunstudyosu.air.progress.ProgressVo;
   import flash.Boot;
   import flash.display.Loader;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   
   public class LoaderModel
   {
      
      public var stage:Stage;
      
      public var loader:Loader;
      
      public var instance:String;
      
      public var binaryLoader:URLLoader;
      
      public function LoaderModel(param1:Stage = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         stage = param1;
      }
      
      public function setInstance(param1:String) : void
      {
         instance = param1;
      }
      
      public function progress(param1:ProgressEvent) : void
      {
         var _loc2_:int = int(param1.bytesLoaded / param1.bytesTotal * 100);
         var _loc3_:ProgressVo = new ProgressVo(_loc2_,SanalikaClient.instance.localizationModel.translate("Loading Client"));
         Dispatcher.dispatchEvent(new OSProgressEvent("LOADING_PROGRESS",_loc3_));
      }
      
      public function load() : void
      {
         binaryLoader = new URLLoader();
         binaryLoader.addEventListener(IOErrorEvent.IO_ERROR,ioError);
         binaryLoader.addEventListener("complete",completed);
         binaryLoader.addEventListener(ProgressEvent.PROGRESS,progress);
         binaryLoader.dataFormat = "binary";
         var _loc1_:String = SanalikaClient.instance.config.loader;
         RebuildLog.write("loader request " + _loc1_);
         binaryLoader.load(new URLRequest(_loc1_));
      }
      
      public function ioError(param1:IOErrorEvent) : void
      {
         RebuildLog.write("loader ioError " + param1.text);
         var _loc2_:ProgressVo = new ProgressVo(0,SanalikaClient.instance.localizationModel.translate("Loading Client Failed"));
         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",_loc2_));
      }
      
      public function completed(param1:Event) : void
      {
         var _loc6_:* = null as String;
         binaryLoader.removeEventListener("complete",completed);
         var _loc2_:LoaderContext = new LoaderContext();
         _loc2_.applicationDomain = new ApplicationDomain(stage.loaderInfo.applicationDomain);
         _loc2_.allowCodeImport = true;
         var _loc3_:* = {};
         _loc3_.bg = SanalikaClient.instance.config.background;
         _loc3_.cs = SanalikaClient.instance.config.core;
         _loc3_.serverName = SanalikaClient.instance.config.serverName != null ? SanalikaClient.instance.config.serverName : instance;
         _loc3_.at = SanalikaClient.instance.config.token != null ? SanalikaClient.instance.config.token : DataStorageController.get("token","");
         _loc3_.fbToken = "";
         _loc3_.location = "";
         _loc3_.platform = "app";
         _loc3_.protocol = SanalikaClient.instance.config.protocol != null ? SanalikaClient.instance.config.protocol : "http://";
         RebuildLog.write("loader complete bytes=" + binaryLoader.data.length + " core=" + Std.string(_loc3_.cs) + " server=" + Std.string(_loc3_.serverName));
         var _loc4_:int = 0;
         var _loc5_:Array = Reflect.fields(_loc3_);
         while(_loc4_ < int(_loc5_.length))
         {
            _loc6_ = _loc5_[_loc4_];
            _loc4_++;
            _loc3_[_loc6_] = Std.string(Reflect.field(_loc3_,_loc6_));
         }
         _loc2_.parameters = _loc3_;
         loader = new Loader();
         var _loc7_:ByteArray = new ByteArray();
         _loc7_ = binaryLoader.data;
         if(_loc7_.length != 0)
         {
            loader.loadBytes(_loc7_,_loc2_);
            stage.addChild(loader);
            RebuildLog.write("loader loadBytes addedToStage");
         }
         SanalikaClient.instance.progresView.dispose();
         SanalikaClient.instance.removeChild(SanalikaClient.instance.progresView);
      }
   }
}

