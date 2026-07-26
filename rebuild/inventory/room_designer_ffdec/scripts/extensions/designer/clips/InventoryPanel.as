package extensions.designer.clips
{
   import com.greensock.TweenMax;
   import com.oyunstudyosu.combobox.ComboBoxVo;
   import com.oyunstudyosu.events.ComboBoxEvent;
   import com.oyunstudyosu.isodesigner.clips.InventoryPanelUI;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.local.arabic.ArabicInputManager;
   import com.oyunstudyosu.utils.TextFieldManager;
   import extensions.designer.engine.IsoScene;
   import extensions.designer.engine.type.Item;
   import flash.display.Sprite;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import org.oyunstudyosu.components.CoreMovieClip;
   import org.oyunstudyosu.components.combobox.CoreComboBox;
   import org.oyunstudyosu.components.scrollBar.CoreScrollBar;
   
   public class InventoryPanel extends CoreMovieClip
   {
      
      private var scene:IsoScene;
      
      public var scrollBar:CoreScrollBar;
      
      private var ui:InventoryPanelUI;
      
      private var itemContainer:Sprite;
      
      private var invItem:DesignInventoryItem;
      
      private var comboBox:CoreComboBox;
      
      private var searchManager:ArabicInputManager;
      
      public var searchTextField:TextField;
      
      private var searchText:String;
      
      public function InventoryPanel(param1:IsoScene)
      {
         super();
         ui = new InventoryPanelUI();
         searchText = $("Search");
         if(searchTextField == null)
         {
            searchTextField = TextFieldManager.createNoneLanguageTextfield(ui.getChildByName("txtSearch") as TextField);
         }
         if(Sanalika.instance.gameModel.language == "ar")
         {
            searchManager = new ArabicInputManager(searchTextField,searchTextField.defaultTextFormat);
         }
         if(searchManager)
         {
            searchManager.clearText();
            searchManager.addText(searchText);
            searchManager.draw();
         }
         else
         {
            searchTextField.text = searchText;
         }
         addChild(ui);
         this.visible = false;
         this.scene = param1;
         itemContainer = new Sprite();
         itemContainer.x = 22;
         itemContainer.y = 55;
         addChild(itemContainer);
         scrollBar = new CoreScrollBar();
         scrollBar.bar.width = scrollBar.scrollBackground.width = 10;
         scrollBar.barColor = 4149685;
         scrollBar.bgColor = 10463450;
         scrollBar.x = ui.maskContainer.x + ui.maskContainer.width + 8;
         scrollBar.y = ui.maskContainer.y;
         addChild(scrollBar);
         scrollBar.direction = "vertical";
         scrollBar.snap = 100;
         scrollBar.setTarget(itemContainer,ui.maskContainer);
         ui.btnClose.addEventListener("click",close);
         addAll();
         this.visible = true;
         searchTextField.addEventListener("keyUp",searchTextUpdate);
         searchTextField.addEventListener("focusIn",focusInSearch);
         searchTextField.addEventListener("focusOut",focusOutSearch);
         ui.background.addEventListener("mouseDown",onStartDrag);
      }
      
      private function searchTextUpdate(param1:KeyboardEvent) : void
      {
         addAll();
      }
      
      protected function focusOutSearch(param1:FocusEvent) : void
      {
         if(searchManager)
         {
            if(searchManager.getText() == "")
            {
               searchManager.addText(searchText);
            }
            searchManager.draw();
         }
         else if(searchTextField.text == "")
         {
            searchTextField.text = searchText;
         }
      }
      
      protected function focusInSearch(param1:FocusEvent) : void
      {
         if(searchManager)
         {
            searchManager.changeFormat(searchTextField.defaultTextFormat);
            if(searchManager.getText() == searchText)
            {
               searchManager.clearText();
            }
         }
         else if(searchTextField.text == searchText)
         {
            searchTextField.text = "";
         }
      }
      
      private function addAll() : void
      {
         var _loc1_:Item = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = int(scene.items.length);
         if(searchManager)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc1_ = scene.items[_loc4_];
               removeItem(_loc1_);
               if($("pro_" + _loc1_.definition).toLowerCase().indexOf(searchManager.getText().toLowerCase()) > -1 || searchManager.getText() == $("Search") || searchManager.getText() == "")
               {
                  addItem(_loc1_,false);
               }
               _loc4_++;
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc1_ = scene.items[_loc3_];
               removeItem(_loc1_);
               if($("pro_" + _loc1_.definition).toLowerCase().indexOf(searchTextField.text.toLowerCase()) > -1 || searchTextField.text == $("Search") || searchTextField.text == "")
               {
                  addItem(_loc1_,false);
               }
               _loc3_++;
            }
         }
         updateItemPositions();
      }
      
      protected function onStartDrag(param1:MouseEvent) : void
      {
         this.startDrag();
         ui.background.addEventListener("mouseUp",onStopDrag);
      }
      
      protected function onStopDrag(param1:MouseEvent) : void
      {
         this.stopDrag();
         ui.background.removeEventListener("mouseUp",onStopDrag);
      }
      
      public function updateItem(param1:Item) : void
      {
         invItem = getItemByDefinition(param1.definition);
         if(invItem)
         {
            invItem.updateQuantity(param1.idList.length);
         }
         else
         {
            addItem(param1);
         }
      }
      
      private function addComboBoxView() : void
      {
         var _loc5_:ComboBoxVo = null;
         var _loc4_:int = 0;
         var _loc3_:Array = [{
            "label":"Classic",
            "id":0
         },{
            "label":"Date Sorting",
            "id":1
         },{
            "label":"Price Descending",
            "id":2
         },{
            "label":"Price Increasing",
            "id":3
         }];
         var _loc1_:Vector.<ComboBoxVo> = new Vector.<ComboBoxVo>();
         var _loc2_:int = int(_loc3_.length);
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = new ComboBoxVo();
            _loc5_.label = $(_loc3_[_loc4_].label);
            _loc5_.index = _loc3_[_loc4_].id;
            _loc1_.push(_loc5_);
            _loc4_++;
         }
         comboBox = new CoreComboBox("up");
         comboBox.dataProvider = _loc1_;
         comboBox.rowCount = 5;
         addChild(comboBox);
         comboBox.x = 20;
         comboBox.y = 40;
         comboBox.addEventListener("itemSelected",sortCategory);
         comboBox.selectedIndex = 0;
      }
      
      protected function sortCategory(param1:ComboBoxEvent) : void
      {
         trace(comboBox.selectedIndex);
      }
      
      public function addItem(param1:Item, param2:Boolean = true) : void
      {
         invItem = getItemByDefinition(param1.definition);
         if(invItem == null)
         {
            invItem = new DesignInventoryItem(scene,param1);
            itemContainer.addChildAt(invItem,0);
            if(param2)
            {
               updateItemPositions();
            }
         }
      }
      
      public function removeItem(param1:Item) : void
      {
         invItem = getItemByDefinition(param1.definition);
         if(invItem)
         {
            itemContainer.removeChild(invItem);
            updateItemPositions();
         }
      }
      
      public function getItemByDefinition(param1:String) : DesignInventoryItem
      {
         var _loc3_:int = 0;
         var _loc2_:int = itemContainer.numChildren;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            invItem = itemContainer.getChildAt(_loc3_) as DesignInventoryItem;
            if(invItem.item.definition == param1)
            {
               return invItem;
            }
            _loc3_++;
         }
         return null;
      }
      
      public function updateItemPositions() : void
      {
         var num:int = itemContainer.numChildren;
         var i:int = 0;
         while(i < num)
         {
            invItem = itemContainer.getChildAt(i) as DesignInventoryItem;
            invItem.y = 106 * i;
            i = i + 1;
         }
         TweenMax.delayedCall(0,function():void
         {
            scrollBar.containerH = itemContainer.height;
         });
      }
      
      private function close(param1:MouseEvent) : void
      {
         scene.switchInventoryPanel();
      }
      
      override public function removed() : void
      {
         this.removeChildren();
         scene = null;
         scrollBar = null;
         ui.btnClose.removeEventListener("click",close);
         ui.background.removeEventListener("mouseDown",onStartDrag);
         ui = null;
      }
   }
}

