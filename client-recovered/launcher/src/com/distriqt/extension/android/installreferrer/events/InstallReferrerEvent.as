package com.distriqt.extension.android.installreferrer.events
{
   import flash.events.Event;
   
   public class InstallReferrerEvent extends Event
   {
      
      private static const TAG:String = "InstallReferrerEvent";
      
      public static const COMPLETE:String = "installreferrer:complete";
      
      public static const FEATURE_NOT_SUPPORTED:String = "installreferrer:feature_not_supported";
      
      public static const SERVICE_UNAVAILABLE:String = "installreferrer:service_unavailable";
      
      public var referrerUrl:String;
      
      public function InstallReferrerEvent(param1:String, param2:String, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.referrerUrl = param2;
      }
      
      override public function clone() : Event
      {
         return new InstallReferrerEvent(type,referrerUrl,bubbles,cancelable);
      }
   }
}

