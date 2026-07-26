package air.net
{
   import flash.net.SecureSocket;
   import flash.net.Socket;
   
   public class SecureSocketMonitor extends SocketMonitor
   {
      
      public function SecureSocketMonitor(param1:String, param2:int)
      {
         super(param1,param2);
      }
      
      override public function toString() : String
      {
         return "[SecureSocketMonitor host=\"" + host + "\" port=\"" + port + "\" available=\"" + available + "\"]";
      }
      
      override protected function createSocket() : Socket
      {
         if(!SecureSocket.isSupported)
         {
            return null;
         }
         return new SecureSocket();
      }
   }
}

