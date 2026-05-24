package com.junkbyte.console.addons.memoryRecorder
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.sampler.NewObjectSample;
   import flash.sampler.Sample;
   import flash.sampler.clearSamples;
   import flash.sampler.getSamples;
   import flash.sampler.pauseSampling;
   import flash.sampler.startSampling;
   import flash.system.System;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class MemoryRecorder extends EventDispatcher
   {
      
      public static var instance:MemoryRecorder = new MemoryRecorder();
      
      private var _interestedClassExpressions:Array = new Array();
      
      private var _ignoredClassExpressions:Array = new Array();
      
      private var _started:Boolean;
      
      private var startMemory:uint;
      
      private var endMemory:uint;
      
      private var startTimer:int;
      
      private var endTimer:int;
      
      private var ticker:Sprite;
      
      public var reportCallback:Function;
      
      public function MemoryRecorder()
      {
         super();
      }
      
      public function get ignoredClassExpressions() : Array
      {
         return this._ignoredClassExpressions;
      }
      
      public function addIgnoredClassExpression(param1:*) : void
      {
         this._ignoredClassExpressions.push(param1);
      }
      
      public function get interestedClassExpressions() : Array
      {
         return this._interestedClassExpressions;
      }
      
      public function addInterestedClassExpression(param1:*) : void
      {
         this._interestedClassExpressions.push(param1);
      }
      
      public function get running() : Boolean
      {
         return this._started || this.ticker != null;
      }
      
      public function start() : void
      {
         if(this.running)
         {
            return;
         }
         this._started = true;
         this.startMemory = System.totalMemory;
         this.startTimer = getTimer();
         startSampling();
         clearSamples();
      }
      
      public function end() : void
      {
         if(!this._started || this.ticker != null)
         {
            return;
         }
         pauseSampling();
         this.endMemory = System.totalMemory;
         this.endTimer = getTimer();
         System.gc();
         this.ticker = new Sprite();
         this.ticker.addEventListener(Event.ENTER_FRAME,this.onEndingEnterFrame);
      }
      
      private function onEndingEnterFrame(param1:Event) : void
      {
         this.ticker.removeEventListener(Event.ENTER_FRAME,this.onEndingEnterFrame);
         this.ticker = null;
         System.gc();
         this.endSampling();
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function endSampling() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         var _loc5_:Sample = null;
         var _loc6_:uint = 0;
         var _loc7_:NewObjectSample = null;
         var _loc3_:Number = 0;
         this.report("MemoryRecorder...");
         this.report("Objects still alive: >>>");
         var _loc4_:Object = new Object();
         for each(_loc5_ in getSamples())
         {
            if(_loc5_ is NewObjectSample)
            {
               _loc7_ = NewObjectSample(_loc5_);
               if(this.shouldPrintClass(_loc7_.type))
               {
                  _loc1_++;
                  if(_loc7_.object !== undefined)
                  {
                     _loc2_++;
                     this.reportNewSample(_loc7_);
                  }
               }
            }
         }
         _loc6_ = this.endTimer - this.startTimer;
         this.report("<<<",_loc2_,"object(s).");
         this.report("New objects:",_loc1_);
         this.report("Time taken:",_loc6_ + "ms.");
         this.report("Memory change:",this.roundMem(this.startMemory) + "mb to",this.roundMem(this.endMemory) + "mb (" + this.roundMem(this.endMemory - this.startMemory) + "mb)");
         this._started = false;
         clearSamples();
      }
      
      private function roundMem(param1:int) : Number
      {
         return Math.round(param1 / 10485.76) / 100;
      }
      
      private function reportNewSample(param1:NewObjectSample) : void
      {
         var className:String = null;
         var sample:NewObjectSample = param1;
         className = getQualifiedClassName(sample.type);
         try
         {
            if(sample.type == String)
            {
               this.reportNewStringSample(sample,className);
            }
            else
            {
               this.report(sample.id,className,this.getSampleSize(sample),sample.object,this.getSampleStack(sample));
            }
         }
         catch(err:Error)
         {
            report(sample.id,getSampleSize(sample),className,getSampleStack(sample));
         }
      }
      
      private function reportNewStringSample(param1:NewObjectSample, param2:String) : void
      {
         var _loc3_:String = "";
         var _loc4_:Function = getDefinitionByName("flash.sampler.getMasterString") as Function;
         var _loc5_:String = param1.object;
         if(_loc4_ != null)
         {
            while(Boolean(_loc5_))
            {
               _loc3_ += "\"" + _loc5_ + "\" > ";
               _loc5_ = _loc4_(_loc5_);
            }
         }
         this.report(param1.id,param2,this.getSampleSize(param1),_loc3_,this.getSampleStack(param1));
      }
      
      private function getSampleStack(param1:Sample) : String
      {
         var _loc3_:String = null;
         var _loc2_:String = "";
         for each(_loc3_ in param1.stack)
         {
            _loc3_ = _loc3_.replace(/.*?\:\:/,"");
            _loc3_ = _loc3_.replace(/\[.*?\:([0-9]+)\]/,":$1");
            _loc2_ += _loc3_ + "; ";
         }
         return _loc2_;
      }
      
      private function getSampleSize(param1:Sample) : String
      {
         if("size" in param1)
         {
            return param1["size"];
         }
         return "";
      }
      
      private function report(... rest) : void
      {
         var _loc2_:Function = this.reportCallback != null ? this.reportCallback : trace;
         _loc2_.apply(this,rest);
      }
      
      private function shouldPrintClass(param1:Class) : Boolean
      {
         return !this.isClassInIgnoredList(param1) && this.isClassInInterestedList(param1);
      }
      
      private function isClassInInterestedList(param1:Class) : Boolean
      {
         if(this._interestedClassExpressions.length == 0)
         {
            return true;
         }
         return this.classMatchesExpressionList(param1,this._interestedClassExpressions);
      }
      
      private function isClassInIgnoredList(param1:Class) : Boolean
      {
         return this.classMatchesExpressionList(param1,this._ignoredClassExpressions);
      }
      
      private function classMatchesExpressionList(param1:Class, param2:Array) : Boolean
      {
         var _loc4_:* = undefined;
         var _loc3_:String = getQualifiedClassName(param1);
         for each(_loc4_ in param2)
         {
            if(_loc3_.search(_loc4_) == 0)
            {
               return true;
            }
         }
         return false;
      }
   }
}

