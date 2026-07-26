package org.oyunstudyosu.alert.buttons
{
   import com.oyunstudyosu.components.CloseButton;
   public class CloseViewButton extends CloseButton
   {
      
      public function CloseViewButton()
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

