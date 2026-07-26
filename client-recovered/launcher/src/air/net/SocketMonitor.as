package air.net
{
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.Socket;
   
   public class SocketMonitor extends ServiceMonitor
   {
      
      private var _port:int;
      
      private var _host:String;
      
      private var _socket:Socket;
      
      private var connecting:Boolean = false;
      
      public function SocketMonitor(param1:String, param2:int)
      {
         var cool:Function = null;
         var uncool:Function = null;
         var host:String = param1;
         var port:int = param2;
         this._socket = this.createSocket();
         cool = function(param1:Event):void
         {
            var event:Event = param1;
            available = true;
            try
            {
               _socket.close();
            }
            catch(e:IOError)
            {
            }
            connecting = false;
         };
         uncool = function(param1:Event):void
         {
            var event:Event = param1;
            available = false;
            try
            {
               _socket.close();
            }
            catch(e:IOError)
            {
            }
            connecting = false;
         };
         super();
         this._host = host;
         this._port = port;
         if(!this._socket)
         {
            stop();
            return;
         }
         this._socket.addEventListener(Event.CONNECT,cool);
         this._socket.addEventListener(IOErrorEvent.IO_ERROR,uncool);
         this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,uncool);
      }
      
      public function get port() : int
      {
         return this._port;
      }
      
      public function get host() : String
      {
         return this._host;
      }
      
      override public function toString() : String
      {
         return "[SocketMonitor host=\"" + this._host + "\" port=\"" + this._port + "\" available=\"" + available + "\"]";
      }
      
      protected function createSocket() : Socket
      {
         return new Socket();
      }
      
      override protected function checkStatus() : void
      {
         if(!this._socket)
         {
            stop();
            return;
         }
         if(this.connecting)
         {
            return;
         }
         this.connecting = true;
         this._socket.connect(this._host,this._port);
      }
   }
}

