package com.junkbyte.console.addons.commandprompt
{
   public class CommandChoice
   {
      
      public var key:String;
      
      public var callback:Function;
      
      public var text:String;
      
      public function CommandChoice(param1:String, param2:Function, param3:String = "")
      {
         super();
         this.key = param1;
         this.callback = param2;
         this.text = param3;
      }
      
      public function toHTMLString() : String
      {
         var _loc1_:String = Boolean(this.text) ? this.text : "";
         if(Boolean(this.key))
         {
            return "&gt; <b>" + this.key + "</b>: " + _loc1_;
         }
         return Boolean(_loc1_) ? _loc1_ : "[CommandChoice empty]";
      }
   }
}

