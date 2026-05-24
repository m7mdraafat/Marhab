package com.distriqt.extension.facebook.core
{
   import com.distriqt.extension.facebook.graphapi.GraphAPI;
   import com.distriqt.extension.facebook.graphapi.GraphRequest;
   import com.distriqt.extension.facebook.graphapi.GraphRequestBatch;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal final class _GraphAPIImpl extends EventDispatcher implements GraphAPI
   {
      
      private var _extContext:ExtensionContext;
      
      private var _currentPermissions:Array;
      
      public function _GraphAPIImpl(param1:ExtensionContext)
      {
         super();
         _extContext = param1;
         _extContext.addEventListener("status",extContext_statusHandler);
      }
      
      public function dispose() : void
      {
         if(_extContext != null)
         {
            _extContext.removeEventListener("status",extContext_statusHandler);
            _extContext = null;
         }
      }
      
      public function get isSupported() : Boolean
      {
         try
         {
            return _extContext.call("graphapi_isSupported") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function makeRequest(param1:GraphRequest) : Boolean
      {
         try
         {
            if(param1 is _GraphRequestImpl)
            {
               _GraphRequestImpl(param1).setContext(_extContext);
               return _GraphRequestImpl(param1).makeRequest();
            }
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function makeBatchRequest(param1:GraphRequestBatch) : Boolean
      {
         try
         {
            if(param1 is _GraphRequestBatchImpl)
            {
               _GraphRequestBatchImpl(param1).setContext(_extContext);
               return _GraphRequestBatchImpl(param1).makeRequest();
            }
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function extContext_statusHandler(param1:StatusEvent) : void
      {
      }
   }
}

