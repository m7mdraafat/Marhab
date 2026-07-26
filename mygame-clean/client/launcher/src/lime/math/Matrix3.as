package lime.math
{
   import flash.Boot;
   import haxe.Exception;
   
   public class Matrix3
   {
      
      public static var init__:Boolean;
      
      public static var __identity:Matrix3;
      
      public var ty:Number;
      
      public var tx:Number;
      
      public var d:Number;
      
      public var c:Number;
      
      public var b:Number;
      
      public var a:Number;
      
      public function Matrix3(param1:Number = 1, param2:Number = 0, param3:Number = 0, param4:Number = 1, param5:Number = 0, param6:Number = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         a = param1;
         b = param2;
         c = param3;
         d = param4;
         tx = param5;
         ty = param6;
      }
      
      public function translate(param1:Number, param2:Number) : void
      {
         tx += param1;
         ty += param2;
      }
      
      public function transformVector(param1:Vector2, param2:Vector2 = undefined) : Vector2
      {
         if(param2 == null)
         {
            param2 = new Vector2();
         }
         param2.x = param1.x * a + param1.y * c + tx;
         param2.y = param1.x * b + param1.y * d + ty;
         return param2;
      }
      
      public function transformRect(param1:Rectangle, param2:Rectangle = undefined) : Rectangle
      {
         if(param2 == null)
         {
            param2 = new Rectangle();
         }
         var _loc3_:Number = a * param1.x + c * param1.y;
         var _loc4_:Number = _loc3_;
         var _loc5_:Number = b * param1.x + d * param1.y;
         var _loc6_:Number = _loc5_;
         var _loc7_:Number = a * (param1.x + param1.width) + c * param1.y;
         var _loc8_:Number = b * (param1.x + param1.width) + d * param1.y;
         if(_loc7_ < _loc3_)
         {
            _loc3_ = _loc7_;
         }
         if(_loc8_ < _loc5_)
         {
            _loc5_ = _loc8_;
         }
         if(_loc7_ > _loc4_)
         {
            _loc4_ = _loc7_;
         }
         if(_loc8_ > _loc6_)
         {
            _loc6_ = _loc8_;
         }
         _loc7_ = a * (param1.x + param1.width) + c * (param1.y + param1.height);
         _loc8_ = b * (param1.x + param1.width) + d * (param1.y + param1.height);
         if(_loc7_ < _loc3_)
         {
            _loc3_ = _loc7_;
         }
         if(_loc8_ < _loc5_)
         {
            _loc5_ = _loc8_;
         }
         if(_loc7_ > _loc4_)
         {
            _loc4_ = _loc7_;
         }
         if(_loc8_ > _loc6_)
         {
            _loc6_ = _loc8_;
         }
         _loc7_ = a * param1.x + c * (param1.y + param1.height);
         _loc8_ = b * param1.x + d * (param1.y + param1.height);
         if(_loc7_ < _loc3_)
         {
            _loc3_ = _loc7_;
         }
         if(_loc8_ < _loc5_)
         {
            _loc5_ = _loc8_;
         }
         if(_loc7_ > _loc4_)
         {
            _loc4_ = _loc7_;
         }
         if(_loc8_ > _loc6_)
         {
            _loc6_ = _loc8_;
         }
         param2.setTo(_loc3_ + _loc7_,_loc5_ + _loc8_,_loc4_ - _loc3_,_loc6_ - _loc5_);
         return param2;
      }
      
      public function toString() : String
      {
         return "matrix(" + a + ", " + b + ", " + c + ", " + d + ", " + tx + ", " + ty + ")";
      }
      
      public function to3DString(param1:Boolean = false) : String
      {
         if(param1)
         {
            return "matrix3d(" + a + ", " + b + ", " + "0, 0, " + c + ", " + d + ", " + "0, 0, 0, 0, 1, 0, " + int(tx) + ", " + int(ty) + ", 0, 1)";
         }
         return "matrix3d(" + a + ", " + b + ", " + "0, 0, " + c + ", " + d + ", " + "0, 0, 0, 0, 1, 0, " + tx + ", " + ty + ", 0, 1)";
      }
      
      public function setTo(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         a = param1;
         b = param2;
         c = param3;
         d = param4;
         tx = param5;
         ty = param6;
      }
      
      public function setRotation(param1:Number, param2:Number = 1) : void
      {
         a = Math.cos(param1) * param2;
         c = Math.sin(param1) * param2;
         b = -c;
         d = a;
      }
      
      public function scale(param1:Number, param2:Number) : void
      {
         a *= param1;
         b *= param2;
         c *= param1;
         d *= param2;
         tx *= param1;
         ty *= param2;
      }
      
      public function rotate(param1:Number) : void
      {
         var _loc2_:Number = Math.cos(param1);
         var _loc3_:Number = Math.sin(param1);
         var _loc4_:Number = a * _loc2_ - b * _loc3_;
         b = a * _loc3_ + b * _loc2_;
         a = _loc4_;
         var _loc5_:Number = c * _loc2_ - d * _loc3_;
         d = c * _loc3_ + d * _loc2_;
         c = _loc5_;
         var _loc6_:Number = tx * _loc2_ - ty * _loc3_;
         ty = tx * _loc3_ + ty * _loc2_;
         tx = _loc6_;
      }
      
      public function invert() : Matrix3
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc1_:Number = a * d - b * c;
         if(_loc1_ == 0)
         {
            a = b = Number(c = Number(d = 0));
            tx = -tx;
            ty = -ty;
         }
         else
         {
            _loc1_ = 1 / _loc1_;
            _loc2_ = d * _loc1_;
            d = a * _loc1_;
            a = _loc2_;
            b *= -_loc1_;
            c *= -_loc1_;
            _loc3_ = -a * tx - c * ty;
            ty = -b * tx - d * ty;
            tx = _loc3_;
         }
         return this;
      }
      
      public function identity() : void
      {
         a = 1;
         b = 0;
         c = 0;
         d = 1;
         tx = 0;
         ty = 0;
      }
      
      public function equals(param1:Matrix3) : Boolean
      {
         if(param1 != null && tx == param1.tx && ty == param1.ty && a == param1.a && b == param1.b && c == param1.c)
         {
            return d == param1.d;
         }
         return false;
      }
      
      public function deltaTransformVector(param1:Vector2, param2:Vector2 = undefined) : Vector2
      {
         if(param2 == null)
         {
            param2 = new Vector2();
         }
         param2.x = param1.x * a + param1.y * c;
         param2.y = param1.x * b + param1.y * d;
         return param2;
      }
      
      public function createGradientBox(param1:Number, param2:Number, param3:Number = 0, param4:Number = 0, param5:Number = 0) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         a = param1 / 1638.4;
         d = param2 / 1638.4;
         if(param3 != 0)
         {
            _loc6_ = Math.cos(param3);
            _loc7_ = Math.sin(param3);
            b = _loc7_ * d;
            c = -_loc7_ * a;
            a *= _loc6_;
            d *= _loc6_;
         }
         else
         {
            b = 0;
            c = 0;
         }
         tx = param4 + param1 / 2;
         ty = param5 + param2 / 2;
      }
      
      public function createBox(param1:Number, param2:Number, param3:Number = 0, param4:Number = 0, param5:Number = 0) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(param3 != 0)
         {
            _loc6_ = Math.cos(param3);
            _loc7_ = Math.sin(param3);
            a = _loc6_ * param1;
            b = _loc7_ * param2;
            c = -_loc7_ * param1;
            d = _loc6_ * param2;
         }
         else
         {
            a = param1;
            b = 0;
            c = 0;
            d = param2;
         }
         tx = param4;
         ty = param5;
      }
      
      public function copyRowTo(param1:int, param2:Vector4) : void
      {
         if(param1 > 2)
         {
            throw Exception.thrown("Row " + param1 + " out of bounds (2)");
         }
         if(param1 == 0)
         {
            param2.x = a;
            param2.y = c;
            param2.z = tx;
         }
         else if(param1 == 1)
         {
            param2.x = b;
            param2.y = d;
            param2.z = ty;
         }
         else
         {
            param2.x = 0;
            param2.y = 0;
            param2.z = 1;
         }
      }
      
      public function copyRowFrom(param1:int, param2:Vector4) : void
      {
         if(param1 > 2)
         {
            throw Exception.thrown("Row " + param1 + " out of bounds (2)");
         }
         if(param1 == 0)
         {
            a = param2.x;
            c = param2.y;
            tx = param2.z;
         }
         else if(param1 == 1)
         {
            b = param2.x;
            d = param2.y;
            ty = param2.z;
         }
      }
      
      public function copyFrom(param1:Matrix3) : void
      {
         a = param1.a;
         b = param1.b;
         c = param1.c;
         d = param1.d;
         tx = param1.tx;
         ty = param1.ty;
      }
      
      public function copyColumnTo(param1:int, param2:Vector4) : void
      {
         if(param1 > 2)
         {
            throw Exception.thrown("Column " + param1 + " out of bounds (2)");
         }
         if(param1 == 0)
         {
            param2.x = a;
            param2.y = b;
            param2.z = 0;
         }
         else if(param1 == 1)
         {
            param2.x = c;
            param2.y = d;
            param2.z = 0;
         }
         else
         {
            param2.x = tx;
            param2.y = ty;
            param2.z = 1;
         }
      }
      
      public function copyColumnFrom(param1:int, param2:Vector4) : void
      {
         if(param1 > 2)
         {
            throw Exception.thrown("Column " + param1 + " out of bounds (2)");
         }
         if(param1 == 0)
         {
            a = param2.x;
            b = param2.y;
         }
         else if(param1 == 1)
         {
            c = param2.x;
            d = param2.y;
         }
         else
         {
            tx = param2.x;
            ty = param2.y;
         }
      }
      
      public function concat(param1:Matrix3) : void
      {
         var _loc2_:Number = a * param1.a + b * param1.c;
         b = a * param1.b + b * param1.d;
         a = _loc2_;
         var _loc3_:Number = c * param1.a + d * param1.c;
         d = c * param1.b + d * param1.d;
         c = _loc3_;
         var _loc4_:Number = tx * param1.a + ty * param1.c + param1.tx;
         ty = tx * param1.b + ty * param1.d + param1.ty;
         tx = _loc4_;
      }
      
      public function clone() : Matrix3
      {
         return new Matrix3(a,b,c,d,tx,ty);
      }
   }
}

