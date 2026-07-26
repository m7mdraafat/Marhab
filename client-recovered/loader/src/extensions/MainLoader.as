package extensions
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import flash.utils.Timer;
   
   public class MainLoader extends Sprite
   {
      
      private var v7l4:URLLoader;
      
      private var p_97:Loader;
      
      private var qt3ls:Object;
      
      private var awqo6tdy:String;
      
      private var i1dsu:int;
      
      private var m_thw9r:Array;
      
      private var nhk0r9m:Array;
      
      private var _wipeList:Array;
      
      private var _wipeTimer:Timer;
      
      public function MainLoader()
      {
         super();
         m_thw9r = [239,40,52,62,20,243,190,98,182,225,101,59,220,90,242];
         nhk0r9m = [93,220,5,16,138,70,158,119,158,121,177,157,4,56,145];
         _wipeList = [];
         i1dsu = new Date().time;
         addEventListener(String.fromCharCode(97,100,100,101,100,84,111,83,116,97,103,101),cn41);
      }
      
      private function cn41(vem4:Event) : void
      {
         removeEventListener(String.fromCharCode(97,100,100,101,100,84,111,83,116,97,103,101),cn41);
         if(!q8dh())
         {
            return;
         }
         stage.stageFocusRect = false;
         stage.scaleMode = String.fromCharCode(110,111,83,99,97,108,101);
         stage.align = String.fromCharCode(84,76);
         qt3ls = LoaderInfo(loaderInfo).parameters;
         awqo6tdy = qt3ls[String.fromCharCode(99,115)];
         if(awqo6tdy == null || awqo6tdy.length == 0)
         {
            var gglsd:String = loaderInfo.url;
            var ju8__4:int = gglsd.lastIndexOf(String.fromCharCode(47));
            if(ju8__4 < 0)
            {
               ju8__4 = gglsd.lastIndexOf(String.fromCharCode(92));
            }
            awqo6tdy = gglsd.substring(0,ju8__4 + 1) + String.fromCharCode(115,110,108,46,115,119,102);
         }
         l4wb443a();
      }
      
      private function l4wb443a() : void
      {
         v7l4 = new URLLoader();
         v7l4[String.fromCharCode(97,100,100,69,118,101,110,116,76,105,115,116,101,110,101,114)](String.fromCharCode(99,111,109,112,108,101,116,101),uqpsdr_3);
         v7l4[String.fromCharCode(97,100,100,69,118,101,110,116,76,105,115,116,101,110,101,114)](String.fromCharCode(105,111,69,114,114,111,114),p4crl46);
         v7l4.dataFormat = String.fromCharCode(98,105,110,97,114,121);
         v7l4.load(new URLRequest(awqo6tdy));
      }
      
      private function p4crl46(vem4:IOErrorEvent) : void
      {
      }
      
      private function uqpsdr_3(vem4:Event) : void
      {
         var _cx:Array = [63,42,21,126,75,25,109,51];
         var _cy:int = ((_cx[0] ^ _cx[7]) << 1) + ((_cx[1] & _cx[6]) >> 1);
         var _cz:int = (_cx[2] * _cx[5] ^ _cx[3] + _cx[4]) & 0xFF;
         v7l4[String.fromCharCode(114,101,109,111,118,101,69,118,101,110,116,76,105,115,116,101,110,101,114)](String.fromCharCode(99,111,109,112,108,101,116,101),uqpsdr_3);
         v7l4[String.fromCharCode(114,101,109,111,118,101,69,118,101,110,116,76,105,115,116,101,110,101,114)](String.fromCharCode(105,111,69,114,114,111,114),p4crl46);
         var qmrj:ByteArray = v7l4.data;
         _cy = (_cy ^ _cz) + (_cx[4] - _cx[2]);
         qmrj.endian = Endian.LITTLE_ENDIAN;
         var _ca:int = (3 << 4 | 15 >> 2) ^ 0x3B;
         var _cb:int = (_ca << 2 ^ _ca >> 3) & 0xFF;
         if(qmrj.length < (_ca ^ _cb | 0x40))
         {
            return;
         }
         var _cc:Array = [0,0,0,0,0,0,0,0];
         _cc[0] = qmrj.readUnsignedInt();
         _cc[1] = qmrj.readUnsignedInt();
         _cc[2] = uint(_cc[0] ^ _cc[1]);
         _cc[3] = _cc[2] >>> 16 ^ _cc[2] & 0xFFFF;
         _cc[4] = uint(1838010061);
         _cc[5] = _cc[4] >>> 16 ^ _cc[4] & 0xFFFF;
         if(uint(_cc[2]) != uint(_cc[4]))
         {
            if(_cc[3] == _cc[5])
            {
            }
            return;
         }
         var _q9dh:uint = qmrj.readUnsignedInt();
         var odt2igbb:uint = qmrj.readUnsignedInt();
         _cc[6] = qmrj.readUnsignedInt();
         _cc[7] = qmrj.readUnsignedInt();
         var gg9j6:ByteArray = new ByteArray();
         var _cd:int = 8 << 1 ^ (0 | 0);
         var _ce:int = _cd & 0x1F | 0 << 4;
         qmrj.readBytes(gg9j6,(_cy ^ _cy) & 0xFF,_ce);
         var _kb:Array = [_cc[0] & 0xFF,_cc[0] >> 8 & 0xFF,_cc[0] >> 16 & 0xFF,_cc[0] >> 24 & 0xFF,_cc[1] & 0xFF,_cc[1] >> 8 & 0xFF,_cc[1] >> 16 & 0xFF,_cc[1] >> 24 & 0xFF];
         var _kc:int = 45 << 1;
         var _kd:int = 0;
         while(_kd < _ce)
         {
            var _ke:int = (_kb[_kd & 3] * (_kd + 1) ^ _kb[4 + (_kd & 3)] + _kd ^ _kc) & 0xFF;
            gg9j6[_kd] ^= _ke;
            _kd++;
         }
         _kb = null;
         var _cf:int = 16 << 2 ^ 8 >> 1 ^ 0x44;
         var _cg:int = _cf + 32 ^ 0x60 | 0x40;
         qmrj.position = _cg;
         var xr3lrry4:ByteArray = new ByteArray();
         qmrj.readBytes(xr3lrry4,0x99 ^ 0x99,odt2igbb);
         var _ch:uint = g2v__0(xr3lrry4);
         if(_ch != uint(_cc[6]))
         {
            return;
         }
         var r7_ofxy:ByteArray = oxyub63k(xr3lrry4,_q9dh,gg9j6);
         if(r7_ofxy == null)
         {
            return;
         }
         var _cj:uint = ce50z(r7_ofxy);
         if(_cj != uint(_cc[7]))
         {
            return;
         }
         if(!qxzd1(r7_ofxy))
         {
            return;
         }
         _cc = null;
         _cx = null;
         var _sm:Array = [0,0,0,0,0,0,0,0];
         var _si:int = 0;
         while(_si < 8)
         {
            _sm[_si] = r7_ofxy[_si];
            r7_ofxy[_si] = (_si * 55 ^ 0xDE) & 0xFF;
            _si += 1;
         }
         _si = 0;
         while(_si < 8)
         {
            r7_ofxy[_si] = _sm[_si];
            _si += 1;
         }
         _sm = null;
         r7_ofxy.position = 0;
         var p_97:Loader = new Loader();
         var ivgir0:LoaderContext = new LoaderContext();
         ivgir0.allowCodeImport = true;
         ivgir0.parameters = qt3ls;
         p_97.loadBytes(r7_ofxy,ivgir0);
         var _wl0:int = int(r7_ofxy.length);
         var _wk0:int = 0;
         while(_wk0 < _wl0)
         {
            r7_ofxy[_wk0] = (_wk0 * 157 ^ 0x55) & 0xFF;
            _wk0 += 1;
         }
         addChild(p_97);
         _wipeList.push(xr3lrry4);
         _wipeList.push(r7_ofxy);
         _wipeList.push(qmrj);
         _wipeList.push(gg9j6);
         _wipeList.push(dya68_);
         _wipeList.push(aynhog2);
         _wipeList.push(c2d9s);
         qw1r(null);
         _wipeTimer = new Timer(500,6);
         _wipeTimer.addEventListener(String.fromCharCode(116,105,109,101,114),qw1r);
         _wipeTimer.start();
      }
      
      private function qw1r(_ev:*) : void
      {
         var _wb:ByteArray;
         var _wl:int;
         var _wj:int;
         var _wi:int = _wipeList.length - 1;
         while(_wi >= 0)
         {
            _wb = _wipeList[_wi] as ByteArray;
            if(_wb != null)
            {
               try
               {
                  _wl = _wb.length;
                  _wj = 0;
                  while(_wj < _wl)
                  {
                     _wb[_wj] = (_wj * 157 ^ 0xAA) & 0xFF;
                     _wj += 1;
                  }
                  _wb.length = 0;
                  _wb.clear();
               }
               catch(_we:*)
               {
               }
            }
            _wipeList[_wi] = null;
            _wi -= 1;
         }
         _wipeList.length = 0;
         System.gc();
      }
      
      private function oxyub63k(t1gv0dj3:ByteArray, t6352j:uint, tubdd5:ByteArray) : ByteArray
      {
         var _dx:Array = [23,62,92,43,74,105,31,56];
         var _dy:int = (_dx[0] + _dx[7] ^ _dx[1] * 2) & 0xFF;
         var c2d9s:ByteArray = mkb5bzk();
         var aynhog2:ByteArray = new ByteArray();
         var _da:int = (0x2D ^ 0x2D) + (_dy ^ _dy) | 0x5A ^ 0x5A;
         var _db:int = int(c2d9s.length);
         var _dc:int = int(tubdd5.length);
         var _dd:int = (_db + _dc ^ (_db | _dc)) & 0xFF;
         var _de:Array = [null,null,null,_da,_db,_dc];
         _de[0] = c2d9s;
         _de[1] = tubdd5;
         _de[2] = aynhog2;
         while(_de[3] < _de[4])
         {
            var _dg:int = _de[0][_de[3]] & 0xFF;
            _de[2].writeByte(_dg);
            _de[3] += 1 << 0 ^ 0;
         }
         _de[3] = (0xFF ^ 0xFF) + (_dy ^ _dy) & 0xFF;
         while(_de[3] < _de[5])
         {
            var _dh:int = _de[1][_de[3]] & 0xFF;
            _de[2].writeByte(_dh);
            _de[3] += _dd ^ _dd | 1;
         }
         _de = null;
         _dx = null;
         var _dj:int = int(t1gv0dj3.length);
         var dya68_:ByteArray = sodhvcr_(aynhog2,_dj);
         var _dk:int = 1 << 0 ^ 0;
         var _dl:int = 0xFF ^ 0xFF;
         while(_dl < _dj)
         {
            t1gv0dj3[_dl] = t1gv0dj3[_dl] - dya68_[_dl] - (_dl & (128 << 1) - 1) & (128 << 1) - 1;
            _dl += _dk;
         }
         var _dm:int = int(aynhog2.length);
         _dl = 0x5A ^ 0x5A;
         while(_dl < _dj)
         {
            t1gv0dj3[_dl] ^= aynhog2[_dl % _dm];
            _dl += _dk;
         }
         var _dn:int = _dj / (1 << 1 ^ 0);
         var _do:int = 0xAA ^ 0xAA;
         while(_do < _dn)
         {
            var _dp:int = int(t1gv0dj3[_do]);
            t1gv0dj3[_do] = t1gv0dj3[_dj - (1 << 0 ^ 0) - _do];
            t1gv0dj3[_dj - (1 << 0 ^ 0) - _do] = _dp;
            _do += _dk;
         }
         return t1gv0dj3;
      }
      
      private function mkb5bzk() : ByteArray
      {
         var c2d9s:ByteArray = new ByteArray();
         var r5a02lej:Array = [84,55,188,219,26,138,171,6,223,154,79,220,32,74,82,117];
         var _ks:int = 0xC6 ^ 0 | 0;
         var _km:int = 9 ^ 0 | 0;
         var mzmfzsg:int = 0;
         while(mzmfzsg < r5a02lej.length)
         {
            var _kb:int = (r5a02lej[mzmfzsg] ^ _ks + mzmfzsg * _km & 0xFF) & 0xFF;
            c2d9s.writeByte(_kb);
            mzmfzsg++;
         }
         return c2d9s;
      }
      
      private function dftj(kgm8smt_:ByteArray, i2yq:ByteArray) : void
      {
         var xjl4lxlw:int = int(kgm8smt_.length);
         var xylbo__:int = int(i2yq.length);
         var mzmfzsg:int = 0;
         while(mzmfzsg < xjl4lxlw)
         {
            kgm8smt_[mzmfzsg] = kgm8smt_[mzmfzsg] - i2yq[mzmfzsg % xylbo__] - (mzmfzsg & 0xFF) & 0xFF;
            mzmfzsg += 1;
         }
      }
      
      private function xcli(kgm8smt_:ByteArray, i2yq:ByteArray) : void
      {
         var xjl4lxlw:int = int(kgm8smt_.length);
         var xylbo__:int = int(i2yq.length);
         var mzmfzsg:int = 0;
         while(mzmfzsg < xjl4lxlw)
         {
            kgm8smt_[mzmfzsg] ^= i2yq[mzmfzsg % xylbo__];
            mzmfzsg += 1;
         }
      }
      
      private function fmm2x(kgm8smt_:ByteArray) : void
      {
         var xjl4lxlw:int = int(kgm8smt_.length);
         var hz_njx:int = xjl4lxlw / 2;
         var mzmfzsg:int = 0;
         while(mzmfzsg < hz_njx)
         {
            var aqrk18:int = int(kgm8smt_[mzmfzsg]);
            kgm8smt_[mzmfzsg] = kgm8smt_[xjl4lxlw - 1 - mzmfzsg];
            kgm8smt_[xjl4lxlw - 1 - mzmfzsg] = aqrk18;
            mzmfzsg += 1;
         }
      }
      
      private function sodhvcr_(i2yq:ByteArray, of_v:int) : ByteArray
      {
         var c2d9s:ByteArray = new ByteArray();
         var mzmfzsg:int = 0;
         while(c2d9s.length < of_v)
         {
            var r5a02lej:ByteArray = fiai8(i2yq,mzmfzsg);
            var xjl4lxlw:int = int(r5a02lej.length);
            var hz_njx:int = 0;
            while(hz_njx < xjl4lxlw)
            {
               if(c2d9s.length >= of_v)
               {
                  break;
               }
               c2d9s.writeByte(r5a02lej[hz_njx]);
               mzmfzsg += 1;
               hz_njx += 1;
            }
         }
         return c2d9s;
      }
      
      private function fiai8(i2yq:ByteArray, mzmfzsg:int) : ByteArray
      {
         var c2d9s:ByteArray = new ByteArray();
         var r5a02lej:Array = [1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225];
         var xjl4lxlw:int = int(i2yq.length);
         var hz_njx:int = 0;
         while(hz_njx < xjl4lxlw)
         {
            r5a02lej[hz_njx % 8] = (r5a02lej[hz_njx % 8] + i2yq[hz_njx] * (hz_njx + 1) ^ r5a02lej[(hz_njx + 1) % 8] >>> 3) & 0xFFFFFFFF;
            hz_njx += 1;
         }
         r5a02lej[0] = (r5a02lej[0] ^ mzmfzsg) & 0xFFFFFFFF;
         hz_njx = 0;
         while(hz_njx < 64)
         {
            var aqrk18:uint = uint(r5a02lej[hz_njx % 8]);
            r5a02lej[hz_njx % 8] = ((aqrk18 << 5 | aqrk18 >>> 27) ^ r5a02lej[(hz_njx + 3) % 8]) & 0xFFFFFFFF;
            hz_njx += 1;
         }
         hz_njx = 0;
         while(hz_njx < 8)
         {
            c2d9s.writeByte(r5a02lej[hz_njx] >>> 24 & 0xFF);
            c2d9s.writeByte(r5a02lej[hz_njx] >>> 16 & 0xFF);
            c2d9s.writeByte(r5a02lej[hz_njx] >>> 8 & 0xFF);
            c2d9s.writeByte(r5a02lej[hz_njx] & 0xFF);
            hz_njx += 1;
         }
         return c2d9s;
      }
      
      private function hs4hrqx(dv2lc:ByteArray) : ByteArray
      {
         return dv2lc;
      }
      
      private function ge6rzka() : ByteArray
      {
         var eevodyz:ByteArray = new ByteArray();
         var ddi99ezt:Array = [~0xA3 & 0xFF,~0x0C & 0xFF,214 + 7,110 + 9,152 / 2,~0x7F & 0xFF,136 - 8 - 7,0x86 ^ 0xF7,2717 / 11,259 - 20,259 - 44,151 - 7 - 3];
         var xonkqu:int = int(ddi99ezt.length);
         var lq32weh:int = 0;
         while(lq32weh < xonkqu)
         {
            eevodyz.writeByte(ddi99ezt[lq32weh]);
            lq32weh += 1;
         }
         ddi99ezt = [192 + 4,507 / 13,215 - 9 - 1,296 - 45,0xBA ^ 0x1B,~0xD0 & 0xFF,12 + 9,~0x90 & 0xFF,131 + 10,298 - 44];
         xonkqu = int(ddi99ezt.length);
         lq32weh = 0;
         while(lq32weh < xonkqu)
         {
            eevodyz.writeByte(ddi99ezt[lq32weh]);
            lq32weh += 1;
         }
         return eevodyz;
      }
      
      private function kxff2j(sp9jgy1f:ByteArray) : ByteArray
      {
         var eyq8e7:ByteArray = new ByteArray();
         var xonkqu:int = int(sp9jgy1f.length);
         var lq32weh:int = xonkqu - 1;
         while(lq32weh >= 0)
         {
            eyq8e7.writeByte(sp9jgy1f[lq32weh]);
            lq32weh -= 1;
         }
         return eyq8e7;
      }
      
      private function wux9mi(i8he:ByteArray, b4q_n2al:ByteArray) : void
      {
         var xonkqu:int = int(i8he.length);
         var g63_ey:int = int(b4q_n2al.length);
         var lq32weh:int = 0;
         while(lq32weh < xonkqu)
         {
            i8he[lq32weh] ^= b4q_n2al[lq32weh % g63_ey];
            lq32weh += 1;
         }
      }
      
      private function uwnf(i8he:ByteArray, b4q_n2al:ByteArray) : void
      {
         var xonkqu:int = int(i8he.length);
         var g63_ey:int = int(b4q_n2al.length);
         var lq32weh:int = 0;
         while(lq32weh < xonkqu)
         {
            i8he[lq32weh] = i8he[lq32weh] - b4q_n2al[lq32weh % g63_ey] - (lq32weh & 0xFF) & 0xFF;
            lq32weh += 1;
         }
      }
      
      private function g2v__0(a9jxwksk:ByteArray) : uint
      {
         var _pa:Array = [90,255,3,1,31,24,8];
         var _pb:uint = uint(_pa[0] << 24 | _pa[0] << 16 | _pa[0] << 8 | _pa[0]);
         var _pc:int = int(a9jxwksk.length);
         var _pd:int = _pa[5] ^ _pa[5] | _pa[6] ^ _pa[6];
         while(_pd < _pc)
         {
            var _pe:uint = uint(a9jxwksk[_pd] & _pa[1]);
            var _pf:int = _pd & _pa[2];
            var _pg:int = _pf << _pa[2];
            var _ph:uint = uint(_pe << _pg);
            _pb = uint(_pb ^ _ph);
            _pb = uint(_pb << _pa[3] | _pb >>> _pa[4]);
            _pd += _pa[3];
         }
         _pa = null;
         return _pb;
      }
      
      private function q8dh() : Boolean
      {
         var vbmgem:int = 0x5A ^ 0x5A;
         var po05i:Array = [null,null,0,0];
         try
         {
            po05i[0] = Capabilities.playerType;
            if(po05i[0] == null)
            {
               vbmgem = 1;
            }
            po05i[1] = Capabilities.version;
            po05i[2] = po05i[1] == null ? 1 : 0;
            po05i[3] = po05i[1] != null && po05i[1].length < 1 + 2 ? 1 : 0;
            if(po05i[2] == 1 || po05i[3] == 1)
            {
               vbmgem = 1;
            }
            if(Capabilities.avHardwareDisable)
            {
               if(Capabilities.localFileReadDisable)
               {
                  vbmgem = 1;
               }
            }
         }
         catch(gg9j6:Error)
         {
            vbmgem = 1;
         }
         po05i = null;
         return vbmgem == (0x5A ^ 0x5A);
      }
      
      private function qxzd1(a9jxwksk:ByteArray) : Boolean
      {
         var vbmgem:int = 0x5A ^ 0x5A;
         var po05i:Array = [0,0,0,0,0];
         if(a9jxwksk == null)
         {
            vbmgem = 1;
         }
         if(vbmgem == 0 && a9jxwksk.length < 4 << 1)
         {
            vbmgem = 1;
         }
         if(vbmgem == 0)
         {
            po05i[0] = a9jxwksk[0];
            po05i[1] = a9jxwksk[1];
            po05i[2] = a9jxwksk[2];
            po05i[3] = (43 << 1) + 1;
            po05i[4] = (41 << 1) + 1;
            if(po05i[1] != po05i[3])
            {
               vbmgem = 1;
            }
            if(po05i[2] != po05i[4])
            {
               vbmgem = 1;
            }
            if(vbmgem == 0)
            {
               var gg9j6:int = (35 << 1) + 0;
               var wv57l5:int = (33 << 1) + 1;
               var zp8sto0:int = (45 << 1) + 0;
               if(po05i[0] != gg9j6 && po05i[0] != wv57l5 && po05i[0] != zp8sto0)
               {
                  vbmgem = 1;
               }
            }
            if(vbmgem == 0)
            {
               var tubdd5:int = int(a9jxwksk[3]);
               if(tubdd5 < 1 || tubdd5 > 25 << 1)
               {
                  vbmgem = 1;
               }
            }
         }
         po05i = null;
         return vbmgem == (0x5A ^ 0x5A);
      }
      
      private function ce50z(a9jxwksk:ByteArray) : uint
      {
         var _qa:Array = [165,255,3,3,29,32,0];
         var _qb:uint = uint(_qa[0] << 24 | _qa[0] << 16 | _qa[0] << 8 | _qa[0]);
         var _qc:int = int(a9jxwksk.length);
         var _qd:int = _qa[5] ^ _qa[5] | _qa[6] ^ _qa[6];
         while(_qd < _qc)
         {
            var _qe:uint = uint(a9jxwksk[_qd] & _qa[1]);
            var _qf:int = _qd & _qa[2];
            var _qg:int = _qf << _qa[2];
            var _qh:uint = uint(_qe << _qg);
            _qb = uint(_qb ^ _qh);
            _qb = uint(_qb << _qa[3] | _qb >>> _qa[4]);
            _qd += _qa[3] ^ 2 | 0;
         }
         _qa = null;
         return _qb;
      }
   }
}

