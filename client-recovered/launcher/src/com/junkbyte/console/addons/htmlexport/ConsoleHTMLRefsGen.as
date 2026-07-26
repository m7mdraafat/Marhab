package com.junkbyte.console.addons.htmlexport
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.vos.Log;
   import flash.utils.describeType;
   
   public class ConsoleHTMLRefsGen
   {
      
      private static const refSearchExpression:RegExp = /<a(\s+)href=\'event:ref_(\d+)\'>/g;
      
      private var console:Console;
      
      private var referencesDepth:uint;
      
      private var referencesMap:Object;
      
      public function ConsoleHTMLRefsGen(param1:Console, param2:uint)
      {
         super();
         this.console = param1;
         this.referencesDepth = param2;
      }
      
      public function fillData(param1:Object) : void
      {
         this.referencesMap = new Object();
         param1.references = this.referencesMap;
         var _loc2_:Log = this.console.logs.last;
         while(Boolean(_loc2_))
         {
            this.processRefIdsFromLine(_loc2_.text);
            _loc2_ = _loc2_.prev;
         }
      }
      
      private function processRefIdsFromLine(param1:String, param2:uint = 0) : void
      {
         var _loc4_:uint = 0;
         refSearchExpression.lastIndex = 0;
         var _loc3_:Object = refSearchExpression.exec(param1);
         while(_loc3_ != null)
         {
            _loc4_ = uint(_loc3_[2]);
            this.processRefId(_loc4_,param2);
            _loc3_ = refSearchExpression.exec(param1);
         }
      }
      
      private function processRefId(param1:uint, param2:uint) : void
      {
         var _loc3_:* = this.console.refs.getRefById(param1);
         if(_loc3_ != null && this.referencesMap[param1] == null)
         {
            this.referencesMap[param1] = this.processRef(_loc3_,param2);
         }
      }
      
      private function processRef(param1:Object, param2:uint) : Object
      {
         var constants:Object;
         var result:Object = null;
         var isstatic:Boolean = false;
         var targetObj:Object = null;
         var constantX:XML = null;
         var accessors:Object = null;
         var staticAccessors:Object = null;
         var accessorX:XML = null;
         var variables:Object = null;
         var staticVariables:Object = null;
         var variableX:XML = null;
         var dynamicVariables:Object = null;
         var X:* = undefined;
         var obj:Object = param1;
         var currentDepth:uint = param2;
         var V:XML = describeType(obj);
         var cls:Object = obj is Class ? obj : obj.constructor;
         var clsV:XML = describeType(cls);
         var isClass:Boolean = obj is Class;
         result = new Object();
         result.name = LogReferences.EscHTML(V.@name);
         constants = new Object();
         result.constants = constants;
         for each(constantX in clsV..constant)
         {
            constants[constantX.@name.toString()] = this.makeValue(cls,constantX.@name.toString(),currentDepth);
         }
         accessors = new Object();
         result.accessors = accessors;
         staticAccessors = new Object();
         result.staticAccessors = staticAccessors;
         for each(accessorX in clsV..accessor)
         {
            isstatic = accessorX.parent().name() != "factory";
            targetObj = isstatic ? staticAccessors : accessors;
            if(accessorX.@access.toString() != "writeonly" && (isstatic || !isClass))
            {
               targetObj[accessorX.@name] = this.makeValue(isstatic ? cls : obj,accessorX.@name.toString(),currentDepth);
            }
         }
         variables = new Object();
         result.variables = variables;
         staticVariables = new Object();
         result.staticVariables = staticVariables;
         for each(variableX in clsV..variable)
         {
            isstatic = variableX.parent().name() != "factory";
            targetObj = isstatic ? staticVariables : variables;
            targetObj[variableX.@name] = this.makeValue(isstatic ? cls : obj,variableX.@name.toString(),currentDepth);
         }
         dynamicVariables = new Object();
         result.dynamicVariables = dynamicVariables;
         try
         {
            for(X in obj)
            {
               dynamicVariables[X] = this.makeValue(obj,X,currentDepth);
            }
         }
         catch(e:Error)
         {
            result.dynamicVariables = e.message;
         }
         return result;
      }
      
      private function makeValue(param1:*, param2:*, param3:uint) : String
      {
         var string:String;
         var v:* = undefined;
         var obj:* = param1;
         var prop:* = param2;
         var currentDepth:uint = param3;
         try
         {
            v = obj[prop];
         }
         catch(err:Error)
         {
            return "<p0><i>" + err.toString() + "</i></p0>";
         }
         string = this.console.refs.makeString(v,null,true);
         if(currentDepth < this.referencesDepth)
         {
            currentDepth++;
            this.processRefIdsFromLine(string,currentDepth);
         }
         return string;
      }
   }
}

