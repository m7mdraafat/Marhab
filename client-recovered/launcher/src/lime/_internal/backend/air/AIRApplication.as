package lime._internal.backend.air
{
   import flash.Boot;
   import flash.desktop.NativeApplication;
   import flash.desktop.SystemIdleMode;
   import flash.events.Event;
   import lime._internal.backend.flash.FlashApplication;
   import lime.app.Application;
   import lime.system.System;
   
   public class AIRApplication extends FlashApplication
   {
      
      public function AIRApplication(param1:Application = undefined)
      {
         super(param1);
         if(Boot.skip_constructor)
         {
            return;
         }
         NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
         NativeApplication.nativeApplication.addEventListener(Event.EXITING,handleExitEvent);
      }
      
      public function handleExitEvent(param1:Event) : void
      {
         System.exit(0);
         if(Application.current.onExit.canceled)
         {
            param1.preventDefault();
            param1.stopImmediatePropagation();
         }
      }
      
      override public function exit() : void
      {
      }
   }
}

