package com.distriqt.extension.facebook.graphapi
{
   import flash.events.IEventDispatcher;
   
   [Event(name="facebook_graphrequest_batch_complete",type="com.distriqt.extension.facebook.graphapi.events.GraphRequestEvent")]
   public interface GraphRequestBatch extends IEventDispatcher
   {
      
      function addRequest(param1:GraphRequest) : void;
      
      function set onComplete(param1:Function) : void;
   }
}

