package com.junkbyte.console.addons.displaymap
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   import flash.display.DisplayObject;
   
   public class DisplayMapAddon
   {
      
      public function DisplayMapAddon()
      {
         super();
      }
      
      public static function start(param1:DisplayObject, param2:Console = null) : DisplayMapPanel
      {
         if(param2 == null)
         {
            param2 = Cc.instance;
         }
         if(param2 == null)
         {
            return null;
         }
         var _loc3_:DisplayMapPanel = new DisplayMapPanel(param2);
         _loc3_.start(param1);
         param2.panels.addPanel(_loc3_);
         return _loc3_;
      }
      
      public static function registerCommand(param1:String = "mapdisplay", param2:Console = null) : void
      {
         var callbackFunction:Function;
         var commandName:String = param1;
         var console:Console = param2;
         if(console == null)
         {
            console = Cc.instance;
         }
         if(console == null || commandName == null)
         {
            return;
         }
         callbackFunction = function(... rest):void
         {
            var _loc2_:* = console.cl.run("this");
            if(_loc2_ is DisplayObject)
            {
               start(_loc2_ as DisplayObject,console);
            }
            else
            {
               console.error("Current scope",_loc2_,"is not a DisplayObject.");
            }
         };
         console.addSlashCommand(commandName,callbackFunction);
      }
      
      public static function addToMenu(param1:String = "DM", param2:DisplayObject = null, param3:Console = null) : void
      {
         var callbackFunction:Function;
         var menuName:String = param1;
         var startingContainer:DisplayObject = param2;
         var console:Console = param3;
         if(console == null)
         {
            console = Cc.instance;
         }
         if(console == null || menuName == null)
         {
            return;
         }
         callbackFunction = function():void
         {
            var _loc1_:DisplayMapPanel = console.panels.getPanel(DisplayMapPanel.NAME) as DisplayMapPanel;
            if(Boolean(_loc1_))
            {
               _loc1_.close();
            }
            else
            {
               if(startingContainer == null)
               {
                  startingContainer = console.parent;
               }
               _loc1_ = start(startingContainer);
               _loc1_.x = console.mouseX - _loc1_.width * 0.5;
               _loc1_.y = console.mouseY + 10;
            }
         };
         console.addMenu(menuName,callbackFunction);
      }
   }
}

