package com.oyunstudyosu.chat
{
   public class EmoticonParser
   {
      
      public static const MAX_EMOTICONS:int = 3;
      
      private var emoticonMap:Object;
      
      private var emoticonSize:Number = 18;
      
      private var emojiBaseUrl:String = "https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/";
      
      public function EmoticonParser()
      {
         super();
         initEmoticonMap();
      }
      
      private function initEmoticonMap() : void
      {
         emoticonMap = {
            ":1":"1f642",
            ":2":"1f603",
            ":3":"1f641",
            ":4":"1f609",
            ":5":"1f61b",
            ":6":"1f62e",
            ":7":"2764",
            ":8":"1f618",
            ":9":"1f602",
            ":10":"1f622",
            ":11":"1f620",
            ":12":"1f60e",
            ":13":"1f615",
            ":14":"1f607",
            ":15":"1f608",
            ":16":"1f611",
            ":17":"1f633",
            ":18":"1f914",
            ":19":"1f63a",
            ":20":"1f923",
            ":21":"1f525",
            ":22":"1f4af",
            ":23":"1f44d",
            ":24":"1f44f",
            ":25":"1f499",
            ":26":"1f49a",
            ":27":"1f49b",
            ":28":"1f49c",
            ":29":"1f600",
            ":30":"1f601"
         };
      }
      
      public function limitEmoticons(text:String) : String
      {
         var emoticons:Array = findEmoticons(text);
         if(emoticons.length <= MAX_EMOTICONS)
         {
            return text;
         }
         var result:String = text;
         var i:int = MAX_EMOTICONS;
         while(i < emoticons.length)
         {
            result = result.split(emoticons[i].code).join("");
            i++;
         }
         return result;
      }
      
      public function hasEmoticons(text:String) : Boolean
      {
         for(var code in emoticonMap)
         {
            if(text.indexOf(code) != -1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getEmojiUrl(code:String) : String
      {
         if(emoticonMap[code] != undefined)
         {
            return emojiBaseUrl + emoticonMap[code] + ".png";
         }
         return null;
      }
      
      public function setEmoticonSize(size:Number) : void
      {
         this.emoticonSize = size;
      }
      
      public function get size() : Number
      {
         return emoticonSize;
      }
      
      public function findEmoticons(text:String) : Array
      {
         var c:String;
         var i:int;
         var found:Boolean;
         var code:String;
         var result:Array = [];
         var codes:Array = [];
         for(c in emoticonMap)
         {
            codes.push(c);
         }
         codes.sort(function(a:String, b:String):int
         {
            return b.length - a.length;
         });
         i = 0;
         while(i < text.length)
         {
            found = false;
            for each(code in codes)
            {
               if(text.substr(i,code.length) == code)
               {
                  result.push({
                     "code":code,
                     "emoji":emoticonMap[code],
                     "position":i
                  });
                  i += code.length;
                  found = true;
                  break;
               }
            }
            if(!found)
            {
               i++;
            }
         }
         return result;
      }
   }
}

