package feathers.style
{
   public interface IVariantStyleObject extends IStyleObject
   {
      
      function set_variant(param1:String) : String;
      
      function get_variant() : String;
      
      function get_styleContext() : Class;
   }
}

