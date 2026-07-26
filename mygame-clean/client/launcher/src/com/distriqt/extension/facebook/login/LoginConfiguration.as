package com.distriqt.extension.facebook.login
{
   public class LoginConfiguration
   {
      
      private static const TAG:String = "LoginConfiguration";
      
      public var permissions:Array;
      
      public var tracking:String = "enabled";
      
      public var nonce:String = null;
      
      public function LoginConfiguration(param1:Array = null)
      {
         super();
         this.permissions = param1 == null ? [] : param1;
         nonce = generateRandomNonce();
      }
      
      public static function generateRandomNonce(param1:Number = 15) : String
      {
         var _loc3_:Number = NaN;
         var _loc5_:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
         var _loc4_:Number = _loc5_.length - 1;
         var _loc2_:String = "";
         _loc3_ = 0;
         while(_loc3_ < param1)
         {
            _loc2_ += _loc5_.charAt(Math.floor(Math.random() * _loc4_));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function setLoginTracking(param1:String) : LoginConfiguration
      {
         this.tracking = param1;
         return this;
      }
      
      public function setNonce(param1:String) : LoginConfiguration
      {
         this.nonce = param1;
         return this;
      }
   }
}

