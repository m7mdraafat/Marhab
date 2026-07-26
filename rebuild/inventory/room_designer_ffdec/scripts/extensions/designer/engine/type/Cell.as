package extensions.designer.engine.type
{
   import com.oyunstudyosu.engine.IntPoint;
   import com.oyunstudyosu.engine.core.Vector3d;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class Cell extends EventDispatcher
   {
      
      public static var TYPE_EMPTY:int = 0;
      
      public static var TYPE_WALK_ONLY:int = -1;
      
      public static var TYPE_DISABLED:int = 3;
      
      public static var TYPE_DIAMOND:int = 4;
      
      public static var TYPE_ADMIN:int = 5;
      
      public static var TYPE_TARGET:int = 6;
      
      public static var TYPE_FISH:int = 7;
      
      public static var TYPE_SANALIKAX:int = 8;
      
      public static var TYPE_SHORTCUT:int = 10;
      
      public static var TYPE_NPC:int = 11;
      
      public var pos3d:Vector3d;
      
      public var pos2d:Point;
      
      public var posMatrix:IntPoint;
      
      public var parentMapEntry:MapEntry;
      
      public var bit:int;
      
      private var _cellType:int = TYPE_EMPTY;
      
      public function Cell(param1:int, param2:int)
      {
         super();
         posMatrix = new IntPoint(param1,param2);
      }
      
      public function get cellType() : int
      {
         return _cellType;
      }
      
      public function set cellType(param1:int) : void
      {
         _cellType = param1;
      }
      
      public function get x() : Number
      {
         return posMatrix.x;
      }
      
      public function get y() : Number
      {
         return posMatrix.y;
      }
      
      public function equals(param1:Cell) : Boolean
      {
         return param1.x == x && param1.y == y;
      }
      
      public function setMapEntry(param1:MapEntry) : void
      {
         this.parentMapEntry = param1;
      }
      
      public function terminate() : void
      {
         pos3d = null;
         pos2d = null;
         posMatrix = null;
      }
   }
}

