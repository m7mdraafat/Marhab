package org.oyunstudyosu.assets.clips
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import org.oyunstudyosu.alert.buttons.CloseViewButton;
   import org.oyunstudyosu.alert.buttons.ReportViewButton;
   public dynamic class RoomMessageTipUI extends MovieClip
   {
      
      public var background:MovieClip;
      
      public var btnClose:CloseViewButton;
      
      public var btnReport:ReportViewButton;
      
      public var txtMessage:TextField;
      
      public function RoomMessageTipUI()
      {
         super();
      }
   }
}

