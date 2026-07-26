package com.tuarua.fre
{
   import flash.system.Capabilities;
   
   [RemoteClass(alias="com.tuarua.fre.ANEError")]
   public class ANEError extends Error
   {
      
      private static const errorTypesCSharp:Array = ["FreSharp.Exceptions.Ok","FreSharp.Exceptions.NoSuchNameException","FreSharp.Exceptions.FreInvalidObjectException","FreSharp.Exceptions.FreTypeMismatchException","FreSharp.Exceptions.FreActionscriptErrorException","FreSharp.Exceptions.FreInvalidArgumentException","FreSharp.Exceptions.FreReadOnlyException","FreSharp.Exceptions.FreWrongThreadException","FreSharp.Exceptions.FreIllegalStateException","FreSharp.Exceptions.FreInsufficientMemoryException"];
      
      private static const errorTypesKotlin:Array = ["FreKotlin.Exceptions.Ok","FreKotlin.Exceptions.FRENoSuchNameException","FreKotlin.Exceptions.FREInvalidObjectException","FreKotlin.Exceptions.FRETypeMismatchException","FreKotlin.Exceptions.FREASErrorException","FreKotlin.Exceptions.FreInvalidArgumentException","FreKotlin.Exceptions.FREReadOnlyException","FreKotlin.Exceptions.FREWrongThreadException","FreKotlin.Exceptions.FreIllegalStateException","FreKotlin.Exceptions.FreInsufficientMemoryException"];
      
      private static const errorTypesSwift:Array = ["ok","noSuchName","invalidObject","typeMismatch","actionscriptError","invalidArgument","readOnly","wrongThread","illegalState","insufficientMemory"];
      
      private var _stackTrace:String;
      
      private var _source:String;
      
      private var _type:String;
      
      public function ANEError(param1:String, param2:int, param3:String, param4:String, param5:String)
      {
         this._stackTrace = param5;
         this._source = param4;
         this._type = param3;
         super(param1,this.getErrorID(this._type));
      }
      
      override public function get errorID() : int
      {
         return super.errorID;
      }
      
      public function get source() : String
      {
         return this._source;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      override public function getStackTrace() : String
      {
         return this._stackTrace;
      }
      
      private function getErrorID(param1:String) : int
      {
         var _loc2_:int = 0;
         if(Capabilities.os.toLowerCase().indexOf("win") == 0)
         {
            _loc2_ = errorTypesCSharp.indexOf(param1);
         }
         else if(Capabilities.os.toLowerCase().indexOf("linux") == 0)
         {
            _loc2_ = errorTypesKotlin.indexOf(param1);
         }
         else
         {
            _loc2_ = errorTypesSwift.indexOf(param1);
         }
         if(_loc2_ == -1)
         {
            _loc2_ = 10;
         }
         return _loc2_;
      }
   }
}

