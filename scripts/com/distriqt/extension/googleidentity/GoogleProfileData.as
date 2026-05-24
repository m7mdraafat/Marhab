package com.distriqt.extension.googleidentity
{
   public class GoogleProfileData
   {
      
      public var name:String = "";
      
      public var email:String = "";
      
      public var givenName:String = "";
      
      public var familyName:String = "";
      
      public var photoUrl:String = "";
      
      public function GoogleProfileData()
      {
         super();
      }
      
      internal static function fromObject(param1:Object) : GoogleProfileData
      {
         var _loc2_:GoogleProfileData = new GoogleProfileData();
         if(param1)
         {
            if(param1.name)
            {
               _loc2_.name = param1.name;
            }
            if(param1.email)
            {
               _loc2_.email = param1.email;
            }
            if(param1.givenName)
            {
               _loc2_.givenName = param1.givenName;
            }
            if(param1.familyName)
            {
               _loc2_.familyName = param1.familyName;
            }
            if(param1.photoUrl)
            {
               _loc2_.photoUrl = param1.photoUrl;
            }
         }
         return _loc2_;
      }
   }
}

