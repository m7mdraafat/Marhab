package com.oyunstudyosu.air.controller
{
   import flash.data.EncryptedLocalStore;
   import flash.net.SharedObject;
   import flash.utils.ByteArray;
   
   public class DataStorageController
   {
      
      public static var name:String = "sanalika";
      
      public function DataStorageController()
      {
      }
      
      public static function getLocalObject() : SharedObject
      {
         return SharedObject.getLocal("sanalika");
      }
      
      public static function getEncryptedData(param1:String) : String
      {
         var _loc2_:ByteArray = EncryptedLocalStore.getItem(param1);
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_.readUTFBytes(_loc2_.length);
      }
      
      public static function get(param1:String, param2:String = undefined) : String
      {
         var _loc4_:* = null as SharedObject;
         var _loc3_:String = null;
         if(EncryptedLocalStore.isSupported)
         {
            _loc3_ = DataStorageController.getEncryptedData(param1);
         }
         else
         {
            _loc4_ = DataStorageController.getLocalObject();
            _loc3_ = Reflect.field(_loc4_.data,param1);
         }
         if(_loc3_ == null && param2 != null)
         {
            return param2;
         }
         return _loc3_;
      }
      
      public static function set(param1:String, param2:*) : void
      {
         var _loc3_:* = null as ByteArray;
         var _loc4_:* = null as SharedObject;
         if(EncryptedLocalStore.isSupported)
         {
            _loc3_ = new ByteArray();
            if(param2 == null)
            {
               _loc3_.clear();
            }
            else
            {
               _loc3_.writeUTFBytes(param2);
            }
            EncryptedLocalStore.setItem(param1,_loc3_);
         }
         else
         {
            _loc4_ = DataStorageController.getLocalObject();
            _loc4_.data[param1] = param2;
            _loc4_.flush();
         }
      }
   }
}

