package com.distriqt.extension.googleidentity
{
   public class GoogleAuthentication
   {
      
      public var idToken:String = "";
      
      public var refreshToken:String = "";
      
      public var accessToken:String = "";
      
      public function GoogleAuthentication()
      {
         super();
      }
      
      internal static function fromObject(param1:Object) : GoogleAuthentication
      {
         var _loc2_:GoogleAuthentication = new GoogleAuthentication();
         if(param1)
         {
            if(param1.idToken)
            {
               _loc2_.idToken = param1.idToken;
            }
            if(param1.refreshToken)
            {
               _loc2_.refreshToken = param1.refreshToken;
            }
            if(param1.accessToken)
            {
               _loc2_.accessToken = param1.accessToken;
            }
         }
         return _loc2_;
      }
   }
}

