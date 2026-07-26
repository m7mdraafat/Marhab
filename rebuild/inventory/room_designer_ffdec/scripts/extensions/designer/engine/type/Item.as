package extensions.designer.engine.type
{
   public class Item
   {
      
      public var definition:String;
      
      public var furnLocation:int;
      
      public var width:Number;
      
      public var height:Number;
      
      public var depth:Number;
      
      public var fixed:int;
      
      public var locked:int;
      
      public var stock:int;
      
      public var quantity:int;
      
      public var idList:Array;
      
      public var entryType:int;
      
      public var version:int;
      
      private var itemObj:Object;
      
      public function Item(param1:Object)
      {
         super();
         this.idList = param1.idList;
         this.definition = param1.clip;
         this.furnLocation = param1.fLoc;
         this.width = param1.width;
         this.height = param1.hight;
         this.depth = param1.depth;
         this.fixed = param1.fixed;
         this.locked = param1.locked;
         this.stock = param1.stock;
         this.quantity = idList.length;
         this.version = param1.v;
         this.entryType = param1.entryType;
         itemObj = param1;
      }
      
      public static function createItem(param1:Good, param2:int) : Item
      {
         return new Item({
            "clip":param1.definition,
            "idList":[param1.id],
            "entryType":param1.entryType,
            "fLoc":param2,
            "width":param1.width,
            "height":param1.height,
            "depth":param1.depth,
            "dirs":param1.directions,
            "v":param1.version
         });
      }
      
      public function push(param1:Number) : void
      {
         idList.push(param1);
         quantity = idList.length;
      }
      
      public function shift() : Number
      {
         var _loc1_:Number = idList.shift();
         quantity = idList.length;
         return _loc1_;
      }
      
      public function clone() : Item
      {
         return new Item(itemObj);
      }
   }
}

