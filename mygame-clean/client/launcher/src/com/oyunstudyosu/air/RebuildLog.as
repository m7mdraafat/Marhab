package com.oyunstudyosu.air
{
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;

   public class RebuildLog
   {
      public function RebuildLog()
      {
      }

      public static function write(param1:String) : void
      {
         trace("[REBUILD] " + param1);
         var _loc2_:File = File.applicationDirectory.resolvePath("runtime/rebuild.log");
         var _loc3_:FileStream = new FileStream();
         try
         {
            _loc3_.open(_loc2_,FileMode.APPEND);
            _loc3_.writeUTFBytes(new Date().toString() + " " + param1 + "\n");
            _loc3_.close();
         }
         catch(_loc_e_:*)
         {
            try
            {
               _loc2_ = File.applicationStorageDirectory.resolvePath("rebuild.log");
               _loc3_.open(_loc2_,FileMode.APPEND);
               _loc3_.writeUTFBytes(new Date().toString() + " " + param1 + "\n");
               _loc3_.close();
            }
            catch(_loc_e2_:*)
            {
               try
               {
                  _loc2_ = File.userDirectory.resolvePath("MarhabRebuild.log");
                  _loc3_.open(_loc2_,FileMode.APPEND);
                  _loc3_.writeUTFBytes(new Date().toString() + " " + param1 + "\n");
                  _loc3_.close();
               }
               catch(_loc_e3_:*)
               {
               }
            }
         }
      }
   }
}