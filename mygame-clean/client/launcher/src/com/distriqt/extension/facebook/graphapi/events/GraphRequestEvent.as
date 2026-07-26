package com.distriqt.extension.facebook.graphapi.events
{
   import flash.events.Event;
   
   public class GraphRequestEvent extends Event
   {
      
      public static const COMPLETE:String = "facebook_graphrequest_complete";
      
      public static const ERROR:String = "facebook_graphrequest_error";
      
      public static const BATCH_COMPLETE:String = "facebook_graphrequest_batch_complete";
      
      public var data:Object;
      
      public var errorCode:int;
      
      public var errorMessage:String;
      
      public function GraphRequestEvent(param1:String, param2:Object, param3:int = -1, param4:String = "", param5:Boolean = false, param6:Boolean = false)
      {
         super(param1,param5,param6);
         this.data = param2;
         this.errorCode = param3;
         this.errorMessage = param4;
      }
      
      override public function clone() : Event
      {
         return new GraphRequestEvent(type,data,errorCode,errorMessage,bubbles,cancelable);
      }
   }
}

