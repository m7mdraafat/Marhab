package com.oyunstudyosu.capture
{
   import flash.utils.getDefinitionByName;

   public class CaptureRuntime
   {
      public function CaptureRuntime()
      {
      }

      public static function get sanalikaInstance() : *
      {
         return getDefinitionByName("Sanalika")["instance"];
      }
   }
}