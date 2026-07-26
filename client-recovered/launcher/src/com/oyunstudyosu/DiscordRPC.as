package com.oyunstudyosu
{
   import com.tuarua.fre.ANEError;
   import flash.events.EventDispatcher;
   import flash.system.Capabilities;
   
   public class DiscordRPC extends EventDispatcher
   {
      
      private static var _discordRPC:DiscordRPC;
      
      public var available:Boolean = false;
      
      public function DiscordRPC()
      {
         var _loc1_:* = undefined;
         super();
         this.setAvailability();
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc1_ = DiscordRPCContext.context.call("init");
            if(_loc1_ is ANEError)
            {
               throw _loc1_ as ANEError;
            }
         }
         _discordRPC = this;
      }
      
      public static function get discordRPC() : DiscordRPC
      {
         if(!_discordRPC)
         {
            new DiscordRPC();
         }
         return _discordRPC;
      }
      
      public static function dispose() : void
      {
         if(Boolean(DiscordRPCContext.context))
         {
            DiscordRPCContext.dispose();
         }
      }
      
      private function setAvailability() : *
      {
         if(Capabilities.playerType == "Desktop")
         {
            this.available = Capabilities.os.indexOf("Windows") >= 0;
         }
      }
      
      public function setParty(param1:String, param2:String, param3:String) : String
      {
         var _loc4_:* = undefined;
         if(int(param2) > int(param3))
         {
            param3 = param2;
         }
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc4_ = DiscordRPCContext.context.call("setParty",param1,param2,param3);
            if(_loc4_ is ANEError)
            {
               throw _loc4_ as ANEError;
            }
         }
         return _loc4_ as String;
      }
      
      public function clearParty() : String
      {
         var _loc1_:* = undefined;
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc1_ = DiscordRPCContext.context.call("clearParty");
            if(_loc1_ is ANEError)
            {
               throw _loc1_ as ANEError;
            }
         }
         return _loc1_ as String;
      }
      
      public function setSecrets(param1:String, param2:String = "") : String
      {
         var _loc3_:* = undefined;
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc3_ = DiscordRPCContext.context.call("setSecrets",param1,param2);
            if(_loc3_ is ANEError)
            {
               throw _loc3_ as ANEError;
            }
         }
         return _loc3_ as String;
      }
      
      public function clearSecrets() : String
      {
         var _loc1_:* = undefined;
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc1_ = DiscordRPCContext.context.call("clearSecrets");
            if(_loc1_ is ANEError)
            {
               throw _loc1_ as ANEError;
            }
         }
         return _loc1_ as String;
      }
      
      public function setDetails(param1:String = "") : String
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            param1 = "";
         }
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc2_ = DiscordRPCContext.context.call("setDetails",param1);
            if(_loc2_ is ANEError)
            {
               throw _loc2_ as ANEError;
            }
         }
         return _loc2_ as String;
      }
      
      public function setState(param1:String = "") : String
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            param1 = "";
         }
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc2_ = DiscordRPCContext.context.call("setState",param1);
            if(_loc2_ is ANEError)
            {
               throw _loc2_ as ANEError;
            }
         }
         return _loc2_ as String;
      }
      
      public function setLargeImage(param1:String, param2:String = "") : String
      {
         var _loc3_:* = undefined;
         if(param2 == null)
         {
            param2 = "";
         }
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc3_ = DiscordRPCContext.context.call("setLargeImage",param1,param2);
            if(_loc3_ is ANEError)
            {
               throw _loc3_ as ANEError;
            }
         }
         return _loc3_ as String;
      }
      
      public function clearLargeImage() : String
      {
         var _loc1_:* = undefined;
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc1_ = DiscordRPCContext.context.call("clearLargeImage");
            if(_loc1_ is ANEError)
            {
               throw _loc1_ as ANEError;
            }
         }
         return _loc1_ as String;
      }
      
      public function setSmallImage(param1:String, param2:String = "") : String
      {
         var _loc3_:* = undefined;
         if(param2 == null)
         {
            param2 = "";
         }
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc3_ = DiscordRPCContext.context.call("setSmallImage",param1,param2);
            if(_loc3_ is ANEError)
            {
               throw _loc3_ as ANEError;
            }
         }
         return _loc3_ as String;
      }
      
      public function clearSmallImage() : String
      {
         var _loc1_:* = undefined;
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc1_ = DiscordRPCContext.context.call("clearSmallImage");
            if(_loc1_ is ANEError)
            {
               throw _loc1_ as ANEError;
            }
         }
         return _loc1_ as String;
      }
      
      public function acceptJoinRequest(param1:String) : *
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            return;
         }
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc2_ = DiscordRPCContext.context.call("acceptJoinRequest",param1);
            if(_loc2_ is ANEError)
            {
               throw _loc2_ as ANEError;
            }
         }
         return _loc2_ as String;
      }
      
      public function rejectJoinRequest(param1:String) : *
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            return;
         }
         if(Boolean(DiscordRPCContext.context) && this.available)
         {
            _loc2_ = DiscordRPCContext.context.call("rejectJoinRequest",param1);
            if(_loc2_ is ANEError)
            {
               throw _loc2_ as ANEError;
            }
         }
         return _loc2_ as String;
      }
   }
}

