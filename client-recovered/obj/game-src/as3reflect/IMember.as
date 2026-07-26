package as3reflect
{
   public interface IMember extends IMetaDataContainer
   {
      
      function get declaringType() : as3reflect.Type;
      
      function get type() : as3reflect.Type;
      
      function get name() : String;
   }
}

