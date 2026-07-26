package com.oyunstudyosu
{
   import com.oyunstudyosu.events.DiscordEvent;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   public class DiscordRPCContext
   {
      
      private static var _context:ExtensionContext;
      
      internal static const NAME:String = "DiscordRPC";
      
      internal static const TRACE:String = "TRACE";
      
      internal static const INIT_ERROR_MESSAGE:String = NAME + " not initialised... use .helloWorld";
      
      private static var _isInited:Boolean = false;
      
      public function DiscordRPCContext()
      {
         super();
      }
      
      public static function get context() : ExtensionContext
      {
         if(_context == null)
         {
            try
            {
               _context = ExtensionContext.createExtensionContext("com.oyunstudyosu." + NAME,null);
               _context.addEventListener(StatusEvent.STATUS,gotEvent);
               _isInited = true;
            }
            catch(e:Error)
            {
               trace("[" + NAME + "] ANE Not loaded properly. Future calls will fail.");
            }
         }
         return _context;
      }
      
      public static function validate() : void
      {
         if(!_isInited)
         {
            throw new Error(INIT_ERROR_MESSAGE);
         }
      }
      
      public static function dispose() : void
      {
         if(!_context)
         {
            return;
         }
         trace("[" + NAME + "] Unloading ANE...");
         _context.removeEventListener(StatusEvent.STATUS,gotEvent);
         _context.dispose();
         _context = null;
         _isInited = false;
      }
      
      private static function gotEvent(param1:StatusEvent) : void
      {
         switch(param1.level)
         {
            case "TRACE":
               trace("[" + NAME + "]",param1.code);
               break;
            default:
               DiscordRPC.discordRPC.dispatchEvent(new DiscordEvent(param1.level,param1.code));
         }
      }
   }
}

