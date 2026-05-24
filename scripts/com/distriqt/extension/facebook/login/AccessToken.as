package com.distriqt.extension.facebook.login
{
   public class AccessToken
   {
      
      public var token:String = null;
      
      public var expirationTimestamp:Number = 0;
      
      public var userId:String = null;
      
      public var applicationId:String = null;
      
      public var permissions:Array;
      
      public var declinedPermissions:Array;
      
      public var graphDomain:String = "";
      
      public function AccessToken()
      {
         super();
         permissions = [];
         declinedPermissions = [];
      }
      
      internal static function fromObject(param1:Object) : AccessToken
      {
         var _loc2_:AccessToken = null;
         if(param1 != null)
         {
            _loc2_ = new AccessToken();
            if(param1.hasOwnProperty("token"))
            {
               _loc2_.token = param1.token;
            }
            if(param1.hasOwnProperty("expirationTimestamp"))
            {
               _loc2_.expirationTimestamp = param1.expirationTimestamp;
            }
            if(param1.hasOwnProperty("userId"))
            {
               _loc2_.userId = param1.userId;
            }
            if(param1.hasOwnProperty("applicationId"))
            {
               _loc2_.applicationId = param1.applicationId;
            }
            if(param1.hasOwnProperty("graphDomain"))
            {
               _loc2_.graphDomain = param1.graphDomain;
            }
            if(param1.hasOwnProperty("permissions"))
            {
               _loc2_.permissions = param1.permissions;
            }
            if(param1.hasOwnProperty("declinedPermissions"))
            {
               _loc2_.declinedPermissions = param1.declinedPermissions;
            }
            return _loc2_;
         }
         return null;
      }
      
      public function hasGranted(param1:String) : Boolean
      {
         for each(var _loc2_ in permissions)
         {
            if(_loc2_.toLowerCase() == param1.toLowerCase())
            {
               return true;
            }
         }
         return false;
      }
   }
}

