package com.oyunstudyosu.air.commands
{
   import com.oyunstudyosu.air.RLog;
   import flash.Boot;
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   
   public class SerialCommand extends Command
   {
      
      public var _completedCommandCount:int;
      
      public var _commands:Array;
      
      public function SerialCommand(param1:Array = undefined)
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         _commands = param1;
      }
      
      public function onSubcommandComplete(param1:Event) : void
      {
         var _loc3_:* = null as Command;
         var _loc2_:Command = param1.target;
         _loc2_.removeEventListener(Event.COMPLETE,onSubcommandComplete);
         RLog.write("launcher.command.complete",{"command":getQualifiedClassName(_loc2_),"index":_completedCommandCount});
         ++_completedCommandCount;
         if(_completedCommandCount == int(_commands.length))
         {
            complete();
         }
         else
         {
            _loc3_ = _commands[_completedCommandCount];
            RLog.write("launcher.command.start",{"command":getQualifiedClassName(_loc3_),"index":_completedCommandCount});
            _loc3_.addEventListener(Event.COMPLETE,onSubcommandComplete);
            _loc3_.execute();
         }
      }
      
      override public function execute() : void
      {
         _completedCommandCount = 0;
         var _loc1_:Command = _commands[_completedCommandCount];
         RLog.write("launcher.command.start",{"command":getQualifiedClassName(_loc1_),"index":_completedCommandCount,"count":_commands.length});
         _loc1_.addEventListener(Event.COMPLETE,onSubcommandComplete);
         _loc1_.execute();
      }
      
      public function addCommand(param1:Command) : void
      {
         if(_commands == null)
         {
            _commands = [];
         }
         _commands.push(param1);
      }
   }
}

