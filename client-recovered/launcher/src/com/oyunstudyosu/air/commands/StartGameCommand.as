package com.oyunstudyosu.air.commands
{
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
         SanalikaClient.instance.loaderModel.load();
         complete();
      }
   }
}

