package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   [ExcludeClass]
   public class _85139574b494cbaa9de9bc19e59e12fde59e920d21cd90c49cd6395ecec4303c_flash_display_Sprite extends Sprite
   {
      
      public function _85139574b494cbaa9de9bc19e59e12fde59e920d21cd90c49cd6395ecec4303c_flash_display_Sprite()
      {
         super();
      }
      
      public function allowDomainInRSL(... rest) : void
      {
         Security.allowDomain(rest);
      }
      
      public function allowInsecureDomainInRSL(... rest) : void
      {
         Security.allowInsecureDomain(rest);
      }
   }
}

