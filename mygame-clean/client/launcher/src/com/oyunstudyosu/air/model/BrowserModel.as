package com.oyunstudyosu.air.model
{
   import flash.Boot;
   import flash.display.Stage;
   import flash.geom.Rectangle;
   import flash.media.StageWebView;
   import haxe.IMap;
   import haxe.ds.StringMap;
   
   public class BrowserModel
   {
      
      public var stage:Stage;
      
      public var browsers:IMap;
      
      public function BrowserModel(param1:Stage = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         browsers = new StringMap();
         stage = param1;
      }
      
      public function remove(param1:String) : void
      {
         var _loc2_:StringMap = browsers;
         var _loc3_:StageWebView = param1 in StringMap.reserved ? _loc2_.getReserved(param1) : _loc2_.h[param1];
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_.dispose();
         _loc3_ = null;
         browsers.remove(param1);
      }
      
      public function get(param1:String) : StageWebView
      {
         var _loc2_:StringMap = browsers;
         var _loc3_:StageWebView = param1 in StringMap.reserved ? _loc2_.getReserved(param1) : _loc2_.h[param1];
         if(_loc3_ == null)
         {
            return null;
         }
         return _loc3_;
      }
      
      public function create(param1:String, param2:Object = undefined, param3:Boolean = false) : StageWebView
      {
         var _loc4_:StageWebView = null;
         var _loc5_:StringMap = browsers;
         if(param1 in StringMap.reserved ? _loc5_.existsReserved(param1) : param1 in _loc5_.h)
         {
            return null;
         }
         _loc4_ = new StageWebView();
         _loc4_.stage = stage;
         if(param2 != null)
         {
            if(param2.x != null || param2.y != null || param2.width != null || param2.height != null)
            {
               _loc4_.viewPort = new Rectangle(param2.x,param2.y,param2.width,param2.height);
            }
            if(param2.url != null)
            {
               _loc4_.loadURL(param2.url);
            }
         }
         var _loc6_:StringMap = browsers;
         if(param1 in StringMap.reserved)
         {
            _loc6_.setReserved(param1,_loc4_);
         }
         else
         {
            _loc6_.h[param1] = _loc4_;
         }
         return _loc4_;
      }
   }
}

