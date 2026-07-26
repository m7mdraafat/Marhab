package com.distriqt.extension.facebook.graphapi.builders
{
   import com.distriqt.extension.facebook.core.Facebook;
   import com.distriqt.extension.facebook.core.facebook_core_internal;
   import com.distriqt.extension.facebook.graphapi.GraphRequest;
   import flash.display.BitmapData;
   
   use namespace facebook_core_internal;
   
   public class GraphRequestBuilder
   {
      
      public static const METHOD_GET:String = "GET";
      
      public static const METHOD_POST:String = "POST";
      
      public static const METHOD_DELETE:String = "DELETE";
      
      private var _request:GraphRequest;
      
      public function GraphRequestBuilder()
      {
         super();
         _request = Facebook.instance.createGraphRequest();
      }
      
      public static function getCurrentUserInfoRequest() : GraphRequest
      {
         return new GraphRequestBuilder().setPath("/me").build();
      }
      
      public static function getCurrentPermissionsRequest() : GraphRequest
      {
         return new GraphRequestBuilder().setPath("/me/permissions").build();
      }
      
      public static function getUserFriendsRequest() : GraphRequest
      {
         return new GraphRequestBuilder().setPath("/me/friends").addField("name").build();
      }
      
      public static function getUserFriendsWithInstalledRequest() : GraphRequest
      {
         return new GraphRequestBuilder().setPath("/me/friends").addField("name").addField("installed").build();
      }
      
      public static function postStatusUpdateRequest(param1:String) : GraphRequest
      {
         return new GraphRequestBuilder().setPath("/me/feed").setMethod("POST").addParameter("message",param1).build();
      }
      
      public static function postLinkToWallRequest(param1:String, param2:String = "", param3:String = "", param4:String = "") : GraphRequest
      {
         return new GraphRequestBuilder().setPath("/me/feed").setMethod("POST").addParameter("link",param1).addParameter("caption",param2).addParameter("message",param3).addParameter("description",param4).build();
      }
      
      public static function postImageToDefaultAlbumRequest(param1:BitmapData, param2:String = "") : GraphRequest
      {
         return new GraphRequestBuilder().setPath("/me/photos").setMethod("POST").setImage(param1).addParameter("message",param2).build();
      }
      
      public function setPath(param1:String) : GraphRequestBuilder
      {
         _request.path = param1;
         return this;
      }
      
      public function setMethod(param1:String) : GraphRequestBuilder
      {
         _request.method = param1;
         return this;
      }
      
      public function addField(param1:String) : GraphRequestBuilder
      {
         _request.fields.push(param1);
         return this;
      }
      
      public function addFields(param1:Array) : GraphRequestBuilder
      {
         for each(var _loc2_ in param1)
         {
            _request.fields.push(_loc2_);
         }
         return this;
      }
      
      public function addParameter(param1:String, param2:Object) : GraphRequestBuilder
      {
         _request.params[param1] = param2;
         return this;
      }
      
      public function setImage(param1:BitmapData) : GraphRequestBuilder
      {
         _request.image = param1;
         return this;
      }
      
      public function setCompleteCallback(param1:Function) : GraphRequestBuilder
      {
         _request.onComplete = param1;
         return this;
      }
      
      public function setErrorCallback(param1:Function) : GraphRequestBuilder
      {
         _request.onError = param1;
         return this;
      }
      
      public function build() : GraphRequest
      {
         if(_request.path == null || _request.path.length == 0)
         {
            throw new Error("Invalid path: You must set a graph API endpoint path for the request");
         }
         if(!isValidHTTPMethod(_request.method))
         {
            throw new Error("Invalid HTTP method: " + _request.method);
         }
         return _request;
      }
      
      private function isValidHTTPMethod(param1:String) : Boolean
      {
         return param1 == "GET" || param1 == "POST" || param1 == "DELETE";
      }
   }
}

