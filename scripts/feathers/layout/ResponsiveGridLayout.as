package feathers.layout
{
   import feathers.core.IMeasureObject;
   import feathers.core.IValidating;
   import feathers.events.FeathersEvent;
   import flash.Boot;
   import flash.display.DisplayObject;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class ResponsiveGridLayout extends EventDispatcher implements ILayout
   {
      
      public var _xxl:Number;
      
      public var _xl:Number;
      
      public var _sm:Number;
      
      public var _rowVerticalAlign:VerticalAlign;
      
      public var _rowItems:Array;
      
      public var _rowGap:Number;
      
      public var _paddingTop:Number;
      
      public var _paddingRight:Number;
      
      public var _paddingLeft:Number;
      
      public var _paddingBottom:Number;
      
      public var _md:Number;
      
      public var _lg:Number;
      
      public var _justifyResetEnabled:Boolean;
      
      public var _columnGap:Number;
      
      public var _columnCount:int;
      
      public function ResponsiveGridLayout(param1:int = 12, param2:Number = 576, param3:Number = 768, param4:Number = 992, param5:Number = 1200, param6:Number = 1400)
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         _rowItems = [];
         _justifyResetEnabled = false;
         _rowVerticalAlign = VerticalAlign.TOP;
         _paddingLeft = 0;
         _paddingBottom = 0;
         _paddingRight = 0;
         _paddingTop = 0;
         _columnGap = 0;
         _rowGap = 0;
         _xxl = 1400;
         _xl = 1200;
         _lg = 992;
         _md = 768;
         _sm = 576;

         _columnCount = param1;
         _sm = param2;
         _md = param3;
         _lg = param4;
         _xl = param5;
         _xxl = param6;
      }
      
      public function set_xxl(param1:Number) : Number
      {
         if(_xxl == param1)
         {
            return _xxl;
         }
         _xxl = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _xxl;
      }
      
      public function set xxl(param1:Number) : void
      {
         set_xxl(param1);
      }
      
      public function set_xl(param1:Number) : Number
      {
         if(_xl == param1)
         {
            return _xl;
         }
         _xl = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _xl;
      }
      
      public function set_sm(param1:Number) : Number
      {
         if(_sm == param1)
         {
            return _sm;
         }
         _sm = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _sm;
      }
      
      public function set_rowVerticalAlign(param1:VerticalAlign) : VerticalAlign
      {
         if(_rowVerticalAlign == param1)
         {
            return _rowVerticalAlign;
         }
         _rowVerticalAlign = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _rowVerticalAlign;
      }
      
      public function set_rowGap(param1:Number) : Number
      {
         if(_rowGap == param1)
         {
            return _rowGap;
         }
         _rowGap = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _rowGap;
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
      
      public function set_md(param1:Number) : Number
      {
         if(_md == param1)
         {
            return _md;
         }
         _md = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _md;
      }
      
      public function set_lg(param1:Number) : Number
      {
         if(_lg == param1)
         {
            return _lg;
         }
         _lg = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _lg;
      }
      
      public function set_justifyResetEnabled(param1:Boolean) : Boolean
      {
         if(_justifyResetEnabled == param1)
         {
            return _justifyResetEnabled;
         }
         _justifyResetEnabled = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _justifyResetEnabled;
      }
      
      public function set_columnGap(param1:Number) : Number
      {
         if(_columnGap == param1)
         {
            return _columnGap;
         }
         _columnGap = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _columnGap;
      }
      
      public function set_columnCount(param1:int) : int
      {
         if(_columnCount == param1)
         {
            return _columnCount;
         }
         _columnCount = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _columnCount;
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
         set_columnGap(param1);
         set_rowGap(param1);
      }
      
      public function positionItem(param1:DisplayObject, param2:int, param3:int, param4:Number, param5:Number) : void
      {
         param1.x = _paddingLeft + (param3 != 0 ? (param4 + _columnGap) * param3 : 0);
         param1.y = param5;
         param1.width = param2 != 0 ? (param4 + _columnGap) * param2 - _columnGap : param4;
         if(_rowVerticalAlign == VerticalAlign.JUSTIFY && _justifyResetEnabled && param1 is IMeasureObject)
         {
            param1.resetHeight();
         }
         if(param1 is IValidating)
         {
            param1.validateNow();
         }
      }
      
      public function layoutItems(param1:Array, param2:Number) : Number
      {
         var _loc10_:* = null as DisplayObject;
         var _loc11_:* = null as ILayoutObject;
         var _loc12_:Boolean = false;
         var _loc13_:* = null as ILayoutData;
         var _loc14_:* = null as ResponsiveGridLayoutData;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc3_:Breakpoint = getBreakpoint(param2);
         var _loc4_:Number = param2 - _paddingLeft - _paddingRight;
         var _loc5_:Number = (_loc4_ + _columnGap) / _columnCount - _columnGap;
         var _loc6_:int = 0;
         var _loc7_:Number = _paddingTop;
         var _loc8_:Number = 0;
         _rowItems.resize(0);
         var _loc9_:int = 0;
         while(_loc9_ < int(param1.length))
         {
            _loc10_ = param1[_loc9_];
            _loc9_++;
            if(_loc10_ is ILayoutObject)
            {
               _loc11_ = _loc10_;
               if(!_loc11_.get_includeInLayout())
               {
                  continue;
               }
            }
            if(!(_loc10_ is ILayoutObject))
            {
               _loc12_ = true;
            }
            else
            {
               _loc11_ = _loc10_;
               _loc13_ = _loc11_.get_layoutData();
               _loc14_ = _loc13_ as ResponsiveGridLayoutData;
               _loc12_ = _loc14_ == null ? true : _loc14_.getDisplay(_loc3_);
            }
            _loc10_.visible = _loc12_;
            if(_loc12_)
            {
               if(!(_loc10_ is ILayoutObject))
               {
                  _loc15_ = 1;
               }
               else
               {
                  _loc11_ = _loc10_;
                  if(!_loc11_.get_includeInLayout())
                  {
                     _loc15_ = 0;
                  }
                  else
                  {
                     _loc13_ = _loc11_.get_layoutData();
                     _loc14_ = _loc13_ as ResponsiveGridLayoutData;
                     if(_loc14_ == null)
                     {
                        _loc15_ = 1;
                     }
                     else
                     {
                        _loc16_ = _loc14_.getSpan(_loc3_);
                        _loc15_ = _loc16_ > _columnCount ? _columnCount : _loc16_;
                     }
                  }
               }
               if(!(_loc10_ is ILayoutObject))
               {
                  _loc16_ = 0;
               }
               else
               {
                  _loc11_ = _loc10_;
                  if(!_loc11_.get_includeInLayout())
                  {
                     _loc16_ = 0;
                  }
                  else
                  {
                     _loc13_ = _loc11_.get_layoutData();
                     _loc14_ = _loc13_ as ResponsiveGridLayoutData;
                     if(_loc14_ == null)
                     {
                        _loc16_ = 0;
                     }
                     else
                     {
                        _loc17_ = _loc14_.getOffset(_loc3_);
                        _loc18_ = _columnCount - _loc15_;
                        _loc16_ = _loc17_ > _loc18_ ? _loc18_ : _loc17_;
                     }
                  }
               }
               if(_loc6_ + _loc16_ + _loc15_ > _columnCount)
               {
                  alignRow(_loc7_,_loc8_);
                  _rowItems.resize(0);
                  _loc6_ = 0;
                  _loc7_ += _loc8_ + _rowGap;
                  _loc8_ = 0;
               }
               _loc6_ += _loc16_;
               _loc10_.x = _paddingLeft + (_loc6_ != 0 ? (_loc5_ + _columnGap) * _loc6_ : 0);
               _loc10_.y = _loc7_;
               _loc10_.width = _loc15_ != 0 ? (_loc5_ + _columnGap) * _loc15_ - _columnGap : _loc5_;
               if(_rowVerticalAlign == VerticalAlign.JUSTIFY && _justifyResetEnabled && _loc10_ is IMeasureObject)
               {
                  _loc10_.resetHeight();
               }
               if(_loc10_ is IValidating)
               {
                  _loc10_.validateNow();
               }
               _loc6_ += _loc15_;
               _loc8_ = Math.max(_loc8_,_loc10_.height);
               _rowItems.push(_loc10_);
            }
         }
         alignRow(_loc7_,_loc8_);
         _rowItems.resize(0);
         if(_loc8_ == 0)
         {
            _loc7_ -= _rowGap;
         }
         return _loc7_ + _loc8_ + _paddingBottom;
      }
      
      public function layout(param1:Array, param2:Measurements, param3:LayoutBoundsResult = undefined) : LayoutBoundsResult
      {
         if(_xxl < _xl)
         {
            throw new IllegalOperationError("xxl must be greater than xl");
         }
         if(_xl < _lg)
         {
            throw new IllegalOperationError("xl must be greater than lg");
         }
         if(_lg < _md)
         {
            throw new IllegalOperationError("lg must be greater than md");
         }
         if(_md < _sm)
         {
            throw new IllegalOperationError("md must be greater than sm");
         }
         var _loc4_:Object = param2.width != null ? param2.width : _md;
         var _loc5_:Number = layoutItems(param1,_loc4_);
         var _loc6_:Number = _loc5_;
         if(param2.height != null)
         {
            _loc6_ = Number(param2.height);
         }
         if(param3 == null)
         {
            param3 = new LayoutBoundsResult();
         }
         param3.contentX = 0;
         param3.contentY = 0;
         param3.contentWidth = _loc4_;
         param3.contentHeight = _loc5_;
         param3.viewPortWidth = _loc4_;
         param3.viewPortHeight = _loc6_;
         return param3;
      }
      
      public function get_xxl() : Number
      {
         return _xxl;
      }
      
      public function get xxl() : Number
      {
         return get_xxl();
      }
      
      public function get_xl() : Number
      {
         return _xl;
      }
      
      public function get_sm() : Number
      {
         return _sm;
      }
      
      public function get_rowVerticalAlign() : VerticalAlign
      {
         return _rowVerticalAlign;
      }
      
      public function get_rowGap() : Number
      {
         return _rowGap;
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
      
      public function get_md() : Number
      {
         return _md;
      }
      
      public function get_lg() : Number
      {
         return _lg;
      }
      
      public function get_justifyResetEnabled() : Boolean
      {
         return _justifyResetEnabled;
      }
      
      public function get_columnGap() : Number
      {
         return _columnGap;
      }
      
      public function get_columnCount() : int
      {
         return _columnCount;
      }
      
      public function getSpan(param1:DisplayObject, param2:Breakpoint) : int
      {
         if(!(param1 is ILayoutObject))
         {
            return 1;
         }
         var _loc3_:ILayoutObject = param1;
         if(!_loc3_.get_includeInLayout())
         {
            return 0;
         }
         var _loc4_:ILayoutData = _loc3_.get_layoutData();
         var _loc5_:ResponsiveGridLayoutData = _loc4_ as ResponsiveGridLayoutData;
         if(_loc5_ == null)
         {
            return 1;
         }
         var _loc6_:int = _loc5_.getSpan(param2);
         if(_loc6_ > _columnCount)
         {
            return _columnCount;
         }
         return _loc6_;
      }
      
      public function getOffset(param1:DisplayObject, param2:int, param3:Breakpoint) : int
      {
         if(!(param1 is ILayoutObject))
         {
            return 0;
         }
         var _loc4_:ILayoutObject = param1;
         if(!_loc4_.get_includeInLayout())
         {
            return 0;
         }
         var _loc5_:ILayoutData = _loc4_.get_layoutData();
         var _loc6_:ResponsiveGridLayoutData = _loc5_ as ResponsiveGridLayoutData;
         if(_loc6_ == null)
         {
            return 0;
         }
         var _loc7_:int = _loc6_.getOffset(param3);
         var _loc8_:int = _columnCount - param2;
         if(_loc7_ > _loc8_)
         {
            return _loc8_;
         }
         return _loc7_;
      }
      
      public function getDisplay(param1:DisplayObject, param2:Breakpoint) : Boolean
      {
         if(!(param1 is ILayoutObject))
         {
            return true;
         }
         var _loc3_:ILayoutObject = param1;
         var _loc4_:ILayoutData = _loc3_.get_layoutData();
         var _loc5_:ResponsiveGridLayoutData = _loc4_ as ResponsiveGridLayoutData;
         if(_loc5_ == null)
         {
            return true;
         }
         return _loc5_.getDisplay(param2);
      }
      
      public function getBreakpoint(param1:Number) : Breakpoint
      {
         if(param1 >= _xxl)
         {
            return Breakpoint.XXL;
         }
         if(param1 >= _xl)
         {
            return Breakpoint.XL;
         }
         if(param1 >= _lg)
         {
            return Breakpoint.LG;
         }
         if(param1 >= _md)
         {
            return Breakpoint.MD;
         }
         if(param1 >= _sm)
         {
            return Breakpoint.SM;
         }
         return Breakpoint.XS;
      }
      
      public function alignRow(param1:Number, param2:Number) : void
      {
         var _loc5_:* = null as DisplayObject;
         var _loc3_:int = 0;
         var _loc4_:Array = _rowItems;
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            switch(_rowVerticalAlign.index)
            {
               case 0:
                  _loc5_.y = param1;
                  break;
               case 1:
                  _loc5_.y = param1 + (param2 - _loc5_.height) / 2;
                  break;
               case 2:
                  _loc5_.y = param1 + param2 - _loc5_.height;
                  break;
               case 3:
                  _loc5_.y = param1;
                  if(_loc5_.height != param2)
                  {
                     _loc5_.height = param2;
                  }
            }
         }
      }
   }
}

