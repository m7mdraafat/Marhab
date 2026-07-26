package com.distriqt.extension.facebook.graphapi.builders
{
   import com.distriqt.extension.facebook.core.Facebook;
   import com.distriqt.extension.facebook.core.facebook_core_internal;
   import com.distriqt.extension.facebook.graphapi.GraphRequest;
   import com.distriqt.extension.facebook.graphapi.GraphRequestBatch;
   
   use namespace facebook_core_internal;
   
   public class GraphRequestBatchBuilder
   {
      
      private static const TAG:String = "GraphRequestBatchBuilder";
      
      private var _batch:GraphRequestBatch;
      
      public function GraphRequestBatchBuilder()
      {
         super();
         _batch = Facebook.instance.createGraphRequestBatch();
      }
      
      public function addRequest(param1:GraphRequest) : GraphRequestBatchBuilder
      {
         _batch.addRequest(param1);
         return this;
      }
      
      public function setCompleteCallback(param1:Function) : GraphRequestBatchBuilder
      {
         _batch.onComplete = param1;
         return this;
      }
      
      public function build() : GraphRequestBatch
      {
         return _batch;
      }
   }
}

