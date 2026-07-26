package
{
   import lime.utils.AssetLibrary;
   import lime.utils.AssetManifest;
   import lime.utils.Assets;
   
   public class ManifestResources
   {
      
      public static var preloadLibraries:Array;
      
      public static var preloadLibraryNames:Array;
      
      public static var rootPath:String;
      
      public function ManifestResources()
      {
      }
      
      public static function init(param1:*) : void
      {
         ManifestResources.preloadLibraries = [];
         ManifestResources.preloadLibraryNames = [];
         ManifestResources.rootPath = null;
         if(param1 != null && Reflect.hasField(param1,"rootPath"))
         {
            ManifestResources.rootPath = Reflect.field(param1,"rootPath");
         }
         if(ManifestResources.rootPath == null)
         {
            ManifestResources.rootPath = "./";
         }
         var _loc3_:String = "{\"name\":\"SanalikaAirUI\",\"assets\":\"ah\",\"rootPath\":\"lib/SanalikaAirUI\",\"version\":2,\"libraryArgs\":[\"SanalikaAirUI.swf\"],\"libraryType\":\"swf.SWFLibrary\"}";
         var _loc4_:AssetManifest = AssetManifest.parse(_loc3_,ManifestResources.rootPath);
         var _loc5_:AssetLibrary = AssetLibrary.fromManifest(_loc4_);
         Assets.registerLibrary("SanalikaAirUI",_loc5_);
         _loc3_ = "{\"name\":null,\"assets\":\"aoy4:sizei207633y4:typey5:IMAGEy9:classNamey30:__ASSET__assets_background_pngy2:idy23:assets%2Fbackground.pnggoR0i692R1R2R3y58:__ASSET__assets_components_buttons_closebutton_default_pngR5y57:assets%2Fcomponents%2Fbuttons%2FCloseButton%2Fdefault.pnggoR0i707R1R2R3y55:__ASSET__assets_components_buttons_closebutton_down_pngR5y54:assets%2Fcomponents%2Fbuttons%2FCloseButton%2Fdown.pnggoR0i699R1R2R3y56:__ASSET__assets_components_buttons_closebutton_hover_pngR5y55:assets%2Fcomponents%2Fbuttons%2FCloseButton%2Fhover.pnggoR0i1001R1R2R3y56:__ASSET__assets_components_buttons_redbutton_default_pngR5y55:assets%2Fcomponents%2Fbuttons%2FRedButton%2Fdefault.pnggoR0i1020R1R2R3y53:__ASSET__assets_components_buttons_redbutton_down_pngR5y52:assets%2Fcomponents%2Fbuttons%2FRedButton%2Fdown.pnggoR0i982R1R2R3y54:__ASSET__assets_components_buttons_redbutton_hover_pngR5y53:assets%2Fcomponents%2Fbuttons%2FRedButton%2Fhover.pnggoR0i969R1R2R3y59:__ASSET__assets_components_buttons_yellowbutton_default_pngR5y58:assets%2Fcomponents%2Fbuttons%2FYellowButton%2Fdefault.pnggoR0i918R1R2R3y56:__ASSET__assets_components_buttons_yellowbutton_down_pngR5y55:assets%2Fcomponents%2Fbuttons%2FYellowButton%2Fdown.pnggoR0i995R1R2R3y57:__ASSET__assets_components_buttons_yellowbutton_hover_pngR5y56:assets%2Fcomponents%2Fbuttons%2FYellowButton%2Fhover.pnggoR0i1564R1R2R3y38:__ASSET__assets_hud_redpanelheader_pngR5y33:assets%2Fhud%2FRedPanelHeader.pnggoR0i1441R1R2R3y41:__ASSET__assets_hud_yellowpanelheader_pngR5y36:assets%2Fhud%2FYellowPanelHeader.pnggh\",\"rootPath\":null,\"version\":2,\"libraryArgs\":[],\"libraryType\":null}";
         _loc4_ = AssetManifest.parse(_loc3_,ManifestResources.rootPath);
         _loc5_ = AssetLibrary.fromManifest(_loc4_);
         Assets.registerLibrary("assets",_loc5_);
         _loc3_ = "{\"name\":null,\"assets\":\"aoy4:sizei192156y4:typey4:FONTy9:classNamey38:__ASSET__assets_fonts_co_text_bold_ttfy2:idy37:assets%2Ffonts%2FCo%20Text%20Bold.ttfgoR0i196484R1R2R3y39:__ASSET__assets_fonts_co_text_light_ttfR5y38:assets%2Ffonts%2FCo%20Text%20Light.ttfgoR0i193032R1R2R3y41:__ASSET__assets_fonts_co_text_regular_ttfR5y40:assets%2Ffonts%2FCo%20Text%20Regular.ttfgoR0i12946R1y5:IMAGER3y31:__ASSET__assets_flags_egypt_pngR5y26:assets%2Fflags%2Fegypt.pnggoR0i6279R1R11R3y32:__ASSET__assets_flags_global_pngR5y27:assets%2Fflags%2Fglobal.pnggoR0i14611R1R11R3y32:__ASSET__assets_flags_marhab_pngR5y27:assets%2Fflags%2Fmarhab.pnggoR0i5029R1R11R3y32:__ASSET__assets_flags_russia_pngR5y27:assets%2Fflags%2Frussia.pnggoR0i13080R1R11R3y31:__ASSET__assets_flags_spain_pngR5y26:assets%2Fflags%2Fspain.pnggoR0i6007R1R11R3y32:__ASSET__assets_flags_turkey_pngR5y27:assets%2Fflags%2Fturkey.pnggoR0i10340R1R11R3y33:__ASSET__assets_flags_unknown_pngR5y28:assets%2Fflags%2Funknown.pnggh\",\"rootPath\":null,\"version\":2,\"libraryArgs\":[],\"libraryType\":null}";
         _loc4_ = AssetManifest.parse(_loc3_,ManifestResources.rootPath);
         _loc5_ = AssetLibrary.fromManifest(_loc4_);
         Assets.registerLibrary("default",_loc5_);
         _loc5_ = Assets.getLibrary("SanalikaAirUI");
         trace("[PRELOAD] ManifestResources getLibrary(SanalikaAirUI) -> " + (_loc5_ != null));
         if(_loc5_ != null)
         {
            ManifestResources.preloadLibraries.push(_loc5_);
         }
         else
         {
            ManifestResources.preloadLibraryNames.push("SanalikaAirUI");
         }
         _loc5_ = Assets.getLibrary("default");
         trace("[PRELOAD] ManifestResources getLibrary(default) -> " + (_loc5_ != null));
         if(_loc5_ != null)
         {
            ManifestResources.preloadLibraries.push(_loc5_);
         }
         else
         {
            ManifestResources.preloadLibraryNames.push("default");
         }
      }
   }
}

