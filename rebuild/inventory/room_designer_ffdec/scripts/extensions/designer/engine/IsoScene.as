package extensions.designer.engine
{
   import com.oyunstudyosu.alert.AlertEvent;
   import com.oyunstudyosu.alert.AlertVo;
   import com.oyunstudyosu.assets.AssetRequest;
   import com.oyunstudyosu.assets.IAssetRequest;
   import com.oyunstudyosu.engine.IntPoint;
   import com.oyunstudyosu.engine.core.CellType;
   import com.oyunstudyosu.engine.core.Vector3d;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.events.OSProgressEvent;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.progress.ProgressVo;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import com.oyunstudyosu.utils.DefinitionUtils;
   import de.polygonal.core.fmt.Sprintf;
   import extensions.RoomDesigner;
   import extensions.designer.clips.InventoryPanel;
   import extensions.designer.clips.ToolBox;
   import extensions.designer.engine.grid.GridManager;
   import extensions.designer.engine.type.Cell;
   import extensions.designer.engine.type.Good;
   import extensions.designer.engine.type.IsoElement;
   import extensions.designer.engine.type.Item;
   import extensions.designer.engine.type.MapEntry;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TransformGestureEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.LoaderContext;
   import flash.utils.Dictionary;
   import flash.xml.XMLNode;
   import org.oyunstudyosu.assets.clips.BotPlaceHolder;
   
   public class IsoScene extends EventDispatcher
   {
      
      public var items:Array;
      
      public var mapEntries:Array;
      
      public var definitions:Array;
      
      private var floorContainer:Sprite;
      
      public var elementsContainer:Sprite;
      
      private var dragContainer:Sprite;
      
      public var container:Sprite;
      
      private var goods:Array;
      
      private var toolbox:ToolBox;
      
      private var inventoryPanel:InventoryPanel;
      
      private var roomSwfSource:String;
      
      private var packageList:Array;
      
      private var lastScale:Number = 1;
      
      private var xOrigin:int;
      
      private var yOrigin:int;
      
      public var columnsCount:int;
      
      public var rowsCount:int;
      
      private var grid:Array;
      
      private var sceneElements:Array;
      
      public var gridManager:GridManager;
      
      private var isChanged:Boolean;
      
      private var reservedAreas:Array;
      
      private var compatibleAreas:Array;
      
      private const cos:Number = 0.9483255309738488;
      
      private const sin:Number = 0.31729905027145594;
      
      public const _tileWidth:Number = 18;
      
      public const _tileHeight:Number = 18;
      
      private var designer:RoomDesigner;
      
      private var dragMouseX:Number;
      
      private var dragMouseY:Number;
      
      private var dragContainerX:Number;
      
      private var dragContainerY:Number;
      
      private var baseX:Number = 0;
      
      private var baseY:Number = 0;
      
      public var paddingX:Number;
      
      public var paddingY:Number;
      
      private var background:MovieClip;
      
      private var map:XMLNode;
      
      private var roomloaderInfoList:Dictionary;
      
      private var loadedCount:int;
      
      public var currentItem:MapEntry;
      
      private var draggingItemContainer:Sprite;
      
      private var roomContext:LoaderContext;
      
      private var furnitureContextList:Vector.<LoaderContext>;
      
      private var g:Graphics;
      
      private var draw:MovieClip;
      
      private var progressVo:ProgressVo;
      
      private var tipContainer:MovieClip;
      
      public function IsoScene(param1:RoomDesigner)
      {
         super();
         this.designer = param1;
         this.container = param1 as Sprite;
         furnitureContextList = new Vector.<LoaderContext>();
         this.gridManager = new GridManager(this);
         progressVo = ProgressVo.LOAD_DESIGNER;
         Dispatcher.addEventListener("RESIZE",onCanvasResize);
         param1.addEventListener("gestureZoom",onGestureZoom);
         onCanvasResize();
      }
      
      public function setScale(param1:int) : void
      {
         designer.scaleX = param1;
         designer.scaleY = param1;
         var _loc3_:Number = container.x / lastScale;
         var _loc2_:Number = container.y / lastScale;
         Connectr.instance.scaleModel.setCurrentScaleSlient(param1);
         container.x = Connectr.instance.scaleModel.currentScale * _loc3_;
         container.y = Connectr.instance.scaleModel.currentScale * _loc2_;
         lastScale = Connectr.instance.scaleModel.currentScale;
         if(container.x > 0)
         {
            trace("targetX > 0");
            container.x = 0;
         }
         else if(container.x < Connectr.instance.gameModel.canvasWidth - container.width)
         {
            trace("targetX < Connectr.instance.gameModel.canvasWidth - container.width");
            container.x = Connectr.instance.gameModel.canvasWidth - container.width;
         }
         if(container.y > 0)
         {
            trace("targetY > 0");
            container.y = 0;
         }
         else if(container.y < Connectr.instance.gameModel.canvasHeight - container.height)
         {
            trace("targetY < Connectr.instance.gameModel.canvasHeight - container.height");
            container.y = Connectr.instance.gameModel.canvasHeight - container.height;
         }
         baseX = container.x / param1;
         baseY = container.y / param1;
         dragMouseX /= param1;
         dragMouseY /= param1;
         dragContainerX = container.x;
         dragContainerY = container.y;
      }
      
      private function onGestureZoom(param1:TransformGestureEvent) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(Connectr.instance.scaleModel.enabled)
         {
            _loc4_ = Number(Connectr.instance.scaleModel.recommendedScaleRate);
            _loc5_ = Number(designer.scaleX);
            trace("e.scaleX: ",param1.scaleX);
            trace("e.scaleY: ",param1.scaleY);
            trace("e.offsetX: ",param1.offsetX);
            trace("e.offsetY: ",param1.offsetY);
            trace("scaleValue: ",_loc5_);
            if(param1.scaleY < 1 || param1.scaleX < 1)
            {
               trace("zoomOut");
               _loc6_ = Math.min(param1.scaleY,param1.scaleX);
            }
            else
            {
               trace("zoomIn");
               _loc6_ = Math.max(param1.scaleY,param1.scaleX);
            }
            if(_loc6_ < 1)
            {
               _loc5_ -= Math.max(param1.scaleY,param1.scaleX) / 50;
            }
            else
            {
               _loc5_ += Math.max(param1.scaleY,param1.scaleX) / 50;
            }
            if(_loc5_ < _loc4_)
            {
               _loc5_ = _loc4_;
            }
            else if(_loc5_ > _loc4_ + 1)
            {
               _loc5_ = _loc4_ + 1;
            }
            designer.scaleX = _loc5_;
            designer.scaleY = _loc5_;
            if(param1.phase == "end")
            {
               _loc3_ = container.x / lastScale;
               _loc2_ = container.y / lastScale;
               Connectr.instance.scaleModel.setCurrentScaleSlient(_loc5_);
               container.x = Connectr.instance.scaleModel.currentScale * _loc3_;
               container.y = Connectr.instance.scaleModel.currentScale * _loc2_;
               lastScale = Connectr.instance.scaleModel.currentScale;
               if(container.x > 0)
               {
                  trace("targetX > 0");
                  container.x = 0;
               }
               else if(container.x < Connectr.instance.gameModel.canvasWidth - container.width)
               {
                  trace("targetX < Connectr.instance.gameModel.canvasWidth - container.width");
                  container.x = Connectr.instance.gameModel.canvasWidth - container.width;
               }
               if(container.y > 0)
               {
                  trace("targetY > 0");
                  container.y = 0;
               }
               else if(container.y < Connectr.instance.gameModel.canvasHeight - container.height)
               {
                  trace("targetY < Connectr.instance.gameModel.canvasHeight - container.height");
                  container.y = Connectr.instance.gameModel.canvasHeight - container.height;
               }
               baseX = container.x / _loc5_;
               baseY = container.y / _loc5_;
               dragMouseX /= _loc5_;
               dragMouseY /= _loc5_;
               dragContainerX = container.x;
               dragContainerY = container.y;
            }
         }
      }
      
      private function onCanvasResize(param1:Event = null) : void
      {
         trace("onCanvasResize");
         paddingX = Connectr.instance.layerModel.gameLayer.x;
         paddingY = Connectr.instance.layerModel.gameLayer.y;
         if(toolbox)
         {
            toolbox.scaleX = Connectr.instance.scaleModel.uiScale;
            toolbox.scaleY = Connectr.instance.scaleModel.uiScale;
            toolbox.x = Connectr.instance.gameModel.canvasWidth / 2;
            toolbox.y = Connectr.instance.gameModel.canvasHeight + toolbox.ui.menuBg.height / Connectr.instance.scaleModel.uiScale;
            trace("Connectr.instance.layerModel.hudLayer.y",Connectr.instance.layerModel.hudLayer.y);
            toolbox.ui.menuBg.width = Connectr.instance.gameModel.canvasWidth / Connectr.instance.scaleModel.uiScale;
         }
         if(inventoryPanel)
         {
            inventoryPanel.x = Connectr.instance.gameModel.canvasWidth - inventoryPanel.width * Connectr.instance.scaleModel.uiScale;
            inventoryPanel.y = 0;
            inventoryPanel.scaleX = Connectr.instance.scaleModel.uiScale;
            inventoryPanel.scaleY = Connectr.instance.scaleModel.uiScale;
         }
         stageMouseMoveEvent(new MouseEvent("",true,false,0,0));
         baseX = container.x / Connectr.instance.scaleModel.currentScale;
         baseY = container.y / Connectr.instance.scaleModel.currentScale;
      }
      
      public function load() : void
      {
         floorContainer = new Sprite();
         elementsContainer = new Sprite();
         dragContainer = new Sprite();
         dragContainer.x = paddingX;
         dragContainer.y = paddingY;
         trace("dragContainer");
         trace(paddingX,paddingY);
         dragContainer.mouseChildren = false;
         progressVo.percent = 0;
         draw = new MovieClip();
         draw.mouseChildren = draw.mouseEnabled = false;
         g = draw.graphics;
         g.lineStyle(1,16596992);
         grid = [];
         sceneElements = [];
         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",progressVo));
         Connectr.instance.serviceModel.requestData("loadroomdesign",{},onLoadResponse);
      }
      
      private function onLoadResponse(param1:Object) : void
      {
         var _loc11_:AlertVo = null;
         var _loc10_:Array = null;
         var _loc8_:String = null;
         var _loc2_:LoaderContext = null;
         Connectr.instance.serviceModel.removeRequestData("loadroomdesign",onLoadResponse);
         if(param1.errorCode)
         {
            _loc11_ = new AlertVo();
            _loc11_.alertType = "Error";
            _loc11_.description = $(param1.errorCode);
            Dispatcher.dispatchEvent(new AlertEvent(_loc11_));
            return;
         }
         roomloaderInfoList = new Dictionary(true);
         map = Connectr.instance.roomModel.getMap();
         reservedAreas = param1.areas;
         packageList = [];
         mapEntries = [];
         items = [];
         goods = [];
         definitions = [];
         trace("######################################################");
         trace("IsoScene.as:",JSON.stringify(param1));
         var _loc9_:Array = [];
         for each(var _loc7_ in param1.furnitures)
         {
            _loc9_.push(_loc7_);
            mapEntries.push(new MapEntry(this,_loc7_,true));
         }
         mapEntries.sortOn("x",16);
         for each(var _loc6_ in param1.inventory)
         {
            _loc9_.push(_loc6_);
            items.push(new Item(_loc6_));
         }
         roomSwfSource = param1.roomKey;
         loadedCount = 0;
         var _loc5_:IAssetRequest = new AssetRequest();
         _loc5_.name = roomSwfSource;
         _loc5_.assetId = Connectr.instance.moduleModel.getPath(roomSwfSource,"ModuleType.ROOM");
         _loc5_.type = "ModuleType.ROOM";
         _loc5_.loadedFunction = onLoaded;
         _loc5_.errorFunction = onError;
         roomContext = Sanalika.instance.domainModel.generateContext("ModuleType.ROOM");
         _loc5_.context = roomContext;
         Connectr.instance.assetModel.request(_loc5_);
         for each(_loc6_ in _loc9_)
         {
            _loc10_ = [];
            if(definitions.indexOf(_loc6_.clip) == -1)
            {
               definitions.push(_loc6_.clip);
               if(_loc6_.dirs == null || _loc6_.dirs.length == 0)
               {
                  packageList.push(_loc6_.clip);
                  _loc10_.push(_loc6_.clip);
               }
               else
               {
                  for each(var _loc4_ in _loc6_.dirs)
                  {
                     packageList.push(_loc6_.clip + "_" + _loc4_);
                     _loc10_.push(_loc6_.clip + "_" + _loc4_);
                  }
               }
               roomloaderInfoList[_loc6_.clip] = _loc6_;
            }
            _loc8_ = "";
            if(_loc6_.v > 0)
            {
               _loc8_ = "." + _loc6_.v;
            }
            for each(var _loc3_ in _loc10_)
            {
               _loc5_ = new AssetRequest();
               _loc5_.name = _loc3_;
               _loc5_.assetId = Sanalika.instance.moduleModel.getPath(_loc3_ + _loc8_,"ModuleType.FURNITURE");
               _loc5_.type = "ModuleType.FURNITURE_EDITOR";
               _loc5_.loadedFunction = onLoaded;
               _loc5_.errorFunction = onError;
               _loc5_.priority = 99;
               _loc2_ = Sanalika.instance.domainModel.generateContext("ModuleType.FURNITURE_EDITOR");
               furnitureContextList.push(_loc2_);
               _loc5_.context = _loc2_;
               Connectr.instance.assetModel.request(_loc5_);
            }
         }
      }
      
      private function onLoaded(param1:IAssetRequest) : void
      {
         trace("request.name: ",param1.name);
         loadedCount = loadedCount + 1;
         trace("loadedCount",loadedCount);
         trace("packageList.length",packageList.length);
         if(packageList.length + 1 == loadedCount)
         {
            trace("TTTTTTTTTTTTTTT");
            Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.DESIGNER_LOADED));
            processSceneData();
         }
         else
         {
            trace("KKKKK");
            progressVo.percent = loadedCount / (packageList.length + 1) * 100;
            Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",progressVo));
         }
      }
      
      private function onError(param1:IAssetRequest) : void
      {
         trace("Error: " + param1.assetId);
         loadedCount = loadedCount + 1;
         trace("loadedCount",loadedCount);
         trace("packageList.length",packageList.length);
         if(packageList.length + 1 == loadedCount)
         {
            trace("TTTTTTTTTTTTTTT");
            Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.DESIGNER_LOADED));
            processSceneData();
         }
         else
         {
            trace("KKKKK");
            progressVo.percent = loadedCount / (packageList.length + 1) * 100;
            Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",progressVo));
         }
         param1.dispose();
      }
      
      private function processSceneData() : void
      {
         var _loc3_:Object = null;
         var _loc4_:Good = null;
         for(var _loc1_ in roomloaderInfoList)
         {
            trace(JSON.stringify(_loc1_));
            trace("roomloaderInfoList",roomloaderInfoList[_loc1_]);
            _loc3_ = roomloaderInfoList[_loc1_];
            trace(JSON.stringify(_loc3_));
            _loc4_ = new Good(_loc1_,[_loc3_.width,_loc3_.height,_loc3_.depth],_loc3_.dirs,_loc3_.entryType,_loc3_.v);
            goods.push(_loc4_);
         }
         xOrigin = parseInt(map.attributes["xOrigin"].toString());
         yOrigin = parseInt(map.attributes["yOrigin"].toString());
         processGrid();
         for each(var _loc2_ in mapEntries)
         {
            addMapEntry(_loc2_);
         }
         var _loc5_:Class = DefinitionUtils.getClass(roomContext.applicationDomain,"bg");
         background = new _loc5_();
         container.addChild(background);
         depthSort();
         container.addChild(floorContainer);
         container.addChild(elementsContainer);
         container.addChild(draw);
         Connectr.instance.layerModel.panelLayer.addChild(dragContainer);
         container.addEventListener("mouseDown",mouseDown);
         toolbox = new ToolBox(this);
         toolbox.addEventListeners();
         updateButtonStates();
         Connectr.instance.layerModel.hudLayer.addChild(toolbox);
         switchInventoryPanel();
         Dispatcher.dispatchEvent(new GameEvent("TRANSITION_IN"));
         onCanvasResize();
      }
      
      private function processGrid() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:Cell = null;
         columnsCount = Connectr.instance.roomModel.gridModel.width;
         rowsCount = Connectr.instance.roomModel.gridModel.height;
         _loc3_ = 0;
         while(_loc3_ < rowsCount)
         {
            _loc1_ = 0;
            while(_loc1_ < columnsCount)
            {
               _loc2_ = new Cell(_loc1_,_loc3_);
               _loc2_.bit = Connectr.instance.roomModel.gridModel.getCellValue(_loc1_,_loc3_);
               switch(_loc2_.bit - -1)
               {
                  case 0:
                     _loc2_.cellType = CellType.TYPE_WALK_ONLY;
                     break;
                  case 1:
                  case 3:
                     _loc2_.cellType = CellType.TYPE_EMPTY;
                     break;
                  case 2:
                     _loc2_.cellType = CellType.TYPE_DISABLED;
                     break;
                  case 4:
                     _loc2_.bit = 0;
                     _loc2_.cellType = CellType.TYPE_DIAMOND;
                     break;
                  case 5:
                     _loc2_.bit = 0;
                     _loc2_.cellType = CellType.TYPE_ADMIN;
               }
               grid.push(_loc2_);
               _loc1_++;
            }
            _loc3_++;
         }
      }
      
      private function addMapEntry(param1:MapEntry) : void
      {
         var _loc2_:IsoElement = null;
         var _loc3_:MovieClip = getMovieClip(param1.getDefinition());
         if(_loc3_)
         {
            _loc3_.mapEntry = param1;
            _loc3_.mouseChildren = false;
            if(param1.entryType == 5)
            {
               this.floorContainer.addChild(_loc3_);
            }
            else
            {
               this.elementsContainer.addChild(_loc3_);
            }
            _loc2_ = new IsoElement(null,_loc3_,this);
            _loc2_.id = param1.definition;
            _loc2_.posMatrix = new IntPoint(param1.x,param1.z);
            param1.element = _loc2_;
            sceneElements.push(_loc2_);
            param1.init(this);
         }
         else
         {
            trace(param1.getDefinition());
            trace("LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL--------------");
         }
      }
      
      public function clearItem(param1:MapEntry) : void
      {
         if(this.elementsContainer == null || this.floorContainer == null || param1.element == null)
         {
            return;
         }
         if(this.elementsContainer.contains(param1.element.container))
         {
            this.elementsContainer.removeChild(param1.element.container);
         }
         else if(this.floorContainer.contains(param1.element.container))
         {
            this.floorContainer.removeChild(param1.element.container);
         }
      }
      
      public function switchInventoryPanel() : void
      {
         if(inventoryPanel == null)
         {
            inventoryPanel = new InventoryPanel(this);
            inventoryPanel.x = Connectr.instance.gameModel.canvasWidth - inventoryPanel.width;
            inventoryPanel.y = 0;
            Connectr.instance.layerModel.hudLayer.addChild(inventoryPanel);
         }
         else
         {
            Connectr.instance.layerModel.hudLayer.removeChild(inventoryPanel);
            inventoryPanel = null;
         }
      }
      
      public function btnQuitClicked(param1:MouseEvent) : void
      {
         var _loc2_:AlertVo = null;
         if(isChanged)
         {
            _loc2_ = new AlertVo();
            _loc2_.alertType = "Confirm";
            _loc2_.title = $("Are you sure?");
            _loc2_.description = $("Your changes will be lost.");
            _loc2_.callBack = quitPanelAnswer;
            Dispatcher.dispatchEvent(new AlertEvent(_loc2_));
         }
         else
         {
            designer.leave();
         }
      }
      
      public function btnSaveClicked(param1:MouseEvent) : void
      {
         var _loc4_:AlertVo = null;
         if(mapEntries.length > 200)
         {
            _loc4_ = new AlertVo();
            _loc4_.alertType = "Error";
            _loc4_.title = $("room_object_max_title");
            _loc4_.description = Sprintf.format($("room_object_max_info"),[mapEntries.length]);
            Dispatcher.dispatchEvent(new AlertEvent(_loc4_));
            return;
         }
         var _loc3_:Array = [];
         for each(var _loc2_ in mapEntries)
         {
            if(!(_loc2_.x == 0 && _loc2_.y == 0 && _loc2_.z == 0))
            {
               _loc3_.push({
                  "id":_loc2_.id,
                  "clip":_loc2_.definition,
                  "dir":(_loc2_.dir > 0 ? _loc2_.dir : 0),
                  "x":_loc2_.x,
                  "y":_loc2_.y,
                  "z":_loc2_.z
               });
            }
         }
         Connectr.instance.serviceModel.requestData("saveroomdesign",{"design":_loc3_},onSaveResponse);
      }
      
      public function quitPanelAnswer(param1:int) : void
      {
         if(param1 == 2)
         {
            designer.leave();
         }
      }
      
      public function onSaveResponse(param1:Object) : void
      {
         Connectr.instance.serviceModel.removeRequestData("saveroomdesign",onSaveResponse);
         var _loc2_:AlertVo = new AlertVo();
         if(param1.errorCode)
         {
            return;
         }
         Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS",ProgressVo.PROGRESS_FULL));
         Connectr.instance.avatarModel.data.saveRoomImage = true;
         Sanalika.instance.roomModel.checkMap(param1);
         designer.leave();
      }
      
      public function btnEraseAllClicked(param1:MouseEvent) : void
      {
         var _loc2_:AlertVo = new AlertVo();
         _loc2_.alertType = "Confirm";
         _loc2_.title = $("Are you sure?");
         _loc2_.description = $("Your furnitures will be removed to inventory.");
         _loc2_.callBack = eraseAllConfirmed;
         Dispatcher.dispatchEvent(new AlertEvent(_loc2_));
      }
      
      public function eraseAllConfirmed(param1:int) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc2_:MapEntry = null;
         _loc4_ = 0;
         if(param1 == 2)
         {
            _loc3_ = [];
            _loc4_ = 0;
            while(_loc4_ < mapEntries.length)
            {
               _loc2_ = mapEntries[_loc4_];
               if(_loc2_.fx != 1)
               {
                  _loc3_.push(_loc2_);
               }
               _loc4_++;
            }
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               eraseDesignInventoryItem(_loc3_[_loc4_]);
               _loc4_++;
            }
         }
      }
      
      public function btnEraseClicked(param1:MouseEvent) : void
      {
         if(currentItem == null)
         {
            return;
         }
         eraseDesignInventoryItem(currentItem);
      }
      
      private function eraseDesignInventoryItem(param1:MapEntry) : void
      {
         var _loc5_:Cell = null;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Item = null;
         _loc7_ = 0;
         while(_loc7_ < param1.width)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.depth)
            {
               _loc5_ = getCellAt(param1.x + _loc7_,0,param1.z + _loc2_);
               if(_loc5_)
               {
                  _loc5_.cellType = Cell.TYPE_EMPTY;
               }
               _loc2_++;
            }
            _loc7_++;
         }
         isChanged = true;
         var _loc6_:Good = getGoodByDefinition(param1.definition);
         _loc6_.id = param1.id;
         if(mapEntries.indexOf(param1) > -1)
         {
            mapEntries.splice(mapEntries.indexOf(param1),1);
         }
         clearItem(param1);
         sceneElements.splice(sceneElements.indexOf(param1.element),1);
         depthSort();
         var _loc4_:Item = getItemByDefinition(param1.definition);
         if(_loc4_ != null)
         {
            _loc4_.push(param1.id);
            if(inventoryPanel)
            {
               inventoryPanel.updateItem(_loc4_);
            }
         }
         else
         {
            _loc3_ = Item.createItem(_loc6_,param1.furnLocation);
            items.push(_loc3_);
            if(inventoryPanel)
            {
               inventoryPanel.addItem(_loc3_);
            }
         }
         if(currentItem == param1)
         {
            currentItem = null;
            _loc6_ = null;
            updateButtonStates();
         }
      }
      
      public function btnRotateClicked(param1:MouseEvent) : void
      {
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc10_:IntPoint = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc13_:int = 0;
         var _loc11_:int = 0;
         if(currentItem == null)
         {
            return;
         }
         var _loc4_:Good = getGoodByDefinition(currentItem.definition);
         if(_loc4_.directions && _loc4_.directions.length == 0)
         {
            updateButtonStates();
            return;
         }
         isChanged = true;
         var _loc12_:int = Math.max(_loc4_.directions.indexOf(currentItem.dir),0);
         var _loc9_:int = _loc12_ + 1 < _loc4_.directions.length ? _loc12_ + 1 : 0;
         _loc6_ = 0;
         while(_loc6_ < currentItem.width)
         {
            _loc2_ = 0;
            while(_loc2_ < currentItem.depth)
            {
               getCellAt(currentItem.x + _loc6_,0,currentItem.z + _loc2_).cellType = Cell.TYPE_EMPTY;
               _loc2_++;
            }
            _loc6_++;
         }
         var _loc3_:IntPoint = currentItem.dir == 3 || currentItem.dir == 7 ? new IntPoint(currentItem.width,currentItem.depth) : new IntPoint(currentItem.depth,currentItem.width);
         if(currentItem.width >= 1 || currentItem.height >= 1)
         {
            while(_loc9_ != _loc12_)
            {
               _loc7_ = true;
               if(_loc4_.directions[_loc9_] == 3 || _loc4_.directions[_loc9_] == 7)
               {
                  _loc10_ = _loc3_.clone();
               }
               else
               {
                  _loc10_ = _loc3_.swap();
               }
               _loc8_ = 0;
               while(_loc8_ < _loc10_.x)
               {
                  _loc5_ = 0;
                  while(_loc5_ < _loc10_.y)
                  {
                     if(!(currentItem.x + _loc8_ < columnsCount && currentItem.z + _loc5_ < rowsCount) || getCellAt(currentItem.x + _loc8_,0,currentItem.z + _loc5_).cellType == Cell.TYPE_DISABLED)
                     {
                        _loc7_ = false;
                        break;
                     }
                     _loc5_++;
                  }
                  if(!_loc7_)
                  {
                     break;
                  }
                  _loc8_++;
               }
               if(_loc7_)
               {
                  break;
               }
               if(++_loc9_ >= _loc4_.directions.length)
               {
                  _loc9_ = 0;
               }
            }
            if(_loc9_ == _loc12_)
            {
               return;
            }
         }
         _loc13_ = 0;
         while(_loc13_ < currentItem.width)
         {
            _loc11_ = 0;
            while(_loc11_ < currentItem.depth)
            {
               getCellAt(currentItem.x + _loc13_,0,currentItem.z + _loc11_).cellType = Cell.TYPE_EMPTY;
               _loc11_++;
            }
            _loc13_++;
         }
         clearItem(this.currentItem);
         sceneElements.splice(sceneElements.indexOf(currentItem.element),1);
         currentItem.dir = _loc4_.directions[_loc9_];
         currentItem.width = _loc10_.x;
         currentItem.depth = _loc10_.y;
         currentItem.definition = _loc4_.definition;
         currentItem.entryType = _loc4_.entryType;
         addMapEntry(currentItem);
         depthSort();
         highlightEntry(currentItem);
      }
      
      public function newGoodClicked(param1:MouseEvent) : void
      {
         trace("newGoodClicked");
         isChanged = true;
         var _loc2_:MovieClip = MovieClip(param1.target);
         unselectEntry(currentItem);
         currentItem = null;
         updateButtonStates();
         var _loc4_:Item = getItemByDefinition(_loc2_.definition);
         var _loc6_:Good = getGoodByDefinition(_loc2_.definition);
         if(!_loc4_)
         {
            trace("item not found");
            return;
         }
         if(!_loc6_)
         {
            trace("good not found ",_loc2_.definition);
            return;
         }
         var _loc3_:int = int(_loc6_.directions && _loc6_.directions.length > 0 ? (_loc6_.directions.indexOf(3) > -1 ? 3 : _loc6_.directions[0]) : -1);
         var _loc7_:MovieClip = getMovieClip(_loc2_.definition + (_loc3_ > -1 ? "_" + _loc3_ : ""));
         var _loc5_:Object = {};
         _loc5_.width = _loc6_.width;
         _loc5_.height = _loc6_.height;
         _loc5_.depth = _loc6_.depth;
         _loc5_.clip = _loc2_.definition;
         _loc5_.dir = _loc3_;
         _loc5_.id = _loc4_.shift();
         _loc5_.fLoc = _loc4_.furnLocation;
         _loc5_.entryType = _loc6_.entryType;
         saveCurrentItem(new MapEntry(this,_loc5_));
         draggingItemContainer = new Sprite();
         draggingItemContainer.addChild(_loc7_);
         draggingItemContainer.scaleX = Connectr.instance.scaleModel.currentScale;
         draggingItemContainer.scaleY = Connectr.instance.scaleModel.currentScale;
         draggingItemContainer.x = param1.stageX - paddingX;
         draggingItemContainer.y = param1.stageY - paddingY;
         drawDragHandler(960465,_loc7_.getBounds(draggingItemContainer));
         dragContainer.addChild(draggingItemContainer);
         draggingItemContainer.alpha = 0.7;
         container.stage.addEventListener("mouseMove",mouseMoved);
         container.stage.addEventListener("mouseUp",mouseUp);
         if(_loc4_.idList.length == 0)
         {
            items.splice(items.indexOf(_loc4_),1);
            if(inventoryPanel)
            {
               inventoryPanel.removeItem(_loc4_);
            }
         }
         else if(inventoryPanel)
         {
            inventoryPanel.updateItem(_loc4_);
         }
      }
      
      private function drawDragHandler(param1:uint, param2:Rectangle = null) : void
      {
         var _loc4_:MovieClip = null;
         var _loc3_:Graphics = draggingItemContainer.graphics;
         if(param2 == null && draggingItemContainer.numChildren > 0)
         {
            _loc4_ = draggingItemContainer.getChildAt(0) as MovieClip;
            param2 = _loc4_.getBounds(draggingItemContainer);
         }
         _loc3_.clear();
         _loc3_.lineStyle(2,param1);
         _loc3_.drawRect(param2.x,param2.y,param2.width,param2.height);
         _loc3_.drawRect(param2.x - 1,param2.y - 1,2,2);
         _loc3_.drawRect(param2.x + param2.width - 1,param2.y - 1,2,2);
         _loc3_.drawRect(param2.x - 1,param2.y + param2.height - 1,2,2);
         _loc3_.drawRect(param2.x + param2.width - 1,param2.y + param2.height - 1,2,2);
      }
      
      public function stageMouseUpEvent(param1:MouseEvent) : void
      {
         trace("stageMouseUpEvent");
         baseX = container.x / Connectr.instance.scaleModel.currentScale;
         baseY = container.y / Connectr.instance.scaleModel.currentScale;
         container.stage.removeEventListener("mouseUp",stageMouseUpEvent);
         container.stage.removeEventListener("mouseMove",stageMouseMoveEvent);
      }
      
      public function stageMouseMoveEvent(param1:MouseEvent) : void
      {
         trace("stageMouseMoveEvent");
         var _loc2_:Number = dragContainerX + (param1.stageX - paddingX) - dragMouseX;
         var _loc3_:Number = dragContainerY + (param1.stageY - paddingY) - dragMouseY;
         if(_loc2_ > 0)
         {
            trace("targetX > 0");
            _loc2_ = 0;
         }
         else if(_loc2_ < Connectr.instance.gameModel.canvasWidth - container.width)
         {
            trace("targetX < Connectr.instance.gameModel.canvasWidth - container.width");
            _loc2_ = Connectr.instance.gameModel.canvasWidth - container.width;
         }
         if(_loc3_ > 0)
         {
            trace("targetY > 0");
            _loc3_ = 0;
         }
         else if(_loc3_ < Connectr.instance.gameModel.canvasHeight - container.height)
         {
            trace("targetY < Connectr.instance.gameModel.canvasHeight - container.height");
            _loc3_ = Connectr.instance.gameModel.canvasHeight - container.height;
         }
         container.x = _loc2_;
         container.y = _loc3_;
      }
      
      private function saveCurrentItem(param1:MapEntry) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc3_:Array = null;
         currentItem = param1;
         if(currentItem.furnLocation == 0)
         {
            return;
         }
         var _loc5_:Array = [];
         var _loc2_:int = currentItem.furnLocation;
         compatibleAreas = [];
         _loc6_ = 0;
         while(_loc6_ < reservedAreas.length)
         {
            _loc4_ = reservedAreas[_loc6_];
            if((_loc2_ & _loc4_.fLoc) > 0)
            {
               _loc3_ = _loc4_.areas;
               compatibleAreas.push({
                  "sx":_loc3_[0],
                  "sy":_loc3_[1],
                  "ex":_loc3_[2],
                  "ey":_loc3_[3]
               });
            }
            _loc6_++;
         }
      }
      
      public function mouseMoved(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         trace("mouseMoved");
         trace("stageX: " + param1.stageX);
         trace("stageY: " + param1.stageY);
         trace("paddingX: " + paddingX);
         trace("paddingY: " + paddingY);
         trace("baseX: " + baseX);
         trace("baseY: " + baseY);
         var _loc3_:Point = translateToGrid((param1.stageX - paddingX) / Connectr.instance.scaleModel.currentScale - baseX,(param1.stageY - paddingY) / Connectr.instance.scaleModel.currentScale - baseY);
         if(isValidPlace(currentItem,_loc3_) || inventoryPanel && inventoryPanel.hitTestPoint((param1.stageX - paddingX) / Connectr.instance.scaleModel.currentScale,(param1.stageY - paddingY) / Connectr.instance.scaleModel.currentScale))
         {
            trace("tile.x: " + _loc3_.x);
            trace("tile.y: " + _loc3_.y);
            _loc2_ = getPosFromGrid(_loc3_.x,_loc3_.y);
            drawDragHandler(65280);
         }
         else
         {
            _loc2_ = new Point((param1.stageX - paddingX) / Connectr.instance.scaleModel.currentScale - baseX,(param1.stageY - paddingY) / Connectr.instance.scaleModel.currentScale - baseY);
            drawDragHandler(16711680);
         }
         draggingItemContainer.scaleX = Connectr.instance.scaleModel.currentScale;
         draggingItemContainer.scaleY = Connectr.instance.scaleModel.currentScale;
         draggingItemContainer.x = _loc2_.x * Connectr.instance.scaleModel.currentScale + baseX * Connectr.instance.scaleModel.currentScale;
         draggingItemContainer.y = _loc2_.y * Connectr.instance.scaleModel.currentScale + baseY * Connectr.instance.scaleModel.currentScale;
      }
      
      private function mouseDown(param1:MouseEvent) : void
      {
         var _loc11_:AlertVo = null;
         var _loc7_:Cell = null;
         var _loc10_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc9_:MovieClip = null;
         var _loc6_:Point = null;
         var _loc5_:Point = null;
         trace("mouseDown");
         unselectEntry(currentItem);
         var _loc3_:MovieClip = param1.target as MovieClip;
         trace("IsoSceneMouseDown");
         trace(_loc3_.name);
         trace(_loc3_.height);
         trace(background.name);
         if(_loc3_ != background)
         {
            if(!_loc3_["mapEntry"])
            {
               return;
            }
            if(_loc3_.mapEntry.fx == 1)
            {
               trace("fixed");
               _loc3_.visible = false;
               _loc11_ = new AlertVo();
               _loc11_.alertType = "tooltip";
               _loc11_.description = $("This object is not moveable");
               Dispatcher.dispatchEvent(new AlertEvent(_loc11_));
               return;
            }
            _loc10_ = 0;
            while(_loc10_ < _loc3_.mapEntry.width)
            {
               _loc8_ = 0;
               while(_loc8_ < _loc3_.mapEntry.depth)
               {
                  _loc7_ = getCellAt(_loc3_.mapEntry.x + _loc10_,0,_loc3_.mapEntry.z + _loc8_);
                  if(_loc7_)
                  {
                     _loc7_.cellType = Cell.TYPE_EMPTY;
                  }
                  _loc8_++;
               }
               _loc10_++;
            }
            if(mapEntries.indexOf(_loc3_.mapEntry) > -1)
            {
               mapEntries.splice(mapEntries.indexOf(_loc3_.mapEntry),1);
            }
            clearItem(_loc3_.mapEntry);
            sceneElements.splice(sceneElements.indexOf(_loc3_.mapEntry.element),1);
            saveCurrentItem(_loc3_.mapEntry);
            _loc4_ = _loc3_.x;
            _loc2_ = _loc3_.y;
            trace("currentItem.getDefinition()",currentItem.getDefinition());
            _loc9_ = getMovieClip(currentItem.getDefinition());
            _loc9_.x = 0;
            _loc9_.y = 0;
            draggingItemContainer = new Sprite();
            draggingItemContainer.addChild(_loc9_);
            _loc6_ = translateToGrid((param1.stageX - paddingX) / Connectr.instance.scaleModel.currentScale - baseX,(param1.stageY - paddingY) / Connectr.instance.scaleModel.currentScale - baseY);
            _loc5_ = new Point(param1.stageX,param1.stageY);
            trace("p",_loc5_);
            draggingItemContainer.scaleX = Connectr.instance.scaleModel.currentScale;
            draggingItemContainer.scaleY = Connectr.instance.scaleModel.currentScale;
            draggingItemContainer.x = _loc5_.x * Connectr.instance.scaleModel.currentScale + baseX * Connectr.instance.scaleModel.currentScale;
            draggingItemContainer.y = _loc5_.y * Connectr.instance.scaleModel.currentScale + baseY * Connectr.instance.scaleModel.currentScale;
            drawDragHandler(960465,_loc9_.getBounds(draggingItemContainer));
            dragContainer.addChild(draggingItemContainer);
            depthSort();
            container.stage.addEventListener("mouseMove",mouseMoved);
            container.stage.addEventListener("mouseUp",mouseUp);
         }
         else
         {
            trace(_loc3_.name);
            trace("else");
            currentItem = null;
            updateButtonStates();
            container.stage.addEventListener("mouseUp",stageMouseUpEvent);
            container.stage.addEventListener("mouseMove",stageMouseMoveEvent);
            dragMouseX = param1.stageX - paddingX;
            dragMouseY = param1.stageY - paddingY;
            dragContainerX = container.x;
            dragContainerY = container.y;
         }
      }
      
      public function mouseUp(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         trace("mouseUp");
         Connectr.instance.layerModel.stage.removeEventListener("mouseMove",mouseMoved);
         Connectr.instance.layerModel.stage.removeEventListener("mouseUp",mouseUp);
         if(currentItem == null)
         {
            return;
         }
         while(draggingItemContainer.numChildren > 0)
         {
            draggingItemContainer.removeChildAt(0);
         }
         dragContainer.removeChild(draggingItemContainer);
         var _loc5_:Point = translateToGrid((param1.stageX - paddingX) / Connectr.instance.scaleModel.currentScale - baseX,(param1.stageY - paddingY) / Connectr.instance.scaleModel.currentScale - baseY);
         if(inventoryPanel)
         {
            _loc4_ = param1.stageX - paddingX;
            _loc2_ = param1.stageY - paddingY;
            if(_loc4_ >= inventoryPanel.x && _loc4_ < inventoryPanel.x + inventoryPanel.width && _loc2_ >= inventoryPanel.y && _loc2_ < inventoryPanel.y + inventoryPanel.height)
            {
               btnEraseClicked(null);
               return;
            }
         }
         if(isValidPlace(currentItem,_loc5_,false))
         {
            currentItem.x = _loc5_.x;
            currentItem.z = _loc5_.y;
            isChanged = true;
         }
         else if(currentItem.element == null)
         {
            putBasket();
            return;
         }
         var _loc6_:Good = getGoodByDefinition(currentItem.definition);
         if(currentItem.dir < 1)
         {
            _loc3_ = int(_loc6_.directions && _loc6_.directions.length > 0 ? (_loc6_.directions.indexOf(3) > -1 ? 3 : _loc6_.directions[0]) : -1);
            currentItem.dir = _loc3_;
            currentItem.width = _loc6_.width;
            currentItem.height = _loc6_.height;
            currentItem.depth = _loc6_.depth;
         }
         mapEntries.push(currentItem);
         addMapEntry(currentItem);
         currentItem.element.moveToCell(currentItem.x,currentItem.y,currentItem.z);
         highlightEntry(currentItem);
         updateButtonStates();
         depthSort();
      }
      
      private function putBasket() : void
      {
         var _loc1_:Item = null;
         var _loc2_:Item = getItemByDefinition(currentItem.definition);
         var _loc3_:Good = getGoodByDefinition(currentItem.definition);
         _loc3_.id = currentItem.id;
         if(_loc2_ != null)
         {
            _loc2_.push(currentItem.id);
            if(inventoryPanel)
            {
               inventoryPanel.updateItem(_loc2_);
            }
         }
         else
         {
            _loc1_ = Item.createItem(_loc3_,currentItem.furnLocation);
            items.push(_loc1_);
            if(inventoryPanel)
            {
               inventoryPanel.addItem(_loc1_);
            }
         }
         currentItem = null;
      }
      
      private function depthSort() : void
      {
         var _loc1_:Vector3d = null;
         for each(var _loc2_ in sceneElements)
         {
            _loc1_ = get3DPosFromGrid(_loc2_.posMatrix.x,_loc2_.posMatrix.y);
            _loc2_.moveTo(_loc1_.x,_loc1_.y,_loc1_.z);
         }
         gridManager.doFixedObjectOperations();
      }
      
      private function updateButtonStates() : void
      {
         var _loc1_:Good = null;
         if(currentItem == null)
         {
            toolbox.disableRotateButton();
            toolbox.disableEraseButton();
            container.removeEventListener("rightClick",btnRotateClicked);
         }
         else
         {
            _loc1_ = getGoodByDefinition(currentItem.definition);
            if(_loc1_.directions && _loc1_.directions.length > 0)
            {
               toolbox.enableRotateButton();
               container.addEventListener("rightClick",btnRotateClicked);
            }
            else
            {
               toolbox.disableRotateButton();
               container.removeEventListener("rightClick",btnRotateClicked);
            }
            toolbox.enableEraseButton();
            _loc1_ = null;
         }
      }
      
      public function getGoodByDefinition(param1:String) : Good
      {
         trace(JSON.stringify(goods));
         for each(var _loc2_ in goods)
         {
            if(_loc2_.definition == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getItemByDefinition(param1:String) : Item
      {
         for each(var _loc2_ in items)
         {
            if(_loc2_.definition == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function highlightEntry(param1:MapEntry) : void
      {
         var _loc3_:Rectangle = param1.element.container.getBounds(param1.element.container);
         var _loc4_:Sprite = new Sprite();
         _loc4_.name = "highlight";
         var _loc2_:Graphics = _loc4_.graphics;
         _loc2_.lineStyle(2,960465);
         _loc2_.drawRect(_loc3_.x,_loc3_.y,_loc3_.width,_loc3_.height);
         _loc2_.drawRect(_loc3_.x - 1,_loc3_.y - 1,2,2);
         _loc2_.drawRect(_loc3_.x + _loc3_.width - 1,_loc3_.y - 1,2,2);
         _loc2_.drawRect(_loc3_.x - 1,_loc3_.y + _loc3_.height - 1,2,2);
         _loc2_.drawRect(_loc3_.x + _loc3_.width - 1,_loc3_.y + _loc3_.height - 1,2,2);
         param1.element.container.addChild(_loc4_);
      }
      
      private function unselectEntry(param1:MapEntry) : void
      {
         if(param1 == null || param1.element == null)
         {
            return;
         }
         var _loc2_:DisplayObject = param1.element.container.getChildByName("highlight");
         if(_loc2_ != null)
         {
            param1.element.container.removeChild(_loc2_);
         }
         _loc2_ = null;
      }
      
      private function isValidPlace(param1:MapEntry, param2:Point, param3:Boolean = false) : Boolean
      {
         var _loc5_:Boolean = false;
         var _loc11_:int = 0;
         var _loc6_:Object = null;
         var _loc10_:AlertVo = null;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:Cell = null;
         if(param2.x < 0 || param2.x >= columnsCount || param2.y < 0 || param2.y >= rowsCount)
         {
            return false;
         }
         if(param2.x + param1.width > columnsCount || param2.y + param1.depth > rowsCount)
         {
            return false;
         }
         if(param1.furnLocation > 0)
         {
            _loc5_ = false;
            _loc11_ = 0;
            while(_loc11_ < compatibleAreas.length)
            {
               _loc6_ = compatibleAreas[_loc11_];
               if(_loc6_.sx <= param2.x && param2.x <= _loc6_.ex && _loc6_.sy <= param2.y && param2.y <= _loc6_.ey)
               {
                  _loc5_ = true;
                  break;
               }
               _loc11_++;
            }
            if(!_loc5_)
            {
               if(param3)
               {
                  _loc10_ = new AlertVo();
                  _loc10_.alertType = "Info";
                  _loc10_.description = $("desinger02");
                  Dispatcher.dispatchEvent(new AlertEvent(_loc10_));
               }
               return false;
            }
         }
         _loc9_ = 0;
         while(_loc9_ < param1.width)
         {
            _loc8_ = 0;
            while(_loc8_ < param1.depth)
            {
               if(param1.entryType == 5)
               {
                  _loc7_ = int(Sanalika.instance.roomModel.gridModel.getCellValue(param2.x + _loc9_,param2.y + _loc8_));
                  if(_loc7_ == 1)
                  {
                     return false;
                  }
               }
               else
               {
                  _loc4_ = getCellAt(param2.x + _loc9_,0,param2.y + _loc8_);
                  trace(param1.definition);
                  trace(_loc4_.cellType);
                  trace(param1.entryType);
                  if(_loc4_.cellType == Cell.TYPE_DISABLED && param1.entryType != 5)
                  {
                     return false;
                  }
               }
               _loc8_++;
            }
            _loc9_++;
         }
         return true;
      }
      
      public function getMovieClip(param1:String) : MovieClip
      {
         var _loc6_:Class = null;
         var _loc7_:* = null;
         var _loc3_:* = null;
         for each(var _loc4_ in furnitureContextList)
         {
            _loc6_ = DefinitionUtils.getClass(_loc4_.applicationDomain,param1,Sanalika.instance.gameModel.weather);
            if(_loc6_)
            {
               return new _loc6_();
            }
         }
         var _loc2_:Class = DefinitionUtils.getClass(roomContext.applicationDomain,param1,Sanalika.instance.gameModel.weather);
         if(_loc2_)
         {
            return new _loc2_();
         }
         var _loc5_:MovieClip = new MovieClip();
         _loc5_.addChild(new BotPlaceHolder());
         return _loc5_;
      }
      
      public function showGrid() : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:Point = null;
         g.clear();
         g.lineStyle(1,16711680);
         _loc3_ = 0;
         while(_loc3_ < rowsCount)
         {
            _loc2_ = 0;
            while(_loc2_ < columnsCount)
            {
               if(gridManager.getGridObj(_loc2_,_loc3_))
               {
                  if(gridManager.getGridObj(_loc2_,_loc3_).isFilled)
                  {
                     _loc1_ = getPosFromGrid(_loc2_,_loc3_);
                     g.drawCircle(_loc1_.x,_loc1_.y,2);
                  }
               }
               _loc2_++;
            }
            _loc3_++;
         }
         drawGrid();
      }
      
      private function drawGrid() : void
      {
         var _loc9_:int = 0;
         var _loc4_:Point = null;
         var _loc2_:Point = null;
         var _loc1_:int = 0;
         var _loc6_:Point = null;
         var _loc3_:Point = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:Point = null;
         g.lineStyle(1,16711680,0.4);
         _loc9_ = 0;
         while(_loc9_ <= rowsCount)
         {
            _loc4_ = get2dPoint(0,0,tileHeight * _loc9_);
            _loc2_ = get2dPoint(tileWidth * columnsCount,0,tileHeight * _loc9_);
            g.moveTo(_loc4_.x,_loc4_.y);
            g.lineTo(_loc2_.x,_loc2_.y);
            _loc9_++;
         }
         _loc1_ = 0;
         while(_loc1_ <= columnsCount)
         {
            _loc6_ = get2dPoint(tileWidth * _loc1_,0,0);
            _loc3_ = get2dPoint(tileWidth * _loc1_,0,tileHeight * rowsCount);
            g.moveTo(_loc6_.x,_loc6_.y);
            g.lineTo(_loc3_.x,_loc3_.y);
            _loc1_++;
         }
         _loc7_ = 0;
         while(_loc7_ < rowsCount)
         {
            _loc8_ = 0;
            while(_loc8_ < columnsCount)
            {
               _loc5_ = getPosFromGrid(_loc8_,_loc7_);
               switch(Cell(grid[_loc7_ * columnsCount + _loc8_]).cellType)
               {
                  case Cell.TYPE_DISABLED:
                     g.lineStyle(4,85);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
                     break;
                  case Cell.TYPE_EMPTY:
                     break;
                  case Cell.TYPE_ADMIN:
                     g.lineStyle(2,16776960);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
                     break;
                  case Cell.TYPE_SANALIKAX:
                     g.lineStyle(2,15094016);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
                     break;
                  case Cell.TYPE_DIAMOND:
                     g.lineStyle(2,65535);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
                     break;
                  case Cell.TYPE_TARGET:
                     g.lineStyle(2,65535);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
                     break;
                  case Cell.TYPE_WALK_ONLY:
                     g.lineStyle(1,16777215);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
                     break;
                  case Cell.TYPE_FISH:
                     g.lineStyle(4,255);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
                     break;
                  case Cell.TYPE_SHORTCUT:
                     g.lineStyle(4,170);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
                     break;
                  case Cell.TYPE_NPC:
                     g.lineStyle(4,13369548);
                     g.drawCircle(_loc5_.x,_loc5_.y,2);
               }
               _loc8_++;
            }
            _loc7_++;
         }
      }
      
      public function translateToGrid(param1:Number, param2:Number) : Point
      {
         var _loc3_:Point = translateStageCoordsTo3DCoords(param1,param2);
         return new Point(Math.floor(_loc3_.x / tileWidth),Math.floor(_loc3_.y / tileWidth));
      }
      
      public function getPosFromGrid(param1:Number, param2:Number) : Point
      {
         return get2dPoint((param1 + 1) * tileWidth - tileWidth / 2,0,(param2 + 1) * tileWidth - tileWidth / 2);
      }
      
      public function get3DPosFromGrid(param1:int, param2:int) : Vector3d
      {
         return new Vector3d((param1 + 1) * tileWidth - tileWidth / 2,0,(param2 + 1) * tileWidth - tileWidth / 2);
      }
      
      public function get2dPoint(param1:Number, param2:Number, param3:Number) : Point
      {
         var _loc4_:Point = new Point();
         _loc4_.x = (param1 - param3) * 0.9483255309738488 + xOrigin;
         _loc4_.y = -(param2 + (param1 + param3) * 0.31729905027145594) + yOrigin;
         return _loc4_;
      }
      
      public function translateToCell(param1:Vector3d) : Cell
      {
         return this.getCellAt(Math.floor(param1.x / this.tileWidth),Math.floor(param1.y / this.tileWidth),Math.floor(param1.z / this.tileWidth));
      }
      
      public function getCellAt(param1:Number, param2:Number, param3:Number) : Cell
      {
         if(param1 < 0 || param3 < 0 || param1 >= columnsCount || param3 >= rowsCount)
         {
            return null;
         }
         return this.grid[param3 * columnsCount + param1];
      }
      
      public function getCellAtPoint(param1:IntPoint) : Cell
      {
         if(grid == null || param1.x >= columnsCount || param1.y >= rowsCount || param1.x < 0 || param1.y < 0)
         {
            return null;
         }
         return this.grid[param1.y * columnsCount + param1.x];
      }
      
      public function translateStageCoordsTo3DCoords(param1:Number, param2:Number) : Point
      {
         var _loc6_:Number = xOrigin - param1;
         var _loc5_:Number = yOrigin - param2;
         var _loc3_:Number = (_loc6_ / 0.9483255309738488 + _loc5_ / 0.31729905027145594) / 2;
         var _loc4_:Number = (-1 * _loc5_ / 0.31729905027145594 + _loc6_ / 0.9483255309738488) / -2;
         return new Point(_loc4_,_loc3_);
      }
      
      public function getPointAtDir(param1:int, param2:int, param3:int, param4:int) : IntPoint
      {
         if(param1 < 0)
         {
            param1 = 8 + param1;
         }
         if(param1 != 8)
         {
            param1 %= 8;
         }
         var _loc5_:IntPoint = null;
         switch(param1 - 1)
         {
            case 0:
               _loc5_ = new IntPoint(param2 + 1,param4);
               break;
            case 1:
               _loc5_ = new IntPoint(param2 + 1,param4 - 1);
               break;
            case 2:
               _loc5_ = new IntPoint(param2,param4 - 1);
               break;
            case 3:
               _loc5_ = new IntPoint(param2 - 1,param4 - 1);
               break;
            case 4:
               _loc5_ = new IntPoint(param2 - 1,param4);
               break;
            case 5:
               _loc5_ = new IntPoint(param2 - 1,param4 + 1);
               break;
            case 6:
               _loc5_ = new IntPoint(param2,param4 + 1);
               break;
            case 7:
               _loc5_ = new IntPoint(param2 + 1,param4 + 1);
         }
         return _loc5_;
      }
      
      public function get tileWidth() : Number
      {
         return 18;
      }
      
      public function get tileHeight() : Number
      {
         return 18;
      }
      
      public function terminate() : void
      {
         toolbox.dispose();
         Connectr.instance.layerModel.hudLayer.removeChild(toolbox);
         Connectr.instance.layerModel.panelLayer.removeChild(dragContainer);
         if(inventoryPanel)
         {
            if(Connectr.instance.layerModel.hudLayer.contains(inventoryPanel))
            {
               Connectr.instance.layerModel.hudLayer.removeChild(inventoryPanel);
            }
         }
         container.stage.removeEventListener("mouseMove",mouseMoved);
         container.stage.removeEventListener("mouseUp",mouseUp);
         container.stage.removeEventListener("mouseUp",stageMouseUpEvent);
         container.stage.removeEventListener("mouseMove",stageMouseMoveEvent);
         container.removeEventListener("mouseDown",mouseDown);
         container.removeEventListener("rightClick",btnRotateClicked);
         designer.removeEventListener("gestureZoom",onGestureZoom);
         Dispatcher.removeEventListener("RESIZE",onCanvasResize);
         if(elementsContainer != null)
         {
            elementsContainer.removeChildren();
            elementsContainer = null;
         }
         if(floorContainer != null)
         {
            floorContainer.removeChildren();
            floorContainer = null;
         }
         if(dragContainer != null)
         {
            dragContainer.removeChildren();
            dragContainer = null;
         }
         if(container != null)
         {
            container.removeChildren();
            container = null;
         }
         grid = null;
         goods = null;
         items = null;
         mapEntries = [];
         inventoryPanel = null;
         toolbox = null;
         roomloaderInfoList = null;
         currentItem = null;
         designer = null;
      }
   }
}

