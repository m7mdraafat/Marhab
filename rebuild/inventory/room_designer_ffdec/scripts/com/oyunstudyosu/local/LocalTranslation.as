package com.oyunstudyosu.local
{
   import de.polygonal.core.fmt.Sprintf;
   import flash.utils.Dictionary;
   
   public class LocalTranslation
   {
      
      private static var translations:Dictionary = new Dictionary();
      
      private static var translation:Dictionary = new Dictionary();
      
      public function LocalTranslation()
      {
         super();
      }
      
      private static function init() : *
      {
         addTranslationEntry("tr","LOGIN_ACCOUNT_REVIEWING_TITLE","Hesap inceleniyor");
         addTranslationEntry("tr","LOGIN_ACCOUNT_REVIEWING","Hesap şu anda destek ekibimiz ({0}) tarafından inceleniyor.\nLütfen daha sonra tekrar giriş yapmayı deneyin.");
         addTranslationEntry("tr","LOGIN_ERROR_TITLE","Hata");
         addTranslationEntry("tr","LOGIN_ACCOUNT_NOT_ACTIVE","Hesabınız aktif değil");
         addTranslationEntry("tr","LOGIN_BANNED_USER","%s tarihine kadar uzaklaştırıldınız!!!");
         addTranslationEntry("tr","LOGIN_BANNED_USER_WITH_REASON","%1$s tarihine kadar \"%2$s\" sebebiyle uzaklaştırıldınız!!!");
         addTranslationEntry("tr","LOGIN_IP_ADDRESS_MAXIMUM_CONNECTION_LIMIT_EXCEEDED","IP adresinizin bağlantı limiti aşıldı");
         addTranslationEntry("tr","Profanity","küfür/hakaret");
         addTranslationEntry("tr","Advertisement","reklam");
         addTranslationEntry("tr","Political","siyasi söylem");
         addTranslationEntry("tr","Religious","dini değerlere saygısızlık");
         addTranslationEntry("tr","Perversity","istismar/taciz");
         addTranslationEntry("tr","Cheat","hile");
         addTranslationEntry("tr","Do you want logout?","Çıkış yapmak istiyor musunuz?");
         addTranslationEntry("tr","You will be logged out.","Hesaptan çıkış yapılacak.");
         addTranslationEntry("ru","LOGIN_ACCOUNT_REVIEWING_TITLE","Счет на рассмотрении");
         addTranslationEntry("ru","LOGIN_ACCOUNT_REVIEWING","В настоящее время аккаунт рассматривается нашей службой поддержки ({0}).\nПопробуйте войти в систему позже.");
         addTranslationEntry("ru","LOGIN_ERROR_TITLE","Ошибка входа");
         addTranslationEntry("ru","LOGIN_ACCOUNT_NOT_ACTIVE","Ваш аккаунт не активирован.");
         addTranslationEntry("ru","LOGIN_BANNED_USER","Вы заблокированы до %s!!!");
         addTranslationEntry("ru","LOGIN_BANNED_USER_WITH_REASON","Вы были заблокированы по \"%2$s\" причине до %1$s!!!");
         addTranslationEntry("ru","LOGIN_IP_ADDRESS_MAXIMUM_CONNECTION_LIMIT_EXCEEDED","Вы превысили максимальное количество подключений с одного IP-адреса.");
         addTranslationEntry("ru","Profanity","ругань/оскорбление");
         addTranslationEntry("ru","Advertisement","Реклама");
         addTranslationEntry("ru","Political","политический дискурс");
         addTranslationEntry("ru","Religious","осквернение религиозных ценностей");
         addTranslationEntry("ru","Perversity","оскорбления/домогательства");
         addTranslationEntry("ru","Cheat","мошенничество");
         addTranslationEntry("ru","Do you want logout?","Вы хотите выйти?");
         addTranslationEntry("ru","You will be logged out.","Вы будете выведены из системы.");
         addTranslationEntry("en","LOGIN_ACCOUNT_REVIEWING_TITLE","Account is under review");
         addTranslationEntry("en","LOGIN_ACCOUNT_REVIEWING","The account is currently under review by our support team ({0}).\nPlease try logging in again later.");
         addTranslationEntry("en","LOGIN_ERROR_TITLE","Login error");
         addTranslationEntry("en","LOGIN_ACCOUNT_NOT_ACTIVE","Account is not active");
         addTranslationEntry("en","LOGIN_BANNED_USER","You are banned until %s!!!");
         addTranslationEntry("en","LOGIN_BANNED_USER_WITH_REASON","You have been banned for \"%2$s\" reason until %1$s!!!");
         addTranslationEntry("en","LOGIN_IP_ADDRESS_MAXIMUM_CONNECTION_LIMIT_EXCEEDED","You have exceeded the maximum number of connections from your IP address.");
         addTranslationEntry("en","Profanity","swearing/insult");
         addTranslationEntry("en","Advertisement","advertisement");
         addTranslationEntry("en","Political","political discourse");
         addTranslationEntry("en","Religious","desecration of religious values");
         addTranslationEntry("en","Perversity","abuse/harassment");
         addTranslationEntry("en","Cheat","cheating");
         addTranslationEntry("en","Do you want logout?","Do you want logout?");
         addTranslationEntry("en","You will be logged out.","You will be logged out.");
         addTranslationEntry("ca","LOGIN_ACCOUNT_REVIEWING_TITLE","Cuenta en revisión");
         addTranslationEntry("ca","LOGIN_ACCOUNT_REVIEWING","La cuenta está siendo revisada por nuestro equipo de soporte ({0}).\nPor favor, intente iniciar sesión de nuevo más tarde.");
         addTranslationEntry("ca","LOGIN_ERROR_TITLE","Error de inicio de sesión");
         addTranslationEntry("ca","LOGIN_ACCOUNT_NOT_ACTIVE","La cuenta no está activa");
         addTranslationEntry("ca","LOGIN_BANNED_USER","Estás baneado hasta el %s!!!");
         addTranslationEntry("ca","LOGIN_BANNED_USER_WITH_REASON","Has sido baneado por \"%2$s\" ¡¡¡hasta %1$s!!!");
         addTranslationEntry("ca","LOGIN_IP_ADDRESS_MAXIMUM_CONNECTION_LIMIT_EXCEEDED","Has alcanzado el límite de conexiones desde la misma IP.");
         addTranslationEntry("ca","Profanity","jurar/insultar");
         addTranslationEntry("ca","Advertisement","publicidad");
         addTranslationEntry("ca","Political","discurso político");
         addTranslationEntry("ca","Religious","profanación de los valores religiosos");
         addTranslationEntry("ca","Perversity","abuso/acoso");
         addTranslationEntry("ca","Cheat","engañar");
         addTranslationEntry("ca","Do you want logout?","¿Quieres cerrar la sesión?");
         addTranslationEntry("ca","You will be logged out.","Se cerrará la sesión.");
         addTranslationEntry("ar","LOGIN_ACCOUNT_REVIEWING_TITLE","الحساب قيد المراجعة");
         addTranslationEntry("ar","LOGIN_ACCOUNT_REVIEWING","الحساب قيد المراجعة حاليًا بواسطة فريق الدعم ({0}).\nيرجى محاولة تسجيل الدخول مرة أخرى في وقت لاحق.");
         addTranslationEntry("ar","LOGIN_ERROR_TITLE","خطأ في تسجيل الدخول");
         addTranslationEntry("ar","LOGIN_ACCOUNT_NOT_ACTIVE","الحساب غير نشط");
         addTranslationEntry("ar","LOGIN_BANNED_USER","تم حظرك حتى %s !!!");
         addTranslationEntry("ar","LOGIN_BANNED_USER_WITH_REASON","لقد تم حظرك لسبب %2$s حتى %1$s !!!");
         addTranslationEntry("ar","LOGIN_IP_ADDRESS_MAXIMUM_CONNECTION_LIMIT_EXCEEDED","لقد تجاوزت الحد الأقصى للاتصال بعنوان IP");
         addTranslationEntry("ar","Profanity","السب / الإهانة");
         addTranslationEntry("ar","Advertisement","إعلان");
         addTranslationEntry("ar","Political","الخطاب السياسي");
         addTranslationEntry("ar","Religious","تدنيس القيم الدينية");
         addTranslationEntry("ar","Perversity","الإساءة / التحرش");
         addTranslationEntry("ar","Cheat","غش");
         addTranslationEntry("ar","Do you want logout?","هل تريد تسجيل الخروج؟");
         addTranslationEntry("ar","You will be logged out.","سيتم تسجيل الخروج.");
      }
      
      private static function addTranslationEntry(param1:String, param2:String, param3:String) : *
      {
         if(translations[param1] == null)
         {
            translations[param1] = new Dictionary();
         }
         translations[param1][param2] = param3;
      }
      
      public static function setLanguage(param1:String) : void
      {
         init();
         if(translations[param1] == null)
         {
            param1 = "en";
         }
         translation = translations[param1];
      }
      
      public static function translate(param1:String, ... rest) : String
      {
         if(!exists(param1))
         {
            return param1;
         }
         return Sprintf.format(translation[param1],rest);
      }
      
      public static function exists(param1:String) : Boolean
      {
         return translation[param1] != null;
      }
   }
}

