package air.desktop
{
   import flash.desktop.IFilePromise;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.IDataInput;
   
   [Version("air2.0")]
   [Event(name="securityError",type="flash.events.SecurityErrorEvent")]
   [Event(name="httpStatus",type="flash.events.HTTPStatusEvent")]
   [Event(name="httpResponseStatus",type="flash.events.HTTPStatusEvent")]
   [Event(name="ioError",type="flash.events.IOErrorEvent")]
   [Event(name="progress",type="flash.events.ProgressEvent")]
   [Event(name="complete",type="flash.events.Event")]
   [Event(name="open",type="flash.events.Event")]
   public class URLFilePromise extends EventDispatcher implements IFilePromise
   {
      
      private var _request:URLRequest;
      
      private var _relativePath:String;
      
      private var _stream:URLStream;
      
      public function URLFilePromise()
      {
         super();
      }
      
      public function set relativePath(param1:String) : void
      {
         this._relativePath = param1;
      }
      
      private function reflectURLStreamEvent(param1:Event) : void
      {
         if(!(param1 is IOErrorEvent) && !(param1 is SecurityErrorEvent))
         {
            dispatchEvent(param1);
         }
      }
      
      public function open() : IDataInput
      {
         this._stream = new URLStream();
         this.registerEventHandlers();
         this._stream.load(this._request);
         return this._stream;
      }
      
      private function registerEventHandlers() : void
      {
         if(Boolean(this._stream))
         {
            this._stream.addEventListener(Event.OPEN,this.reflectURLStreamEvent);
            this._stream.addEventListener(Event.COMPLETE,this.reflectURLStreamEvent);
            this._stream.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.reflectURLStreamEvent);
            this._stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,this.reflectURLStreamEvent);
            this._stream.addEventListener(ProgressEvent.PROGRESS,this.reflectURLStreamEvent);
            this._stream.addEventListener(IOErrorEvent.IO_ERROR,this.reflectURLStreamEvent);
            this._stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.reflectURLStreamEvent);
         }
      }
      
      private function unregisterEventHandlers() : void
      {
         if(Boolean(this._stream))
         {
            this._stream.removeEventListener(Event.OPEN,this.reflectURLStreamEvent);
            this._stream.removeEventListener(Event.COMPLETE,this.reflectURLStreamEvent);
            this._stream.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.reflectURLStreamEvent);
            this._stream.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,this.reflectURLStreamEvent);
            this._stream.removeEventListener(ProgressEvent.PROGRESS,this.reflectURLStreamEvent);
            this._stream.removeEventListener(IOErrorEvent.IO_ERROR,this.reflectURLStreamEvent);
            this._stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.reflectURLStreamEvent);
         }
      }
      
      public function get request() : URLRequest
      {
         return this._request;
      }
      
      public function get relativePath() : String
      {
         return this._relativePath;
      }
      
      public function get isAsync() : Boolean
      {
         return true;
      }
      
      public function reportError(param1:ErrorEvent) : void
      {
         dispatchEvent(param1);
      }
      
      public function close() : void
      {
         if(Boolean(this._stream))
         {
            this._stream.close();
         }
         this.unregisterEventHandlers();
      }
      
      public function set request(param1:URLRequest) : void
      {
         this._request = param1;
      }
   }
}

