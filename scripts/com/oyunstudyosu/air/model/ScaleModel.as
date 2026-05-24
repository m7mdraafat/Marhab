package com.oyunstudyosu.air.model
{
   import flash.Boot;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import openfl.Lib;
   
   public class ScaleModel
   {
      
      public var width:int;
      
      public var stage:Stage;
      
      public var height:int;
      
      public var defaultWidth:int;
      
      public var defaultHeight:int;
      
      public function ScaleModel(param1:Stage = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         height = 550;
         width = 800;
         defaultHeight = 500;
         defaultWidth = 800;
         stage = param1;
      }
      
      public function get_isLandscape() : Boolean
      {
         return Lib.get_current().stage.stageWidth >= Lib.get_current().stage.stageHeight;
      }
      
      public function getRecommendedScaleRate() : Number
      {
         if(!SanalikaClient.instance.airModel.isMobile())
         {
            return calculateBestScaleRate(defaultWidth,defaultHeight);
         }
         if(!get_isLandscape())
         {
            return calculateBestScaleRate(defaultHeight,defaultWidth);
         }
         return calculateBestScaleRate(defaultWidth,defaultHeight);
      }
      
      public function calculateBestScaleRate(param1:int, param2:int) : Number
      {
         var _loc6_:* = null as Error;
         var _loc4_:Number = 1;
         var _loc5_:Number = 0.001;
         if(param1 <= 0 || param2 <= 0)
         {
            return _loc4_;
         }
         try
         {
            if(stage.stageWidth <= param1 || stage.stageHeight <= param2)
            {
               return _loc4_;
            }
            while(!(param1 * (_loc4_ + _loc5_) > stage.stageWidth || param2 * (_loc4_ + _loc5_) > stage.stageHeight))
            {
               _loc4_ += _loc5_;
            }
         }
         catch(_loc_e_:Error)
         {
            _loc6_ = _loc_e_;
            _loc4_ = 1;
         }
         return _loc4_;
      }
   }
}

