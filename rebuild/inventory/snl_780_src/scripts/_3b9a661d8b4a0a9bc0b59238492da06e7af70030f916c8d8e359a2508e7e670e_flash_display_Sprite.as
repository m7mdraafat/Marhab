package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   public class _3b9a661d8b4a0a9bc0b59238492da06e7af70030f916c8d8e359a2508e7e670e_flash_display_Sprite extends Sprite
   {
      
      public function _3b9a661d8b4a0a9bc0b59238492da06e7af70030f916c8d8e359a2508e7e670e_flash_display_Sprite()
      {
         super();
      }
      
      public function allowDomainInRSL(... rest) : void
      {
         Security.allowDomain.apply(null,rest);
      }
      
      public function allowInsecureDomainInRSL(... rest) : void
      {
         Security.allowInsecureDomain.apply(null,rest);
      }
   }
}

