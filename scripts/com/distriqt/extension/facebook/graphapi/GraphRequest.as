package com.distriqt.extension.facebook.graphapi
{
   import flash.display.BitmapData;
   import flash.events.IEventDispatcher;
   
   [Event(name="facebook_graphrequest_complete",type="com.distriqt.extension.facebook.graphapi.events.GraphRequestEvent")]
   [Event(name="facebook_graphrequest_error",type="com.distriqt.extension.facebook.graphapi.events.GraphRequestEvent")]
   public interface GraphRequest extends IEventDispatcher
   {
      
      function get path() : String;
      
      function set path(param1:String) : void;
      
      function get method() : String;
      
      function set method(param1:String) : void;
      
      function get params() : Object;
      
      function set params(param1:Object) : void;
      
      function get paramsJSON() : String;
      
      function get fields() : Array;
      
      function set fields(param1:Array) : void;
      
      function get image() : BitmapData;
      
      function set image(param1:BitmapData) : void;
      
      function set onComplete(param1:Function) : void;
      
      function set onError(param1:Function) : void;
   }
}

