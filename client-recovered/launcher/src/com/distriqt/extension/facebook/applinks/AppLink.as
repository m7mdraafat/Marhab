package com.distriqt.extension.facebook.applinks
{
   public class AppLink
   {
      
      public var data:Object;
      
      public function AppLink()
      {
         super();
      }
      
      public function get dataJSON() : String
      {
         try
         {
            return JSON.stringify(data);
         }
         catch(e:Error)
         {
         }
         return "";
      }
   }
}

