package
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import haxe.ds.StringMap;
   import lime.system.System;
   import lime.utils.AssetLibrary;
   import com.oyunstudyosu.air.RebuildLog;
   import openfl.display.Application;
   import openfl.display.DefaultPreloader;
   import openfl.display.Preloader;
   import openfl.display.Window;
   // Classes referenced only via Type.resolveClass / getDefinitionByName
   // (swf.SWFLibrary, every __ASSET__*) are force-linked by rebuild/compile.ps1
   // via -includes+= so they survive AVM2 dead-code elimination.

   public class ApplicationMain
   {
      
      public function ApplicationMain()
      {
      }
      
      public static function main() : void
      {
         RebuildLog.write("ApplicationMain.main");
         System.__registerEntryPoint("MyGame",ApplicationMain.create);
         ApplicationMain.create(null);
      }
      
      public static function create(param1:*) : void
      {
         var stage:Stage;
         var preloader:Preloader;
         var _loc7_:* = null as AssetLibrary;
         var _loc8_:* = null as String;
         RebuildLog.write("ApplicationMain.create");
         var _loc2_:Application = new Application();
         ManifestResources.init(param1);
         var _loc3_:StringMap = _loc2_.meta;
         if("build" in StringMap.reserved)
         {
            _loc3_.setReserved("build","5");
         }
         else
         {
            _loc3_.h["build"] = "5";
         }
         _loc3_ = _loc2_.meta;
         if("company" in StringMap.reserved)
         {
            _loc3_.setReserved("company","MyGame");
         }
         else
         {
            _loc3_.h["company"] = "MyGame";
         }
         _loc3_ = _loc2_.meta;
         if("file" in StringMap.reserved)
         {
            _loc3_.setReserved("file","MyGame");
         }
         else
         {
            _loc3_.h["file"] = "MyGame";
         }
         _loc3_ = _loc2_.meta;
         if("name" in StringMap.reserved)
         {
            _loc3_.setReserved("name","MyGame");
         }
         else
         {
            _loc3_.h["name"] = "MyGame";
         }
         _loc3_ = _loc2_.meta;
         if("packageName" in StringMap.reserved)
         {
            _loc3_.setReserved("packageName","com.mygame.standalone");
         }
         else
         {
            _loc3_.h["packageName"] = "com.mygame.standalone";
         }
         _loc3_ = _loc2_.meta;
         if("version" in StringMap.reserved)
         {
            _loc3_.setReserved("version","1.0");
         }
         else
         {
            _loc3_.h["version"] = "1.0";
         }
         preloader = new Preloader(new DefaultPreloader());
         _loc2_.__preloader.onProgress.add(function(param1:int, param2:int):void
         {
            preloader.update(param1,param2);
         });
         _loc2_.__preloader.onComplete.add(function():void
         {
            preloader.start();
         });
         stage = _loc2_.__window.stage;
         var _loc4_:Function = function():void
         {
            RebuildLog.write("preloader complete");
            ApplicationMain.start(stage);
         };
         preloader.onComplete.add(_loc4_);
         var _loc5_:int = 0;
         var _loc6_:Array = ManifestResources.preloadLibraries;
         while(_loc5_ < int(_loc6_.length))
         {
            _loc7_ = _loc6_[_loc5_];
            _loc5_++;
            _loc2_.__preloader.addLibrary(_loc7_);
         }
         _loc5_ = 0;
         _loc6_ = ManifestResources.preloadLibraryNames;
         while(_loc5_ < int(_loc6_.length))
         {
            _loc8_ = _loc6_[_loc5_];
            _loc5_++;
            _loc2_.__preloader.addLibraryName(_loc8_);
         }
         trace("[PRELOAD] ApplicationMain about to call __preloader.load() libs=" + ManifestResources.preloadLibraries.length + " names=" + ManifestResources.preloadLibraryNames.length);
         _loc2_.__preloader.load();
         trace("[PRELOAD] ApplicationMain about to call exec()");
         _loc5_ = _loc2_.exec();
         trace("[PRELOAD] ApplicationMain exec() returned " + _loc5_);
      }
      
      public static function start(param1:Stage) : void
      {
         RebuildLog.write("ApplicationMain.start");
         var _loc2_:DisplayObject = param1.getChildAt(0);
         if(_loc2_ == null || !(_loc2_ is DisplayObjectContainer))
         {
            _loc2_ = new MovieClip();
            param1.addChild(_loc2_);
         }
         new DocumentClass(_loc2_);
      }
   }
}

import lime.app.Application;

Application;

