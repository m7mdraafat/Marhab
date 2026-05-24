package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   [ExcludeClass]
   public class _13e4ee38d57be653f87582737cf46e49c8583521ef5fbc81fb64766472c1d4c6_flash_display_Sprite extends Sprite
   {
      
      public function _13e4ee38d57be653f87582737cf46e49c8583521ef5fbc81fb64766472c1d4c6_flash_display_Sprite()
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

