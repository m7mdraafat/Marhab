package feathers.text._TextFormat
{
   import feathers.text.TextFormat;
   import flash.text.TextFormat;
   
   public final class AbstractTextFormat_Impl_
   {
      
      public function AbstractTextFormat_Impl_()
      {
      }
      
      public static function fromSimpleTextFormat(param1:flash.text.TextFormat) : feathers.text.TextFormat
      {
         var _loc2_:feathers.text.TextFormat = new feathers.text.TextFormat(param1.font,param1.size,param1.color,param1.bold,param1.italic,param1.underline,param1.url,param1.target,param1.align,param1.leftMargin,param1.rightMargin,param1.indent,param1.leading);
         _loc2_.set_blockIndent(param1.blockIndent);
         _loc2_.set_bullet(param1.bullet);
         _loc2_.set_kerning(param1.kerning);
         _loc2_.set_letterSpacing(param1.letterSpacing);
         _loc2_.set_tabStops(param1.tabStops);
         return _loc2_;
      }
      
      public static function toSimpleTextFormat(param1:feathers.text.TextFormat) : flash.text.TextFormat
      {
         return param1.toSimpleTextFormat();
      }
   }
}

