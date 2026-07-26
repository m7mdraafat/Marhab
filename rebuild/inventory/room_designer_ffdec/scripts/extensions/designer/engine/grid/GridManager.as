package extensions.designer.engine.grid
{
   import extensions.designer.engine.IsoScene;
   import extensions.designer.engine.type.MapEntry;
   
   public class GridManager
   {
      
      public var maxAreaNo:int;
      
      public var sortedMapEntries:Array;
      
      private var grid:Array;
      
      private var gridDepth:int;
      
      private var gridWidth:int;
      
      private var scene:IsoScene;
      
      public function GridManager(param1:IsoScene)
      {
         super();
         this.scene = param1;
      }
      
      public function doFixedObjectOperations() : void
      {
         var freeAreaNo:int;
         var sortedMapEntriesIndex:int;
         var i:int;
         var j:int;
         var w:int;
         var d:int;
         var me:MapEntry;
         var ekObj:GridVO;
         var lastx:int;
         var lastz:int;
         var lastGrid:GridVO;
         var backArray:Array;
         var childIndex:int;
         var m:MapEntry;
         var backOperations4X:* = function():void
         {
            while(true)
            {
               if(backArray.length == 0)
               {
                  lastx = 0;
                  break;
               }
               me = backArray[backArray.length - 1];
               if(me.z + me.depth - 1 != lastz)
               {
                  lastx = me.x + me.width;
                  break;
               }
               backArray.pop();
            }
            lastz = lastz + 1;
         };
         trace("doFixedObjectOperations Designer");
         initGrid();
         maxAreaNo = scene.mapEntries.length;
         freeAreaNo = maxAreaNo;
         sortedMapEntries = [];
         sortedMapEntriesIndex = freeAreaNo - 1;
         i = 0;
         while(i < freeAreaNo)
         {
            me = scene.mapEntries[i];
            ekObj = new GridVO(true,me);
            w = 0;
            while(w < me.width)
            {
               d = 0;
               while(d < me.depth)
               {
                  if(me.entryType == 5)
                  {
                     setGridObj(me.x + w,me.z + d,new GridVO(false,null,-1));
                  }
                  else
                  {
                     setGridObj(me.x + w,me.z + d,ekObj);
                  }
                  d = d + 1;
               }
               w = w + 1;
            }
            i = i + 1;
         }
         i = 0;
         while(i < gridDepth)
         {
            j = 0;
            while(j < gridWidth)
            {
               if(!getGridObj(j,i))
               {
                  setGridObj(j,i,new GridVO(false,null,-1));
               }
               j = j + 1;
            }
            i = i + 1;
         }
         lastx = 0;
         lastz = 0;
         backArray = [];
         do
         {
            lastGrid = getGridObj(lastx,lastz);
            if(!lastGrid)
            {
               return;
            }
            if(lastGrid.isFilled)
            {
               me = lastGrid.mapEntry;
               if(me.z + me.depth - 1 == lastz)
               {
                  freeAreaNo = freeAreaNo - 1;
                  lastGrid.freeAreaNo = sortedMapEntriesIndex;
                  sortedMapEntries[sortedMapEntriesIndex] = me;
                  sortedMapEntriesIndex = sortedMapEntriesIndex - 1;
                  backArray.push(me);
                  if(me.x + me.width == gridWidth)
                  {
                     if(me.z + me.depth == gridDepth)
                     {
                        break;
                     }
                  }
                  else
                  {
                     lastz = me.z;
                  }
                  lastx = me.x + me.width;
               }
               else
               {
                  backOperations4X();
               }
            }
            else
            {
               lastGrid.freeAreaNo = freeAreaNo;
               lastx = lastx + 1;
            }
            if(lastx == gridWidth)
            {
               backOperations4X();
            }
         }
         while(lastz != gridDepth);
         childIndex = 0;
         i = 0;
         for(; i < sortedMapEntries.length; i = i + 1)
         {
            m = sortedMapEntries[i] as MapEntry;
            if(m)
            {
               if(m.element != null)
               {
                  try
                  {
                     scene.elementsContainer.setChildIndex(m.element.container,childIndex);
                     childIndex = childIndex + 1;
                  }
                  catch(e:Error)
                  {
                     trace("error while setChildIndex()");
                  }
                  continue;
               }
            }
         }
      }
      
      public function getGridObj(param1:int, param2:int) : GridVO
      {
         try
         {
            return grid[param1 + param2 * gridWidth];
         }
         catch(e:Error)
         {
            var _loc5_:* = null;
         }
         return _loc5_;
      }
      
      private function initGrid() : void
      {
         grid = [];
         gridWidth = scene.columnsCount;
         gridDepth = scene.rowsCount;
      }
      
      private function setGridObj(param1:int, param2:int, param3:GridVO) : void
      {
         grid[param1 + param2 * gridWidth] = param3;
      }
   }
}

