package mx.effects
{
   import mx.core.mx_internal;
   import mx.effects.effectClasses.ZoomInstance;
   
   use namespace mx_internal;
   
   [Alternative(replacement="spark.effects.Scale",since="4.0")]
   public class Zoom extends TweenEffect
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var AFFECTED_PROPERTIES:Array = ["scaleX","scaleY","x","y","width","height"];
      
      [Inspectable(category="Other",defaultValue="false")]
      public var captureRollEvents:Boolean;
      
      [Inspectable(category="General",defaultValue="NaN")]
      public var originX:Number;
      
      [Inspectable(category="General",defaultValue="NaN")]
      public var originY:Number;
      
      [Inspectable(category="General",defaultValue="0.01")]
      public var zoomHeightFrom:Number;
      
      [Inspectable(category="General",defaultValue="1")]
      public var zoomHeightTo:Number;
      
      [Inspectable(category="General",defaultValue="0.01")]
      public var zoomWidthFrom:Number;
      
      [Inspectable(category="General",defaultValue="1")]
      public var zoomWidthTo:Number;
      
      public function Zoom(param1:Object = null)
      {
         super(param1);
         instanceClass = ZoomInstance;
         mx_internal::applyActualDimensions = false;
         relevantProperties = ["scaleX","scaleY","width","height","visible"];
      }
      
      override public function getAffectedProperties() : Array
      {
         return AFFECTED_PROPERTIES;
      }
      
      override protected function initInstance(param1:IEffectInstance) : void
      {
         var _loc2_:ZoomInstance = null;
         super.initInstance(param1);
         _loc2_ = ZoomInstance(param1);
         _loc2_.zoomWidthFrom = this.zoomWidthFrom;
         _loc2_.zoomWidthTo = this.zoomWidthTo;
         _loc2_.zoomHeightFrom = this.zoomHeightFrom;
         _loc2_.zoomHeightTo = this.zoomHeightTo;
         _loc2_.originX = this.originX;
         _loc2_.originY = this.originY;
         _loc2_.captureRollEvents = this.captureRollEvents;
      }
   }
}

