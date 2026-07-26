package motion.actuators
{
   import flash.Boot;
   import motion.IComponentPath;
   
   public class PropertyPathDetails extends PropertyDetails
   {
      
      public var path:IComponentPath;
      
      public function PropertyPathDetails(param1:Object = undefined, param2:String = undefined, param3:IComponentPath = undefined, param4:Boolean = true)
      {
         super(param1,param2,0,0,param4);
         
         if(Boot.skip_constructor)
         {
            return;
         }
         path = param3;
      }
   }
}

