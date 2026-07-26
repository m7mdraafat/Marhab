package com.tuarua.fre
{
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class ANEUtils
   {
      
      public function ANEUtils()
      {
         super();
      }
      
      public static function getClass(param1:Object) : Class
      {
         return Class(getDefinitionByName(getQualifiedClassName(param1)));
      }
      
      public static function getClassProps(param1:*) : Vector.<Object>
      {
         var _loc4_:String = null;
         var _loc6_:Object = null;
         var _loc7_:XML = null;
         var _loc8_:Object = null;
         var _loc9_:XML = null;
         var _loc10_:Object = null;
         var _loc2_:Vector.<Object> = new Vector.<Object>(0);
         var _loc3_:Boolean = false;
         for(_loc4_ in param1)
         {
            _loc6_ = {};
            _loc6_.name = _loc4_;
            if(Boolean(param1.hasOwnProperty(_loc4_)))
            {
               _loc6_.type = getClassType(param1[_loc4_]);
               _loc6_.cls = _loc6_.type == "*" ? null : getClass(Class(getDefinitionByName(_loc6_.type)));
               _loc2_.push(_loc6_);
               _loc3_ = true;
            }
         }
         if(_loc3_)
         {
            return _loc2_;
         }
         var _loc5_:XML = describeType(param1);
         if(Boolean(_loc5_.variable) && _loc5_.variable.length() > 0)
         {
            for each(_loc7_ in _loc5_.variable)
            {
               _loc8_ = {};
               _loc8_.name = _loc7_.@name.toString();
               _loc8_.type = _loc7_.@type.toString();
               _loc8_.cls = _loc8_.type == "*" ? null : getClass(Class(getDefinitionByName(_loc8_.type)));
               _loc2_.push(_loc8_);
            }
         }
         else if(Boolean(_loc5_.factory) && Boolean(_loc5_.factory.variable) && _loc5_.factory.variable.length() > 0)
         {
            for each(_loc9_ in _loc5_.factory.variable)
            {
               _loc10_ = {};
               _loc10_.name = _loc9_.@name.toString();
               _loc10_.type = _loc9_.@type.toString();
               _loc10_.cls = _loc10_.type == "*" ? null : getClass(Class(getDefinitionByName(_loc10_.type)));
               _loc2_.push(_loc10_);
            }
         }
         return _loc2_;
      }
      
      public static function map(param1:Object, param2:Class) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Class = null;
         _loc3_ = new param2();
         for(_loc4_ in param1)
         {
            _loc5_ = _loc4_;
            if(param1[_loc5_] is String)
            {
               _loc6_ = String;
            }
            else if(param1[_loc5_] is Boolean)
            {
               _loc6_ = Boolean;
            }
            else if(param1[_loc5_] is int)
            {
               _loc6_ = int;
            }
            else if(param1[_loc5_] is Number)
            {
               _loc6_ = Number;
            }
            else
            {
               _loc6_ = getPropClass(_loc5_,param2);
            }
            switch(_loc6_)
            {
               case String:
               case int:
               case Number:
               case Boolean:
               case Array:
               case Vector.<String>:
               case Vector.<int>:
               case Vector.<Number>:
               case Vector.<Boolean>:
                  _loc3_[_loc5_] = param1[_loc5_];
                  break;
               case Date:
                  _loc3_[_loc5_] = new Date(Date.parse(param1[_loc5_]));
                  break;
               default:
                  _loc3_[_loc5_] = _loc6_ == null ? param1[_loc5_] : map(param1[_loc5_],getPropClass(_loc5_,param2));
            }
         }
         return _loc3_;
      }
      
      public static function getClassType(param1:*) : String
      {
         return getQualifiedClassName(param1);
      }
      
      private static function getPropClass(param1:String, param2:Class) : Class
      {
         var _loc4_:Object = null;
         var _loc3_:Vector.<Object> = getClassProps(param2);
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.name == param1)
            {
               return _loc4_.cls;
            }
         }
         return null;
      }
      
      public function getClass(param1:Object) : Class
      {
         return Class(getDefinitionByName(getQualifiedClassName(param1)));
      }
      
      public function getClassProps(param1:*) : Vector.<Object>
      {
         var _loc4_:String = null;
         var _loc6_:Object = null;
         var _loc7_:XML = null;
         var _loc8_:Object = null;
         var _loc9_:XML = null;
         var _loc10_:Object = null;
         var _loc2_:Vector.<Object> = new Vector.<Object>(0);
         var _loc3_:Boolean = false;
         for(_loc4_ in param1)
         {
            _loc6_ = {};
            _loc6_.name = _loc4_;
            if(Boolean(param1.hasOwnProperty(_loc4_)))
            {
               _loc6_.type = this.getClassType(param1[_loc4_]);
               _loc6_.cls = _loc6_.type == "*" ? null : this.getClass(Class(getDefinitionByName(_loc6_.type)));
               _loc2_.push(_loc6_);
               _loc3_ = true;
            }
         }
         if(_loc3_)
         {
            return _loc2_;
         }
         var _loc5_:XML = describeType(param1);
         if(Boolean(_loc5_.variable) && _loc5_.variable.length() > 0)
         {
            for each(_loc7_ in _loc5_.variable)
            {
               _loc8_ = {};
               _loc8_.name = _loc7_.@name.toString();
               _loc8_.type = _loc7_.@type.toString();
               _loc8_.cls = _loc8_.type == "*" ? null : this.getClass(Class(getDefinitionByName(_loc8_.type)));
               _loc2_.push(_loc8_);
            }
         }
         else if(Boolean(_loc5_.factory) && Boolean(_loc5_.factory.variable) && _loc5_.factory.variable.length() > 0)
         {
            for each(_loc9_ in _loc5_.factory.variable)
            {
               _loc10_ = {};
               _loc10_.name = _loc9_.@name.toString();
               _loc10_.type = _loc9_.@type.toString();
               _loc10_.cls = _loc10_.type == "*" ? null : this.getClass(Class(getDefinitionByName(_loc10_.type)));
               _loc2_.push(_loc10_);
            }
         }
         return _loc2_;
      }
      
      public function getClassType(param1:*) : String
      {
         return getQualifiedClassName(param1);
      }
   }
}

