package com.oyunstudyosu.commands.shortcut
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.commands.Command;
   import com.oyunstudyosu.engine.scene.components.SceneCharacterComponent;
   
   public class HideCommand extends Command
   {
      
      public function HideCommand()
      {
         super();
      }
      
      override public function execute() : void
      {
         CaptureRuntime.sanalikaInstance.avatarModel.isHideMode = !CaptureRuntime.sanalikaInstance.avatarModel.isHideMode;
         process();
      }
      
      private function process() : void
      {
         if(CaptureRuntime.sanalikaInstance.engine == null || !CaptureRuntime.sanalikaInstance.engine.scene == null)
         {
            return;
         }
         var _loc1_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         if(_loc1_ != null)
         {
            _loc1_.singleMode(CaptureRuntime.sanalikaInstance.avatarModel.isHideMode);
         }
         CaptureRuntime.sanalikaInstance.engine.scene.ceilingContainer.visible = !CaptureRuntime.sanalikaInstance.avatarModel.isHideMode;
      }
   }
}

