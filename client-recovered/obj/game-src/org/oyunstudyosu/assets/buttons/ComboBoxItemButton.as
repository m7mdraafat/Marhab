package org.oyunstudyosu.assets.buttons
{
   import com.oyunstudyosu.components.SanalikaButton;
   public class ComboBoxItemButton extends SanalikaButton
   {
      
      public function ComboBoxItemButton()
      {
         addFrameScript(0,this.frame1);
         super();
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

