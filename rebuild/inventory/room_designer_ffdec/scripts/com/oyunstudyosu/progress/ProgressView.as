package com.oyunstudyosu.progress
{
   import com.greensock.TweenMax;
   import com.oyunstudyosu.events.Dispatcher;
   import com.oyunstudyosu.events.GameEvent;
   import com.oyunstudyosu.events.OSProgressEvent;
   import com.oyunstudyosu.utils.NumberUtils;
   import com.oyunstudyosu.utils.STextField;
   import flash.display.Sprite;
   import flash.utils.Dictionary;
   import org.oyunstudyosu.assets.clips.ProgressUI;
   
   public class ProgressView extends Sprite
   {
      
      private var view:ProgressUI;
      
      private var currentPercent:int;
      
      private var initProgress:int;
      
      private var progressText:Dictionary;
      
      public var stxtTitle:STextField;
      
      public function ProgressView()
      {
         super();
         progressText = new Dictionary();
         var _loc1_:int = Math.random() * 5;
         switch(_loc1_)
         {
            case 0:
               progressText["LOADING"] = "°j°m";
               break;
            case 1:
               progressText["LOADING"] = "><((((‘>";
               break;
            case 2:
               progressText["LOADING"] = "‘-‘_@_";
               break;
            case 3:
               progressText["LOADING"] = "(,,,)=(^.^)=(,,,)";
               break;
            case 4:
               progressText["LOADING"] = "—-{,_,”>";
               break;
            case 5:
               progressText["LOADING"] = "~~~~~~~~*o/~~~~~/*~~~~~~~";
         }
         progressText["CONNECTING"] = "connecting to Sanalika...";
         progressText["LANG_FILE_READY"] = "what? no no not that file...";
         progressText["CONNECTED"] = "yes! plug that cable!";
         progressText["LOGINED"] = "logged in to alien server?";
         progressText["CONFIG_READY"] = "counting stars...";
         progressText["INFO_FILE_READY"] = "still loading some useless files...huh";
         progressText["GAME_EXTENSIONS_LOADED"] = "extending muscles";
         progressText["INIT_READY"] = "initiating rockets...";
         progressText["GAME_READY"] = "ready for some rock\'n roll...";
         progressText["PROGRESS_FULL"] = "progress full";
         progressText["LOAD_DESIGNER"] = "loading designer...";
         progressText["DESIGNER_LOADED"] = "designer loaded...";
         progressText["JOINING_USER_ROOM"] = "joining user room";
         progressText["ROOM_FILES"] = "room files are loading";
         progressText["QUEUE"] = "waiting in the queue...";
         view = new ProgressUI();
         addChild(view);
         Dispatcher.addEventListener("INIT_PROGRESS",onInitProgress);
         Dispatcher.addEventListener("LOADING_PROGRESS",onLoadingProgress);
         Dispatcher.addEventListener("INITCOMMAND",setLang);
         changeAnimation();
      }
      
      private function setLang(param1:GameEvent) : void
      {
         Dispatcher.removeEventListener("INITCOMMAND",setLang);
         if(param1.lang == "tr")
         {
            progressText["CONNECTING"] = "Sanalika\'ya bağlanıyor...";
            progressText["LANG_FILE_READY"] = "enişte koş koş başlıyor...";
            progressText["CONNECTED"] = "necati, nerede bu kablonun diğer ucu!";
            progressText["LOGINED"] = "galiba sanırsam bağlandık kaptan";
            progressText["CONFIG_READY"] = "gereksiz dosyalar yükleniyor...";
            progressText["INFO_FILE_READY"] = "daha fazla gereksiz dosya yükleniyor...";
            progressText["GAME_EXTENSIONS_LOADED"] = "ısınmadan bu kadar yükleme yapılmaz! yavaş!";
            progressText["INIT_READY"] = "roketleri ateşlemeye 3...";
            progressText["GAME_READY"] = "neredeyse pişmek üzere";
            progressText["PROGRESS_FULL"] = "doldu abi, gazla!";
            progressText["LOAD_DESIGNER"] = "dekoratorü yükle Skati...";
            progressText["DESIGNER_LOADED"] = "dekoratör yüklendi Kaptan...";
            progressText["JOINING_USER_ROOM"] = "katıl kurt";
            progressText["ROOM_FILES"] = "oda dosyalarını da yükle güzel güzel";
            progressText["QUEUE"] = "kuyrukta bekliyoruz";
         }
         if(param1.lang == "_ar")
         {
            progressText["CONNECTING"] = "في طور الاتصال بمرحب...";
            progressText["LANG_FILE_READY"] = "هيا أسرع ياعمي .. نحن على وشك البدء...";
            progressText["CONNECTED"] = "يا ناجي، أين الطرف الآخر لهذا الكابل!";
            progressText["LOGINED"] = "على الأغلب أظن أننا على اتصال أيها القبطان";
            progressText["CONFIG_READY"] = "جاري تحميل ملفات لا لزوم لها ...";
            progressText["INFO_FILE_READY"] = "جاري تحميل مزيد من الملفات غير المرغوب فيها ...";
            progressText["GAME_EXTENSIONS_LOADED"] = "ينبغي ألا يتم التحميل بهذا القدر قبل استكمال التحمية! على مهلك";
            progressText["INIT_READY"] = "نحن على وشك الإقلاع .. ثلاثة .. اثنان .. واحد";
            progressText["GAME_READY"] = "إنه على وشك النضوج تقريبا";
            progressText["PROGRESS_FULL"] = "لقد امتلآت بالغاز";
            progressText["LOAD_DESIGNER"] = "حمل الديكور يافتى...";
            progressText["DESIGNER_LOADED"] = "الديكور حمل أيها القبطان...";
            progressText["JOINING_USER_ROOM"] = "اشترك معنا يا ديب";
            progressText["ROOM_FILES"] = "حمل ملفات غرفتك أيضا بشكل سلس";
         }
         if(param1.lang == "ru")
         {
            progressText["CONNECTING"] = "Подключение к Sanalika..";
            progressText["LANG_FILE_READY"] = "что? нет, нет, не этот файл...";
            progressText["CONNECTED"] = "Да! Подключи этот кабель!";
            progressText["LOGINED"] = "Вход в чужой сервер";
            progressText["CONFIG_READY"] = "Подсчет звезд";
            progressText["INFO_FILE_READY"] = "хех..всё ещё загружает ненужные";
            progressText["GAME_EXTENSIONS_LOADED"] = "расширение мышц";
            progressText["INIT_READY"] = "иницирующие ракеты";
            progressText["GAME_READY"] = "готовы к рок-н-роллу";
            progressText["PROGRESS_FULL"] = "полный прогресс";
            progressText["LOAD_DESIGNER"] = "загрузка дизайнера";
            progressText["DESIGNER_LOADED"] = "дизайнер загружен";
            progressText["JOINING_USER_ROOM"] = "присоединение к пользовательской комнате";
            progressText["ROOM_FILES"] = "файлы комнаты загружаются";
         }
      }
      
      private function translateProcess(param1:String) : String
      {
         if(progressText[param1])
         {
            return progressText[param1];
         }
         return param1;
      }
      
      private function changeAnimation() : void
      {
         TweenMax.killDelayedCallsTo(changeAnimation);
         var _loc1_:int = int(NumberUtils.randRange(1,view.bar.animation.totalFrames));
         view.bar.animation.gotoAndStop(_loc1_);
         TweenMax.delayedCall(20,changeAnimation);
      }
      
      private function onProgressCompleted() : void
      {
         initProgress = 0;
         currentPercent = 0;
         this.visible = false;
      }
      
      private function onLoadingProgress(param1:OSProgressEvent) : void
      {
         currentPercent = initProgress + (100 - initProgress) * param1.vo.percent / 100;
         this.visible = true;
         view.bar.loadingText.text = translateProcess(param1.vo.description) + "\n%" + param1.vo.percent;
         if(currentPercent >= 100)
         {
            onProgressCompleted();
         }
      }
      
      private function onInitProgress(param1:OSProgressEvent) : void
      {
         initProgress = param1.vo.percent;
         view.bar.loadingText.text = translateProcess(param1.vo.description);
         this.visible = true;
         if(initProgress >= 100)
         {
            onProgressCompleted();
         }
      }
      
      public function dispose() : void
      {
         TweenMax.killDelayedCallsTo(changeAnimation);
         Dispatcher.removeEventListener("INIT_PROGRESS",onInitProgress);
         Dispatcher.removeEventListener("LOADING_PROGRESS",onLoadingProgress);
      }
   }
}

