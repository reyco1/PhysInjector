package com.reyco1.physinjector.events
{
	import Box2D.Dynamics.b2Body;
	
	import flash.events.Event;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.b2ContactImpulse;
	
	public class ContactEvent extends Event
	{
		public static const BEGIN_CONTACT:String 	= "ContactEvent.BEGIN_CONTACT";
		public static const END_CONTACT:String   	= "ContactEvent.END_CONTACT";
		public static const POST_SOLVE:String   	= "ContactEvent.POST_SOLVE";
		public static const PRE_SOLVE:String   		= "ContactEvent.PRE_SOLVE";
		
		public var bodyA:b2Body;
		public var bodyB:b2Body;
		public var details:Object;
		public var fixtureA:b2Fixture;
		public var fixtureB:b2Fixture;
		public var contact:b2Contact;
		public var oldManifold:b2Manifold;
		public var impulse:b2ContactImpulse;
		
		public function ContactEvent(type:String, details:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.details = details;
			super(type, bubbles, cancelable);
		}
	}
}