package com.oyunstudyosu.privatechat
{
   public class PrivateChatMessage implements IPrivateChatMessage
   {
      
      private var _sender:String;
      
      private var _date:String;
      
      private var _content:String;
      
      private var _status:String;
      
      private var _messageID:String;
      
      public function PrivateChatMessage()
      {
         super();
      }
      
      public function get sender() : String
      {
         return _sender;
      }
      
      public function set sender(param1:String) : void
      {
         if(_sender == param1)
         {
            return;
         }
         _sender = param1;
      }
      
      public function get date() : String
      {
         return _date;
      }
      
      public function set date(param1:String) : void
      {
         if(_date == param1)
         {
            return;
         }
         _date = param1;
      }
      
      public function get content() : String
      {
         return _content;
      }
      
      public function set content(param1:String) : void
      {
         if(_content == param1)
         {
            return;
         }
         _content = param1;
      }
      
      public function get status() : String
      {
         return _status;
      }
      
      public function set status(param1:String) : void
      {
         if(_status == param1)
         {
            return;
         }
         _status = param1;
      }
      
      public function get messageID() : String
      {
         return _messageID;
      }
      
      public function set messageID(param1:String) : void
      {
         if(_messageID == param1)
         {
            return;
         }
         _messageID = param1;
      }
      
      public function get isMine() : Boolean
      {
         return sender == Sanalika.instance.avatarModel.avatarId;
      }
      
      public function clone() : IPrivateChatMessage
      {
         var _loc1_:IPrivateChatMessage = new PrivateChatMessage();
         _loc1_.content = this.content;
         _loc1_.date = this.date;
         _loc1_.messageID = this.messageID;
         _loc1_.sender = this.sender;
         _loc1_.status = this.status;
         return _loc1_;
      }
   }
}

