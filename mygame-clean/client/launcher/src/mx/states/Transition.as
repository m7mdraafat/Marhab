package mx.states
{
   import mx.core.mx_internal;
   import mx.effects.IEffect;
   
   use namespace mx_internal;
   
   [DefaultProperty("effect")]
   public class Transition
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public var effect:IEffect;
      
      [Inspectable(category="General")]
      public var fromState:String = "*";
      
      [Inspectable(category="General")]
      public var toState:String = "*";
      
      public var autoReverse:Boolean = false;
      
      [Inspectable(category="General",enumeration="end,stop",defaultValue="end")]
      public var interruptionBehavior:String = InterruptionBehavior.END;
      
      public function Transition()
      {
         super();
      }
   }
}

