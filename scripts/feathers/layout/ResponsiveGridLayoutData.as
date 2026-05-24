package feathers.layout
{
   import feathers.events.FeathersEvent;
   import flash.Boot;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class ResponsiveGridLayoutData extends EventDispatcher implements ILayoutData
   {
      
      public var _xxlSpan:int;
      
      public var _xxlOffset:int;
      
      public var _xxlDisplay:Object;
      
      public var _xlSpan:int;
      
      public var _xlOffset:int;
      
      public var _xlDisplay:Object;
      
      public var _span:int;
      
      public var _smSpan:int;
      
      public var _smOffset:int;
      
      public var _smDisplay:Object;
      
      public var _offset:int;
      
      public var _mdSpan:int;
      
      public var _mdOffset:int;
      
      public var _mdDisplay:Object;
      
      public var _lgSpan:int;
      
      public var _lgOffset:int;
      
      public var _lgDisplay:Object;
      
      public var _display:Boolean;
      
      public function ResponsiveGridLayoutData(param1:int = 1, param2:int = 0, param3:int = -1, param4:int = -1, param5:int = -1, param6:int = -1, param7:int = -1, param8:int = -1, param9:int = -1, param10:int = -1)
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         _xxlDisplay = null;
         _xxlOffset = -1;
         _xxlSpan = -1;
         _xlDisplay = null;
         _xlOffset = -1;
         _xlSpan = -1;
         _lgDisplay = null;
         _lgOffset = -1;
         _lgSpan = -1;
         _mdDisplay = null;
         _mdOffset = -1;
         _mdSpan = -1;
         _smDisplay = null;
         _smOffset = -1;
         _smSpan = -1;
         _display = true;
         _offset = 0;
         _span = 1;

         set_span(param1);
         set_offset(param2);
         set_smSpan(param3);
         set_smOffset(param4);
         set_mdSpan(param5);
         set_mdOffset(param6);
         set_lgSpan(param7);
         set_lgOffset(param8);
         set_xlSpan(param9);
         set_xlOffset(param10);
      }
      
      public function set_xxlSpan(param1:int) : int
      {
         if(_xxlSpan == param1)
         {
            return _xxlSpan;
         }
         _xxlSpan = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _xxlSpan;
      }
      
      public function set xxlSpan(param1:int) : void
      {
         set_xxlSpan(param1);
      }
      
      public function set_xxlOffset(param1:int) : int
      {
         if(_xxlOffset == param1)
         {
            return _xxlOffset;
         }
         _xxlOffset = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _xxlOffset;
      }
      
      public function set xxlOffset(param1:int) : void
      {
         set_xxlOffset(param1);
      }
      
      public function set_xxlDisplay(param1:Object) : Object
      {
         if(_xxlDisplay == param1)
         {
            return _xxlDisplay;
         }
         _xxlDisplay = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _xxlDisplay;
      }
      
      public function set xxlDisplay(param1:Object) : void
      {
         set_xxlDisplay(param1);
      }
      
      public function set_xlSpan(param1:int) : int
      {
         if(_xlSpan == param1)
         {
            return _xlSpan;
         }
         _xlSpan = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _xlSpan;
      }
      
      public function set_xlOffset(param1:int) : int
      {
         if(_xlOffset == param1)
         {
            return _xlOffset;
         }
         _xlOffset = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _xlOffset;
      }
      
      public function set_xlDisplay(param1:Object) : Object
      {
         if(_xlDisplay == param1)
         {
            return _xlDisplay;
         }
         _xlDisplay = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _xlDisplay;
      }
      
      public function set xlDisplay(param1:Object) : void
      {
         set_xlDisplay(param1);
      }
      
      public function set_span(param1:int) : int
      {
         if(param1 <= 0)
         {
            throw new ArgumentError("span must be greater than 0");
         }
         if(_span == param1)
         {
            return _span;
         }
         _span = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _span;
      }
      
      public function set_smSpan(param1:int) : int
      {
         if(_smSpan == param1)
         {
            return _smSpan;
         }
         _smSpan = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _smSpan;
      }
      
      public function set_smOffset(param1:int) : int
      {
         if(_smOffset == param1)
         {
            return _smOffset;
         }
         _smOffset = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _smOffset;
      }
      
      public function set_smDisplay(param1:Object) : Object
      {
         if(_smDisplay == param1)
         {
            return _smDisplay;
         }
         _smDisplay = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _smDisplay;
      }
      
      public function set smDisplay(param1:Object) : void
      {
         set_smDisplay(param1);
      }
      
      public function set_offset(param1:int) : int
      {
         if(_offset == param1)
         {
            return _offset;
         }
         _offset = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _offset;
      }
      
      public function set_mdSpan(param1:int) : int
      {
         if(_mdSpan == param1)
         {
            return _mdSpan;
         }
         _mdSpan = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _mdSpan;
      }
      
      public function set_mdOffset(param1:int) : int
      {
         if(_mdOffset == param1)
         {
            return _mdOffset;
         }
         _mdOffset = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _mdOffset;
      }
      
      public function set_mdDisplay(param1:Object) : Object
      {
         if(_mdDisplay == param1)
         {
            return _mdDisplay;
         }
         _mdDisplay = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _mdDisplay;
      }
      
      public function set mdDisplay(param1:Object) : void
      {
         set_mdDisplay(param1);
      }
      
      public function set_lgSpan(param1:int) : int
      {
         if(_lgSpan == param1)
         {
            return _lgSpan;
         }
         _lgSpan = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _lgSpan;
      }
      
      public function set_lgOffset(param1:int) : int
      {
         if(_lgOffset == param1)
         {
            return _lgOffset;
         }
         _lgOffset = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _lgOffset;
      }
      
      public function set_lgDisplay(param1:Object) : Object
      {
         if(_lgDisplay == param1)
         {
            return _lgDisplay;
         }
         _lgDisplay = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _lgDisplay;
      }
      
      public function set lgDisplay(param1:Object) : void
      {
         set_lgDisplay(param1);
      }
      
      public function set_display(param1:Boolean) : Boolean
      {
         if(_display == param1)
         {
            return _display;
         }
         _display = param1;
         FeathersEvent.dispatch(this,Event.CHANGE);
         return _display;
      }
      
      public function set display(param1:Boolean) : void
      {
         set_display(param1);
      }
      
      public function get_xxlSpan() : int
      {
         return _xxlSpan;
      }
      
      public function get xxlSpan() : int
      {
         return get_xxlSpan();
      }
      
      public function get_xxlOffset() : int
      {
         return _xxlOffset;
      }
      
      public function get xxlOffset() : int
      {
         return get_xxlOffset();
      }
      
      public function get_xxlDisplay() : Object
      {
         return _xxlDisplay;
      }
      
      public function get xxlDisplay() : Object
      {
         return get_xxlDisplay();
      }
      
      public function get_xlSpan() : int
      {
         return _xlSpan;
      }
      
      public function get_xlOffset() : int
      {
         return _xlOffset;
      }
      
      public function get_xlDisplay() : Object
      {
         return _xlDisplay;
      }
      
      public function get xlDisplay() : Object
      {
         return get_xlDisplay();
      }
      
      public function get_span() : int
      {
         return _span;
      }
      
      public function get_smSpan() : int
      {
         return _smSpan;
      }
      
      public function get_smOffset() : int
      {
         return _smOffset;
      }
      
      public function get_smDisplay() : Object
      {
         return _smDisplay;
      }
      
      public function get smDisplay() : Object
      {
         return get_smDisplay();
      }
      
      public function get_offset() : int
      {
         return _offset;
      }
      
      public function get_mdSpan() : int
      {
         return _mdSpan;
      }
      
      public function get_mdOffset() : int
      {
         return _mdOffset;
      }
      
      public function get_mdDisplay() : Object
      {
         return _mdDisplay;
      }
      
      public function get mdDisplay() : Object
      {
         return get_mdDisplay();
      }
      
      public function get_lgSpan() : int
      {
         return _lgSpan;
      }
      
      public function get_lgOffset() : int
      {
         return _lgOffset;
      }
      
      public function get_lgDisplay() : Object
      {
         return _lgDisplay;
      }
      
      public function get lgDisplay() : Object
      {
         return get_lgDisplay();
      }
      
      public function get_display() : Boolean
      {
         return _display;
      }
      
      public function get display() : Boolean
      {
         return get_display();
      }
      
      public function getSpan(param1:Breakpoint) : int
      {
         switch(param1.index)
         {
            case 0:
               return _span;
            case 1:
               if(_smSpan == -1)
               {
                  return getSpan(Breakpoint.XS);
               }
               return _smSpan;
               break;
            case 2:
               if(_mdSpan == -1)
               {
                  return getSpan(Breakpoint.SM);
               }
               return _mdSpan;
               break;
            case 3:
               if(_lgSpan == -1)
               {
                  return getSpan(Breakpoint.MD);
               }
               return _lgSpan;
               break;
            case 4:
               if(_xlSpan == -1)
               {
                  return getSpan(Breakpoint.LG);
               }
               return _xlSpan;
               break;
            case 5:
               if(_xxlSpan == -1)
               {
                  return getSpan(Breakpoint.XL);
               }
               return _xxlSpan;
               break;
            default:
               return;
         }
      }
      
      public function getOffset(param1:Breakpoint) : int
      {
         switch(param1.index)
         {
            case 0:
               return _offset;
            case 1:
               if(_smOffset == -1)
               {
                  return getOffset(Breakpoint.XS);
               }
               return _smOffset;
               break;
            case 2:
               if(_mdOffset == -1)
               {
                  return getOffset(Breakpoint.SM);
               }
               return _mdOffset;
               break;
            case 3:
               if(_lgOffset == -1)
               {
                  return getOffset(Breakpoint.MD);
               }
               return _lgOffset;
               break;
            case 4:
               if(_xlOffset == -1)
               {
                  return getOffset(Breakpoint.LG);
               }
               return _xlOffset;
               break;
            case 5:
               if(_xxlOffset == -1)
               {
                  return getOffset(Breakpoint.XL);
               }
               return _xxlOffset;
               break;
            default:
               return;
         }
      }
      
      public function getDisplay(param1:Breakpoint) : Boolean
      {
         switch(param1.index)
         {
            case 0:
               return _display;
            case 1:
               if(_smDisplay == null)
               {
                  return getDisplay(Breakpoint.XS);
               }
               return _smDisplay;
               break;
            case 2:
               if(_mdDisplay == null)
               {
                  return getDisplay(Breakpoint.SM);
               }
               return _mdDisplay;
               break;
            case 3:
               if(_lgDisplay == null)
               {
                  return getDisplay(Breakpoint.MD);
               }
               return _lgDisplay;
               break;
            case 4:
               if(_xlDisplay == null)
               {
                  return getDisplay(Breakpoint.LG);
               }
               return _xlDisplay;
               break;
            case 5:
               if(_xxlDisplay == null)
               {
                  return getDisplay(Breakpoint.XL);
               }
               return _xxlDisplay;
               break;
            default:
               return;
         }
      }
   }
}

