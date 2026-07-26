package com.oyunstudyosu.air.ui.alert
{
   import flash.display.DisplayObject;
   
   public interface IAlertView
   {
      
      function init() : void;
      
      function dragger() : DisplayObject;
      
      function dispose() : void;
   }
}

