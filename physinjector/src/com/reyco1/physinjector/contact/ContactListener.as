package com.reyco1.physinjector.contact
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	
	import com.reyco1.physinjector.events.ContactEvent;
	
	import flash.events.EventDispatcher;
	
	public class ContactListener extends b2ContactListener
	{
		public var dispatcher:EventDispatcher;
		
		public function ContactListener()
		{
			super();
			dispatcher = new EventDispatcher();
		}
		
		override public function BeginContact(contact:b2Contact):void
		{
			var event:ContactEvent = new ContactEvent(ContactEvent.BEGIN_CONTACT);
			event.bodyA 	= contact.GetFixtureA().GetBody();
			event.bodyB 	= contact.GetFixtureB().GetBody();
			event.fixtureA 	= contact.GetFixtureA();
			event.fixtureB 	= contact.GetFixtureB();
			event.contact	= contact;
			
			dispatcher.dispatchEvent( event );
		}
		
		override public function EndContact(contact:b2Contact):void
		{
			var event:ContactEvent = new ContactEvent(ContactEvent.END_CONTACT);
			event.bodyA 	= contact.GetFixtureA().GetBody();
			event.bodyB 	= contact.GetFixtureB().GetBody();
			event.fixtureA 	= contact.GetFixtureA();
			event.fixtureB 	= contact.GetFixtureB();
			event.contact	= contact;
			
			dispatcher.dispatchEvent( event );
		}
		
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var event:ContactEvent = new ContactEvent(ContactEvent.PRE_SOLVE);
			event.bodyA 	  = contact.GetFixtureA().GetBody();
			event.bodyB 	  = contact.GetFixtureB().GetBody();
			event.fixtureA 	  = contact.GetFixtureA();
			event.fixtureB 	  = contact.GetFixtureB();
			event.contact	  = contact;
			event.oldManifold = oldManifold;
			
			dispatcher.dispatchEvent( event );
		}
		
		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			var event:ContactEvent = new ContactEvent(ContactEvent.POST_SOLVE);
			event.bodyA 	  = contact.GetFixtureA().GetBody();
			event.bodyB 	  = contact.GetFixtureB().GetBody();
			event.fixtureA 	  = contact.GetFixtureA();
			event.fixtureB 	  = contact.GetFixtureB();
			event.contact	  = contact;
			event.impulse 	  = impulse;
			
			dispatcher.dispatchEvent( event );
		}
	}
}