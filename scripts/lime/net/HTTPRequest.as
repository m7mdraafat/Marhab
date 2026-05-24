package lime.net
{
   import flash.Boot;
   import lime.net._HTTPRequest.AbstractHTTPRequest;
   
   public class HTTPRequest extends AbstractHTTPRequest
   {
      
      public function HTTPRequest(param1:String = undefined)
      {
         super(param1);
         if(Boot.skip_constructor)
         {
            return;
         }
      }
   }
}

