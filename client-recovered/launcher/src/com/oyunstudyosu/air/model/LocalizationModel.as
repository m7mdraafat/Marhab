package com.oyunstudyosu.air.model
{
   import flash.Boot;
   import flash.system.Capabilities;
   import haxe.IMap;
   import haxe.ds.StringMap;
   
   public class LocalizationModel
   {
      
      public var translations:IMap;
      
      public var tr_translations:IMap;
      
      public var es_translations:IMap;
      
      public var ar_translations:IMap;
      
      public function LocalizationModel()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         var _loc1_:StringMap = new StringMap();
         if("Download Complete" in StringMap.reserved)
         {
            _loc1_.setReserved("Download Complete","Descarga completa");
         }
         else
         {
            _loc1_.h["Download Complete"] = "Descarga completa";
         }
         if("Downloading Update" in StringMap.reserved)
         {
            _loc1_.setReserved("Downloading Update","Descargando actualización");
         }
         else
         {
            _loc1_.h["Downloading Update"] = "Descargando actualización";
         }
         if("Loading Client Failed" in StringMap.reserved)
         {
            _loc1_.setReserved("Loading Client Failed","Error al cargar el cliente");
         }
         else
         {
            _loc1_.h["Loading Client Failed"] = "Error al cargar el cliente";
         }
         if("Loading Client" in StringMap.reserved)
         {
            _loc1_.setReserved("Loading Client","Cargando Cliente");
         }
         else
         {
            _loc1_.h["Loading Client"] = "Cargando Cliente";
         }
         if("Initializing..." in StringMap.reserved)
         {
            _loc1_.setReserved("Initializing...","Inicializando...");
         }
         else
         {
            _loc1_.h["Initializing..."] = "Inicializando...";
         }
         if("Error" in StringMap.reserved)
         {
            _loc1_.setReserved("Error","Error");
         }
         else
         {
            _loc1_.h["Error"] = "Error";
         }
         if("Retry" in StringMap.reserved)
         {
            _loc1_.setReserved("Retry","Rever");
         }
         else
         {
            _loc1_.h["Retry"] = "Rever";
         }
         if("Information" in StringMap.reserved)
         {
            _loc1_.setReserved("Information","Información");
         }
         else
         {
            _loc1_.h["Information"] = "Información";
         }
         if("The config file download failed, please make sure you have an internet connection and try again" in StringMap.reserved)
         {
            _loc1_.setReserved("The config file download failed, please make sure you have an internet connection and try again","La descarga del archivo de configuración falló, asegúrese de tener una conexión a Internet e intente nuevamente");
         }
         else
         {
            _loc1_.h["The config file download failed, please make sure you have an internet connection and try again"] = "La descarga del archivo de configuración falló, asegúrese de tener una conexión a Internet e intente nuevamente";
         }
         if("To perform the update, you must run the program as an administrator" in StringMap.reserved)
         {
            _loc1_.setReserved("To perform the update, you must run the program as an administrator","Para realizar la actualización, debe ejecutar el programa como administrador");
         }
         else
         {
            _loc1_.h["To perform the update, you must run the program as an administrator"] = "Para realizar la actualización, debe ejecutar el programa como administrador";
         }
         if("You have been redirected to the web page to download the update" in StringMap.reserved)
         {
            _loc1_.setReserved("You have been redirected to the web page to download the update","Ha sido redirigido a la página web para descargar la actualización");
         }
         else
         {
            _loc1_.h["You have been redirected to the web page to download the update"] = "Ha sido redirigido a la página web para descargar la actualización";
         }
         es_translations = _loc1_;
         var _loc2_:StringMap = new StringMap();
         if("Download Complete" in StringMap.reserved)
         {
            _loc2_.setReserved("Download Complete","تم التحميل");
         }
         else
         {
            _loc2_.h["Download Complete"] = "تم التحميل";
         }
         if("Downloading Update" in StringMap.reserved)
         {
            _loc2_.setReserved("Downloading Update","تحميل التحديث");
         }
         else
         {
            _loc2_.h["Downloading Update"] = "تحميل التحديث";
         }
         if("Loading Client Failed" in StringMap.reserved)
         {
            _loc2_.setReserved("Loading Client Failed","فشل تحميل العميل");
         }
         else
         {
            _loc2_.h["Loading Client Failed"] = "فشل تحميل العميل";
         }
         if("Loading Client" in StringMap.reserved)
         {
            _loc2_.setReserved("Loading Client","تحميل العميل");
         }
         else
         {
            _loc2_.h["Loading Client"] = "تحميل العميل";
         }
         if("Initializing..." in StringMap.reserved)
         {
            _loc2_.setReserved("Initializing...","جاري التهيئة...");
         }
         else
         {
            _loc2_.h["Initializing..."] = "جاري التهيئة...";
         }
         if("Error" in StringMap.reserved)
         {
            _loc2_.setReserved("Error","خطأ");
         }
         else
         {
            _loc2_.h["Error"] = "خطأ";
         }
         if("Retry" in StringMap.reserved)
         {
            _loc2_.setReserved("Retry","أعد المحاولة");
         }
         else
         {
            _loc2_.h["Retry"] = "أعد المحاولة";
         }
         if("Information" in StringMap.reserved)
         {
            _loc2_.setReserved("Information","معلومة");
         }
         else
         {
            _loc2_.h["Information"] = "معلومة";
         }
         if("The config file download failed, please make sure you have an internet connection and try again" in StringMap.reserved)
         {
            _loc2_.setReserved("The config file download failed, please make sure you have an internet connection and try again","فشل تنزيل ملف التكوين ، يرجى التأكد من اتصالك بالإنترنت وحاول مرة أخرى");
         }
         else
         {
            _loc2_.h["The config file download failed, please make sure you have an internet connection and try again"] = "فشل تنزيل ملف التكوين ، يرجى التأكد من اتصالك بالإنترنت وحاول مرة أخرى";
         }
         if("To perform the update, you must run the program as an administrator" in StringMap.reserved)
         {
            _loc2_.setReserved("To perform the update, you must run the program as an administrator","لتنفيذ التحديث ، يجب تشغيل البرنامج كمسؤول");
         }
         else
         {
            _loc2_.h["To perform the update, you must run the program as an administrator"] = "لتنفيذ التحديث ، يجب تشغيل البرنامج كمسؤول";
         }
         if("You have been redirected to the web page to download the update" in StringMap.reserved)
         {
            _loc2_.setReserved("You have been redirected to the web page to download the update","لقد تم إعادة توجيهك إلى صفحة الويب لتنزيل التحديث");
         }
         else
         {
            _loc2_.h["You have been redirected to the web page to download the update"] = "لقد تم إعادة توجيهك إلى صفحة الويب لتنزيل التحديث";
         }
         ar_translations = _loc2_;
         var _loc3_:StringMap = new StringMap();
         if("Download Complete" in StringMap.reserved)
         {
            _loc3_.setReserved("Download Complete","İndirme Tamamlandı");
         }
         else
         {
            _loc3_.h["Download Complete"] = "İndirme Tamamlandı";
         }
         if("Downloading Update" in StringMap.reserved)
         {
            _loc3_.setReserved("Downloading Update","Güncelleme İndiriliyor");
         }
         else
         {
            _loc3_.h["Downloading Update"] = "Güncelleme İndiriliyor";
         }
         if("Loading Client Failed" in StringMap.reserved)
         {
            _loc3_.setReserved("Loading Client Failed","İstemci yüklenemedi");
         }
         else
         {
            _loc3_.h["Loading Client Failed"] = "İstemci yüklenemedi";
         }
         if("Loading Client" in StringMap.reserved)
         {
            _loc3_.setReserved("Loading Client","İstemci Yükleniyor");
         }
         else
         {
            _loc3_.h["Loading Client"] = "İstemci Yükleniyor";
         }
         if("Initializing..." in StringMap.reserved)
         {
            _loc3_.setReserved("Initializing...","Başlatılıyor...");
         }
         else
         {
            _loc3_.h["Initializing..."] = "Başlatılıyor...";
         }
         if("Error" in StringMap.reserved)
         {
            _loc3_.setReserved("Error","Hata");
         }
         else
         {
            _loc3_.h["Error"] = "Hata";
         }
         if("Retry" in StringMap.reserved)
         {
            _loc3_.setReserved("Retry","Yeniden Dene");
         }
         else
         {
            _loc3_.h["Retry"] = "Yeniden Dene";
         }
         if("Information" in StringMap.reserved)
         {
            _loc3_.setReserved("Information","Bilgi");
         }
         else
         {
            _loc3_.h["Information"] = "Bilgi";
         }
         if("The config file download failed, please make sure you have an internet connection and try again" in StringMap.reserved)
         {
            _loc3_.setReserved("The config file download failed, please make sure you have an internet connection and try again","Yapılandırma dosyası indirilemedi, lütfen internet bağlantınız olduğundan emin olun ve tekrar deneyin");
         }
         else
         {
            _loc3_.h["The config file download failed, please make sure you have an internet connection and try again"] = "Yapılandırma dosyası indirilemedi, lütfen internet bağlantınız olduğundan emin olun ve tekrar deneyin";
         }
         if("To perform the update, you must run the program as an administrator" in StringMap.reserved)
         {
            _loc3_.setReserved("To perform the update, you must run the program as an administrator","Güncellemeyi gerçekleştirmek için programı yönetici olarak çalıştırmanız gerekir");
         }
         else
         {
            _loc3_.h["To perform the update, you must run the program as an administrator"] = "Güncellemeyi gerçekleştirmek için programı yönetici olarak çalıştırmanız gerekir";
         }
         if("You have been redirected to the web page to download the update" in StringMap.reserved)
         {
            _loc3_.setReserved("You have been redirected to the web page to download the update","Güncellemeyi indirmek için web sayfasına yönlendirildiniz");
         }
         else
         {
            _loc3_.h["You have been redirected to the web page to download the update"] = "Güncellemeyi indirmek için web sayfasına yönlendirildiniz";
         }
         tr_translations = _loc3_;
         translations = null;
         initLanguage();
      }
      
      public function translate(param1:String) : String
      {
         var _loc2_:Boolean = false;
         var _loc3_:* = null as StringMap;
         if(translations != null)
         {
            _loc3_ = translations;
            _loc2_ = param1 in StringMap.reserved ? _loc3_.existsReserved(param1) : param1 in _loc3_.h;
         }
         else
         {
            _loc2_ = false;
         }
         if(_loc2_)
         {
            _loc3_ = translations;
            if(param1 in StringMap.reserved)
            {
               return _loc3_.getReserved(param1);
            }
            return _loc3_.h[param1];
         }
         return param1;
      }
      
      public function initLanguage() : void
      {
         var _loc1_:String = Capabilities.language;
         if(_loc1_ == "ar")
         {
            translations = ar_translations;
         }
         else if(_loc1_ == "es")
         {
            translations = es_translations;
         }
         else if(_loc1_ == "tr")
         {
            translations = tr_translations;
         }
      }
   }
}

