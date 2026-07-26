package com.junkbyte.console.addons.commandprompt
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   
   public class CommandPrompt
   {
      
      public var ch:String = Console.CONSOLE_CHANNEL;
      
      public var headerQuestion:String;
      
      public var footerText:String;
      
      public var defaultCallback:Function;
      
      protected var _console:Console;
      
      protected var _choices:Array = new Array();
      
      private var _wasAutoCompleteEnabled:Boolean;
      
      private var _wasScopeShown:Boolean;
      
      public function CommandPrompt(param1:String = null, param2:Function = null, param3:Array = null)
      {
         super();
         this.headerQuestion = param1;
         this.defaultCallback = param2;
         if(Boolean(param3))
         {
            this._choices = param3;
         }
      }
      
      public function addCmdChoice(param1:CommandChoice) : void
      {
         this._choices.push(param1);
      }
      
      public function start() : void
      {
         if(Boolean(this.console))
         {
            this.console.config.commandLineInputPassThrough = this.commandLinePassThrough;
            this._wasAutoCompleteEnabled = this.console.config.commandLineAutoCompleteEnabled;
            this._wasScopeShown = this.console.config.style.showCommandLineScope;
            this.console.config.commandLineAutoCompleteEnabled = false;
            this.console.config.style.showCommandLineScope = false;
            this.ask();
         }
      }
      
      protected function ask() : void
      {
         if(Boolean(this.headerQuestion))
         {
            this.console.addHTMLch(this.ch,-2,"<b>" + this.headerQuestion + "</b>");
         }
         this.printChoices();
         if(this.footerText !== null)
         {
            this.console.addHTMLch(this.ch,-2,this.footerText);
         }
      }
      
      protected function printChoices() : void
      {
         var _loc1_:CommandChoice = null;
         for each(_loc1_ in this._choices)
         {
            this.console.addHTMLch(this.ch,4,_loc1_.toHTMLString());
         }
      }
      
      protected function commandLinePassThrough(param1:String) : void
      {
         var _loc2_:CommandChoice = null;
         for each(_loc2_ in this._choices)
         {
            if(_loc2_.key.toLowerCase() == param1.toLowerCase())
            {
               this.end();
               _loc2_.callback(_loc2_.key);
               return;
            }
         }
         if(this.defaultCallback != null)
         {
            this.end();
            this.defaultCallback(param1);
         }
      }
      
      protected function end() : void
      {
         this.console.config.commandLineInputPassThrough = null;
         this.console.config.commandLineAutoCompleteEnabled = this._wasAutoCompleteEnabled;
         this.console.config.style.showCommandLineScope = this._wasScopeShown;
      }
      
      public function setConsole(param1:Console) : void
      {
         if(Boolean(param1))
         {
            this._console = param1;
         }
      }
      
      protected function get console() : Console
      {
         if(Boolean(this._console))
         {
            return this._console;
         }
         return Cc.instance;
      }
   }
}

