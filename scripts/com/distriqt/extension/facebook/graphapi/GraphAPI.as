package com.distriqt.extension.facebook.graphapi
{
   import flash.events.IEventDispatcher;
   
   public interface GraphAPI extends IEventDispatcher
   {
      
      function get isSupported() : Boolean;
      
      function makeRequest(param1:GraphRequest) : Boolean;
      
      function makeBatchRequest(param1:GraphRequestBatch) : Boolean;
   }
}

