package org.oyunstudyosu.assets.buttons
{
   import com.oyunstudyosu.components.SanalikaButton;
   public class ComboBoxItemButton extends SanalikaButton
   {
      
      public function ComboBoxItemButton()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

