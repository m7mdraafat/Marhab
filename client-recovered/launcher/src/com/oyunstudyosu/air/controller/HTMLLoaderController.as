package com.oyunstudyosu.air.controller
{
   import flash.html.HTMLLoader;
   
   public class HTMLLoaderController
   {
      
      public function HTMLLoaderController()
      {
      }
      
      public static function create() : HTMLLoader
      {
         return new HTMLLoader();
      }
   }
}

