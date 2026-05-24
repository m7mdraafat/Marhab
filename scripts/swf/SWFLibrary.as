package swf
{
   import flash.Boot;
   import flash.display.AVM1Movie;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   import haxe.Resource;
   import haxe.ds.StringMap;
   import haxe.io.Bytes;
   import lime.app.Future;
   import lime.app.Promise;
   import lime.graphics.Image;
   import openfl.utils.AssetLibrary;
   import openfl.utils._ByteArray.ByteArray_Impl_;
   
   public class SWFLibrary extends AssetLibrary
   {
      
      public static var __meta__:* = {"obj":{"SuppressWarnings":["checkstyle:FieldDocComment"]}};
      
      public var loader:Loader;
      
      public var id:String;
      
      public var context:LoaderContext;
      
      public var applicationDomain:ApplicationDomain;
      
      public function SWFLibrary(param1:String = undefined)
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         id = param1;
      }
      
      override public function load() : Future
      {
         var promise1:Promise;
         var _gthis:SWFLibrary;
         var _loc2_:Boolean = false;
         var _loc3_:* = null as String;
         var _loc4_:* = null as StringMap;
         var _loc5_:Boolean = false;
         _gthis = this;
         promise1 = new Promise();
         var _loc1_:ByteArray = ByteArray_Impl_.fromBytes(Resource.getBytes("swf:" + id));
         if(_loc1_ == null)
         {
            _loc3_ = id;
            _loc4_ = classTypes;
            _loc2_ = _loc3_ in StringMap.reserved ? _loc4_.existsReserved(_loc3_) : _loc3_ in _loc4_.h;
         }
         else
         {
            _loc2_ = false;
         }
         if(_loc2_)
         {
            _loc3_ = id;
            _loc4_ = classTypes;
            _loc1_ = Type.createInstance(_loc3_ in StringMap.reserved ? _loc4_.getReserved(_loc3_) : _loc4_.h[_loc3_],[]);
         }
         if(_loc1_ == null)
         {
            _loc3_ = id;
            _loc4_ = paths;
            _loc5_ = _loc3_ in StringMap.reserved ? _loc4_.existsReserved(_loc3_) : _loc3_ in _loc4_.h;
         }
         else
         {
            _loc5_ = true;
         }
         if(_loc5_)
         {
            context = new LoaderContext(false,ApplicationDomain.currentDomain,null);
            context.allowCodeImport = true;
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function(param1:IOErrorEvent):void
            {
               promise1.error(param1.text);
            });
            loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,function(param1:ProgressEvent):void
            {
               promise1.progress(int(param1.bytesLoaded),int(param1.bytesTotal));
            });
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(param1:*):void
            {
               _gthis.applicationDomain = _gthis.loader.contentLoaderInfo.applicationDomain;
               promise1.complete(_gthis);
            });
            if(_loc1_ != null)
            {
               loader.loadBytes(_loc1_,context);
            }
            else
            {
               _loc3_ = id;
               _loc4_ = paths;
               loader.load(new URLRequest(_loc3_ in StringMap.reserved ? _loc4_.getReserved(_loc3_) : _loc4_.h[_loc3_]),context);
            }
         }
         else
         {
            applicationDomain = ApplicationDomain.currentDomain;
            promise1.complete(this);
         }
         return promise1.future;
      }
      
      override public function isLocal(param1:String, param2:String) : Boolean
      {
         return true;
      }
      
      override public function getMovieClip(param1:String) : MovieClip
      {
         var _loc2_:* = null as MovieClip;
         if(param1 == "")
         {
            if(Std.isOfType(loader.content,AVM1Movie))
            {
               _loc2_ = new MovieClip();
               _loc2_.addChild(loader);
               return _loc2_;
            }
            return loader.content;
         }
         return Type.createInstance(applicationDomain.getDefinition(param1),[]);
      }
      
      override public function getImage(param1:String) : Image
      {
         return Image.fromBitmapData(Type.createEmptyInstance(applicationDomain.getDefinition(param1)));
      }
      
      override public function exists(param1:String, param2:String) : Boolean
      {
         if(param1 == "" && param2 == "MOVIE_CLIP")
         {
            return true;
         }
         if(param2 == "IMAGE" || param2 == "MOVIE_CLIP")
         {
            return applicationDomain.hasDefinition(param1);
         }
         return false;
      }
   }
}

