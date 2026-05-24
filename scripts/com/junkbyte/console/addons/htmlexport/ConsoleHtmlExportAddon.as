package com.junkbyte.console.addons.htmlexport
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import com.junkbyte.console.view.MainPanel;
   import com.junkbyte.console.vos.Log;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   
   public class ConsoleHtmlExportAddon
   {
      
      [Embed(source="template.html",mimeType="application/octet-stream")]
      private static var EmbeddedTemplate:Class = ConsoleHtmlExportAddon_EmbeddedTemplate;
      
      public static const HTML_REPLACEMENT:String = "{text:\'HTML_REPLACEMENT\'}";
      
      public var referencesDepth:uint = 1;
      
      protected var console:Console;
      
      public function ConsoleHtmlExportAddon(param1:Console)
      {
         super();
         if(param1 == null)
         {
            param1 = Cc.instance;
         }
         this.console = param1;
      }
      
      public static function addToMenu(param1:String = "export", param2:Console = null) : ConsoleHtmlExportAddon
      {
         var _loc3_:ConsoleHtmlExportAddon = null;
         if(param2 == null)
         {
            param2 = Cc.instance;
         }
         if(Boolean(param2))
         {
            _loc3_ = new ConsoleHtmlExportAddon(param2);
            param2.addMenu(param1,_loc3_.exportToFile,new Array(),"Export logs to HTML");
         }
         return _loc3_;
      }
      
      public function exportToFile(param1:String = null) : void
      {
         var file:FileReference;
         var html:String = null;
         var fileName:String = param1;
         if(fileName == null)
         {
            fileName = this.generateFileName();
         }
         file = new FileReference();
         try
         {
            html = this.exportHTMLString();
            file["save"](html,fileName);
         }
         catch(err:Error)
         {
            console.report("Failed to save to file: " + err,8);
         }
      }
      
      protected function generateFileName() : String
      {
         var _loc1_:Date = new Date();
         var _loc2_:String = "log@" + _loc1_.getFullYear() + "." + (_loc1_.getMonth() + 1) + "." + (_loc1_.getDate() + 1);
         _loc2_ += "_" + _loc1_.hours + "." + _loc1_.minutes;
         return _loc2_ + ".html";
      }
      
      public function exportHTMLString() : String
      {
         var _loc1_:String = String(new EmbeddedTemplate() as ByteArray);
         return _loc1_.replace(HTML_REPLACEMENT,this.exportJSON());
      }
      
      protected function exportJSON() : String
      {
         var libJSON:Class;
         var nativeJSON:Class = null;
         var object:Object = this.exportObject();
         try
         {
            nativeJSON = getDefinitionByName("JSON") as Class;
            return nativeJSON["stringify"](object);
         }
         catch(error:Error)
         {
         }
         libJSON = getDefinitionByName("com.adobe.serialization.json.JSON") as Class;
         return libJSON["encode"](object);
      }
      
      protected function exportObject() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.config = this.getConfigToEncode();
         _loc1_.ui = this.getUIDataToEncode();
         _loc1_.logs = this.getLogsToEncode();
         var _loc2_:ConsoleHTMLRefsGen = new ConsoleHTMLRefsGen(this.console,this.referencesDepth);
         _loc2_.fillData(_loc1_);
         return _loc1_;
      }
      
      protected function getConfigToEncode() : Object
      {
         var _loc1_:ConsoleConfig = this.console.config;
         var _loc2_:Object = this.convertTypeToObject(_loc1_);
         _loc2_.style = this.getStyleToEncode();
         return _loc2_;
      }
      
      protected function getStyleToEncode() : Object
      {
         var _loc1_:ConsoleStyle = this.console.config.style;
         var _loc2_:Object = this.convertTypeToObject(_loc1_);
         _loc2_.styleSheet = this.getStyleSheetToEncode(_loc1_);
         return _loc2_;
      }
      
      protected function getStyleSheetToEncode(param1:ConsoleStyle) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Object = new Object();
         for each(_loc3_ in param1.styleSheet.styleNames)
         {
            _loc2_[_loc3_] = param1.styleSheet.getStyle(_loc3_);
         }
         return _loc2_;
      }
      
      protected function getUIDataToEncode() : Object
      {
         var _loc1_:Object = new Object();
         var _loc2_:MainPanel = this.console.panels.mainPanel;
         _loc1_.viewingPriority = _loc2_.priority;
         _loc1_.viewingChannels = _loc2_.viewingChannels;
         _loc1_.ignoredChannels = _loc2_.ignoredChannels;
         return _loc1_;
      }
      
      protected function getLogsToEncode() : Object
      {
         var _loc3_:Object = null;
         var _loc1_:Array = new Array();
         var _loc2_:Log = this.console.logs.last;
         while(Boolean(_loc2_))
         {
            _loc3_ = this.convertTypeToObject(_loc2_);
            delete _loc3_.next;
            delete _loc3_.prev;
            _loc1_.push(_loc3_);
            _loc2_ = _loc2_.prev;
         }
         return _loc1_.reverse();
      }
      
      protected function convertTypeToObject(param1:Object) : Object
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc2_:Object = new Object();
         var _loc3_:XML = describeType(param1);
         for each(_loc4_ in _loc3_.variable)
         {
            _loc5_ = _loc4_.@name;
            _loc2_[_loc5_] = param1[_loc5_];
         }
         return _loc2_;
      }
   }
}

