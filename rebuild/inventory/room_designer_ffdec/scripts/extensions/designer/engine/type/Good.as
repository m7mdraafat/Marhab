package extensions.designer.engine.type
{
   public class Good
   {
      
      public var definition:String;
      
      public var width:Number;
      
      public var height:Number;
      
      public var depth:Number;
      
      public var directions:Array;
      
      public var dimensions:Array;
      
      public var id:Number;
      
      public var entryType:int;
      
      public var version:int;
      
      public function Good(param1:String, param2:Array, param3:Array, param4:int, param5:int)
      {
         super();
         this.definition = param1;
         this.width = param2[0];
         this.height = param2[1];
         this.depth = param2[2];
         this.directions = param3;
         this.dimensions = param2;
         this.entryType = param4;
         this.version = param5;
      }
      
      public function clone() : Good
      {
         var _loc1_:Good = new Good(this.definition,this.dimensions,this.directions,this.entryType,this.version);
         _loc1_.id = this.id;
         return _loc1_;
      }
   }
}

