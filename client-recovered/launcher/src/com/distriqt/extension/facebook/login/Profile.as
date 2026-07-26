package com.distriqt.extension.facebook.login
{
   public class Profile
   {
      
      public var id:String;
      
      public var firstName:String = null;
      
      public var middleName:String = null;
      
      public var lastName:String = null;
      
      public var name:String = null;
      
      public var linkUrl:String = null;
      
      public var pictureUrl:String;
      
      public function Profile()
      {
         super();
      }
      
      internal static function fromObject(param1:Object) : Profile
      {
         var _loc2_:Profile = null;
         if(param1 != null)
         {
            _loc2_ = new Profile();
            if(param1.hasOwnProperty("firstName"))
            {
               _loc2_.firstName = param1.firstName;
            }
            if(param1.hasOwnProperty("middleName"))
            {
               _loc2_.middleName = param1.middleName;
            }
            if(param1.hasOwnProperty("lastName"))
            {
               _loc2_.lastName = param1.lastName;
            }
            if(param1.hasOwnProperty("id"))
            {
               _loc2_.id = param1.id;
            }
            if(param1.hasOwnProperty("name"))
            {
               _loc2_.name = param1.name;
            }
            if(param1.hasOwnProperty("linkUrl"))
            {
               _loc2_.linkUrl = param1.linkUrl;
            }
            if(param1.hasOwnProperty("pictureUrl"))
            {
               _loc2_.pictureUrl = param1.pictureUrl;
            }
            return _loc2_;
         }
         return null;
      }
   }
}

