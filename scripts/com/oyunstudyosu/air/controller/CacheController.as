package com.oyunstudyosu.air.controller
{
   import flash.filesystem.File;
   
   public class CacheController
   {
      
      public function CacheController()
      {
      }
      
      public static function get isSupported() : Boolean
      {
         return SanalikaClient.instance.cacheModel.get_isSupported();
      }
      
      public static function get isAvailable() : Boolean
      {
         return SanalikaClient.instance.cacheModel.get_isAvailable();
      }
      
      public static function get path() : String
      {
         return SanalikaClient.instance.cacheModel.get_path();
      }
      
      public static function set path(param1:String) : void
      {
         SanalikaClient.instance.cacheModel.set_path(param1);
      }
      
      public static function disable() : void
      {
         SanalikaClient.instance.cacheModel.disable();
      }
      
      public static function enable() : void
      {
         SanalikaClient.instance.cacheModel.enable();
      }
      
      public static function checkPermissionByPath(param1:File) : Boolean
      {
         return SanalikaClient.instance.cacheModel.checkPermissionByPath(param1);
      }
      
      public static function checkPermission() : Boolean
      {
         return SanalikaClient.instance.cacheModel.checkPermission();
      }
      
      public static function resolvePath() : File
      {
         return SanalikaClient.instance.cacheModel.resolvePath();
      }
      
      public static function cleanTemporaryFiles() : void
      {
         SanalikaClient.instance.cacheModel.cleanTemporaryFiles();
      }
      
      public static function cleanFiles() : void
      {
         SanalikaClient.instance.cacheModel.cleanFiles();
      }
      
      public static function isCacheVersionCorrect() : Boolean
      {
         return SanalikaClient.instance.cacheModel.isCacheVersionCorrect();
      }
      
      public static function createOrUpdateCacheVersionFile() : void
      {
         SanalikaClient.instance.cacheModel.createOrUpdateCacheVersionFile();
      }
   }
}

