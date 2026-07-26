package com.oyunstudyosu.achievement
{
      import com.oyunstudyosu.capture.CaptureRuntime;
import com.oyunstudyosu.sanalika.interfaces.IAchievementModel;
   import com.oyunstudyosu.service.IServiceModel;
   
   public class AchievementController
   {
      
      private var servicemodel:IServiceModel;
      
      private var achievementModel:IAchievementModel;
      
      public function AchievementController()
      {
         super();
         servicemodel = CaptureRuntime.sanalikaInstance.serviceModel;
         achievementModel = CaptureRuntime.sanalikaInstance.achievementModel;
         servicemodel.listenExtension("achievementupdate",rewardCountUpdate);
      }
      
      private function rewardCountUpdate(param1:Object) : void
      {
         achievementModel.rewardCount++;
      }
   }
}

