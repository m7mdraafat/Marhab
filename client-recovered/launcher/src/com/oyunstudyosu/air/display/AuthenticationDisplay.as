package com.oyunstudyosu.air.display
{
   import com.oyunstudyosu.air.events.Dispatcher;
   import com.oyunstudyosu.air.events.GameEvent;
   import flash.Boot;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.LocationChangeEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import openfl.Lib;
   
   public class AuthenticationDisplay extends BrowserDisplay
   {
      
      public var closeButton:TextField;
      
      public function AuthenticationDisplay()
      {
         super();
         var _gthis:AuthenticationDisplay;
         if(Boot.skip_constructor)
         {
            return;
         }
         _gthis = this;

         closeButton = new TextField();
         closeButton.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            _gthis.dispose();
         });
         closeButton.defaultTextFormat = new TextFormat("Co Text Bold",30,16711680);
         closeButton.text = "X";
         closeButton.scaleX = closeButton.scaleY = SanalikaClient.instance.scaleModel.getRecommendedScaleRate();
         closeButton.embedFonts = true;
         addChild(closeButton);
         Dispatcher.addEventListener("FACEBOOK_AUTHENTICATION",onFacebookAuthentication);
         Dispatcher.addEventListener("GOOGLE_AUTHENTICATION",onGoogleAuthentication);
         Lib.setTimeout(function():void
         {
            _gthis.onResize(null);
         },0);
      }
      
      override public function onResize(param1:Event) : void
      {
         var _loc2_:Number = closeButton.textWidth * closeButton.scaleX * SanalikaClient.instance.scaleModel.getRecommendedScaleRate();
         closeButton.x = Lib.get_current().stage.stageWidth - _loc2_;
         closeButton.y = 0;
         viewPort.x = _loc2_;
         viewPort.y = _loc2_;
         var _loc3_:int = Lib.get_current().stage.stageWidth;
         viewPort.width = _loc3_ - _loc2_ * 2;
         var _loc4_:int = Lib.get_current().stage.stageHeight;
         viewPort.height = _loc4_ - _loc2_ * 2;
      }
      
      override public function onLocationChanging(param1:LocationChangeEvent) : void
      {
         if(param1.location == "sanalika://facebook-register")
         {
            stageWebView.stop();
            SanalikaClient.instance.nativeExtensionModel.facebokAuthenticationModel.authenticate();
         }
         else if(param1.location == "sanalika://google-register")
         {
            stageWebView.stop();
            SanalikaClient.instance.nativeExtensionModel.googleAuthenticationModel.authenticate();
         }
         else if(StringTools.endsWith(param1.location,"/app/success"))
         {
            dispose();
         }
      }
      
      public function onGoogleAuthentication(param1:GameEvent) : void
      {
         stageWebView.loadURL(initialURL + "/google/" + Std.string(param1.data));
      }
      
      public function onFacebookAuthentication(param1:GameEvent) : void
      {
         stageWebView.loadURL(initialURL + "/facebook/" + Std.string(param1.data));
      }
      
      override public function dispose() : void
      {
         Dispatcher.removeEventListener("FACEBOOK_AUTHENTICATION",onFacebookAuthentication);
         Dispatcher.removeEventListener("GOOGLE_AUTHENTICATION",onGoogleAuthentication);
         super.dispose();
      }
   }
}

