package com.oyunstudyosu.commands.shortcut
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.commands.Command;
   import com.oyunstudyosu.engine.ICharacter;
   import com.oyunstudyosu.engine.scene.components.SceneCharacterComponent;
   
   public class HandItemCommand extends Command
   {
      
      public function HandItemCommand()
      {
         super();
      }
      
      override public function execute() : void
      {
         if(CaptureRuntime.sanalikaInstance.engine == null || !CaptureRuntime.sanalikaInstance.engine.scene == null || !CaptureRuntime.sanalikaInstance.engine.scene.existsComponent(SceneCharacterComponent))
         {
            return;
         }
         var _loc1_:SceneCharacterComponent = CaptureRuntime.sanalikaInstance.engine.scene.getComponent(SceneCharacterComponent) as SceneCharacterComponent;
         var _loc2_:ICharacter = _loc1_.myChar;
         if(_loc2_ != null)
         {
            if(_loc2_.getHandItem() != null)
            {
               _loc2_.useHandItem("0");
            }
            else
            {
               trace("HandItemCommand execute");
               _loc2_.useHandItem(CaptureRuntime.sanalikaInstance.avatarModel.lastHoldedItem);
            }
         }
      }
   }
}

