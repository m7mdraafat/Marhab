package extensions.designer.engine.type
{
   import com.oyunstudyosu.engine.IntPoint;
   import com.oyunstudyosu.engine.core.Vector3d;
   import extensions.designer.engine.IsoScene;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class IsoElement extends EventDispatcher
   {
      
      public static const DEPTHCHANGE:String = "renderableElementDepthChange";
      
      public static const SHOW:String = "renderableElementShow";
      
      public static const HIDE:String = "renderableElementHide";
      
      public var id:String;
      
      public var pos:Vector3d;
      
      public var pos2d:Point;
      
      public var posMatrix:IntPoint;
      
      public var cell:Cell;
      
      public var scene:IsoScene;
      
      public var container:MovieClip;
      
      public var ekDepth:int;
      
      public var movedFromBackAreas:Boolean;
      
      public var numberedCharArrayIndex:int;
      
      public var animated:Boolean;
      
      public function IsoElement(param1:Vector3d, param2:MovieClip, param3:IsoScene)
      {
         super();
         this.scene = param3;
         this.container = param2;
         if(param1 != null)
         {
            this.pos = param1.clone();
         }
      }
      
      public function moveToCell(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:Vector3d = scene.get3DPosFromGrid(param1,param3);
         moveTo(_loc4_.x,_loc4_.y,_loc4_.z);
         _loc4_ = null;
      }
      
      public function moveTo(param1:Number, param2:Number, param3:Number) : void
      {
         pos = new Vector3d(param1,param2,param3);
         var _loc4_:Cell = this.scene.translateToCell(pos);
         if(_loc4_ == null)
         {
            container.x = 100;
            container.y = 100;
            return;
         }
         this.cell = _loc4_;
         this.pos2d = scene.getPosFromGrid(cell.posMatrix.x,cell.posMatrix.y);
         this.posMatrix = cell.posMatrix.clone();
         container.x = pos2d.x;
         container.y = pos2d.y;
      }
      
      public function dispose() : void
      {
         pos = null;
         pos2d = null;
         posMatrix = null;
         cell = null;
         scene = null;
         while(container.numChildren > 0)
         {
            container.removeChildAt(0);
         }
         container = null;
      }
   }
}

