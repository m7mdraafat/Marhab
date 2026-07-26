package com.oyunstudyosu.air.model
{
   import flash.Boot;
   import flash.events.FileListEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.Capabilities;
   
   public class CacheModel
   {
      
      public static var CACHE_VERSION:String = "1";
      
      public var isAvailable:Boolean;
      
      public var _path:String;
      
      public function CacheModel()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _path = null;
      }
      
      public function set_path(param1:String) : String
      {
         _path = param1;
         isAvailable = checkPermission();
         return param1;
      }
      
      public function resolvePath() : File
      {
         return File.applicationStorageDirectory.resolvePath(get_path());
      }
      
      public function isCacheVersionCorrect() : Boolean
      {
         var _loc2_:* = null as File;
         var _loc3_:* = null as FileStream;
         var _loc4_:* = null as String;
         var _loc5_:* = null as Error;
         try
         {
            _loc2_ = resolvePath().resolvePath("cacheVersion.dat");
            _loc3_ = new FileStream();
            _loc3_.open(_loc2_,FileMode.READ);
            _loc4_ = _loc3_.readUTF();
            _loc3_.close();
            return _loc4_ == "1";
         }
         catch(_loc_e_:Error)
         {
            _loc5_ = _loc_e_;
            return false;
         }
      }
      
      public function get_path() : String
      {
         var _loc1_:* = null as File;
         if(_path == null)
         {
            _loc1_ = File.applicationStorageDirectory.resolvePath("cache");
            _loc1_.createDirectory();
            set_path(_loc1_.nativePath.toString() + File.separator.toString());
         }
         return _path;
      }
      
      public function get_isSupported() : Boolean
      {
         if(Capabilities.version.substr(0,3) == "IOS" || Capabilities.version.substr(0,3) == "AND")
         {
            return false;
         }
         return true;
      }
      
      public function get_isAvailable() : Boolean
      {
         if(!get_isSupported())
         {
            return false;
         }
         return isAvailable;
      }
      
      public function enable() : void
      {
         set_path(_path);
      }
      
      public function disable() : void
      {
         isAvailable = false;
      }
      
      public function directoryListingHandlerClearTempFiles(param1:FileListEvent) : void
      {
         var _loc5_:int = 0;
         var _loc2_:Array = param1.files;
         var _loc3_:int = 0;
         var _loc4_:int = int(_loc2_.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            if(int(_loc2_[_loc5_].name.indexOf(".tmp")) > -1)
            {
               _loc2_[_loc5_].deleteFileAsync();
            }
         }
      }
      
      public function directoryListingHandlerClearAllFiles(param1:FileListEvent) : void
      {
         var _loc5_:int = 0;
         var _loc2_:Array = param1.files;
         var _loc3_:int = 0;
         var _loc4_:int = int(_loc2_.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            if(_loc2_[_loc5_].name != "cacheVersion.dat")
            {
               _loc2_[_loc5_].deleteFileAsync();
            }
         }
      }
      
      public function createOrUpdateCacheVersionFile() : void
      {
         var _loc2_:* = null as File;
         var _loc3_:* = null as Error;
         var _loc4_:* = null as FileStream;
         try
         {
            _loc2_ = resolvePath().resolvePath("cacheVersion.dat");
            try
            {
               _loc2_.deleteFile();
            }
            catch(_loc_e_:Error)
            {
               _loc3_ = _loc_e_;
            }
            _loc4_ = new FileStream();
            _loc4_.open(_loc2_,FileMode.WRITE);
            _loc4_.writeUTF("1");
            _loc4_.close();
         }
         catch(_loc_e_:Error)
         {
            _loc3_ = _loc_e_;
         }
      }
      
      public function cleanTemporaryFiles() : void
      {
         var _loc2_:* = null as File;
         var _loc3_:* = null as Error;
         if(!get_isAvailable())
         {
            return;
         }
         try
         {
            _loc2_ = resolvePath();
            _loc2_.addEventListener(FileListEvent.DIRECTORY_LISTING,directoryListingHandlerClearTempFiles);
            _loc2_.getDirectoryListingAsync();
         }
         catch(_loc_e_:Error)
         {
            _loc3_ = _loc_e_;
         }
      }
      
      public function cleanFiles() : void
      {
         var _loc2_:* = null as File;
         var _loc3_:* = null as Error;
         if(!get_isAvailable())
         {
            return;
         }
         try
         {
            _loc2_ = resolvePath();
            _loc2_.addEventListener(FileListEvent.DIRECTORY_LISTING,directoryListingHandlerClearAllFiles);
            _loc2_.getDirectoryListingAsync();
         }
         catch(_loc_e_:Error)
         {
            _loc3_ = _loc_e_;
         }
      }
      
      public function checkPermissionByPath(param1:File) : Boolean
      {
         var _loc3_:* = null as FileStream;
         var _loc4_:* = null as Error;
         if(!get_isSupported())
         {
            return false;
         }
         try
         {
            _loc3_ = new FileStream();
            _loc3_.open(param1,FileMode.WRITE);
            _loc3_.writeUTF("");
            _loc3_.close();
         }
         catch(_loc_e_:Error)
         {
            _loc4_ = _loc_e_;
            return false;
         }
         return true;
      }
      
      public function checkPermission() : Boolean
      {
         var _loc2_:* = null as File;
         var _loc3_:* = null as Error;
         try
         {
            _loc2_ = resolvePath().resolvePath(Math.random() + "_verify.tmp");
            return checkPermissionByPath(_loc2_);
         }
         catch(_loc_e_:Error)
         {
            _loc3_ = _loc_e_;
            return false;
         }
      }
   }
}

