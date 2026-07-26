package com.oyunstudyosu.air.ui
{
   import feathers.controls.LayoutGroup;
   import feathers.layout.VerticalLayout;
   import flash.Boot;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class InstanceItem extends LayoutGroup
   {
      
      public var title:TextField;
      
      public var image:Sprite;
      
      public function InstanceItem()
      {
         super();
         if(Boot.skip_constructor)
         {
            return;
         }
         set_layout(new VerticalLayout());
         image = new Sprite();
         addChild(image);
         var _loc1_:TextFormat = new TextFormat("Co Text Bold",16,null,false);
         _loc1_.align = "center";
         title = new TextField();
         title.width = 146;
         title.height = 31.9;
         title.selectable = false;
         title.defaultTextFormat = _loc1_;
         title.embedFonts = true;
         addChild(title);
      }
   }
}

