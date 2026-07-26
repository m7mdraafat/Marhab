package com.oyunstudyosu.model
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.commands.shortcut.FindMeCommand;
   import com.oyunstudyosu.commands.shortcut.HandItemCommand;
   import com.oyunstudyosu.commands.shortcut.HideCommand;
   
   public class ShortCutModel
   {
      
      private var hideCommand:HideCommand;
      
      private var findMeCommand:FindMeCommand;
      
      private var handItemCommand:HandItemCommand;
      
      public function ShortCutModel()
      {
         super();
         CaptureRuntime.sanalikaInstance.keyboardModel.addKeyMapping("CTRL+SHIFT+H",charHideProcess);
         CaptureRuntime.sanalikaInstance.keyboardModel.addKeyMapping("CTRL+SHIFT+F",findMeProcess);
         CaptureRuntime.sanalikaInstance.keyboardModel.addKeyMapping("CTRL+SHIFT+I",handItemProcess);
         CaptureRuntime.sanalikaInstance.keyboardModel.addKeyMapping("CTRL+SHIFT+M",moveFastProcess);
      }
      
      private function moveFastProcess() : void
      {
         trace("move fast");
      }
      
      private function findMeProcess() : void
      {
         findMeCommand = new FindMeCommand();
         findMeCommand.execute();
      }
      
      private function handItemProcess() : void
      {
         handItemCommand = new HandItemCommand();
         handItemCommand.execute();
      }
      
      private function charHideProcess() : void
      {
         hideCommand = new HideCommand();
         hideCommand.execute();
      }
   }
}

