package com.reyco1.physinjector.events
{
	import flash.events.Event;
	
	public class PhysicsPropertyChangeEvent extends Event
	{
		public static const CHANGE:String = "PhysicsPropertyChangeEvent.CHANGE";
		
		public var property:String;
		public var value:*;
		public var host:String;
		
		public function PhysicsPropertyChangeEvent(type:String, property:String, value:*, host:String = "bodyDef", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.property = property;
			this.value = value;
			this.host = host;
			
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new PhysicsPropertyChangeEvent(type, property, value, host, bubbles, cancelable);
		}
	}
}