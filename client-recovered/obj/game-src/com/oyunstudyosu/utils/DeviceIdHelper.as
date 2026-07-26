package com.oyunstudyosu.utils
{
   import com.adobe.crypto.MD5;
   import flash.system.Capabilities;
   
   public class DeviceIdHelper
   {
      
      private static var _cachedDeviceId:String = null;
      
      public function DeviceIdHelper()
      {
         super();
      }
      
      public static function getDeviceId() : String
      {
         if(_cachedDeviceId != null)
         {
            return _cachedDeviceId;
         }
         var raw:String = "";
         if(Capabilities.playerType == "Desktop")
         {
            raw = getAirDeviceId();
         }
         else
         {
            raw = getWebFingerprint();
         }
         _cachedDeviceId = MD5.hash(raw);
         return _cachedDeviceId;
      }
      
      private static function getAirDeviceId() : String
      {
         var NetworkInfo:Class;
         var netInfo:*;
         var interfaces:*;
         var i:int;
         var iface:*;
         var Context:Class;
         var FileClass:Class;
         var userDir:*;
         var parts:Array = [];
         try
         {
            NetworkInfo = Sanalika.instance.stage.loaderInfo.applicationDomain.getDefinition("flash.net.NetworkInfo") as Class;
            if(NetworkInfo != null)
            {
               netInfo = NetworkInfo["networkInfo"];
               if(netInfo != null)
               {
                  interfaces = netInfo.findInterfaces();
                  if(interfaces != null)
                  {
                     i = 0;
                     while(i < interfaces.length)
                     {
                        iface = interfaces[i];
                        if(iface.hardwareAddress != null && iface.hardwareAddress != "" && iface.hardwareAddress != "00:00:00:00:00:00")
                        {
                           parts.push(iface.hardwareAddress);
                           break;
                        }
                        i++;
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
         }
         if(Capabilities.version.substr(0,3) == "AND")
         {
            parts.push("AND_" + Capabilities.os);
            parts.push(Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY);
            parts.push(Capabilities.screenDPI.toString());
            parts.push(Capabilities.cpuArchitecture);
            try
            {
               Context = Sanalika.instance.stage.loaderInfo.applicationDomain.getDefinition("android.content.Context") as Class;
               if(Context != null)
               {
                  parts.push("ctx");
               }
            }
            catch(e2:Error)
            {
            }
         }
         else
         {
            parts.push(Capabilities.os);
            parts.push(Capabilities.cpuArchitecture);
            parts.push(Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY);
            parts.push(Capabilities.screenDPI.toString());
            parts.push(Capabilities.language);
            parts.push(Capabilities.manufacturer);
            try
            {
               FileClass = Sanalika.instance.stage.loaderInfo.applicationDomain.getDefinition("flash.filesystem.File") as Class;
               if(FileClass != null)
               {
                  userDir = FileClass["userDirectory"];
                  if(userDir != null)
                  {
                     parts.push(userDir.nativePath);
                  }
               }
            }
            catch(e3:Error)
            {
            }
         }
         if(parts.length == 0)
         {
            parts.push(Capabilities.os);
            parts.push(Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY);
            parts.push(Capabilities.cpuArchitecture);
         }
         return parts.join("|");
      }
      
      private static function getWebFingerprint() : String
      {
         var parts:Array = [];
         parts.push(Capabilities.os);
         parts.push(Capabilities.version);
         parts.push(Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY);
         parts.push(Capabilities.screenDPI.toString());
         parts.push(Capabilities.language);
         parts.push(Capabilities.cpuArchitecture);
         parts.push(Capabilities.manufacturer);
         parts.push(Capabilities.pixelAspectRatio.toString());
         return parts.join("|");
      }
   }
}

