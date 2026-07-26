package feathers.layout
{
   import feathers.core.IValidating;
   import feathers.events.FeathersEvent;
   import flash.Boot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class TiledRowsLayout extends EventDispatcher implements ILayout
   {
      
      public var _verticalGap:Number;
      
      public var _verticalAlign:VerticalAlign;
      
      public var _requestedMinColumnCount:Object;
      
      public var _requestedMaxColumnCount:Object;
      
      public var _requestedColumnCount:Object;
      
      public var _paddingTop:Number;
      
      public var _paddingRight:Number;
      
      public var _paddingLeft:Number;
      
      public var _paddingBottom:Number;
      
      public var _minVerticalGap:Number;
      
      public var _minHorizontalGap:Number;
      
      public var _horizontalGap:Number;
      
      public var _horizontalAlign:HorizontalAlign;
      
      public var _alignEmptyHorizontalTiles:Boolean;
      
      public function TiledRowsLayout()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         _requestedMaxColumnCount = null;
         _requestedMinColumnCount = null;
         _requestedColumnCount = null;
         _alignEmptyHorizontalTiles = false;
         _verticalAlign = VerticalAlign.TOP;
         _horizontalAlign = HorizontalAlign.LEFT;
         _minVerticalGap = 0;
         _verticalGap = 0;
         _minHorizontalGap = 0;
         _horizontalGap = 0;
         _paddingLeft = 0;
         _paddingBottom = 0;
         _paddingRight = 0;
         _paddingTop = 0;

      }
      
      public function validateItems(param1:Array, param2:Measurements) : void
      {
         var _loc4_:* = null as DisplayObject;
         var _loc5_:* = null as ILayoutObject;
         var _loc3_:int = 0;
         while(_loc3_ < int(param1.length))
         {
            _loc4_ = param1[_loc3_];
            _loc3_++;
            if(_loc4_ is ILayoutObject)
            {
               _loc5_ = _loc4_;
               if(!_loc5_.get_includeInLayout())
               {
                  continue;
               }
            }
            if(_loc4_ is IValidating)
            {
               _loc4_.validateNow();
            }
         }
      }
      
      public function set_verticalGap(param1:Number) : Number
      {
         if(_verticalGap == param1)
         {
            return _verticalGap;
         }
         _verticalGap = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _verticalGap;
      }
      
      public function set_verticalAlign(param1:VerticalAlign) : VerticalAlign
      {
         if(_verticalAlign == param1)
         {
            return _verticalAlign;
         }
         _verticalAlign = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _verticalAlign;
      }
      
      public function set_requestedMinColumnCount(param1:Object) : Object
      {
         if(_requestedMinColumnCount == param1)
         {
            return _requestedMinColumnCount;
         }
         _requestedMinColumnCount = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _requestedMinColumnCount;
      }
      
      public function set_requestedMaxColumnCount(param1:Object) : Object
      {
         if(_requestedMaxColumnCount == param1)
         {
            return _requestedMaxColumnCount;
         }
         _requestedMaxColumnCount = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _requestedMaxColumnCount;
      }
      
      public function set_requestedColumnCount(param1:Object) : Object
      {
         if(_requestedColumnCount == param1)
         {
            return _requestedColumnCount;
         }
         _requestedColumnCount = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _requestedColumnCount;
      }
      
      public function set_paddingTop(param1:Number) : Number
      {
         if(_paddingTop == param1)
         {
            return _paddingTop;
         }
         _paddingTop = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _paddingTop;
      }
      
      public function set_paddingRight(param1:Number) : Number
      {
         if(_paddingRight == param1)
         {
            return _paddingRight;
         }
         _paddingRight = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _paddingRight;
      }
      
      public function set_paddingLeft(param1:Number) : Number
      {
         if(_paddingLeft == param1)
         {
            return _paddingLeft;
         }
         _paddingLeft = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _paddingLeft;
      }
      
      public function set_paddingBottom(param1:Number) : Number
      {
         if(_paddingBottom == param1)
         {
            return _paddingBottom;
         }
         _paddingBottom = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _paddingBottom;
      }
      
      public function set_minVerticalGap(param1:Number) : Number
      {
         if(_minVerticalGap == param1)
         {
            return _minVerticalGap;
         }
         _minVerticalGap = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _minVerticalGap;
      }
      
      public function set_minHorizontalGap(param1:Number) : Number
      {
         if(_minHorizontalGap == param1)
         {
            return _minHorizontalGap;
         }
         _minHorizontalGap = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _minHorizontalGap;
      }
      
      public function set_horizontalGap(param1:Number) : Number
      {
         if(_horizontalGap == param1)
         {
            return _horizontalGap;
         }
         _horizontalGap = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _horizontalGap;
      }
      
      public function set_horizontalAlign(param1:HorizontalAlign) : HorizontalAlign
      {
         if(_horizontalAlign == param1)
         {
            return _horizontalAlign;
         }
         _horizontalAlign = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _horizontalAlign;
      }
      
      public function set_alignEmptyHorizontalTiles(param1:Boolean) : Boolean
      {
         if(_alignEmptyHorizontalTiles == param1)
         {
            return _alignEmptyHorizontalTiles;
         }
         _alignEmptyHorizontalTiles = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _alignEmptyHorizontalTiles;
      }
      
      public function setPadding(param1:Number) : void
      {
         set_paddingTop(param1);
         set_paddingRight(param1);
         set_paddingBottom(param1);
         set_paddingLeft(param1);
      }
      
      public function setGap(param1:Number) : void
      {
         set_horizontalGap(param1);
         set_verticalGap(param1);
      }
      
      public function layout(param1:Array, param2:Measurements, param3:LayoutBoundsResult = undefined) : LayoutBoundsResult
      {
         var _loc5_:* = null as DisplayObject;
         var _loc6_:* = null as ILayoutObject;
         var _loc20_:int = 0;
         var _loc25_:Number = NaN;
         if(param3 == null)
         {
            param3 = new LayoutBoundsResult();
         }
         if(int(param1.length) == 0)
         {
            param3.contentX = 0;
            param3.contentY = 0;
            param3.contentWidth = _paddingLeft + _paddingRight;
            param3.contentHeight = _paddingTop + _paddingBottom;
            param3.viewPortWidth = param3.contentWidth;
            param3.viewPortHeight = param3.contentHeight;
            return param3;
         }
         var _loc4_:int = 0;
         while(_loc4_ < int(param1.length))
         {
            _loc5_ = param1[_loc4_];
            _loc4_++;
            if(_loc5_ is ILayoutObject)
            {
               _loc6_ = _loc5_;
               if(!_loc6_.get_includeInLayout())
               {
                  continue;
               }
            }
            if(_loc5_ is IValidating)
            {
               _loc5_.validateNow();
            }
         }
         var _loc7_:Number = 0;
         var _loc8_:Number = 0;
         _loc4_ = 0;
         while(_loc4_ < int(param1.length))
         {
            _loc5_ = param1[_loc4_];
            _loc4_++;
            if(_loc5_ is ILayoutObject)
            {
               _loc6_ = _loc5_;
               if(!_loc6_.get_includeInLayout())
               {
                  continue;
               }
            }
            _loc7_ = Math.max(_loc7_,_loc5_.width);
            _loc8_ = Math.max(_loc8_,_loc5_.height);
         }
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         if(_loc8_ < 0)
         {
            _loc8_ = 0;
         }
         var _loc9_:Number = _horizontalGap;
         var _loc10_:Boolean = _horizontalGap == 1 / 0;
         if(_loc10_)
         {
            _loc9_ = _minHorizontalGap;
         }
         _loc4_ = calculateHorizontalTileCount(_loc7_,param2.width,param2.maxWidth,_loc9_,int(param1.length));
         var _loc11_:Object = param2.width;
         if(_loc11_ == null)
         {
            _loc11_ = _paddingLeft + _paddingRight + _loc4_ * (_loc7_ + _loc9_) - _loc9_;
            if(param2.minWidth != null && _loc11_ < param2.minWidth)
            {
               _loc11_ = param2.minWidth;
            }
            else if(param2.maxWidth != null && _loc11_ > param2.maxWidth)
            {
               _loc11_ = param2.maxWidth;
            }
         }
         var _loc12_:Number = _loc11_ - get_paddingLeft() - get_paddingRight();
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 1;
         var _loc16_:Number = _paddingLeft;
         var _loc17_:Number = _paddingTop;
         var _loc18_:int = 0;
         var _loc19_:int = int(param1.length);
         while(_loc18_ < _loc19_)
         {
            _loc20_ = _loc18_++;
            _loc5_ = param1[_loc20_];
            if(_loc5_ is ILayoutObject)
            {
               _loc6_ = _loc5_;
               if(!_loc6_.get_includeInLayout())
               {
                  continue;
               }
            }
            if(_loc5_.width != _loc7_)
            {
               _loc5_.width = _loc7_;
            }
            if(_loc5_.height != _loc8_)
            {
               _loc5_.height = _loc8_;
            }
            if(_loc14_ >= _loc4_)
            {
               applyHorizontalAlignToRow(param1,_loc20_ - _loc14_,_loc14_,_loc4_,_loc12_,_loc7_);
               _loc16_ = _paddingLeft;
               _loc17_ += _loc8_;
               _loc15_++;
               _loc13_ = int(Math.max(_loc13_,_loc14_));
               _loc14_ = 0;
            }
            _loc5_.x = _loc16_;
            _loc5_.y = _loc17_;
            _loc16_ += _loc7_ + _loc9_;
            _loc14_++;
         }
         applyHorizontalAlignToRow(param1,int(param1.length) - _loc14_,_loc14_,_loc4_,_loc12_,_loc7_);
         _loc13_ = int(Math.max(_loc13_,_loc14_));
         _loc17_ += _loc8_ + get_paddingBottom();
         var _loc21_:Number = _verticalGap;
         var _loc22_:Boolean = _verticalGap == 1 / 0;
         if(_loc22_)
         {
            _loc21_ = _minVerticalGap;
         }
         var _loc23_:Object = param2.height;
         if(_loc23_ == null)
         {
            _loc23_ = _paddingTop + _paddingBottom + _loc15_ * (_loc8_ + _loc21_) - _loc21_;
            if(param2.minHeight != null && _loc23_ < param2.minHeight)
            {
               _loc23_ = param2.minHeight;
            }
            else if(param2.maxHeight != null && _loc23_ > param2.maxHeight)
            {
               _loc23_ = param2.maxHeight;
            }
         }
         var _loc24_:Number = _loc23_ - get_paddingTop() - get_paddingBottom();
         if(_loc22_)
         {
            _loc25_ = _loc15_ * (_loc8_ + _loc21_) - _loc21_;
            if(_loc24_ > _loc25_)
            {
               _loc21_ += (_loc24_ - _loc25_) / (_loc15_ - 1);
            }
         }
         _loc17_ += (_loc15_ - 1) * _loc21_;
         applyVerticalAlignAndGap(param1,_loc23_ - get_paddingTop() - get_paddingBottom(),_loc8_,_loc15_,_loc13_,_loc21_);
         if(param3 == null)
         {
            param3 = new LayoutBoundsResult();
         }
         param3.contentX = 0;
         param3.contentY = 0;
         param3.contentWidth = _loc11_;
         param3.contentHeight = _loc17_;
         param3.viewPortWidth = _loc11_;
         param3.viewPortHeight = _loc23_;
         return param3;
      }
      
      public function get_verticalGap() : Number
      {
         return _verticalGap;
      }
      
      public function get_verticalAlign() : VerticalAlign
      {
         return _verticalAlign;
      }
      
      public function get_requestedMinColumnCount() : Object
      {
         return _requestedMinColumnCount;
      }
      
      public function get_requestedMaxColumnCount() : Object
      {
         return _requestedMaxColumnCount;
      }
      
      public function get_requestedColumnCount() : Object
      {
         return _requestedColumnCount;
      }
      
      public function get_paddingTop() : Number
      {
         return _paddingTop;
      }
      
      public function get_paddingRight() : Number
      {
         return _paddingRight;
      }
      
      public function get_paddingLeft() : Number
      {
         return _paddingLeft;
      }
      
      public function get_paddingBottom() : Number
      {
         return _paddingBottom;
      }
      
      public function get_minVerticalGap() : Number
      {
         return _minVerticalGap;
      }
      
      public function get_minHorizontalGap() : Number
      {
         return _minHorizontalGap;
      }
      
      public function get_horizontalGap() : Number
      {
         return _horizontalGap;
      }
      
      public function get_horizontalAlign() : HorizontalAlign
      {
         return _horizontalAlign;
      }
      
      public function get_alignEmptyHorizontalTiles() : Boolean
      {
         return _alignEmptyHorizontalTiles;
      }
      
      public function calculateHorizontalTileCount(param1:Number, param2:Object, param3:Object, param4:Number, param5:int) : int
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param2 != null)
         {
            _loc6_ = int((param2 - _paddingLeft - _paddingRight + param4) / (param1 + param4));
            if(_requestedColumnCount != null)
            {
               if(_requestedColumnCount > _loc6_)
               {
                  return _loc6_;
               }
               return int(Math.max(1,_requestedColumnCount));
            }
            _loc7_ = _loc6_;
            if(_loc7_ < 1)
            {
               _loc7_ = 1;
            }
            else if(_loc7_ > param5)
            {
               _loc7_ = param5;
            }
            if(_requestedMinColumnCount != null)
            {
               if(_requestedMinColumnCount < _loc7_)
               {
                  return _loc7_;
               }
               return int(Math.max(1,_requestedMinColumnCount));
            }
            if(_requestedMaxColumnCount != null)
            {
               if(_requestedMaxColumnCount > _loc7_)
               {
                  return _loc7_;
               }
               return int(Math.max(1,_requestedMaxColumnCount));
            }
            return _loc7_;
         }
         _loc6_ = param5;
         if(_requestedColumnCount != null)
         {
            _loc6_ = int(Math.max(1,_requestedColumnCount));
         }
         else if(_requestedMinColumnCount != null)
         {
            if(_loc6_ < _requestedMinColumnCount)
            {
               _loc6_ = int(_requestedMinColumnCount);
            }
         }
         else if(_requestedMaxColumnCount != null)
         {
            if(_loc6_ > _requestedMaxColumnCount)
            {
               _loc6_ = int(_requestedMaxColumnCount);
            }
         }
         _loc7_ = 2147483647;
         if(param3 != null && param3 < Number(Math.POSITIVE_INFINITY))
         {
            _loc7_ = int((param3 - _paddingLeft - _paddingRight + param4) / (param1 + param4));
            if(_loc7_ < 1)
            {
               _loc7_ = 1;
            }
         }
         if(_loc6_ > _loc7_)
         {
            _loc6_ = _loc7_;
         }
         if(_loc6_ < 1)
         {
            _loc6_ = 1;
         }
         return _loc6_;
      }
      
      public function applyVerticalAlignAndGap(param1:Array, param2:Number, param3:Number, param4:int, param5:int, param6:Number) : void
      {
         var _loc10_:Number = NaN;
         var _loc14_:int = 0;
         var _loc15_:* = null as DisplayObject;
         var _loc16_:* = null as ILayoutObject;
         var _loc7_:Number = 0;
         var _loc8_:Number = param6;
         var _loc9_:Boolean = _verticalGap == 1 / 0;
         if(!_loc9_)
         {
            _loc10_ = param4 * (param3 + param6) - param6;
            switch(_verticalAlign.index)
            {
               case 0:
                  _loc7_ = 0;
                  break;
               case 1:
                  _loc7_ = (param2 - _loc10_) / 2;
                  break;
               case 2:
                  _loc7_ = param2 - _loc10_;
                  break;
               default:
                  throw new ArgumentError("Unknown vertical align: " + Std.string(_verticalAlign));
            }
            if(_loc7_ < 0)
            {
               _loc7_ = 0;
            }
         }
         if(_loc7_ == 0 && _loc8_ == 0)
         {
            return;
         }
         _loc10_ = _loc7_;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = int(param1.length);
         while(_loc12_ < _loc13_)
         {
            _loc14_ = _loc12_++;
            _loc15_ = param1[_loc14_];
            if(_loc15_ is ILayoutObject)
            {
               _loc16_ = _loc15_;
               if(!_loc16_.get_includeInLayout())
               {
                  continue;
               }
            }
            if(_loc11_ > 0 && int(_loc11_ % param5) == 0)
            {
               _loc10_ += _loc8_;
            }
            _loc15_.y += _loc10_;
            _loc11_++;
         }
      }
      
      public function applyHorizontalAlignToRow(param1:Array, param2:int, param3:int, param4:int, param5:Number, param6:Number) : void
      {
         var _loc11_:Number = NaN;
         var _loc15_:int = 0;
         var _loc16_:* = null as DisplayObject;
         var _loc17_:* = null as ILayoutObject;
         if(_alignEmptyHorizontalTiles && param4 > param3)
         {
            param3 = param4;
         }
         var _loc7_:Number = 0;
         var _loc8_:Number = 0;
         var _loc9_:Number = _horizontalGap;
         var _loc10_:Boolean = _horizontalGap == 1 / 0;
         if(_loc10_)
         {
            _loc9_ = _minHorizontalGap;
            _loc11_ = param3 * (param6 + _loc9_);
            if(param3 > 0)
            {
               _loc11_ -= _loc9_;
            }
            if(param3 > 1 && param5 > _loc11_)
            {
               _loc9_ += (param5 - _loc11_) / (param3 - 1);
            }
            _loc8_ = _loc9_ - _minHorizontalGap;
         }
         else
         {
            _loc11_ = param3 * (param6 + _loc9_);
            if(param3 > 0)
            {
               _loc11_ -= _loc9_;
            }
            switch(_horizontalAlign.index)
            {
               case 0:
                  _loc7_ = 0;
                  break;
               case 1:
                  _loc7_ = (param5 - _loc11_) / 2;
                  break;
               case 2:
                  _loc7_ = param5 - _loc11_;
                  break;
               default:
                  throw new ArgumentError("Unknown horizontal align: " + Std.string(_horizontalAlign));
            }
            if(_loc7_ < 0)
            {
               _loc7_ = 0;
            }
         }
         if(_loc7_ == 0 && _loc8_ == 0)
         {
            return;
         }
         _loc11_ = _loc7_;
         var _loc12_:int = param2 + param3;
         if(_loc12_ > int(param1.length))
         {
            _loc12_ = int(param1.length);
         }
         var _loc13_:int = param2;
         var _loc14_:int = _loc12_;
         while(_loc13_ < _loc14_)
         {
            _loc15_ = _loc13_++;
            _loc16_ = param1[_loc15_];
            if(_loc16_ is ILayoutObject)
            {
               _loc17_ = _loc16_;
               if(!_loc17_.get_includeInLayout())
               {
                  continue;
               }
            }
            _loc16_.x += _loc11_;
            _loc11_ += _loc8_;
         }
      }
   }
}

