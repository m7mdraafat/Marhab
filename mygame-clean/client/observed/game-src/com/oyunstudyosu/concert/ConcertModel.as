package com.oyunstudyosu.concert
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.greensock.TweenMax;
   import com.oyunstudyosu.assets.AssetRequest;
   import com.oyunstudyosu.assets.IAssetRequest;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import com.oyunstudyosu.sanalika.interfaces.IConcertModel;
   import com.smartfoxserver.v2.core.SFSEvent;
   import com.smartfoxserver.v2.entities.Room;
   import com.smartfoxserver.v2.entities.User;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   
   public class ConcertModel implements IConcertModel
   {
      
      private var groupName:String;
      
      private var swfPath:String;
      
      private var soundPath:String;
      
      private var sound:Sound;
      
      private var soundchannel:SoundChannel;
      
      private var request:IAssetRequest;
      
      private var clip:MovieClip;
      
      private var soundList:Array;
      
      private var swfList:Array;
      
      private var isPlaying:Boolean;
      
      private var delayCount:int;
      
      private var groupError:Boolean;
      
      private var mediaData:Object;
      
      private var isSceneLoaded:Boolean = false;
      
      public var radio:Boolean = false;
      
      public function ConcertModel()
      {
         super();
         Connectr.instance.serviceModel.listenExtension("mediaevent",concertVariableUpdate);
         Dispatcher.addEventListener("SCENE_LOADED",sceneLoaded);
      }
      
      private function concertVariableUpdate(param1:Object) : void
      {
         mediaData = param1.path;
         if(param1.status == 1)
         {
            delayCount = 0;
            if(!isPlaying && isSceneLoaded)
            {
               playMedia(mediaData,false);
            }
         }
         else
         {
            disposeMedia(param1.status);
         }
      }
      
      public function playMedia(param1:Object, param2:Boolean = false) : void
      {
         radio = param2;
         soundPath = param1.stream_path;
         groupName = param1.groupID;
         if(soundPath != null)
         {
            TweenMax.killDelayedCallsTo(playMedia);
            if(sound)
            {
               sound.removeEventListener("ioError",streamError);
               sound.removeEventListener(Event.OPEN,onStreamOpen);
               try
               {
                  sound.close();
               }
               catch(e:Error)
               {
               }
            }
            if(soundchannel)
            {
               soundchannel.removeEventListener(Event.SOUND_COMPLETE,onStreamComplete);
               soundchannel.stop();
            }
            isPlaying = true;
            sound = new Sound();
            soundchannel = null;
            sound.addEventListener(Event.OPEN,onStreamOpen);
            sound.addEventListener("ioError",streamError);
            sound.load(new URLRequest(soundPath),new SoundLoaderContext(1000,true));
         }
         if(groupName != null && groupName != "" && clip == null && !groupError)
         {
            swfPath = CaptureRuntime.sanalikaInstance.moduleModel.getPath(groupName,"ModuleType.CONCERT_SWF");
            request = new AssetRequest();
            request.assetId = swfPath;
            request.type = "ModuleType.CONCERT_SWF";
            request.loadedFunction = onLoaded;
            request.errorFunction = onError;
            request.context = CaptureRuntime.sanalikaInstance.domainModel.assetContext;
            request.priority = 99;
            CaptureRuntime.sanalikaInstance.assetModel.request(request);
         }
      }
      
      private function onError(param1:Object) : void
      {
         groupError = true;
      }
      
      private function onStreamOpen(param1:Event) : void
      {
         if(sound)
         {
            sound.removeEventListener(Event.OPEN,onStreamOpen);
            soundchannel = sound.play();
            if(soundchannel)
            {
               soundchannel.addEventListener(Event.SOUND_COMPLETE,onStreamComplete);
            }
         }
      }
      
      private function onStreamComplete(param1:Event) : void
      {
         if(soundchannel)
         {
            soundchannel.removeEventListener(Event.SOUND_COMPLETE,onStreamComplete);
         }
         if(sound)
         {
            sound.removeEventListener("ioError",streamError);
            sound.removeEventListener(Event.OPEN,onStreamOpen);
            try
            {
               sound.close();
            }
            catch(e:Error)
            {
            }
         }
         isPlaying = false;
         sound = null;
         soundchannel = null;
         soundPath = "";
      }
      
      protected function streamError(param1:IOErrorEvent) : void
      {
         if(sound)
         {
            sound.removeEventListener("ioError",streamError);
            sound.removeEventListener(Event.OPEN,onStreamOpen);
            try
            {
               sound.close();
            }
            catch(e:Error)
            {
            }
            sound = null;
         }
         if(soundchannel)
         {
            soundchannel.removeEventListener(Event.SOUND_COMPLETE,onStreamComplete);
            soundchannel.stop();
            soundchannel = null;
         }
         soundPath = "";
         isPlaying = false;
         if(mediaData)
         {
            delayCount += 1;
            if(delayCount < 50)
            {
               TweenMax.killDelayedCallsTo(playMedia);
               TweenMax.delayedCall(3 * delayCount,playMedia,[mediaData,radio]);
            }
         }
      }
      
      private function onLoaded(param1:IAssetRequest) : void
      {
         clip = param1.display as MovieClip;
         param1.dispose();
         if(CaptureRuntime.sanalikaInstance.engine.scene.bg)
         {
            CaptureRuntime.sanalikaInstance.engine.scene.bg.addChild(clip);
         }
      }
      
      private function sceneLoaded(param1:GameEvent) : void
      {
         if(radio)
         {
            return;
         }
         isSceneLoaded = true;
         if(mediaData == null)
         {
            return;
         }
         CaptureRuntime.sanalikaInstance.serviceModel.sfs.addEventListener("userExitRoom",onUserExitRoom);
         playMedia(mediaData,false);
      }
      
      private function onUserExitRoom(param1:SFSEvent) : void
      {
         if(radio)
         {
            return;
         }
         var _loc3_:Room = param1.params.room;
         var _loc2_:User = param1.params.user;
         if(_loc3_.isGame)
         {
            return;
         }
         if(_loc2_.isItMe)
         {
            disposeMedia(2);
         }
      }
      
      public function disposeMedia(param1:Boolean) : void
      {
         TweenMax.killDelayedCallsTo(playMedia);
         if(sound)
         {
            sound.removeEventListener("ioError",streamError);
            sound.removeEventListener(Event.OPEN,onStreamOpen);
            try
            {
               sound.close();
            }
            catch(e:Error)
            {
            }
         }
         if(soundchannel)
         {
            soundchannel.removeEventListener(Event.SOUND_COMPLETE,onStreamComplete);
            soundchannel.stop();
         }
         if(clip && CaptureRuntime.sanalikaInstance.engine.scene.bg.contains(clip))
         {
            CaptureRuntime.sanalikaInstance.engine.scene.bg.removeChild(clip);
         }
         if(clip)
         {
            clip.stop();
            clip = null;
         }
         if(param1 == 0 || param1 == 1)
         {
            isPlaying = false;
         }
         if(param1 == 2)
         {
            isSceneLoaded = false;
         }
         groupError = false;
         sound = null;
         soundchannel = null;
         soundPath = "";
         groupName = null;
         soundPath = null;
         mediaData = null;
         CaptureRuntime.sanalikaInstance.serviceModel.sfs.removeEventListener("userExitRoom",onUserExitRoom);
      }
   }
}

