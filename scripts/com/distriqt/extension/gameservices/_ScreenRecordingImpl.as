package com.distriqt.extension.gameservices
{
   import com.distriqt.extension.gameservices.events.ScreenRecordingEvent;
   import com.distriqt.extension.gameservices.recording.ScreenRecording;
   import com.distriqt.extension.gameservices.recording.ScreenRecordingOptions;
   import flash.display.Bitmap;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.filesystem.File;
   
   internal class _ScreenRecordingImpl extends EventDispatcher implements ScreenRecording
   {
      
      private static const TAG:String = "_ScreenRecordingImpl";
      
      [Embed(source="/com/distriqt/extension/gameservices/recording/stop_recording_button.png")]
      private static var DefaultStopRecordingButton:Class = stop_recording_button_png$90d74ac431f78120c11f3fa0c66bf63b1350089600;
      
      private var _extContext:ExtensionContext;
      
      private var _availabilityCallbacks:Array = [];
      
      public function _ScreenRecordingImpl(param1:ExtensionContext)
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
            return _extContext.call("screenrecording_isSupported") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function checkAvailability(param1:Function = null) : Boolean
      {
         try
         {
            _availabilityCallbacks.push(param1);
            return _extContext.call("screenrecording_checkAvailability") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function start(param1:ScreenRecordingOptions = null) : Boolean
      {
         var _loc2_:File = null;
         try
         {
            if(param1 == null)
            {
               param1 = new ScreenRecordingOptions();
            }
            _loc2_ = new File(param1.filepath);
            if(_loc2_.exists)
            {
               _loc2_.deleteFile();
            }
            if(param1.uiOverlayStopButton == null)
            {
               param1.uiOverlayStopButton = (new DefaultStopRecordingButton() as Bitmap).bitmapData;
            }
            return _extContext.call("screenrecording_start",param1) as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function stop() : Boolean
      {
         try
         {
            return _extContext.call("screenrecording_stop") as Boolean;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      private function extContext_statusHandler(param1:StatusEvent) : void
      {
         var _loc2_:Object = null;
         try
         {
            switch(param1.code)
            {
               case "screenrecording:availability:changed":
                  _loc2_ = JSON.parse(param1.level);
                  for each(var _loc3_ in _availabilityCallbacks)
                  {
                     _loc3_(_loc2_.available);
                  }
                  _availabilityCallbacks = [];
                  dispatchEvent(new ScreenRecordingEvent(param1.code));
                  break;
               case "screenrecording:started":
               case "screenrecording:stopped":
               case "screenrecording:controls:shown":
               case "screenrecording:controls:closed":
               case "screenrecording:preview:shown":
               case "screenrecording:preview:closed":
                  dispatchEvent(new ScreenRecordingEvent(param1.code));
                  break;
               case "screenrecording:complete":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new ScreenRecordingEvent(param1.code,_loc2_.filepath));
                  break;
               case "screenrecording:error":
                  _loc2_ = JSON.parse(param1.level);
                  dispatchEvent(new ScreenRecordingEvent(param1.code,null,_loc2_.message,_loc2_.code));
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

