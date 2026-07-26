package feathers.core
{
   public interface ITextControl extends IUIControl
   {
      
      function set_text(param1:String) : String;
      
      function get_text() : String;
      
      function get_baseline() : Number;
   }
}

