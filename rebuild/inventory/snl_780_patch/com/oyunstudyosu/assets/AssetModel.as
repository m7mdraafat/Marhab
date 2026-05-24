package com.oyunstudyosu.assets
{
   import com.adobe.crypto.MD5;
   import com.greensock.events.LoaderEvent;
   import com.greensock.loading.BinaryDataLoader;
   import com.greensock.loading.LoaderMax;
   import com.oyunstudyosu.enums.ModuleType;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import com.oyunstudyosu.utils.Tracker;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.ImageDecodingPolicy;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class AssetModel implements IAssetModel
   {
      
      private static var _cR:Array = [126,185,243,211,108,23,65,132,168,138,193,92,246,207,209,46,61,98,149,180,62,92,175,148,161,219,183,59,148,73,104,237,227,252,85,26,20,31,133,135,215,252,197,90,38,41,205,208,231,63,97,76,69,202,147,69,127,26,83,56,184,82,158,213,184,181,114,77,3,6,50,173,61,242,216,142,105,20,194,190,162,87,53,110,171,221,83,240,168,151,100,97,11,25,45,246];
      
      private static var _nB1:Array = [163,88,199,30,155,116,240,45,70,191,131,225];
      
      private static var _nB2:Array = [103,222,75,140,49,169,245,18,122,196,94,144];
      
      private static var _nB3:Array = [210,79,136,19,174,101,201,60,113,250,39,182];
      
      private static var _qW:Array = null;
      
      private static var _hV:Array = [1576739526,2358602276,194787283,2461872539,1727829726,2901912621,678501642,1813121464];
      
      private static var _hM:uint = 938656929;
      
      private var FileStream:Class;
      
      private var File:Class;
      
      private var stage:Stage;
      
      public var queueLength:int = 0;
      
      public var queueLimit:int = 7;
      
      public var queue:Array;
      
      public var requestList:Dictionary;
      
      public var fileStreamQueue:Dictionary;
      
      public var pendingList:Dictionary;
      
      public var loadingList:Dictionary;
      
      protected var context:LoaderContext;
      
      private var allowedModuleTypes:Vector.<String>;
      
      public var assetList:Vector.<AssetData> = new Vector.<AssetData>();
      
      private var _vK3:Dictionary = new Dictionary();
      
      public function AssetModel(param1:Stage)
      {
         super();
         this.stage = param1;
         this.queue = new Array();
         this.fileStreamQueue = new Dictionary();
         this.requestList = new Dictionary();
         this.pendingList = new Dictionary();
         this.loadingList = new Dictionary();
         this.context = new LoaderContext();
         this.context.checkPolicyFile = true;
         this.context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
         this.context.securityDomain = null;
         this.context.allowCodeImport = false;
         this.context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
         this.allowedModuleTypes = new Vector.<String>();
         this.allowedModuleTypes.push(ModuleType.CLOTH_PNG);
         this.allowedModuleTypes.push("BG");
         this.allowedModuleTypes.push(ModuleType.PNG);
         this.allowedModuleTypes.push("BMP");
         this.allowedModuleTypes.push(ModuleType.PANEL);
         this.allowedModuleTypes.push("OTHER");
         this.allowedModuleTypes.push(ModuleType.EXTENSION);
         this.allowedModuleTypes.push(ModuleType.FURNITURE_EDITOR);
         this.allowedModuleTypes.push(ModuleType.AD_AIRSHIP);
         this.allowedModuleTypes.push(ModuleType.AD_BILLBOARD);
         this.allowedModuleTypes.push(ModuleType.AD_BOT);
         this.allowedModuleTypes.push(ModuleType.AD_SKIN);
         this.allowedModuleTypes.push(ModuleType.SMILEY);
         this.allowedModuleTypes.push(ModuleType.PROFILE_SKIN);
      }
      
      private static function _mW6(_a:Array, _b:Array) : Array
      {
         var _r:Array = new Array(_a.length);
         var _i:int = 0;
         while(_i < _a.length)
         {
            _r[_i] = int(_a[_i]) + int(_b[_i % _b.length]) & 0xFF;
            _i++;
         }
         return _r;
      }
      
      private static function _pL2(_k:Array) : Array
      {
         var _s:Array = new Array(256);
         var _j:int = 0;
         var _i:int = 0;
         while(_i < 256)
         {
            _s[_i] = _i;
            _i++;
         }
         _i = 0;
         while(_i < 256)
         {
            _j = _j + _s[_i] + int(_k[_i % _k.length]) & 0xFF;
            var _t:int = int(_s[_i]);
            _s[_i] = _s[_j];
            _s[_j] = _t;
            _i++;
         }
         if(_nB3.length == 0)
         {
            _i = 0;
            while(_i < 128)
            {
               _t = int(_s[_i]);
               _s[_i] = _s[255 - _i];
               _s[255 - _i] = _t;
               _i++;
            }
         }
         return _s;
      }
      
      private static function _kZ2(_a:Array, _b:int) : int
      {
         var _r:int = 0;
         var _i:int = 0;
         while(_i < _a.length)
         {
            _r = _r + int(_a[_i]) * (_b + _i) & 0xFFFF;
            _i++;
         }
         return _r ^ int(_nB3[_b & 7]);
      }
      
      private static function _tG6(_d:ByteArray, _rk:Array, _pn:int) : ByteArray
      {
         var _n:int = int(_d.length);
         if(_n == 0)
         {
            return _d;
         }
         var _o:uint = 0;
         var _i:int = 0;
         while(_i < _rk.length)
         {
            _o = uint(uint(_o) + uint(_rk[_i]) * uint(_pn + 1));
            _i++;
         }
         _o %= _n;
         var _sp:int = _n - _o;
         var _r:ByteArray = new ByteArray();
         if(_nB1.length == 0)
         {
            _sp = 0;
         }
         _i = _sp;
         while(_i < _n)
         {
            _r.writeByte(_d[_i]);
            _i++;
         }
         _i = 0;
         while(_i < _sp)
         {
            _r.writeByte(_d[_i]);
            _i++;
         }
         _r.position = 0;
         return _r;
      }
      
      private static function _jY9(_v:uint, _n:int) : uint
      {
         return _v >>> _n | _v << 32 - _n;
      }
      
      private static function _sH1(_mk:Array, _sl:ByteArray, _rn:int) : Array
      {
         var _c:Array = new Array(32);
         var _f:int = _nB3.length > 0 ? 0 : 7;
         var _i:int = 0;
         while(_i < 32)
         {
            _c[_i] = int(_mk[_i]) ^ int(_sl[_i % _sl.length]);
            _c[_i] = _c[_i] + _rn * 37 + _f & 0xFF;
            _i++;
         }
         var _it:int = 0;
         while(_it < 8)
         {
            var _h:Array = _uN8(_c,_rn * 1000 + _it);
            _i = 0;
            while(_i < 32)
            {
               _c[_i] = int(_h[_i]);
               _i++;
            }
            if(_nB1.length == 0)
            {
               _c[0] ^= int(_nB2[_it & 7]);
            }
            _it++;
         }
         return _c;
      }
      
      private static function _uN8(_a:Array, _c:int) : Array
      {
         var _f:Array = new Array(8);
         var _q:int = 0;
         while(_q < 8)
         {
            _f[_q] = uint(uint(_hV[_q]) ^ _hM);
            _q++;
         }
         var _i:int = 0;
         while(_i < _a.length)
         {
            _f[_i % 8] = uint(uint(_f[_i % 8]) + uint(_a[_i]) * uint(_i + 1) ^ uint(_f[(_i + 1) % 8]) >>> 3);
            _i++;
         }
         _f[0] = uint(uint(_f[0]) ^ uint(_c));
         var _lim:int = _nB2.length > 0 ? 64 : 48;
         _i = 0;
         while(_i < _lim)
         {
            var _w:uint = uint(_f[_i % 8]);
            _f[_i % 8] = uint((_w << 5 | _w >>> 27) ^ uint(_f[(_i + 3) % 8]));
            _i++;
         }
         var _o:Array = [];
         _i = 0;
         while(_i < 8)
         {
            _w = uint(_f[_i]);
            _o.push(_w >> 24 & 0xFF);
            _o.push(_w >> 16 & 0xFF);
            _o.push(_w >> 8 & 0xFF);
            _o.push(_w & 0xFF);
            _i++;
         }
         return _o;
      }
      
      private static function _rX7() : Array
      {
         if(_qW != null)
         {
            return _qW;
         }
         var _w:Array = new Array(32);
         var _t:int = _nB1.length > 0 ? 3 : 4;
         var _z:int = 0;
         while(_z < 32)
         {
            var _g:int = (_z >>> _t) * (_t << 3);
            var _b:int = (_z & 7) * _t;
            _w[_z] = _cR[_g + _b + 1] ^ _cR[_g + _b + 2];
            _z++;
         }
         if(_nB2.length > 0)
         {
            _nB3[0] = _w[0];
         }
         if(_nB3.length == 0)
         {
            _z = 0;
            while(_z < 32)
            {
               _w[_z] ^= int(_nB1[_z & 7]);
               _z++;
            }
         }
         _qW = _w;
         return _qW;
      }
      
      private static function _qM4(_s:Array) : Array
      {
         var _v:Array = new Array(256);
         var _i:int = 0;
         while(_i < 256)
         {
            _v[int(_s[_i])] = _i;
            _i++;
         }
         return _v;
      }
      
      private static function _wJ5(_k:Array, _tl:int) : ByteArray
      {
         var _x:ByteArray = new ByteArray();
         var _ct:int = 0;
         while(_x.length < _tl)
         {
            var _bl:Array = _uN8(_k,_ct);
            var _j:int = 0;
            while(_j < _bl.length)
            {
               if(_x.length >= _tl)
               {
                  break;
               }
               _x.writeByte(int(_bl[_j]));
               _ct++;
               _j++;
            }
         }
         _x.position = 0;
         return _x;
      }
      
      private static function _nR4(_d:ByteArray, _k:Array) : ByteArray
      {
         var _sl:ByteArray = new ByteArray();
         _d.position = 16;
         _d.readBytes(_sl,0,16);
         var _c:Array = new Array(32);
         var _i:int = 0;
         while(_i < 32)
         {
            _c[_i] = int(_k[_i]) ^ int(_sl[_i % _sl.length]);
            _i++;
         }
         var _h:Array = _uN8(_c,0);
         var _r:ByteArray = new ByteArray();
         _i = 0;
         while(_i < _h.length)
         {
            _r.writeByte(int(_h[_i]));
            _i++;
         }
         _r.position = 0;
         return _r;
      }
      
      private static function _vF3(_d:ByteArray, _rk:Array, _pn:int) : ByteArray
      {
         var _st:int = 7;
         var _kl:int = int(_rk.length);
         var _ln:int = int(_d.length);
         var _r0:int = int(_nB1[3]) & 0;
         while(_st != 0)
         {
            switch(_st + _r0)
            {
               case 7:
                  _d = _tG6(_d,_rk,_pn);
                  _st = 13;
                  break;
               case 13:
                  var _i:int = 0;
                  while(_i < _ln)
                  {
                     var _n:int = int(_rk[_i % _kl]) % 7 + 1;
                     _d[_i] = (_d[_i] >>> _n | _d[_i] << 8 - _n) & 0xFF;
                     _i++;
                  }
                  _st = 19;
                  break;
               case 4:
                  var _ex:ByteArray = _wJ5(_rk,_ln);
                  _i = 0;
                  while(_i < _ln)
                  {
                     _d[_i] = _d[_i] - _ex[_i] - (_i & 0xFF) & 0xFF;
                     _i++;
                  }
                  _st = 19;
                  break;
               case 19:
                  _i = _ln - 1;
                  while(_i > 0)
                  {
                     _d[_i] ^= _d[_i - 1];
                     _i--;
                  }
                  _d[0] ^= int(_rk[0]);
                  _st = 11;
                  break;
               case 8:
                  _i = 0;
                  while(_i < _nB2.length)
                  {
                     _nB2[_i] = (_nB2[_i] ^ int(_rk[_i % _kl])) & 0xFF;
                     _i++;
                  }
                  _st = 0;
                  break;
               case 11:
                  var _sb:Array = _pL2(_rk);
                  var _isb:Array = _qM4(_sb);
                  _i = 0;
                  while(_i < _ln)
                  {
                     _d[_i] = int(_isb[_d[_i]]);
                     _i++;
                  }
                  _st = 16;
                  break;
               case 15:
                  _sb = _pL2(_nB1);
                  _i = 0;
                  while(_i < _ln)
                  {
                     _d[_i] = int(_sb[_d[_i]]);
                     _i++;
                  }
                  _st = 0;
                  break;
               case 16:
                  _i = 0;
                  while(_i < _ln)
                  {
                     _d[_i] ^= int(_rk[_i % _kl]);
                     _i++;
                  }
                  _st = 2;
                  break;
               case 22:
                  var _fh:Array = _uN8(_nB3,_pn);
                  _i = 0;
                  while(_i < _ln && _i < _fh.length)
                  {
                     _d[_i] ^= int(_fh[_i]);
                     _i++;
                  }
                  _st = 0;
                  break;
               case 2:
                  var _hl:int = _ln >> 1;
                  _i = 0;
                  while(_i < _hl)
                  {
                     var _tmp:int = int(_d[_i]);
                     _d[_i] = _d[_ln - 1 - _i];
                     _d[_ln - 1 - _i] = _tmp;
                     _i++;
                  }
                  _st = 0;
                  break;
               default:
                  _nB3[1] = _nB3[1] + _ln & 0xFF;
                  _st = 0;
            }
         }
         _d.position = 0;
         return _d;
      }
      
      public function get ROOT() : String
      {
         return Connectr.instance.gameModel.fileServer;
      }
      
      public function getAsset(param1:String, param2:String) : AssetData
      {
         var _loc3_:AssetData = null;
         for each(_loc3_ in this.assetList)
         {
            if(_loc3_.assetId == param1 && _loc3_.type == param2)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function requestQueue(param1:AssetRequestQueue) : void
      {
         var _loc2_:AssetRequest = null;
         if(param1.isCompleted)
         {
            throw "Already completed queue cannot be requeued.";
         }
         for each(_loc2_ in param1.queue)
         {
            this.request(_loc2_);
         }
      }
      
      public function request(param1:IAssetRequest) : void
      {
         if(Connectr.instance != null && Connectr.instance.airModel != null && Boolean(Connectr.instance.airModel.isAir()))
         {
            this.File = this.stage.loaderInfo.applicationDomain.getDefinition("flash.filesystem.File") as Class;
            this.FileStream = this.stage.loaderInfo.applicationDomain.getDefinition("flash.filesystem.FileStream") as Class;
         }
         var _loc2_:* = this.pendingList[param1.assetId] != null;
         this.addPendingList(param1);
         if(!_loc2_)
         {
            this.addQueue(param1);
         }
         this.handleQueue();
      }
      
      public function addQueue(param1:IAssetRequest) : void
      {
         this.queue.push(param1);
      }
      
      public function handleQueue() : void
      {
         var _loc1_:IAssetRequest = null;
         if(this.queue.length == 0 || this.queueLength >= this.queueLimit)
         {
            return;
         }
         this.queue.sortOn("priority");
         this.queue.reverse();
         for each(_loc1_ in this.queue)
         {
            if(this.queueLength >= this.queueLimit)
            {
               break;
            }
            this.startLoad(_loc1_);
            this.queue.removeAt(this.queue.indexOf(_loc1_));
         }
      }
      
      protected function startLoad(param1:IAssetRequest) : void
      {
         var _loc2_:BinaryDataLoader = null;
         var _loc3_:* = undefined;
         var _loc4_:Loader = null;
         ++this.queueLength;
         if(Connectr.instance.airModel.isAir())
         {
            _loc3_ = null;
            if(Connectr.instance.cacheModel.resolvePath() != null)
            {
               _loc3_ = Connectr.instance.cacheModel.resolvePath().resolvePath(MD5.hash(param1.assetId));
            }
            if(_loc3_ != null && _loc3_.exists && Boolean(Connectr.instance.cacheModel.isAvailable))
            {
               // Cache hit: file:// URL works fine through BinaryDataLoader.
               _loc2_ = new BinaryDataLoader(_loc3_.url);
               this.loadingList[param1.assetId] = _loc2_;
               this.requestList[_loc2_] = param1;
               _loc2_.addEventListener(LoaderEvent.COMPLETE,this.onBinaryLoaded);
               _loc2_.addEventListener(LoaderEvent.ERROR,this.onBinaryError);
               _loc2_.addEventListener(LoaderEvent.FAIL,this.onBinaryError);
               _loc2_.load();
            }
            else
            {
               // Network fetch: route through launcher-side MyGameAssetProxy.
               // Inner-SWF URLLoader/BinaryDataLoader is silently denied for
               // remote hosts; the launcher's URLLoader is not.
               var _proxyUrl:String = (param1.root != null && param1.root != "")
                                      ? (param1.root + param1.assetId)
                                      : (this.ROOT + param1.assetId);
               this._proxyFetchToLoader(param1, _proxyUrl);
            }
         }
         else if(param1.type == ModuleType.PANEL)
         {
            var _loc5_:URLLoader = new URLLoader();
            _loc5_.dataFormat = URLLoaderDataFormat.BINARY;
            this.loadingList[param1.assetId] = _loc5_;
            this._vK3[_loc5_] = param1;
            _loc5_.addEventListener(Event.COMPLETE,this._yD0);
            _loc5_.addEventListener(IOErrorEvent.IO_ERROR,this._zA8);
            if(param1.context == null)
            {
               param1.context = this.context;
            }
            if(param1.root != null || param1.root == "")
            {
               _loc5_.load(new URLRequest(param1.root + param1.assetId));
            }
            else
            {
               _loc5_.load(new URLRequest(this.ROOT + param1.assetId));
            }
         }
         else
         {
            _loc4_ = new Loader();
            param1.loader = _loc4_;
            this.loadingList[param1.assetId] = _loc4_;
            this.requestList[_loc4_] = param1;
            _loc4_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaded);
            _loc4_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
            _loc4_.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
            _loc4_.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
            if(param1.context == null)
            {
               param1.context = this.context;
            }
            if(param1.root != null || param1.root == "")
            {
               _loc4_.load(new URLRequest(param1.root + param1.assetId),param1.context);
            }
            else
            {
               _loc4_.load(new URLRequest(this.ROOT + param1.assetId),param1.context);
            }
         }
      }

      // ---- PATCH: launcher-proxy bridge --------------------------------------
      // Inner-SWF URLLoader/BinaryDataLoader is silently denied for remote
      // hosts (LoaderContext sandbox). Route every network asset through the
      // launcher-side MyGameAssetProxy and feed the bytes into a Loader the
      // same way onBinaryLoaded does today.
      private function _proxyFetchToLoader(req:IAssetRequest, url:String) : void
      {
         var self:AssetModel = this;
         var proxy:Class = null;
         try {
            var dom:ApplicationDomain = ApplicationDomain.currentDomain;
            while (dom != null && proxy == null) {
               if (dom.hasDefinition("MyGameAssetProxy")) {
                  proxy = dom.getDefinition("MyGameAssetProxy") as Class;
                  break;
               }
               dom = dom.parentDomain;
            }
         } catch (lookupErr:Error) {
            trace("[AssetModel] proxy lookup failed: " + lookupErr.message);
         }
         if (proxy == null) {
            trace("[AssetModel] no MyGameAssetProxy; BinaryDataLoader fallback " + url);
            var fallback:BinaryDataLoader = new BinaryDataLoader(url);
            this.loadingList[req.assetId] = fallback;
            this.requestList[fallback] = req;
            fallback.addEventListener(LoaderEvent.COMPLETE,this.onBinaryLoaded);
            fallback.addEventListener(LoaderEvent.ERROR,this.onBinaryError);
            fallback.addEventListener(LoaderEvent.FAIL,this.onBinaryError);
            fallback.load();
            return;
         }
         trace("[AssetModel] proxy " + req.type + " " + url);
         proxy.fetchBinary(url,
            function(data:Object):void { self._onProxyBytes(req, data as ByteArray); },
            function(msg:String):void  { self._onProxyError(req, url, msg);          }
         );
      }

      private function _onProxyBytes(req:IAssetRequest, bytes:ByteArray) : void
      {
         if (bytes == null || bytes.length == 0) {
            trace("[AssetModel] proxy returned empty bytes for " + req.assetId);
            this._failRequest(req);
            return;
         }
         var loader:Loader = new Loader();
         if (req.context == null) {
            req.context = new LoaderContext();
            req.context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
         }
         var ctx:LoaderContext = req.context;
         ctx.allowCodeImport     = true;
         ctx.securityDomain      = null;
         ctx.checkPolicyFile     = false;
         ctx.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
         req.loader = loader;
         this.loadingList[req.assetId] = loader;
         this.requestList[loader] = req;
         var processed:ByteArray = this._xE9(bytes);
         if (processed.length == 0) {
            trace("[AssetModel] _xE9 returned 0 bytes for " + req.assetId);
            this._failRequest(req);
            return;
         }
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaded);
         try {
            loader.loadBytes(processed, ctx);
         } catch (le:Error) {
            trace("[AssetModel] loader.loadBytes threw for " + req.assetId + ": " + le.message);
            this._failRequest(req);
         }
      }

      private function _onProxyError(req:IAssetRequest, url:String, msg:String) : void
      {
         trace("[AssetModel] proxy fail " + url + " :: " + msg);
         this._failRequest(req);
      }

      private function _failRequest(req:IAssetRequest) : void
      {
         // Mirror onError's notify-then-cleanup pattern without an IOErrorEvent.
         var list:Array = this.pendingList[req.assetId];
         if (list) {
            for (var i:int = 0; i < list.length; i++) {
               var r:IAssetRequest = list[i] as IAssetRequest;
               if (r != null && r.errorFunction != null) {
                  try { r.errorFunction(r); } catch (e:Error) {}
               } else if (r != null && !r.isQueueRequest) {
                  try { r.dispose(); } catch (e2:Error) {}
               }
            }
         }
         delete this.loadingList[req.assetId];
         delete this.pendingList[req.assetId];
         if (this.queueLength > 0) { --this.queueLength; }
         this.handleQueue();
      }
      // ---- /PATCH ------------------------------------------------------------

      protected function onBinaryLoaded(param1:Event) : void
      {
         var _loc5_:LoaderContext;
         var _loc6_:ByteArray;
         var _loc7_:* = undefined;
         var _loc8_:* = undefined;
         var _loc9_:* = undefined;
         var _loc2_:BinaryDataLoader = LoaderMax.getLoader(param1.target.name);
         var _loc3_:IAssetRequest = this.requestList[_loc2_] as IAssetRequest;
         var _loc4_:Loader = new Loader();
         if(_loc3_.context == null)
         {
            _loc3_.context = new LoaderContext();
            _loc3_.context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
         }
         _loc5_ = _loc3_.context;
         _loc5_.allowCodeImport = true;
         _loc5_.securityDomain = null;
         _loc5_.checkPolicyFile = false;
         _loc5_.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
         _loc3_.loader = _loc4_;
         this.loadingList[_loc3_.assetId] = _loc4_;
         this.requestList[_loc4_] = _loc3_;
         _loc6_ = new ByteArray();
         _loc6_ = param1.target.content;
         delete this.requestList[_loc2_];
         _loc2_.unload();
         _loc2_.dispose(true);
         _loc2_ = null;
         _loc6_ = this._xE9(_loc6_);
         if(_loc6_.length != 0)
         {
            _loc4_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
            _loc4_.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
            _loc4_.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
            _loc4_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaded);
            _loc4_.loadBytes(_loc6_,_loc5_);
            if(Connectr.instance.cacheModel.isAvailable)
            {
               try
               {
                  _loc7_ = Connectr.instance.cacheModel.resolvePath().resolvePath(MD5.hash(_loc3_.assetId) + ".tmp");
                  _loc8_ = Connectr.instance.cacheModel.resolvePath().resolvePath(MD5.hash(_loc3_.assetId));
                  if(!_loc7_.exists && !_loc8_.exists)
                  {
                     _loc9_ = new this.FileStream();
                     _loc9_.addEventListener(Event.CLOSE,this.onFileClosed);
                     _loc9_.openAsync(_loc7_,"write");
                     _loc9_.writeBytes(_loc6_,0,_loc6_.length);
                     _loc9_.close();
                     this.fileStreamQueue[_loc9_] = new Array(_loc7_,_loc8_);
                  }
               }
               catch(e:Error)
               {
               }
            }
         }
      }
      
      private function onFileClosed(param1:Event) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:* = undefined;
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         try
         {
            _loc2_ = param1.target;
            _loc3_ = this.fileStreamQueue[_loc2_];
            _loc4_ = _loc3_[0];
            _loc5_ = _loc3_[1];
            _loc4_.moveToAsync(_loc5_);
            delete this.fileStreamQueue[_loc2_];
         }
         catch(e:Error)
         {
         }
      }
      
      protected function addPendingList(param1:IAssetRequest) : void
      {
         if(param1.root != null || param1.root == "")
         {
         }
         var _loc2_:Array = this.pendingList[param1.assetId];
         if(_loc2_)
         {
            _loc2_.push(param1);
         }
         else
         {
            _loc2_ = [];
            _loc2_.push(param1);
            this.pendingList[param1.assetId] = _loc2_;
         }
      }
      
      protected function onProgress(param1:ProgressEvent) : void
      {
         var _loc2_:Loader = (param1.target as LoaderInfo).loader;
         var _loc3_:IAssetRequest = this.requestList[_loc2_] as IAssetRequest;
         if(_loc3_.progressFunction != null)
         {
            _loc3_.progressFunction(param1.bytesLoaded * 100 / param1.bytesTotal);
         }
      }
      
      protected function onLoaded(param1:Event) : void
      {
         var list:Array;
         var copyBytes:ByteArray = null;
         var subContentArray:Array = null;
         var i:int = 0;
         var subRequest:IAssetRequest = null;
         var displayObject:DisplayObject = null;
         var subRequestLoader:Loader = null;
         var cloneSubRequest:AssetRequest = null;
         var bitmap:Bitmap = null;
         var event:Event = param1;
         var loader:Loader = (event.target as LoaderInfo).loader;
         var loaderInfo:LoaderInfo = event.target as LoaderInfo;
         var content:MovieClip = loaderInfo.content as MovieClip;
         var request:IAssetRequest = this.requestList[loader] as IAssetRequest;
         delete this.loadingList[request.assetId];
         list = this.pendingList[request.assetId];
         if(list)
         {
            copyBytes = null;
            subContentArray = new Array();
            i = 0;
            for(; i < list.length; i++)
            {
               subRequest = list[i] as IAssetRequest;
               subRequest.context = request.context;
               if(subRequest.loadedFunction != null)
               {
                  if(this.isRequestDisplaySupported(subRequest))
                  {
                     displayObject = loader.content;
                     if(subRequest.clone && i > 0)
                     {
                        if(displayObject is MovieClip)
                        {
                           subRequestLoader = new Loader();
                           cloneSubRequest = subRequest.cloneRequest();
                           cloneSubRequest.loader = subRequestLoader;
                           subContentArray.push(cloneSubRequest);
                           subRequestLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(param1:Event):*
                           {
                              var _loc2_:LoaderInfo = param1.currentTarget as LoaderInfo;
                              var _loc3_:AssetRequest = subContentArray.pop();
                              _loc3_.display = _loc2_.loader.content;
                              _loc3_.loadedFunction(_loc3_);
                           });
                           subRequestLoader.loadBytes(loader.contentLoaderInfo.bytes,subRequest.context);
                           continue;
                        }
                     }
                     if(i > 0 && displayObject is Bitmap)
                     {
                        bitmap = displayObject as Bitmap;
                        displayObject = new Bitmap(bitmap.bitmapData);
                     }
                     subRequest.display = displayObject;
                  }
                  subRequest.loadedFunction(subRequest);
               }
            }
         }
         delete this.pendingList[request.assetId];
         delete this.requestList[loader];
         this.deleteRequest(request);
         if(!(request.type == ModuleType.SMILEY || request.type == ModuleType.PANEL))
         {
            loader.unloadAndStop();
         }
         if(!request.isQueueRequest)
         {
            request.dispose();
         }
         loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoaded);
         loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
         loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         loader = null;
         loaderInfo = null;
      }
      
      protected function isRequestDisplaySupported(param1:IAssetRequest) : Boolean
      {
         if(param1.type == null)
         {
            return true;
         }
         return this.allowedModuleTypes.indexOf(param1.type) != -1;
      }
      
      protected function onSecurityError(param1:SecurityErrorEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:IAssetRequest = null;
         var _loc2_:Loader = (param1.target as LoaderInfo).loader;
         var _loc3_:IAssetRequest = this.requestList[_loc2_] as IAssetRequest;
         trace("Security error." + param1.text);
         Tracker.track("asset","load","error","Security error." + param1.text);
         var _loc4_:Array = this.pendingList[_loc3_.assetId];
         if(_loc4_)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc6_ = _loc4_[_loc5_] as IAssetRequest;
               if(_loc6_.errorFunction != null)
               {
                  _loc6_.errorFunction(_loc6_);
               }
               else if(!_loc6_.isQueueRequest)
               {
                  _loc6_.dispose();
               }
               _loc5_++;
            }
         }
         this.deleteRequest(_loc3_);
      }
      
      protected function onBinaryError(param1:LoaderEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:IAssetRequest = null;
         var _loc2_:BinaryDataLoader = LoaderMax.getLoader(param1.target.name);
         trace("binaryLoader: " + _loc2_);
         var _loc3_:IAssetRequest = this.requestList[_loc2_] as IAssetRequest;
         trace("Error loading " + (_loc3_.root ? _loc3_.root : this.ROOT) + _loc3_.assetId);
         Tracker.track("asset","load","error","Error loading " + (_loc3_.root ? _loc3_.root : this.ROOT) + _loc3_.assetId);
         var _loc4_:Array = this.pendingList[_loc3_.assetId];
         if(_loc4_)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc6_ = _loc4_[_loc5_] as IAssetRequest;
               if(_loc6_.errorFunction != null)
               {
                  _loc6_.errorFunction(_loc6_);
               }
               else if(!_loc6_.isQueueRequest)
               {
                  _loc6_.dispose();
               }
               _loc5_++;
            }
         }
         this.deleteRequest(_loc3_);
      }
      
      protected function onError(param1:IOErrorEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:IAssetRequest = null;
         var _loc2_:Loader = (param1.target as LoaderInfo).loader;
         var _loc3_:IAssetRequest = this.requestList[_loc2_] as IAssetRequest;
         trace("Error loading " + (_loc3_.root ? _loc3_.root : this.ROOT) + _loc3_.assetId);
         Tracker.track("asset","load","error","Error loading " + (_loc3_.root ? _loc3_.root : this.ROOT) + _loc3_.assetId);
         var _loc4_:Array = this.pendingList[_loc3_.assetId];
         if(_loc4_)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc6_ = _loc4_[_loc5_] as IAssetRequest;
               if(_loc6_.errorFunction != null)
               {
                  _loc6_.errorFunction(_loc6_);
               }
               else if(!_loc6_.isQueueRequest)
               {
                  _loc6_.dispose();
               }
               _loc5_++;
            }
         }
         this.deleteRequest(_loc3_);
      }
      
      private function deleteRequest(param1:IAssetRequest) : void
      {
         --this.queueLength;
         this.handleQueue();
         try
         {
            param1.loader.removeEventListener(LoaderEvent.COMPLETE,this.onBinaryLoaded);
            param1.loader.removeEventListener(LoaderEvent.ERROR,this.onBinaryError);
            param1.loader.removeEventListener(LoaderEvent.FAIL,this.onBinaryError);
         }
         catch(e:Error)
         {
         }
         try
         {
            param1.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoaded);
            param1.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
            param1.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
            param1.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         }
         catch(e:Error)
         {
         }
         try
         {
            delete this.pendingList[param1.assetId];
            delete this.requestList[param1.loader];
            delete this.loadingList[param1.assetId];
         }
         catch(e:Error)
         {
         }
      }
      
      private function _zA8(param1:IOErrorEvent) : void
      {
         var _a:URLLoader = param1.target as URLLoader;
         _a.removeEventListener(Event.COMPLETE,this._yD0);
         _a.removeEventListener(IOErrorEvent.IO_ERROR,this._zA8);
         var _r:IAssetRequest = this._vK3[_a] as IAssetRequest;
         delete this._vK3[_a];
         var _e:Array = this.pendingList[_r.assetId];
         if(_e)
         {
            var _j:int = 0;
            while(_j < _e.length)
            {
               var _s:IAssetRequest = _e[_j] as IAssetRequest;
               if(_s.errorFunction != null)
               {
                  _s.errorFunction(_s);
               }
               _j++;
            }
         }
         this.deleteRequest(_r);
      }
      
      private function _yD0(param1:Event) : void
      {
         var _a:URLLoader = param1.target as URLLoader;
         _a.removeEventListener(Event.COMPLETE,this._yD0);
         _a.removeEventListener(IOErrorEvent.IO_ERROR,this._zA8);
         var _r:IAssetRequest = this._vK3[_a] as IAssetRequest;
         delete this._vK3[_a];
         var _d:ByteArray = _a.data as ByteArray;
         _d = this._xE9(_d);
         if(_r.context == null)
         {
            _r.context = new LoaderContext();
            _r.context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
         }
         _r.context.allowCodeImport = true;
         _r.context.securityDomain = null;
         _r.context.checkPolicyFile = false;
         _r.context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
         var _l:Loader = new Loader();
         _r.loader = _l;
         this.loadingList[_r.assetId] = _l;
         this.requestList[_l] = _r;
         _l.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaded);
         _l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         _l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         _l.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         _l.loadBytes(_d,_r.context);
      }
      
      private function _xE9(_d:ByteArray) : ByteArray
      {
         if(_d == null || _d.length < 64)
         {
            return _d;
         }
         _d.position = 0;
         var _s0:int = int(_d[0]);
         var _s1:int = int(_d[1]);
         var _s2:int = int(_d[2]);
         var _sv:Array = [int(_nB1[3]) ^ int(_nB1[1]),int(_nB1[0]) ^ 0xE0,int(_nB2[0]) ^ 0x3D];
         var _sw:int = int(_nB1[1]) ^ 0x0F;
         var _ss:int = int(_nB1[2]) ^ 0x94;
         if(_s1 == _sw && _s2 == _ss && (_s0 == _sv[0] || _s0 == _sv[1] || _s0 == _sv[2]))
         {
            _d.position = 0;
            return _d;
         }
         _d.endian = String.fromCharCode(108,105,116,116,108,101,69,110,100,105,97,110);
         _d.position = 0;
         var _mg1:uint = _d.readUnsignedInt();
         var _mg2:uint = _d.readUnsignedInt();
         var _eM:uint = uint(uint(1390109676) ^ uint(4151157812));
         if(uint(_mg1 ^ _mg2) != _eM)
         {
            _d.position = 0;
            return _d;
         }
         var _v1:uint = uint(uint(3178470949) ^ uint(3276768380));
         var _v2:uint = uint(uint(3664331768) ^ uint(1857799433));
         var _os:uint = uint(_d.readUnsignedInt() ^ _v1);
         var _es:uint = uint(_d.readUnsignedInt() ^ _v2);
         var _sl:ByteArray = new ByteArray();
         _d.readBytes(_sl,0,16);
         _d.position = 64;
         var _enc:ByteArray = new ByteArray();
         _d.readBytes(_enc,0,_es);
         var _mk:Array = _rX7();
         var _np:int = 2;
         var _p:int = _np - 1;
         while(_p >= 0)
         {
            var _rk:Array = _sH1(_mk,_sl,_p);
            _enc = _vF3(_enc,_rk,_p);
            _p--;
         }
         _enc.position = 0;
         return _enc;
      }
   }
}

