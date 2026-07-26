package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   [ExcludeClass]
   public class _d1f5b966d472e00ac86a04ae1823ad2b420b46ce1b40e68637331e103388e58e_flash_display_Sprite extends Sprite
   {
      
      public function _d1f5b966d472e00ac86a04ae1823ad2b420b46ce1b40e68637331e103388e58e_flash_display_Sprite()
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

