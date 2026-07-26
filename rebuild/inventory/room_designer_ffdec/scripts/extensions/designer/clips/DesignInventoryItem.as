package extensions.designer.clips
{
   import com.oyunstudyosu.assets.AssetRequest;
   import com.oyunstudyosu.assets.IAssetRequest;
   import com.oyunstudyosu.furniture.FurnitureData;
   import com.oyunstudyosu.isodesigner.clips.DesignInventoryItemUI;
   import com.oyunstudyosu.local.$;
   import de.polygonal.core.fmt.Sprintf;
   import extensions.designer.engine.IsoScene;
   import extensions.designer.engine.type.Item;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.System;
   import org.oyunstudyosu.assets.clips.NoPic;
   
   public class DesignInventoryItem extends Sprite
   {
      
      private var holder:DesignInventoryItemUI;
      
      private var scene:IsoScene;
      
      public var item:Item;
      
      private var tipContainer:MovieClip;
      
      private var tip:Sprite;
      
      public var noPic:NoPic;
      
      public function DesignInventoryItem(param1:IsoScene, param2:Item)
      {
         super();
         this.scene = param1;
         this.item = param2;
         holder = new DesignInventoryItemUI();
         this.addChild(holder);
         holder.mouseChildren = false;
         tipContainer = new MovieClip();
         this.addChild(tipContainer);
         addClip(param2);
         this.addEventListener("rollOver",overProduct);
      }
      
      private function addClip(param1:Item) : void
      {
         holder.addEventListener("mouseDown",scene.newGoodClicked);
         var _loc2_:* = new AssetRequest();
         _loc2_.assetId = "/static/items/furnitures/r_" + param1.definition + ".png";
         _loc2_.type = "ModuleType.PNG";
         _loc2_.loadedFunction = onLoaded;
         _loc2_.errorFunction = onError;
         _loc2_.priority = 99;
         Sanalika.instance.assetModel.request(_loc2_);
         holder.definition = param1.definition;
         if(param1.quantity > 1)
         {
            holder.quantity.visible = true;
            holder.quantity.lbl.text = param1.quantity;
         }
         else
         {
            holder.quantity.visible = false;
         }
      }
      
      private function onLoaded(param1:IAssetRequest) : void
      {
         var _loc2_:Bitmap = param1.display as Bitmap;
         _loc2_.x = -(_loc2_.width / 2);
         _loc2_.y = -(_loc2_.height / 2);
         holder.container.addChild(_loc2_);
      }
      
      private function onError(param1:IAssetRequest) : void
      {
         noPic = new NoPic();
         noPic.txtInfo.text = "Not Found\n" + $("pro_" + item.definition) + "\n[" + item.definition + "]";
         holder.container.addChild(noPic);
      }
      
      protected function overProduct(param1:MouseEvent) : void
      {
         var _loc2_:Array = FurnitureData.getFlatFurnitureTypes([item.furnLocation]);
         Sanalika.instance.toolTipModel.showTip(this.parent.parent,Sprintf.format($("pro_" + item.definition) + "\n" + $("usableFurnLocations"),[FurnitureData.getStringValue(_loc2_)]));
         if(param1.ctrlKey)
         {
            System.setClipboard(item.definition);
         }
      }
      
      public function updateQuantity(param1:int) : void
      {
         if(param1 > 1)
         {
            holder.quantity.visible = true;
            holder.quantity.lbl.text = param1;
         }
         else
         {
            holder.quantity.visible = false;
         }
      }
      
      public function dispose() : void
      {
         this.removeEventListener("rollOver",overProduct);
      }
   }
}

