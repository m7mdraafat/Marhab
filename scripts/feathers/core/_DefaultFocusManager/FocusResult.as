package feathers.core._DefaultFocusManager
{
   import feathers.core.IFocusObject;
   import flash.Boot;
   
   public class FocusResult
   {
      
      public var wrapped:Boolean;
      
      public var newFocus:IFocusObject;
      
      public function FocusResult(param1:IFocusObject = undefined, param2:Boolean = false)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         newFocus = param1;
         wrapped = param2;
      }
   }
}

