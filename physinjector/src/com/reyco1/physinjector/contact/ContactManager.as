// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.reyco1.physinjector.contact
{
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.PhysicsObject;
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
		
		/* listen methods */		
		
		public static function onContactBegin(nameOrGroupA:String, nameOrGroupB:String, handler:Function, isGroupListener:Boolean = false):void
		{
			ContactManager.register(onBeginObjects, nameOrGroupA, nameOrGroupB, handler, isGroupListener);	
		}
		
		public static function onContactEnd(nameOrGroupA:String, nameOrGroupB:String, handler:Function, isGroupListener:Boolean = false):void
		{
			ContactManager.register(onEndObjects, nameOrGroupA, nameOrGroupB, handler, isGroupListener);	
		}
		
		public static function onPreSolve(nameOrGroupA:String, nameOrGroupB:String, handler:Function, isGroupListener:Boolean = false):void
		{
			ContactManager.register(onPreObjects, nameOrGroupA, nameOrGroupB, handler, isGroupListener);	
		}
		
		public static function onPostSolve(nameOrGroupA:String, nameOrGroupB:String, handler:Function, isGroupListener:Boolean = false):void
		{
			ContactManager.register(onPostObjects, nameOrGroupA, nameOrGroupB, handler, isGroupListener);	
		}		
		
		/* remove listen methods */
		
		public static function removeContactBegin(nameOrGroupA:String, nameOrGroupB:String, handler:Function):void
		{
			delete onBeginObjects[nameOrGroupA+nameOrGroupB];
		}
		
		public static function removeContactEnd(nameOrGroupA:String, nameOrGroupB:String, handler:Function):void
		{
			delete onEndObjects[nameOrGroupA+nameOrGroupB];
		}
		
		public static function removePreSolve(nameOrGroupA:String, nameOrGroupB:String, handler:Function):void
		{
			delete onPreObjects[nameOrGroupA+nameOrGroupB];
		}
		
		public static function removePostSolve(nameOrGroupA:String, nameOrGroupB:String, handler:Function):void
		{
			delete onPostObjects[nameOrGroupA+nameOrGroupB];
		}
		
		/* handler methods */
		
		protected static function handleContactBegin(event:ContactEvent):void
		{
			evaluate(onBeginObjects, event);
		}
		
		protected static function handlePostSolve(event:ContactEvent):void
		{
			evaluate(onPostObjects, event);
		}
		
		protected static function handlePreSolve(event:ContactEvent):void
		{
			evaluate(onPreObjects, event);
		}
		
		protected static function handleContactEnd(event:ContactEvent):void
		{
			evaluate(onEndObjects, event);
		}
		
		/* register */
		
		private static function register(dic:Dictionary, nameOrGroupA:String, nameOrGroupB:String, handler:Function, isGroupListener:Boolean = false):void
		{
			if(!isGroupListener)
				dic[nameOrGroupA+nameOrGroupB] = new ContactData(injector.getPhysicsObjectByName(nameOrGroupA), injector.getPhysicsObjectByName(nameOrGroupB), handler, isGroupListener);
			else
				dic[nameOrGroupA+nameOrGroupB] = new ContactData(nameOrGroupA, nameOrGroupB, handler, isGroupListener);
		}
		
		/* evaluate  */
		
		private static function evaluate(dictionary:Dictionary, event:ContactEvent):void
		{
			for each (var contactData:ContactData in dictionary)
			{
				if(!contactData.isGroupListener)
				{
					if( contactData.groupOrObjectA.body == event.bodyA && contactData.groupOrObjectB.body == event.bodyB || 
						contactData.groupOrObjectA.body == event.bodyB && contactData.groupOrObjectB.body == event.bodyA)
					{
						contactData.handler.call(null, contactData.groupOrObjectA, contactData.groupOrObjectB, event.contact);
					}
				}
				else
				{
					if(
						contactData.groupOrObjectA == PhysicsObject(event.bodyA.GetUserData()).physicsProperties.contactGroup && 
					    contactData.groupOrObjectB == PhysicsObject(event.bodyB.GetUserData()).physicsProperties.contactGroup)
					{
						contactData.handler.call(null, PhysicsObject(event.bodyA.GetUserData()), PhysicsObject(event.bodyB.GetUserData()), event.contact);
					}
					else if(
						contactData.groupOrObjectA == PhysicsObject(event.bodyB.GetUserData()).physicsProperties.contactGroup &&
						contactData.groupOrObjectB == PhysicsObject(event.bodyA.GetUserData()).physicsProperties.contactGroup)
					{
						contactData.handler.call(null, PhysicsObject(event.bodyB.GetUserData()), PhysicsObject(event.bodyA.GetUserData()), event.contact);
					}
				}
			}
		}
	}
}

import com.reyco1.physinjector.data.PhysicsObject;

class ContactData
{
	public var groupOrObjectA:*;
	public var groupOrObjectB:*;
	public var handler:Function;
	public var isGroupListener:Boolean;
	
	public function ContactData(groupOrObjectA:*, groupOrObjectB:*, handler:Function, isGroupListener:Boolean)
	{
		this.groupOrObjectA  = groupOrObjectA;
		this.groupOrObjectB  = groupOrObjectB;
		this.isGroupListener = isGroupListener;
		this.handler 		 = handler;
	}
}