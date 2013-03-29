package com.reyco1.physinjector.contact
{
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.events.ContactEvent;
	
	import flash.utils.Dictionary;

	public class ContactManager
	{
		public  static var contacts:ContactListener;		
		private static var injector:PhysInjector;
		private static var onBeginObjects:Dictionary;
		private static var onEndObjects:Dictionary;
		private static var onPreObjects:Dictionary;
		private static var onPostObjects:Dictionary;
		
		public static function init(injector:PhysInjector):void
		{
			ContactManager.injector = injector;
			
			contacts  		= new ContactListener();			
			onBeginObjects 	= new Dictionary();
			onEndObjects 	= new Dictionary();
			onPreObjects 	= new Dictionary();
			onPostObjects 	= new Dictionary();
			
			PhysInjector.WORLD.SetContactListener( contacts );
			
			contacts.dispatcher.addEventListener( ContactEvent.BEGIN_CONTACT, handleContactBegin);
			contacts.dispatcher.addEventListener( ContactEvent.END_CONTACT,   handleContactEnd);
			contacts.dispatcher.addEventListener( ContactEvent.PRE_SOLVE, 	  handlePreSolve);
			contacts.dispatcher.addEventListener( ContactEvent.POST_SOLVE,    handlePostSolve);
		}
		
		public static function dispose():void
		{
			contacts.dispatcher.removeEventListener( ContactEvent.BEGIN_CONTACT, handleContactBegin);
			contacts.dispatcher.removeEventListener( ContactEvent.END_CONTACT,   handleContactEnd);
			contacts.dispatcher.removeEventListener( ContactEvent.PRE_SOLVE, 	 handlePreSolve);
			contacts.dispatcher.removeEventListener( ContactEvent.POST_SOLVE,    handlePostSolve);
			
			onBeginObjects 	= null;
			onEndObjects 	= null;
			onPreObjects 	= null;
			onPostObjects 	= null;
			
			injector 		= null;
			contacts		= null;
		}
		
		public static function onContactBegin(objectNameA:String, objectNameB:String, handler:Function):void
		{
			onBeginObjects[objectNameA+objectNameB] = new ContactData(injector.getPhysicsObjectByName(objectNameA), injector.getPhysicsObjectByName(objectNameB), handler);
		}
		
		public static function onContactEnd(objectNameA:String, objectNameB:String, handler:Function):void
		{
			onEndObjects[objectNameA+objectNameB] = new ContactData(injector.getPhysicsObjectByName(objectNameA), injector.getPhysicsObjectByName(objectNameB), handler);
		}
		
		public static function onPreSolve(objectNameA:String, objectNameB:String, handler:Function):void
		{
			onPreObjects[objectNameA+objectNameB] = new ContactData(injector.getPhysicsObjectByName(objectNameA), injector.getPhysicsObjectByName(objectNameB), handler);
		}
		
		public static function onPostSolve(objectNameA:String, objectNameB:String, handler:Function):void
		{
			onPostObjects[objectNameA+objectNameB] = new ContactData(injector.getPhysicsObjectByName(objectNameA), injector.getPhysicsObjectByName(objectNameB), handler);
		}
		
		protected static function handleContactBegin(event:ContactEvent):void
		{
			for each (var contactData:ContactData in onBeginObjects)
			{
				if(contactData.objectA.body == event.bodyA && contactData.objectB.body == event.bodyB || contactData.objectA.body == event.bodyB && contactData.objectB.body == event.bodyA)
				{
					contactData.handler.call(null, contactData.objectA, contactData.objectB, event.contact);
				}
			}
		}
		
		protected static function handlePostSolve(event:ContactEvent):void
		{
			for each (var contactData:ContactData in onPostObjects)
			{
				if(contactData.objectA.body == event.bodyA && contactData.objectB.body == event.bodyB || contactData.objectA.body == event.bodyB && contactData.objectB.body == event.bodyA)
				{
					contactData.handler.call(null, contactData.objectA, contactData.objectB, event.contact);
				}
			}
		}
		
		protected static function handlePreSolve(event:ContactEvent):void
		{
			for each (var contactData:ContactData in onPreObjects)
			{
				if(contactData.objectA.body == event.bodyA && contactData.objectB.body == event.bodyB || contactData.objectA.body == event.bodyB && contactData.objectB.body == event.bodyA)
				{
					contactData.handler.call(null, contactData.objectA, contactData.objectB, event.contact);
				}
			}
		}
		
		protected static function handleContactEnd(event:ContactEvent):void
		{
			for each (var contactData:ContactData in onEndObjects)
			{
				if(contactData.objectA.body == event.bodyA && contactData.objectB.body == event.bodyB || contactData.objectA.body == event.bodyB && contactData.objectB.body == event.bodyA)
				{
					contactData.handler.call(null, contactData.objectA, contactData.objectB, event.contact);
				}
			}
		}
	}
}

import com.reyco1.physinjector.data.PhysicsObject;

class ContactData
{
	public var objectA:PhysicsObject;
	public var objectB:PhysicsObject;
	public var handler:Function;
	
	public function ContactData(objectA:PhysicsObject, objectB:PhysicsObject, handler:Function)
	{
		this.objectA = objectA;
		this.objectB = objectB;
		this.handler = handler;
	}
}