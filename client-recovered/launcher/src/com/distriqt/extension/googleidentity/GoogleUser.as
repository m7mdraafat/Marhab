package com.distriqt.extension.googleidentity
{
   public class GoogleUser
   {
      
      public var userID:String = "";
      
      public var serverAuthCode:String = "";
      
      public var authentication:GoogleAuthentication;
      
      public var profile:GoogleProfileData;
      
      public function GoogleUser()
      {
         super();
         authentication = new GoogleAuthentication();
         profile = new GoogleProfileData();
      }
      
      internal static function fromObject(param1:Object) : GoogleUser
      {
         var _loc2_:GoogleUser = new GoogleUser();
         _loc2_.userID = param1.userID;
         _loc2_.serverAuthCode = param1.serverAuthCode;
         _loc2_.authentication = GoogleAuthentication.fromObject(param1.authentication);
         _loc2_.profile = GoogleProfileData.fromObject(param1.profile);
         return _loc2_;
      }
      
      public function toString() : String
      {
         return "GoogleUser[ " + userID + " profile:{ " + profile.email + ", " + profile.name + ", " + profile.givenName + ", " + profile.familyName + ", " + profile.photoUrl + " } ]";
      }
   }
}

