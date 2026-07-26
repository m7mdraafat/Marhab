package com.oyunstudyosu.air.commands
{
   import flash.Boot;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class Command extends EventDispatcher
   {
      
      public function Command()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
      }
      
      public function execute() : void
      {
         throw new Error("This is an abstract method. You need to override this.");
      }
      
      public function dispose() : void
      {
      }
      
      public function complete(param1:Event = undefined) : void
      {
         dispose();
         if(hasEventListener(Event.COMPLETE))
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
   }
}

