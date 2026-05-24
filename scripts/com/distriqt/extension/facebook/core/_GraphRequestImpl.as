package com.distriqt.extension.facebook.core
{
   import com.distriqt.extension.facebook.graphapi.GraphRequest;
   import com.distriqt.extension.facebook.graphapi.events.GraphRequestEvent;
   import flash.display.BitmapData;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _GraphRequestImpl extends EventDispatcher implements GraphRequest
   {
      
      private var _extContext:ExtensionContext;
      
      internal var _identifier:String = "";
      
      private var _path:String = "";
      
      private var _method:String = "GET";
      
      private var _fields:Array;
      
      private var _params:Object;
      
      private var _image:BitmapData;
      
      private var _onComplete:Function;
      
      private var _onError:Function;
      
      public function _GraphRequestImpl()
      {
         super();
         _fields = [];
         _params = {};
         _image = null;
      }
      
      public function get path() : String
      {
         return _path;
      }
      
      public function set path(param1:String) : void
      {
         _path = param1;
      }
      
      public function get method() : String
      {
         return _method;
      }
      
      public function set method(param1:String) : void
      {
         _method = param1;
      }
      
      public function get fields() : Array
      {
         return _fields;
      }
      
      public function set fields(param1:Array) : void
      {
         _fields = param1;
      }
      
      public function get params() : Object
      {
         return _params;
      }
      
      public function set params(param1:Object) : void
      {
         _params = param1;
      }
      
      public function get paramsJSON() : String
      {
         try
         {
            return JSON.stringify(_params);
         }
         catch(e:Error)
         {
         }
         return "";
      }
      
      public function get image() : BitmapData
      {
         return _image;
      }
      
      public function set image(param1:BitmapData) : void
      {
         _image = param1;
      }
      
      public function set onComplete(param1:Function) : void
      {
         _onComplete = param1;
      }
      
      public function set onError(param1:Function) : void
      {
         _onError = param1;
      }
      
      internal function cleanup() : void
      {
         _onComplete = null;
         _onError = null;
         clearContext();
      }
      
      internal function clearContext() : void
      {
         if(_extContext != null)
         {
            _extContext.removeEventListener("status",extContext_statusHandler);
            _extContext = null;
         }
      }
      
      internal function setContext(param1:ExtensionContext) : void
      {
         clearContext();
         _extContext = param1;
         _extContext.addEventListener("status",extContext_statusHandler);
      }
      
      internal function makeRequest() : Boolean
      {
         try
         {
            _identifier = _extContext.call("graphapi_makeRequest",this) as String;
            return _identifier != "";
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function isGraphRequestEvent(param1:StatusEvent) : Boolean
      {
         switch(param1.code)
         {
            case "facebook_graphrequest_complete":
            case "facebook_graphrequest_error":
               break;
            default:
               return false;
         }
         return true;
      }
      
      private function extContext_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         if(isGraphRequestEvent(param1))
         {
            try
            {
               _loc2_ = JSON.parse(param1.level);
               if(_loc2_.identifier == _identifier)
               {
                  switch(param1.code)
                  {
                     case "facebook_graphrequest_complete":
                        dispatchEvent(new GraphRequestEvent(param1.code,_loc2_.result));
                        if(_onComplete != null)
                        {
                           try
                           {
                              _onComplete(_loc2_.result);
                           }
                           catch(e:Error)
                           {
                           }
                        }
                        break;
                     case "facebook_graphrequest_error":
                        dispatchEvent(new GraphRequestEvent(param1.code,null,_loc2_.errorCode,_loc2_.errorMessage));
                        if(_onError != null)
                        {
                           try
                           {
                              _onError(_loc2_.errorCode,_loc2_.errorMessage);
                           }
                           catch(e:Error)
                           {
                           }
                        }
                  }
                  cleanup();
               }
            }
            catch(e:Error)
            {
            }
         }
      }
   }
}

