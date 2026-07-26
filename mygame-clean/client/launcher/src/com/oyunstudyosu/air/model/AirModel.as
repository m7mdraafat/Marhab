package com.oyunstudyosu.air.model
{
   import flash.display.Stage;
   import flash.system.Capabilities;
   
   public class AirModel
   {
      
      public var stage:Stage;
      
      public function AirModel(param1:Stage = undefined)
      {
      }
      
      public function isMobile() : Boolean
      {
         if(!isAndroid())
         {
            return isIos();
         }
         return true;
      }
      
      public function isIos() : Boolean
      {
         return Capabilities.version.substr(0,3) == "IOS";
      }
      
      public function isDesktop() : Boolean
      {
         if(isAir())
         {
            return !isMobile();
         }
         return false;
      }
      
      public function isAndroid() : Boolean
      {
         return Capabilities.version.substr(0,3) == "AND";
      }
      
      public function isAir() : Boolean
      {
         return Capabilities.playerType == "Desktop";
      }
      
      public function a() : void
      {
      }
   }
}

