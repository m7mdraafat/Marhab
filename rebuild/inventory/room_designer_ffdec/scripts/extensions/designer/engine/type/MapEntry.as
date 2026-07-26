package extensions.designer.engine.type
{
   import com.oyunstudyosu.engine.IntPoint;
   import extensions.designer.engine.IsoScene;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class MapEntry
   {
      
      public static var OBJECT_TYPE_NONE:int = 0;
      
      public static var OBJECT_TYPE_CHAIR:int = 1;
      
      public static var OBJECT_TYPE_ATARI:int = 2;
      
      public var id:int;
      
      public var furnLocation:int;
      
      public var x:int;
      
      public var y:int;
      
      public var z:int;
      
      public var entryType:int;
      
      public var width:Number;
      
      public var height:Number;
      
      public var depth:Number;
      
      public var fx:int;
      
      public var lc:int;
      
      public var st:int;
      
      public var sv:int;
      
      public var definition:String;
      
      public var dir:int;
      
      public var center:Point;
      
      public var heighInPx:Number;
      
      public var chairs:Array;
      
      public var hasReservedGrids:Boolean;
      
      public var scene:IsoScene;
      
      public var element:IsoElement;
      
      public function MapEntry(param1:IsoScene, param2:Object, param3:Boolean = false)
      {
         super();
         this.id = param2.id;
         this.furnLocation = param2.fLoc;
         this.x = param2.posX;
         this.y = param2.posY;
         this.z = param2.posZ;
         this.width = param2.width;
         this.height = param2.height;
         this.depth = param2.depth;
         this.fx = param2.fixed;
         this.lc = param2.locked;
         this.st = param2.stock;
         this.sv = param2.stockValue;
         this.definition = param2.clip;
         this.dir = param2.direction;
         trace("this.definition",this.definition);
         trace("this.dir",this.dir);
         this.entryType = param2.entryType;
         if(param3)
         {
            if(dir == 1 || dir == 5)
            {
               this.width = param2.depth;
               this.depth = param2.width;
            }
         }
         this.scene = param1;
      }
      
      public function getInstanceMovieClip() : MovieClip
      {
         var _loc2_:String = getDefinition();
         var _loc1_:MovieClip = scene.getMovieClip(_loc2_);
         _loc1_.mapEntry = this;
         return _loc1_;
      }
      
      public function init(param1:IsoScene) : void
      {
         var _loc3_:Cell = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:Cell = null;
         if(width == 1 && depth == 1)
         {
            center = param1.getPosFromGrid(x,z);
            _loc3_ = param1.getCellAt(x,y,z);
            if(_loc3_ == null)
            {
               trace("grid is nulll :" + (x + _loc5_) + "," + y + ", " + (z + _loc4_));
               return;
            }
            _loc3_.setMapEntry(this);
            if(this.entryType != 5)
            {
               _loc3_.cellType = Cell.TYPE_DISABLED;
            }
         }
         else
         {
            center = param1.get2dPoint((x + width - 1) * param1.tileWidth,0,(z + depth - 1) * param1.tileWidth);
            _loc5_ = 0;
            while(_loc5_ < width)
            {
               _loc4_ = 0;
               while(_loc4_ < depth)
               {
                  _loc2_ = param1.getCellAt(x + _loc5_,y,z + _loc4_);
                  if(_loc2_ == null)
                  {
                     trace("grid is null: " + (x + _loc5_) + "," + y + ", " + (z + _loc4_));
                  }
                  else
                  {
                     if(_loc2_)
                     {
                        _loc2_.setMapEntry(this);
                     }
                     if(this.entryType != 5)
                     {
                        _loc2_.cellType = Cell.TYPE_DISABLED;
                     }
                  }
                  _loc4_++;
               }
               _loc5_++;
            }
         }
         heighInPx = height * param1.tileWidth;
      }
      
      public function getDirOfChair(param1:IntPoint) : int
      {
         if(param1 == null)
         {
            throw new Error("Null grid");
         }
         if(hasReservedGrids)
         {
            for each(var _loc2_ in chairs)
            {
               if(_loc2_.grid.equals(param1))
               {
                  return _loc2_.dir;
               }
            }
            return 4;
         }
         return (dir + 4) % 8;
      }
      
      public function getFrontPos(param1:IsoScene) : IntPoint
      {
         var _loc4_:int = 0;
         var _loc3_:IntPoint = param1.getPointAtDir(dir,x,y,z);
         var _loc2_:Cell = param1.getCellAtPoint(_loc3_);
         if(_loc2_ != null && _loc2_.cellType == Cell.TYPE_DISABLED)
         {
            _loc4_ = dir - 2;
            while(true)
            {
               if(_loc4_ != dir)
               {
                  _loc3_ = param1.getPointAtDir(_loc4_,x,y,z);
                  if(param1.getCellAtPoint(_loc3_).cellType != Cell.TYPE_DISABLED)
                  {
                     break;
                  }
               }
               _loc4_ += 2;
            }
         }
         _loc2_ = null;
         return _loc3_;
      }
      
      public function getDefinition() : String
      {
         return definition + (dir > 0 ? "_" + dir : "");
      }
   }
}

