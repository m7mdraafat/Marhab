package com.oyunstudyosu.displayAd
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.greensock.TweenMax;
   import com.oyunstudyosu.assets.AssetRequest;
   import com.oyunstudyosu.assets.IAssetRequest;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.sanalika.interfaces.ICookieModel;
   import com.oyunstudyosu.utils.Tracker;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Security;
   
   public class AdSkin
   {
      
      private var request:AssetRequest;
      
      public var data:Object;
      
      private var cookieModel:ICookieModel;
      
      private var adClip:MovieClip;
      
      public var adClip2:MovieClip;
      
      private var assetPath:String = "/static/assets/";
      
      public function AdSkin()
      {
         super();
         data = {};
         data.alias = "2019Otizm";
         data.clickUrl = "http://bit.ly/2JYRoKt";
      }
      
      public function execute() : void
      {
         try
         {
            loadAdAsset();
         }
         catch(error:Error)
         {
            return;
         }
      }
      
      public function loadAdAsset() : void
      {
         if(!CaptureRuntime.sanalikaInstance.airModel.isAir())
         {
            Security.allowDomain("http://www.google.com");
            Security.allowDomain("http://tpc.googlesyndication.com");
            Security.allowDomain("http://partner.googleadservices.com");
            Security.allowDomain("https://www.google.com");
            Security.allowDomain("https://tpc.googlesyndication.com");
            Security.allowDomain("https://partner.googleadservices.com");
            Security.allowDomain("https://fs.sanalika.com");
         }
         request = new AssetRequest();
         request.assetId = assetPath + data.alias + "ps.png";
         request.type = "ModuleType.AD_SKIN";
         request.loadedFunction = onLoaded;
         request.errorFunction = onError;
         request.context = CaptureRuntime.sanalikaInstance.domainModel.assetContext;
         request.priority = 99;
         CaptureRuntime.sanalikaInstance.assetModel.request(request);
      }
      
      private function onError(param1:Object) : void
      {
         request.dispose();
      }
      
      public function onLoaded(param1:IAssetRequest) : void
      {
         adClip = new MovieClip();
         adClip.addChild(param1.display);
         var _loc2_:Bitmap = param1.display as Bitmap;
         var _loc3_:Bitmap = new Bitmap(_loc2_.bitmapData);
         adClip.x = adClip.width - 10;
         adClip.buttonMode = true;
         adClip.addEventListener("click",adClicked);
         adClip.addEventListener("mouseOver",adOver);
         adClip.addEventListener("mouseOut",adOut);
         CaptureRuntime.sanalikaInstance.layerModel.pageLayer.addChild(adClip);
         adClip2 = new MovieClip();
         adClip2.addChild(_loc3_);
         adClip2.x = CaptureRuntime.sanalikaInstance.layerModel.canvasWidth + 10;
         adClip2.buttonMode = true;
         adClip2.addEventListener("click",adClicked);
         adClip2.addEventListener("mouseOver",adOver);
         adClip2.addEventListener("mouseOut",adOut);
         CaptureRuntime.sanalikaInstance.layerModel.pageLayer.addChild(adClip2);
         param1.dispose();
         Dispatcher.addEventListener("RESIZE",onResize,true);
         move();
      }
      
      private function onResize(param1:GameEvent = null) : void
      {
         move();
      }
      
      private function move() : void
      {
         adClip.x = CaptureRuntime.sanalikaInstance.layerModel.gameLayer.x - adClip.width - 10;
         adClip2.x = CaptureRuntime.sanalikaInstance.layerModel.gameLayer.x + CaptureRuntime.sanalikaInstance.layerModel.canvasWidth + 10;
         adClip.y = CaptureRuntime.sanalikaInstance.layerModel.gameLayer.y;
         adClip2.y = CaptureRuntime.sanalikaInstance.layerModel.gameLayer.y;
      }
      
      protected function adOver(param1:MouseEvent) : void
      {
         TweenMax.to(param1.target,0,{"glowFilter":{
            "color":16777215,
            "alpha":1,
            "blurX":4,
            "blurY":4,
            "strength":4
         }});
      }
      
      protected function adOut(param1:MouseEvent) : void
      {
         TweenMax.to(param1.target,0,{"glowFilter":{
            "color":16777215,
            "alpha":0,
            "blurX":0,
            "blurY":0,
            "strength":0
         }});
      }
      
      protected function adClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         Tracker.track("ad","clickSkin",data.alias,CaptureRuntime.sanalikaInstance.roomModel.key);
         navigateToURL(new URLRequest(data.clickUrl),"_blank");
      }
      
      public function dispose() : void
      {
         data = null;
         if(adClip)
         {
            adClip.removeEventListener("mouseOver",adOver);
            adClip.removeEventListener("mouseOut",adOut);
            adClip.removeEventListener("click",adClicked);
            adClip2.removeEventListener("mouseOver",adOver);
            adClip2.removeEventListener("mouseOut",adOut);
            adClip2.removeEventListener("click",adClicked);
         }
         Dispatcher.removeEventListener("RESIZE",onResize,true);
      }
   }
}

