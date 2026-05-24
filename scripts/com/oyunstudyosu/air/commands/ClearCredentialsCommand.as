package com.oyunstudyosu.air.commands
{
   import com.junkbyte.console.Cc;
   import com.oyunstudyosu.air.controller.DataStorageController;
   import com.oyunstudyosu.air.embed.EmbedConfigData;
   import flash.Boot;
   import haxe.Exception;
   import haxe.ds.StringMap;
   
   public class ClearCredentialsCommand extends Command
   {
      
      public function ClearCredentialsCommand()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
      }
      
      override public function execute() : void
      {
         // Decompiler emitted the cleanup logic only inside a catch block, so on
         // a normal run complete() was never called and the launcher hung.
         // Rewritten to always iterate the embed config keys and always finish.
         Cc.info("ClearCredentialsCommand.execute()");
         try
         {
            var _loc1_:StringMap = EmbedConfigData.instances;
            if(_loc1_ != null && _loc1_.h != null)
            {
               for(var key:String in _loc1_.h)
               {
                  // StringMap.h uses a "$" prefix for keys that collide with
                  // reserved JS names; strip if present.
                  var realKey:String = key;
                  if(realKey.length > 0 && realKey.charAt(0) == "$")
                  {
                     realKey = realKey.substr(1);
                  }
                  DataStorageController.set(realKey + "_email","");
                  DataStorageController.set(realKey + "_password","");
               }
            }
         }
         catch(_loc_e_:*)
         {
            Cc.info("ClearCredentialsCommand.execute caught: " + _loc_e_);
         }
         complete();
      }
   }
}

