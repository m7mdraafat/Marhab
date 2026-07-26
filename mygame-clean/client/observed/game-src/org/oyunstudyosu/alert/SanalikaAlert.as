package org.oyunstudyosu.alert
{
   import com.oyunstudyosu.capture.CaptureLog;
   import com.oyunstudyosu.local.$;
   import com.oyunstudyosu.panel.Panel;
   import com.oyunstudyosu.sanalika.extension.Connectr;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.ApplicationDomain;
   import org.oyunstudyosu.components.CoreMovieClip;
   public class SanalikaAlert extends Panel
   {
      
      private var view:IAlertView;
      
      public function SanalikaAlert()
      {
         super();
      }
      
      override public function init() : void
      {
         super.init();
         var _loc1_:Object = null;
         try
         {
            _loc1_ = ApplicationDomain.currentDomain.getDefinition("org.oyunstudyosu.alert.views::" + data.params.alertType + "View");
         }
         catch(_captureAlertViewError:*)
         {
            var _captureAlertType:String = data == null || data.params == null ? "unknown" : String(data.params.alertType);
            CaptureLog.writeOnce("alert.view.missing",_captureAlertType,{"alertType":_captureAlertType,"message":String(_captureAlertViewError)});
            return;
         }
         trace(data.params.alertType);
         this.view = new _loc1_();
         this.view.vo = Connectr.instance.alertModel.toAlertVo(data.params);
         if(this.view.vo.title == null)
         {
            this.view.vo.title = $(this.view.vo.alertType);
         }
         try
         {
            (this.view as MovieClip).height *= Connectr.instance.scaleModel.uiScale;
            (this.view as MovieClip).width *= Connectr.instance.scaleModel.uiScale;
         }
         catch(e:Error)
         {
         }
         addChild(this.view as CoreMovieClip);
         try
         {
            this.view.init();
         }
         catch(_captureAlertInitError:*)
         {
            var _captureAlertInitType:String = data == null || data.params == null ? "unknown" : String(data.params.alertType);
            CaptureLog.writeOnce("alert.view.init.error",_captureAlertInitType,{"alertType":_captureAlertInitType,"message":String(_captureAlertInitError)});
            return;
         }
         dragHandler = this.view.dragger();
         (this.view as EventDispatcher).addEventListener("closeClicked",this.closeClicked);
         show();
      }
      
      protected function closeClicked(param1:Event) : void
      {
         close();
      }
      
      override public function dispose() : void
      {
         if(this.view)
         {
            this.view.dispose();
            removeChild(this.view as CoreMovieClip);
            this.view = null;
         }
         super.dispose();
      }
   }
}

