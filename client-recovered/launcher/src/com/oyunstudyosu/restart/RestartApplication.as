package com.oyunstudyosu.restart
{
   import flash.external.ExtensionContext;
   
   public class RestartApplication
   {
      
      private static var extContext:ExtensionContext = null;
      
      private static var extensionID:String = "com.oyunstudyosu.restart";
      
      public function RestartApplication()
      {
         super();
      }
      
      public static function restart() : void
      {
         if(!extContext)
         {
            extContext = ExtensionContext.createExtensionContext(extensionID,"");
         }
         extContext.call("restart");
      }
   }
}

