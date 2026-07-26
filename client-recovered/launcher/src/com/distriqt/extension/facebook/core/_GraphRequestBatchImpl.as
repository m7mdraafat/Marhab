package com.distriqt.extension.facebook.core
{
   import com.distriqt.extension.facebook.graphapi.GraphRequest;
   import com.distriqt.extension.facebook.graphapi.GraphRequestBatch;
   import com.distriqt.extension.facebook.graphapi.events.GraphRequestEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   
   internal class _GraphRequestBatchImpl extends EventDispatcher implements GraphRequestBatch
   {
      
      private static const TAG:String = "_GraphRequestBatchImpl";
      
      private var _extContext:ExtensionContext;
      
      private var _identifier:String = "";
      
      private var _requests:Array;
      
      private var _onComplete:Function;
      
      public function _GraphRequestBatchImpl()
      {
         super();
         _requests = [];
      }
      
      public function get requests() : Array
      {
         return _requests;
      }
      
      public function set onComplete(param1:Function) : void
      {
         _onComplete = param1;
      }
      
      private function cleanup() : void
      {
         _onComplete = null;
         clearContext();
      }
      
      private function clearContext() : void
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
      
      public function addRequest(param1:GraphRequest) : void
      {
         _requests.push(param1);
      }
      
      internal function makeRequest() : Boolean
      {
         var _loc1_:int = 0;
         try
         {
            _identifier = _extContext.call("graphapi_makeRequestBatch",this) as String;
            _loc1_ = 0;
            while(_loc1_ < _requests.length)
            {
               _GraphRequestImpl(_requests[_loc1_]).setContext(_extContext);
               _GraphRequestImpl(_requests[_loc1_])._identifier = _identifier + String(_loc1_);
               _loc1_++;
            }
            return _identifier != "";
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function isGraphRequestBatchEvent(param1:StatusEvent) : Boolean
      {
         var _loc2_:String = param1.code;
         if("facebook_graphrequest_batch_complete" !== _loc2_)
         {
            return false;
         }
         return true;
      }
      
      private function extContext_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         if(isGraphRequestBatchEvent(param1))
         {
            try
            {
               _loc2_ = JSON.parse(param1.level);
               if(_loc2_.identifier == _identifier)
               {
                  var _loc6_:String = param1.code;
                  if("facebook_graphrequest_batch_complete" === _loc6_)
                  {
                     dispatchEvent(new GraphRequestEvent(param1.code,null));
                     if(_onComplete != null)
                     {
                        try
                        {
                           _onComplete();
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

