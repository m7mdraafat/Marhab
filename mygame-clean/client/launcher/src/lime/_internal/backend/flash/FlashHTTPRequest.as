package lime._internal.backend.flash
{
   import flash.Boot;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.utils.ByteArray;
   import haxe.IMap;
   import haxe.ds.StringMap;
   import haxe.io.Bytes;
   import lime.app.Future;
   import lime.app.Promise_String;
   import lime.app.Promise_haxe_io_Bytes;
   import lime.net.HTTPRequestHeader;
   import lime.net._IHTTPRequest;
   import lime.net._HTTPRequest.AbstractHTTPRequest;
   
   public class FlashHTTPRequest
   {
      
      public var urlRequest:URLRequest;
      
      public var urlLoader:URLLoader;
      
      public var parent:_IHTTPRequest;
      
      public function FlashHTTPRequest()
      {
      }
      
      public function loadText(param1:String) : Future
      {
         var _gthis:FlashHTTPRequest = this;
         var promise:Promise_String = new Promise_String();
         construct(false);
         urlLoader.addEventListener(ProgressEvent.PROGRESS,function(param1:ProgressEvent):void
         {
            promise.progress(int(param1.bytesLoaded),int(param1.bytesTotal));
         });
         urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,function(param1:HTTPStatusEvent):void
         {
            var _loc2_:AbstractHTTPRequest = _gthis.parent as AbstractHTTPRequest;
            _loc2_.responseStatus = param1.status;
            if(Boolean(_loc2_.enableResponseHeaders))
            {
               _loc2_.responseHeaders = param1.responseHeaders;
            }
         });
         urlLoader.addEventListener(IOErrorEvent.IO_ERROR,function(param1:IOErrorEvent):void
         {
            promise.error(param1.errorID);
         });
         urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function(param1:SecurityErrorEvent):void
         {
            promise.error(403);
         });
         urlLoader.addEventListener(Event.COMPLETE,function(param1:*):void
         {
            var _temp_1:* = _gthis.urlLoader.data;
            if(!(_temp_1 is String))
            {
               throw "Class cast error";
            }
            promise.complete(_temp_1);
         });
         urlLoader.load(urlRequest);
         return promise.future;
      }
      
      public function loadData(param1:String) : Future
      {
         var _gthis:FlashHTTPRequest = this;
         var promise:Promise_haxe_io_Bytes = new Promise_haxe_io_Bytes();
         construct(true);
         urlLoader.addEventListener(ProgressEvent.PROGRESS,function(param1:ProgressEvent):void
         {
            promise.progress(int(param1.bytesLoaded),int(param1.bytesTotal));
         });
         urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,function(param1:HTTPStatusEvent):void
         {
            var _loc2_:AbstractHTTPRequest = _gthis.parent as AbstractHTTPRequest;
            _loc2_.responseStatus = param1.status;
            if(Boolean(_loc2_.enableResponseHeaders))
            {
               _loc2_.responseHeaders = param1.responseHeaders;
            }
         });
         urlLoader.addEventListener(IOErrorEvent.IO_ERROR,function(param1:IOErrorEvent):void
         {
            promise.error(param1.errorID);
         });
         urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function(param1:SecurityErrorEvent):void
         {
            promise.error(403);
         });
         urlLoader.addEventListener(Event.COMPLETE,function(param1:*):void
         {
            promise.complete(Bytes.ofData(_gthis.urlLoader.data));
         });
         urlLoader.load(urlRequest);
         return promise.future;
      }
      
      public function init(param1:_IHTTPRequest) : void
      {
         parent = param1;
      }
      
      public function construct(param1:Boolean) : void
      {
         var _loc4_:* = null as StringMap;
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:* = null;
         var _loc10_:int = 0;
         var _loc11_:Boolean = false;
         var _loc12_:int = 0;
         var _loc13_:* = null;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:* = null as String;
         var _loc17_:* = null as String;
         var _loc18_:* = null as String;
         var _loc19_:* = null as StringMap;
         var _loc20_:* = null as String;
         var _loc22_:* = null as HTTPRequestHeader;
         var _request:AbstractHTTPRequest = parent as AbstractHTTPRequest;
         urlLoader = new URLLoader();
         urlRequest = new URLRequest();
         var _loc2_:String = "";
         var _loc3_:String = _request.uri;
         if(_request.data != null)
         {
            urlRequest.data = _request.data.b;
         }
         else
         {
            _loc4_ = _request.formData;
            _loc5_ = _loc4_.h;
            _loc6_ = _loc4_.rh;
            _loc7_ = 0;
            _loc8_ = false;
            _loc9_ = _loc5_;
            _loc10_ = _loc7_;
            _loc11_ = Boot.__hasnext(_loc9_,_loc10_);
            if(!_loc11_ && _loc6_ != null)
            {
               _loc5_ = _loc6_;
               _loc9_ = _loc5_;
               _loc7_ = 0;
               _loc10_ = _loc7_;
               _loc6_ = null;
               _loc8_ = true;
               _loc11_ = Boot.__hasnext(_loc9_,_loc10_);
            }
            _loc12_ = _loc10_;
            while(true)
            {
               _loc13_ = _loc5_;
               _loc14_ = _loc7_;
               _loc15_ = Boot.__hasnext(_loc13_,_loc14_);
               if(!_loc15_ && _loc6_ != null)
               {
                  _loc5_ = _loc6_;
                  _loc13_ = _loc5_;
                  _loc7_ = 0;
                  _loc14_ = _loc7_;
                  _loc6_ = null;
                  _loc8_ = true;
                  _loc15_ = Boot.__hasnext(_loc13_,_loc14_);
               }
               _loc12_ = _loc14_;
               if(!_loc15_)
               {
                  break;
               }
               _loc16_ = Boot.__nextname(_loc12_,_loc5_);
               _loc7_ = _loc12_;
               if(_loc8_)
               {
                  _loc16_ = _loc16_.substr(1);
               }
               _loc17_ = _loc16_;
               if(_loc2_.length > 0)
               {
                  _loc2_ += "&";
               }
               _loc18_ = encodeURIComponent(_loc17_) + "=";
               _loc19_ = _request.formData;
               _loc20_ = Std.string(_loc17_ in StringMap.reserved ? _loc19_.getReserved(_loc17_) : _loc19_.h[_loc17_]);
               _loc2_ += _loc18_ + encodeURIComponent(_loc20_);
            }
            if(_loc2_ != "" && _request.method == "GET")
            {
               if(_loc3_.indexOf("?") > -1)
               {
                  _loc3_ += "&" + _loc2_;
               }
               else
               {
                  _loc3_ += "?" + _loc2_;
               }
               _loc2_ = "";
            }
         }
         if(param1)
         {
            urlLoader.dataFormat = "binary";
         }
         urlRequest.url = _loc3_;
         urlRequest.contentType = _request.contentType;
         urlRequest.method = _request.method == "POST" ? "POST" : "GET";
         _loc7_ = 0;
         var _loc21_:Array = _request.headers;
         while(_loc7_ < int(_loc21_.length))
         {
            _loc22_ = _loc21_[_loc7_];
            _loc7_++;
            urlRequest.requestHeaders.push(new URLRequestHeader(_loc22_.name,_loc22_.value));
         }
      }
      
      public function cancel() : void
      {
         if(urlLoader != null)
         {
            urlLoader.close();
         }
      }
   }
}

