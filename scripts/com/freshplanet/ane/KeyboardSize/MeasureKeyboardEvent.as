package com.freshplanet.ane.KeyboardSize
{
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class MeasureKeyboardEvent extends Event
   {
      
      public static const KEYBOARD_WILL_SHOW:String = "KEYBOARD_WILL_SHOW";
      
      public static const KEYBOARD_WILL_CHANGE:String = "KEYBOARD_WILL_CHANGE";
      
      public static const KEYBOARD_WILL_HIDE:String = "KEYBOARD_WILL_HIDE";
      
      public static const KEYBOARD_DID_SHOW:String = "KEYBOARD_DID_SHOW";
      
      public static const KEYBOARD_DID_CHANGE:String = "KEYBOARD_DID_CHANGE";
      
      public static const KEYBOARD_DID_HIDE:String = "KEYBOARD_DID_HIDE";
      
      public static const LOG:String = "LOG";
      
      public var data:Object;
      
      private var _keyboardRect:Rectangle;
      
      public function MeasureKeyboardEvent(param1:String, param2:String = null)
      {
         var _loc4_:Object = null;
         var _loc3_:Number = NaN;
         super(param1);
         if(param2 && param2.length)
         {
            data = JSON.parse(param2);
            _loc4_ = data.viewRect;
            if(_loc4_)
            {
               _loc3_ = Number(data.hasOwnProperty("nativeScale") ? data.nativeScale : 1);
               _keyboardRect = new Rectangle(_loc4_.x * _loc3_,_loc4_.y * _loc3_,_loc4_.width * _loc3_,_loc4_.height * _loc3_);
            }
         }
      }
      
      public function get keyboardRect() : Rectangle
      {
         return _keyboardRect;
      }
   }
}

