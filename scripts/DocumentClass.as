package
{
   import flash.Boot;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   
   public class DocumentClass extends SanalikaClient
   {
      
      public function DocumentClass(param1:DisplayObjectContainer = undefined)
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         param1.addChild(this);

         dispatchEvent(new Event(Event.ADDED_TO_STAGE,false,false));
      }
   }
}

