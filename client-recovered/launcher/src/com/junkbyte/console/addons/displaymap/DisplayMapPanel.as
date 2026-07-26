package com.junkbyte.console.addons.displaymap
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.view.ConsolePanel;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Dictionary;
   
   public class DisplayMapPanel extends ConsolePanel
   {
      
      public static const NAME:String = "displayMapPanel";
      
      public static var numOfFramesToUpdate:uint = 10;
      
      private var rootDisplay:DisplayObject;
      
      private var mapIndex:uint;
      
      private var indexToDisplayMap:Object;
      
      private var openings:Dictionary;
      
      private var framesSinceUpdate:uint;
      
      public function DisplayMapPanel(param1:Console)
      {
         super(param1);
         name = NAME;
         init(60,100,false);
         txtField = makeTF("mapPrints");
         txtField.multiline = true;
         txtField.autoSize = TextFieldAutoSize.LEFT;
         registerTFRoller(txtField,this.onMenuRollOver,this.linkHandler);
         registerDragger(txtField);
         addChild(txtField);
      }
      
      public function start(param1:DisplayObject) : void
      {
         this.rootDisplay = param1;
         this.openings = new Dictionary(true);
         if(this.rootDisplay == null)
         {
            return;
         }
         this.rootDisplay.addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this.addToOpening(this.rootDisplay);
      }
      
      public function stop() : void
      {
         if(this.rootDisplay == null)
         {
            return;
         }
         this.rootDisplay.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.rootDisplay = null;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         ++this.framesSinceUpdate;
         if(this.framesSinceUpdate >= numOfFramesToUpdate)
         {
            this.framesSinceUpdate = 0;
            this.update();
         }
      }
      
      private function update() : void
      {
         var _loc2_:DisplayObjectContainer = null;
         this.mapIndex = 0;
         this.indexToDisplayMap = new Object();
         var _loc1_:String = "<p><p3>";
         if(this.rootDisplay == null)
         {
            _loc1_ += "null";
         }
         else
         {
            _loc1_ += "<menu> <a href=\"event:close\"><b>X</b></a></menu><br/>";
            _loc2_ = this.rootDisplay.parent;
            if(Boolean(_loc2_))
            {
               _loc1_ += "<p5><b>" + this.makeLink(_loc2_," ^ ","focus") + "</b>" + this.makeName(_loc2_) + "</p5><br/>";
               _loc1_ += this.printChild(this.rootDisplay,1);
            }
            else
            {
               _loc1_ += this.printChild(this.rootDisplay,0);
            }
         }
         txtField.htmlText = _loc1_ + "</p3></p>";
         width = txtField.width + 4;
         height = txtField.height;
      }
      
      private function printChild(param1:DisplayObject, param2:uint) : String
      {
         var _loc3_:String = null;
         var _loc4_:DisplayObjectContainer = null;
         if(param1 == null)
         {
            return "";
         }
         if(param1 is DisplayObjectContainer)
         {
            _loc4_ = param1 as DisplayObjectContainer;
            if(this.openings[param1] == true)
            {
               _loc3_ = "<p5><b>" + this.generateSteps(param1,param2) + this.makeLink(param1,"-" + _loc4_.numChildren,"minimize") + "</b> " + this.makeName(param1) + "</p5><br/>";
               _loc3_ += this.printChildren(_loc4_,param2 + 1);
            }
            else
            {
               _loc3_ = "<p4><b>" + this.generateSteps(param1,param2) + this.makeLink(param1,"+" + _loc4_.numChildren,"expand") + "</b> " + this.makeName(param1) + "</p4><br/>";
            }
            return _loc3_;
         }
         return "<p3>" + this.generateSteps(param1,param2) + this.makeName(param1) + "</p3><br/>";
      }
      
      private function printChildren(param1:DisplayObjectContainer, param2:uint) : String
      {
         var _loc3_:String = "";
         var _loc4_:uint = uint(param1.numChildren);
         var _loc5_:uint = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ += this.printChild(param1.getChildAt(_loc5_),param2);
            _loc5_++;
         }
         return _loc3_;
      }
      
      private function generateSteps(param1:Object, param2:uint) : String
      {
         var _loc3_:String = "";
         var _loc4_:uint = 0;
         while(_loc4_ < param2)
         {
            if(_loc4_ == param2 - 1)
            {
               if(param1 is DisplayObjectContainer)
               {
                  _loc3_ += this.makeLink(param1," &gt; ","focus");
               }
               else
               {
                  _loc3_ += " &gt; ";
               }
            }
            else
            {
               _loc3_ += " · ";
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function onMenuRollOver(param1:TextEvent) : void
      {
         var _loc2_:String = Boolean(param1.text) ? param1.text.replace("event:","") : "";
         if(_loc2_ == "close")
         {
            _loc2_ = "Close";
         }
         else if(_loc2_.indexOf("expand") == 0)
         {
            _loc2_ = "expand";
         }
         else if(_loc2_.indexOf("minimize") == 0)
         {
            _loc2_ = "minimize";
         }
         else if(_loc2_.indexOf("focus") == 0)
         {
            _loc2_ = "focus";
         }
         else
         {
            _loc2_ = null;
         }
         console.panels.tooltip(_loc2_,this);
      }
      
      private function makeName(param1:Object) : String
      {
         return this.makeLink(param1,param1.name,"scope") + " {<menu>" + this.makeLink(param1,LogReferences.ShortClassName(param1),"inspect") + "</menu>}";
      }
      
      private function makeLink(param1:Object, param2:String, param3:String) : String
      {
         ++this.mapIndex;
         this.indexToDisplayMap[this.mapIndex] = param1;
         return "<a href=\'event:" + param3 + "_" + this.mapIndex + "\'>" + param2 + "</a>";
      }
      
      private function getDisplay(param1:String) : DisplayObject
      {
         var _loc2_:Array = param1.split("_");
         return this.indexToDisplayMap[_loc2_[_loc2_.length - 1]];
      }
      
      protected function linkHandler(param1:TextEvent) : void
      {
         TextField(param1.currentTarget).setSelection(0,0);
         console.panels.tooltip(null);
         if(param1.text == "close")
         {
            this.close();
         }
         else if(param1.text.indexOf("expand") == 0)
         {
            this.addToOpening(this.getDisplay(param1.text));
         }
         else if(param1.text.indexOf("minimize") == 0)
         {
            this.removeFromOpening(this.getDisplay(param1.text));
         }
         else if(param1.text.indexOf("focus") == 0)
         {
            this.focus(this.getDisplay(param1.text) as DisplayObjectContainer);
         }
         else if(param1.text.indexOf("scope") == 0)
         {
            this.scope(this.getDisplay(param1.text));
         }
         else if(param1.text.indexOf("inspect") == 0)
         {
            this.inspect(this.getDisplay(param1.text));
         }
         param1.stopPropagation();
      }
      
      private function focus(param1:DisplayObjectContainer) : void
      {
         this.rootDisplay = param1;
         this.addToOpening(param1);
         this.update();
      }
      
      private function addToOpening(param1:DisplayObject) : void
      {
         if(this.openings[param1] == undefined)
         {
            this.openings[param1] = true;
            this.update();
         }
      }
      
      private function removeFromOpening(param1:DisplayObject) : void
      {
         if(this.openings[param1] != undefined)
         {
            delete this.openings[param1];
            this.update();
         }
      }
      
      protected function scope(param1:DisplayObject) : void
      {
         console.cl.setReturned(param1,true);
      }
      
      protected function inspect(param1:DisplayObject) : void
      {
         console.refs.focus(param1);
      }
      
      override public function close() : void
      {
         this.stop();
         super.close();
      }
   }
}

