package com.distriqt.extension.facebook.appevents
{
   public class AppEventsConstants
   {
      
      public static const EVENT_NAME_ACTIVATED_APP:String = "fb_mobile_activate_app";
      
      public static const EVENT_NAME_DEACTIVATED_APP:String = "fb_mobile_deactivate_app";
      
      public static const EVENT_NAME_SESSION_INTERRUPTIONS:String = "fb_mobile_app_interruptions";
      
      public static const EVENT_NAME_TIME_BETWEEN_SESSIONS:String = "fb_mobile_time_between_sessions";
      
      public static const EVENT_NAME_COMPLETED_REGISTRATION:String = "fb_mobile_complete_registration";
      
      public static const EVENT_NAME_VIEWED_CONTENT:String = "fb_mobile_content_view";
      
      public static const EVENT_NAME_SEARCHED:String = "fb_mobile_search";
      
      public static const EVENT_NAME_RATED:String = "fb_mobile_rate";
      
      public static const EVENT_NAME_COMPLETED_TUTORIAL:String = "fb_mobile_tutorial_completion";
      
      public static const EVENT_NAME_PUSH_TOKEN_OBTAINED:String = "fb_mobile_obtain_push_token";
      
      public static const EVENT_NAME_ADDED_TO_CART:String = "fb_mobile_add_to_cart";
      
      public static const EVENT_NAME_ADDED_TO_WISHLIST:String = "fb_mobile_add_to_wishlist";
      
      public static const EVENT_NAME_INITIATED_CHECKOUT:String = "fb_mobile_initiated_checkout";
      
      public static const EVENT_NAME_ADDED_PAYMENT_INFO:String = "fb_mobile_add_payment_info";
      
      [Deprecated(message="Use AppEventsLogger.logPurchase instead")]
      public static const EVENT_NAME_PURCHASED:String = "fb_mobile_purchase";
      
      public static const EVENT_NAME_ACHIEVED_LEVEL:String = "fb_mobile_level_achieved";
      
      public static const EVENT_NAME_UNLOCKED_ACHIEVEMENT:String = "fb_mobile_achievement_unlocked";
      
      public static const EVENT_NAME_SPENT_CREDITS:String = "fb_mobile_spent_credits";
      
      public static const EVENT_NAME_CONTACT:String = "Contact";
      
      public static const EVENT_NAME_CUSTOMIZE_PRODUCT:String = "CustomizeProduct";
      
      public static const EVENT_NAME_DONATE:String = "Donate";
      
      public static const EVENT_NAME_FIND_LOCATION:String = "FindLocation";
      
      public static const EVENT_NAME_SCHEDULE:String = "Schedule";
      
      public static const EVENT_NAME_START_TRIAL:String = "StartTrial";
      
      public static const EVENT_NAME_SUBMIT_APPLICATION:String = "SubmitApplication";
      
      public static const EVENT_NAME_SUBSCRIBE:String = "Subscribe";
      
      public static const EVENT_NAME_AD_IMPRESSION:String = "AdImpression";
      
      public static const EVENT_NAME_AD_CLICK:String = "AdClick";
      
      public static const EVENT_NAME_LIVE_STREAMING_START:String = "fb_sdk_live_streaming_start";
      
      public static const EVENT_NAME_LIVE_STREAMING_STOP:String = "fb_sdk_live_streaming_stop";
      
      public static const EVENT_NAME_LIVE_STREAMING_PAUSE:String = "fb_sdk_live_streaming_pause";
      
      public static const EVENT_NAME_LIVE_STREAMING_RESUME:String = "fb_sdk_live_streaming_resume";
      
      public static const EVENT_NAME_LIVE_STREAMING_ERROR:String = "fb_sdk_live_streaming_error";
      
      public static const EVENT_NAME_LIVE_STREAMING_UPDATE_STATUS:String = "fb_sdk_live_streaming_update_status";
      
      public static const EVENT_NAME_PRODUCT_CATALOG_UPDATE:String = "fb_mobile_catalog_update";
      
      public static const EVENT_PARAM_LIVE_STREAMING_PREV_STATUS:String = "live_streaming_prev_status";
      
      public static const EVENT_PARAM_LIVE_STREAMING_STATUS:String = "live_streaming_status";
      
      public static const EVENT_PARAM_LIVE_STREAMING_ERROR:String = "live_streaming_error";
      
      public static const EVENT_PARAM_CURRENCY:String = "fb_currency";
      
      public static const EVENT_PARAM_REGISTRATION_METHOD:String = "fb_registration_method";
      
      public static const EVENT_PARAM_CONTENT_TYPE:String = "fb_content_type";
      
      public static const EVENT_PARAM_CONTENT:String = "fb_content";
      
      public static const EVENT_PARAM_CONTENT_ID:String = "fb_content_id";
      
      public static const EVENT_PARAM_SEARCH_STRING:String = "fb_search_string";
      
      public static const EVENT_PARAM_SUCCESS:String = "fb_success";
      
      public static const EVENT_PARAM_MAX_RATING_VALUE:String = "fb_max_rating_value";
      
      public static const EVENT_PARAM_PAYMENT_INFO_AVAILABLE:String = "fb_payment_info_available";
      
      public static const EVENT_PARAM_NUM_ITEMS:String = "fb_num_items";
      
      public static const EVENT_PARAM_LEVEL:String = "fb_level";
      
      public static const EVENT_PARAM_DESCRIPTION:String = "fb_description";
      
      public static const EVENT_PARAM_SOURCE_APPLICATION:String = "fb_mobile_launch_source";
      
      public static const EVENT_PARAM_PACKAGE_FP:String = "fb_mobile_pckg_fp";
      
      public static const EVENT_PARAM_APP_CERT_HASH:String = "fb_mobile_app_cert_hash";
      
      public static const EVENT_PARAM_VALUE_YES:String = "1";
      
      public static const EVENT_PARAM_VALUE_NO:String = "0";
      
      public static const EVENT_PARAM_AD_TYPE:String = "ad_type";
      
      public static const EVENT_PARAM_ORDER_ID:String = "fb_order_id";
      
      public static const EVENT_PARAM_VALUE_TO_SUM:String = "_valueToSum";
      
      public static const EVENT_PARAM_PRODUCT_CUSTOM_LABEL_0:String = "fb_product_custom_label_0";
      
      public static const EVENT_PARAM_PRODUCT_CUSTOM_LABEL_1:String = "fb_product_custom_label_1";
      
      public static const EVENT_PARAM_PRODUCT_CUSTOM_LABEL_2:String = "fb_product_custom_label_2";
      
      public static const EVENT_PARAM_PRODUCT_CUSTOM_LABEL_3:String = "fb_product_custom_label_3";
      
      public static const EVENT_PARAM_PRODUCT_CUSTOM_LABEL_4:String = "fb_product_custom_label_4";
      
      public static const EVENT_PARAM_PRODUCT_CATEGORY:String = "fb_product_category";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IOS_URL:String = "fb_product_applink_ios_url";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IOS_APP_STORE_ID:String = "fb_product_applink_ios_app_store_id";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IOS_APP_NAME:String = "fb_product_applink_ios_app_name";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IPHONE_URL:String = "fb_product_applink_iphone_url";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IPHONE_APP_STORE_ID:String = "fb_product_applink_iphone_app_store_id";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IPHONE_APP_NAME:String = "fb_product_applink_iphone_app_name";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IPAD_URL:String = "fb_product_applink_ipad_url";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IPAD_APP_STORE_ID:String = "fb_product_applink_ipad_app_store_id";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_IPAD_APP_NAME:String = "fb_product_applink_ipad_app_name";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_ANDROID_URL:String = "fb_product_applink_android_url";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_ANDROID_PACKAGE:String = "fb_product_applink_android_package";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_ANDROID_APP_NAME:String = "fb_product_applink_android_app_name";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_WINDOWS_PHONE_URL:String = "fb_product_applink_windows_phone_url";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_WINDOWS_PHONE_APP_ID:String = "fb_product_applink_windows_phone_app_id";
      
      public static const EVENT_PARAM_PRODUCT_APPLINK_WINDOWS_PHONE_APP_NAME:String = "fb_product_applink_windows_phone_app_name";
      
      public function AppEventsConstants()
      {
         super();
      }
   }
}

