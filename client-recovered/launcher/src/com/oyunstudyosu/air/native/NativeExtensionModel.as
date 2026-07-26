package com.oyunstudyosu.air.native
{
   import com.distriqt.extension.core.Core;
   import flash.Boot;
   import flash.display.NativeWindow;
   import flash.display.Stage;
   
   public class NativeExtensionModel
   {
      
      public var stage:Stage;
      
      public var nativeWindow:NativeWindow;
      
      public var googleAuthenticationModel:GoogleAuthenticationModel;
      
      public var facebokAuthenticationModel:FacebookAuthenticationModel;
      
      public function NativeExtensionModel(param1:Stage = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         stage = param1;
         // Distriqt ANEs (Core / Facebook / GoogleIdentity) are not bundled in
         // this dev build. Swallow init failures so the launcher can still boot;
         // any feature that needs these will degrade gracefully (or no-op).
         try
         {
            Core.init();
         }
         catch(_loc_e_:*)
         {
            trace("[NATIVE] Core.init() failed: " + _loc_e_);
         }
         try
         {
            facebokAuthenticationModel = new FacebookAuthenticationModel();
         }
         catch(_loc_e2_:*)
         {
            trace("[NATIVE] FacebookAuthenticationModel ctor failed: " + _loc_e2_);
            facebokAuthenticationModel = null;
         }
         try
         {
            googleAuthenticationModel = new GoogleAuthenticationModel();
         }
         catch(_loc_e3_:*)
         {
            trace("[NATIVE] GoogleAuthenticationModel ctor failed: " + _loc_e3_);
            googleAuthenticationModel = null;
         }
      }
   }
}

