package extensions
{
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import extensions.designer.engine.IsoScene;
   import org.oyunstudyosu.components.CoreMovieClip;
   
   public class RoomDesigner extends CoreMovieClip
   {
      
      public var scene:IsoScene;
      
      public function RoomDesigner()
      {
         super();
         Dispatcher.addEventListener("TERMINATE_GAME",onTerminateGame);
      }
      
      override public function added() : void
      {
      }
      
      private function onTerminateGame(param1:GameEvent) : void
      {
         dispose();
      }
      
      public function design() : void
      {
         Connectr.instance.panelModel.clearPanelsByType("hud");
         scene = new IsoScene(this);
         scene.load();
         trace("designn init");
      }
      
      public function leave() : void
      {
         Connectr.instance.roomModel.getController().startload();
         dispose();
      }
      
      public function dispose() : void
      {
         Dispatcher.removeEventListener("TERMINATE_SCENE",onTerminateGame);
         if(scene)
         {
            scene.terminate();
            scene = null;
         }
         if(Connectr.instance.layerModel)
         {
            Connectr.instance.layerModel.gameLayer.removeChild(this);
         }
      }
   }
}

