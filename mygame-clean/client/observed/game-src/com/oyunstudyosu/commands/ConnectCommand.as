package com.oyunstudyosu.commands
{
   import com.oyunstudyosu.capture.CaptureLog;
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.events.OSProgressEvent;
   import com.oyunstudyosu.progress.ProgressVo;
   import com.smartfoxserver.v2.SmartFox;
   import com.smartfoxserver.v2.core.SFSEvent;
   
   public class ConnectCommand extends Command
   {
      
      private var sfs:SmartFox;
      
      public function ConnectCommand()
      {
         super();
         sfs = CaptureRuntime.sanalikaInstance.serviceModel.sfs;
      }
      
      override public function execute() : void
      {
         sfs.addEventListener("connection",onConnection);
         sfs.addEventListener("connectionResume",onConnectionResume);
         if(CaptureRuntime.sanalikaInstance.gameModel.serverName == "local")
         {
            CaptureRuntime.sanalikaInstance.gameModel.chatServer = "127.0.0.1";
         }
         else
         {
            CaptureRuntime.sanalikaInstance.gameModel.chatServer = CaptureRuntime.sanalikaInstance.gameModel.serverName + "-sfs.rage-world.net";
         }
         sfs.useWebSocket = true;
         sfs.useSSL = false;
         sfs.connect(CaptureRuntime.sanalikaInstance.gameModel.chatServer,sfs.useSSL ? 8443 : 8080);
         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.CONNECTING));
      }
      
      private function onConnection(param1:SFSEvent) : void
      {
         if(param1.params.success)
         {
            trace("sfs connected");
            Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.CONNECTED));
            complete();
            dispose();
         }
         else
         {
            Dispatcher.dispatchEvent(new GameEvent("RELOAD"));
            trace("Connection Failure: " + param1.params.errorMessage);
         }
      }
      
      private function onConnectionResume(param1:SFSEvent) : void
      {
         trace("onConnectionResume()");
         dispose();
      }
      
      override public function dispose() : void
      {
         if(sfs != null)
         {
            try
            {
               sfs.removeEventListener("connection",onConnection);
               sfs.removeEventListener("connectionResume",onConnectionResume);
            }
            catch(_captureConnectDisposeError:*)
            {
               CaptureLog.write("command.dispose.error",{"command":"ConnectCommand","message":String(_captureConnectDisposeError)});
            }
         }
         sfs = null;
      }
   }
}

