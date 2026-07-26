package com.oyunstudyosu.air.alert.views
{
   import com.oyunstudyosu.air.alert.AlertResponse;
   import com.oyunstudyosu.air.alert.AlertVo;
   import com.oyunstudyosu.air.components.CloseButton;
   import com.oyunstudyosu.air.components.RedButton;
   import com.oyunstudyosu.air.ui.alert.IAlertView;
   import flash.Boot;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import openfl.display._internal.FlashGraphics;
   import openfl.utils.Assets;
   
   public class ErrorView extends BaseView implements IAlertView
   {
      
      public var vo:AlertVo;
      
      public var titleTextField:TextField;
      
      public var messageTextField:TextField;
      
      public var mcDragger:DisplayObject;
      
      public var lbl_Title:TextField;
      
      public var lblMsg:TextField;
      
      public var btnOk:RedButton;
      
      public var btnClose:CloseButton;
      
      public var background:Shape;
      
      public function ErrorView()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         background = new Shape();
         addChild(background);
         var _loc1_:DisplayObject = new Bitmap(Assets.getBitmapData("assets:assets/hud/RedPanelHeader.png"));
         _loc1_.x = -2;
         addChild(_loc1_);
         var _loc2_:TextFormat = new TextFormat("Co Text Bold",16,null,false);
         _loc2_.color = 16777215;
         _loc2_.align = "center";
         lbl_Title = new TextField();
         lbl_Title.text = "";
         lbl_Title.x = 36;
         lbl_Title.y = 3;
         lbl_Title.width = 284;
         lbl_Title.height = 36;
         lbl_Title.defaultTextFormat = _loc2_;
         lbl_Title.embedFonts = true;
         lbl_Title.selectable = false;
         addChild(lbl_Title);
         var _loc3_:Sprite = new Sprite();
         _loc3_.x = _loc1_.x;
         _loc3_.y = _loc1_.y;
         var _loc4_:Graphics = _loc3_.graphics;
         var _loc5_:BitmapData = null;
         FlashGraphics.bitmapFill[_loc4_] = _loc5_;
         _loc4_.beginFill(16777215,1);
         _loc3_.graphics.drawRect(0,0,_loc1_.width,_loc1_.height);
         _loc4_ = _loc3_.graphics;
         _loc5_ = null;
         FlashGraphics.bitmapFill[_loc4_] = _loc5_;
         _loc4_.endFill();
         _loc3_.alpha = 0;
         mcDragger = _loc3_;
         addChild(mcDragger);
         btnClose = new CloseButton();
         btnClose.visible = false;
         btnClose.x = 337;
         btnClose.y = 0;
         btnClose.visible = false;
         addChild(btnClose);
         btnOk = new RedButton();
         btnOk.x = 120;
         btnOk.y = 180;
         addChild(btnOk);
         var _loc6_:TextFormat = new TextFormat("Co Text Bold",12,null,false);
         _loc6_.align = "center";
         lblMsg = new TextField();
         lblMsg.text = "";
         lblMsg.x = 25;
         lblMsg.y = 43;
         lblMsg.width = 314;
         lblMsg.height = 124;
         lblMsg.multiline = true;
         lblMsg.defaultTextFormat = _loc6_;
         lblMsg.embedFonts = true;
         lblMsg.wordWrap = true;
         lblMsg.selectable = false;
         addChild(lblMsg);
      }
      
      public function okClicked(param1:MouseEvent) : void
      {
         vo.response = AlertResponse.OK;
         if(vo.callBack != null)
         {
            vo.callBack(vo.response,vo);
         }
         dispatchEvent(new Event("closeClicked"));
      }
      
      override public function init() : void
      {
         btnClose.addEventListener(MouseEvent.CLICK,closeClicked);
         btnOk.set_text("OK");
         btnOk.addEventListener(MouseEvent.CLICK,okClicked);
         titleTextField = lbl_Title;
         messageTextField = lblMsg;
         titleTextField.text = vo.title;
         messageTextField.htmlText = vo.description;
         messageTextField.mouseEnabled = true;
         messageTextField.height = messageTextField.textHeight + 8;
         if(messageTextField.height > 150)
         {
            messageTextField.y = 38;
         }
         else
         {
            messageTextField.y = (190 - messageTextField.height) / 2 + 20;
         }
         background.graphics.clear();
         var _loc1_:Graphics = background.graphics;
         var _loc2_:BitmapData = null;
         FlashGraphics.bitmapFill[_loc1_] = _loc2_;
         _loc1_.beginFill(16777215,1);
         if(messageTextField.height < 150)
         {
            background.graphics.drawRoundRect(5,27,346,210,8);
            btnOk.y = 184;
         }
         else
         {
            background.graphics.drawRoundRect(5,27,346,messageTextField.y + messageTextField.height + 30,8);
            btnOk.y = messageTextField.y + messageTextField.height + 8;
         }
         _loc1_ = background.graphics;
         _loc2_ = null;
         FlashGraphics.bitmapFill[_loc1_] = _loc2_;
         _loc1_.endFill();
         background.alpha = 0.9;
         super.init();
      }
      
      public function dragger() : DisplayObject
      {
         return mcDragger;
      }
      
      public function dispose() : void
      {
         btnClose.removeEventListener(MouseEvent.CLICK,closeClicked);
         btnOk.removeEventListener(MouseEvent.CLICK,okClicked);
      }
      
      public function closeClicked(param1:MouseEvent) : void
      {
         vo.response = AlertResponse.CLOSE;
         if(vo.callBack != null)
         {
            vo.callBack(vo.response,vo);
         }
         dispatchEvent(new Event("closeClicked"));
      }
   }
}

