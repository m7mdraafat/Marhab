package com.oyunstudyosu.air.commands
{
   import com.oyunstudyosu.air.RLog;
   import flash.Boot;
   
   public class StartGameCommand extends Command
   {
      
      public function StartGameCommand()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
      }
      
      override public function execute() : void
      {
         RLog.write("launcher.startGame.execute",{});
         SanalikaClient.instance.loaderModel.load();
         complete();
      }
   }
}

