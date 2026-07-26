package com.oyunstudyosu.commands
{
   import flash.utils.getQualifiedClassName;
   import com.oyunstudyosu.capture.CaptureLog;
   import flash.events.Event;
   
   public class SerialCommand extends Command
   {
      
      private var _commands:Array;
      
      private var _completedCommandCount:int;
      
      public function SerialCommand(... rest)
      {
         super();
         this._commands = rest;
      }
      
      public function addCommand(param1:Command) : void
      {
         if(this._commands == null)
         {
            this._commands = [];
         }
         this._commands.push(param1);
      }
      
      override public function execute() : void
      {
         this._completedCommandCount = 0;
         var _loc1_:Command = Command(this._commands[this._completedCommandCount]);
         _loc1_.addEventListener(Event.COMPLETE,this.onSubcommandComplete);
         CaptureLog.write("serial.execute",{"index":this._completedCommandCount,"command":getQualifiedClassName(_loc1_)});
         try
         {
            _loc1_.execute();
         }
         catch(_captureCommandError:*)
         {
            CaptureLog.write("serial.execute.error",{"index":this._completedCommandCount,"command":getQualifiedClassName(_loc1_),"message":String(_captureCommandError)});
            _loc1_.dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function onSubcommandComplete(param1:Event) : void
      {
         var _loc2_:Command = null;
         Command(param1.target).removeEventListener(Event.COMPLETE,this.onSubcommandComplete);
         ++this._completedCommandCount;
         if(this._completedCommandCount == this._commands.length)
         {
            complete();
         }
         else
         {
            _loc2_ = Command(this._commands[this._completedCommandCount]);
            _loc2_.addEventListener(Event.COMPLETE,this.onSubcommandComplete);
            CaptureLog.write("serial.execute",{"index":this._completedCommandCount,"command":getQualifiedClassName(_loc2_)});
            try
            {
               _loc2_.execute();
            }
            catch(_captureCommandError:*)
            {
               CaptureLog.write("serial.execute.error",{"index":this._completedCommandCount,"command":getQualifiedClassName(_loc2_),"message":String(_captureCommandError)});
               _loc2_.dispatchEvent(new Event(Event.COMPLETE));
            }
         }
      }
   }
}

