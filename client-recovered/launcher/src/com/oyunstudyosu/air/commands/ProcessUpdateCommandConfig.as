package com.oyunstudyosu.air.commands
{
   import com.junkbyte.console.Cc;
   import com.oyunstudyosu.air.alert.AlertVo;
   import com.oyunstudyosu.air.alert.views.WarningView;
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.OSProgressEvent;
   import com.oyunstudyosu.air.progress.ProgressVo;
   import flash.Boot;
   import flash.desktop.NativeApplication;
   import flash.desktop.NativeProcess;
   import flash.desktop.NativeProcessStartupInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.utils.ByteArray;
   import haxe.Exception;
   import haxe.io.Error;
   import openfl.Lib;
   
   public class ProcessUpdateCommandConfig extends Command
   {
      
      public var versionData:Object;
      
      public var currentPlatform:String;
      
      public function ProcessUpdateCommandConfig()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         currentPlatform = "windows";
      }
      
      public function getUpdateData(param1:Array) : Object
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         while(_loc2_ < int(param1.length))
         {
            _loc3_ = param1[_loc2_];
            _loc2_++;
            if(_loc3_.platform == currentPlatform)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      override public function execute() : void
      {
         var _loc2_:* = null as WarningView;
         Cc.info("ProcessUpdateCommandConfig.execute()");
         var _loc1_:* = SanalikaClient.instance.config;
         versionData = getUpdateData(_loc1_.versionData);
         if(versionData == null)
         {
            complete();
            return;
         }
         if(versionData.version != "1.0.1.2")
         {
            if(currentPlatform == "windows")
            {
               downloadUpdate();
            }
            else
            {
               Lib.navigateToURL(new URLRequest(versionData.url),"_blank");
               _loc2_ = new WarningView();
               _loc2_.vo = new AlertVo();
               _loc2_.vo.title = SanalikaClient.instance.localizationModel.translate("Information");
               _loc2_.vo.description = SanalikaClient.instance.localizationModel.translate("You have been redirected to the web page to download the update");
               _loc2_.init();
               Lib.get_current().stage.addChild(_loc2_);
            }
         }
         else
         {
            complete();
         }
      }
      
      public function downloadUpdate() : void
      {
         var _loc1_:URLLoader = new URLLoader();
         var _loc2_:URLRequestHeader = new URLRequestHeader("Accept-Encoding","");
         _loc1_.addEventListener(Event.COMPLETE,downloadComplete);
         _loc1_.addEventListener(ProgressEvent.PROGRESS,downloadProgress);
         _loc1_.dataFormat = "binary";
         var _loc3_:URLRequest = new URLRequest(versionData.url);
         _loc3_.requestHeaders.push(_loc2_);
         _loc1_.load(_loc3_);
      }
      
      public function downloadProgress(param1:ProgressEvent) : void
      {
         var _loc2_:int = int(param1.bytesLoaded / param1.bytesTotal * 100);
         var _loc3_:ProgressVo = new ProgressVo(_loc2_,"");
         if(_loc2_ == 100)
         {
            _loc3_.description = SanalikaClient.instance.localizationModel.translate("Download Complete");
         }
         else
         {
            _loc3_.description = SanalikaClient.instance.localizationModel.translate("Downloading Update");
         }
         Dispatcher.dispatchEvent(new OSProgressEvent("LOADING_PROGRESS",_loc3_));
      }
      
      public function downloadComplete(param1:Event) : void
      {
         var _loc7_:* = null as NativeProcessStartupInfo;
         var _loc8_:* = null as NativeProcess;
         var _loc9_:* = null;
         var _loc10_:* = null as WarningView;
         var _loc3_:* = param1.target;
         var _loc4_:ByteArray = _loc3_.data;
         var _loc5_:File = File.cacheDirectory.resolvePath("SanalikaInstaller.exe");
         var _loc6_:FileStream = new FileStream();
         _loc6_.open(_loc5_,FileMode.WRITE);
         _loc6_.writeBytes(_loc4_,0,_loc4_.length);
         _loc6_.close();
         try
         {
            _loc7_ = new NativeProcessStartupInfo();
            _loc7_.executable = _loc5_;
            _loc8_ = new NativeProcess();
            _loc8_.start(_loc7_);
            NativeApplication.nativeApplication.exit(-1);
         }
         catch(_loc_e_:*)
         {
            throw _loc9_;
         }
      }
   }
}

