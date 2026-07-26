package extensions.designer.clips
{
   import com.oyunstudyosu.isodesigner.clips.ToolBoxUI;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import extensions.designer.engine.IsoScene;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ToolBox extends MovieClip
   {
      
      private var scene:IsoScene;
      
      public var ui:ToolBoxUI;
      
      public function ToolBox(param1:IsoScene)
      {
         super();
         ui = new ToolBoxUI();
         addChild(ui);
         this.scene = param1;
      }
      
      public function addEventListeners() : void
      {
         ui.btnEraseAll.addEventListener("click",scene.btnEraseAllClicked);
         ui.btnRotate.addEventListener("click",scene.btnRotateClicked);
         ui.btnErase.addEventListener("click",scene.btnEraseClicked);
         ui.btnInventory.addEventListener("click",btnInventoryClicked);
         ui.btnQuit.addEventListener("click",scene.btnQuitClicked);
         ui.btnSave.addEventListener("click",scene.btnSaveClicked);
         Connectr.instance.toolTipModel.addTip(ui.btnRotate,$("Rotate"));
         Connectr.instance.toolTipModel.addTip(ui.btnErase,$("Remove"));
         Connectr.instance.toolTipModel.addTip(ui.btnInventory,$("Inventory"));
         Connectr.instance.toolTipModel.addTip(ui.btnQuit,$("Exit"));
         Connectr.instance.toolTipModel.addTip(ui.btnSave,$("Save"));
         Connectr.instance.toolTipModel.addTip(ui.btnEraseAll,$("RemoveAll"));
      }
      
      private function btnInventoryClicked(param1:Event) : void
      {
         scene.switchInventoryPanel();
      }
      
      public function disableSaveButton() : void
      {
         ui.btnSave.removeEventListener("click",scene.btnSaveClicked);
         ui.btnSave.alpha = 0.5;
      }
      
      public function disableRotateButton() : void
      {
         ui.btnRotate.removeEventListener("click",scene.btnRotateClicked);
         ui.btnRotate.alpha = 0.5;
      }
      
      public function enableRotateButton() : void
      {
         ui.btnRotate.addEventListener("click",scene.btnRotateClicked);
         ui.btnRotate.alpha = 1;
      }
      
      public function disableEraseButton() : void
      {
         ui.btnErase.removeEventListener("click",scene.btnEraseClicked);
         ui.btnErase.alpha = 0.5;
      }
      
      public function enableEraseButton() : void
      {
         ui.btnErase.addEventListener("click",scene.btnEraseClicked);
         ui.btnErase.alpha = 1;
      }
      
      public function dispose() : void
      {
         Connectr.instance.toolTipModel.removeTip(ui.btnRotate);
         Connectr.instance.toolTipModel.removeTip(ui.btnErase);
         Connectr.instance.toolTipModel.removeTip(ui.btnInventory);
         Connectr.instance.toolTipModel.removeTip(ui.btnQuit);
         Connectr.instance.toolTipModel.removeTip(ui.btnSave);
         ui.btnRotate.removeEventListener("click",scene.btnRotateClicked);
         ui.btnErase.removeEventListener("click",scene.btnEraseClicked);
         ui.btnEraseAll.removeEventListener("click",scene.btnEraseAllClicked);
         ui.btnInventory.removeEventListener("click",btnInventoryClicked);
         ui.btnQuit.removeEventListener("click",scene.btnQuitClicked);
         ui.btnSave.removeEventListener("click",scene.btnSaveClicked);
         scene = null;
         ui = null;
      }
   }
}

