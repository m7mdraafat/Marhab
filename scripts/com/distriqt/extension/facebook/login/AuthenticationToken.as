package com.distriqt.extension.facebook.login
{
   public class AuthenticationToken
   {
      
      private static const TAG:String = "AuthenticationToken";
      
      public var graphDomain:String;
      
      public var token:String;
      
      public var nonce:String;
      
      public function AuthenticationToken()
      {
         super();
      }
      
      internal static function fromObject(param1:Object) : AuthenticationToken
      {
         var _loc2_:AuthenticationToken = null;
         if(param1 != null)
         {
            _loc2_ = new AuthenticationToken();
            if(param1.hasOwnProperty("token"))
            {
               _loc2_.token = param1.token;
            }
            if(param1.hasOwnProperty("graphDomain"))
            {
               _loc2_.graphDomain = param1.graphDomain;
            }
            if(param1.hasOwnProperty("nonce"))
            {
               _loc2_.nonce = param1.nonce;
            }
            return _loc2_;
         }
         return null;
      }
   }
}

