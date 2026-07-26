package com.oyunstudyosu.air.controller
{
   import flash.display.Stage;
   import flash.media.StageWebView;
   
   public class BrowserController
   {
      
      public function BrowserController()
      {
      }
      
      public static function init(param1:Stage) : void
      {
      }
      
      public static function create(param1:String, param2:Object, param3:Boolean = false) : StageWebView
      {
         return SanalikaClient.instance.browserModel.create(param1,param2,param3);
      }
      
      public static function remove(param1:String) : void
      {
         SanalikaClient.instance.browserModel.remove(param1);
      }
      
      public static function get(param1:String) : StageWebView
      {
         return SanalikaClient.instance.browserModel.get(param1);
      }
   }
}

