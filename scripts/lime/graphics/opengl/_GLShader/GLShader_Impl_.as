package lime.graphics.opengl._GLShader
{
   import lime.graphics.opengl.GLObject;
   import lime.utils.Log;
   
   public final class GLShader_Impl_
   {
      
      public function GLShader_Impl_()
      {
      }
      
      public static function fromInt(param1:int) : GLObject
      {
         return GLObject.fromInt(2,param1);
      }
      
      public static function fromSource(param1:*, param2:String, param3:int) : GLObject
      {
         var _loc5_:* = null as String;
         var _loc4_:GLObject = param1.createShader(param3);
         param1.shaderSource(_loc4_,param2);
         param1.compileShader(_loc4_);
         if(param1.getShaderParameter(_loc4_,int(param1.COMPILE_STATUS)) == 0)
         {
            if(param3 == int(param1.VERTEX_SHADER))
            {
               _loc5_ = "Error compiling vertex shader";
            }
            else if(param3 == int(param1.FRAGMENT_SHADER))
            {
               _loc5_ = "Error compiling fragment shader";
            }
            else
            {
               _loc5_ = "Error compiling unknown shader type";
            }
            _loc5_ += "\n" + param1.getShaderInfoLog(_loc4_);
            Log.error(_loc5_,{
               "fileName":"lime/graphics/opengl/GLShader.hx",
               "lineNumber":40,
               "className":"lime.graphics.opengl._GLShader.GLShader_Impl_",
               "methodName":"fromSource"
            });
         }
         return _loc4_;
      }
   }
}

