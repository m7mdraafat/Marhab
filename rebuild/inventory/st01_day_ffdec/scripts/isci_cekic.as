package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol321")]
   public dynamic class isci_cekic extends MovieClip
   {
      
      public function isci_cekic()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         gotoAndPlay(int(Math.random() * 10) * 100);
      }
   }
}

