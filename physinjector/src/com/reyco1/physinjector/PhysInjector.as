package com.reyco1.physinjector
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	
	import com.reyco1.physinjector.contact.ContactListener;
	import com.reyco1.physinjector.data.PhysicsObject;
	import com.reyco1.physinjector.data.PhysicsProperties;
	import com.reyco1.physinjector.events.ContactEvent;
	import com.reyco1.physinjector.factory.BodyFactory;
	import com.reyco1.physinjector.manager.DebugDrawManager;
	import com.reyco1.physinjector.manager.DragManager;
	import com.reyco1.physinjector.manager.Juggler;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * Main class which gets the Box2D engine ready and started 
	 * @author Reynaldo
	 * 
	 */	
	public class PhysInjector extends EventDispatcher implements IEventDispatcher
	{
		public static const SQUARE:int   = 0;
		public static const CIRCLE:int   = 1;
		public static const POLYGON:int  = 2;
		public static const RATIO:Number = 50;
		
		public static var WORLD:b2World;
		public static var REGISTRATION:Point =  new Point(0.5, 0.5);
		
		protected var defaultGravity:b2Vec2;
		protected var contacts:ContactListener;
		protected var bodyHash:Dictionary;
		
		private   var draggingAllowed:Boolean = true;
		private   var joints:Vector.<b2Joint>;
		private   var bodyDestroyQueue:Vector.<b2Body>;
		private   var jointDestroyQueue:Vector.<b2Joint>;
		private   var stage:Stage;
		private   var dragManager:DragManager;
		private   var debugDrawManager:DebugDrawManager;
		
		public    var juggler:Juggler;
		public    var bodies:Vector.<b2Body>
		public 	  var onContactBegin:Function;
		public 	  var onContactEnd:Function;
		
		/**
		 * Prepares the Box2D initial setup 
		 * @param stage A reference to the native Flash Stage
		 * @param gravity An instance of the b2Vec2 class indicating the direction of the force of gravity
		 * @param draggingAllowed Aboolean indicatin if dragging is allowed. Default:false
		 * @param debugDraw A reference to an instance of a Sprite where Box2D can draw the debug shapes
		 * 
		 */		
		public function PhysInjector(stage:Stage, gravity:b2Vec2 = null, draggingAllowed:Boolean = false, debugDraw:* = null)
		{
			defaultGravity 	     = gravity ? gravity : new b2Vec2(0.0, 10);
			this.draggingAllowed = draggingAllowed;
			this.stage		  	 = stage;
			
			bodyHash		  = new Dictionary();
			bodies			  = new Vector.<b2Body>();
			joints			  = new Vector.<b2Joint>();
			bodyDestroyQueue  = new Vector.<b2Body>();
			jointDestroyQueue = new Vector.<b2Joint>();
			contacts  		  = new ContactListener();	
			dragManager		  = new DragManager(stage);
			WORLD	  		  = new b2World( defaultGravity, true );
			
			contacts.dispatcher.addEventListener( ContactEvent.BEGIN_CONTACT, handleContactBegin);
			contacts.dispatcher.addEventListener( ContactEvent.END_CONTACT,   handleContactEnd);
			
			WORLD.SetContactListener( contacts );			
			
			allowDrag = draggingAllowed;
			
			if(debugDraw != null)
			{
				debugDrawManager = new DebugDrawManager(debugDraw);
			}
			
			juggler = new Juggler();
		}
		
		/**
		 * Provides physics properties for the passed display object 
		 * @param displayObj The display object to which the physics properties are going to be applied to
		 * @param type The type of physics behavior: PhysInjector.SQUARE, PhysInjector.CIRCLE or PhysInjector.POLYGON
		 * @param properties An instance of the PhysicsProperties class. This class holds all the new physics properties that will be applied to your display object
		 * @return An instance of the PhysicsObject which holds references to teh display objec, physics object and the physics propeties
		 * 
		 */		
		public function injectPhysics(displayObj:*, type:int, properties:PhysicsProperties = null):PhysicsObject
		{
			var b:b2Body;
			var globalPosition:Point;
			var currentRotation:Number;
			var bounds:Rectangle;
			
			var offsetX:Number = displayObj.width  * -REGISTRATION.x;
			var offsetY:Number = displayObj.height * -REGISTRATION.y;
			
			switch(type)
			{
				case CIRCLE:
				{
					globalPosition = displayObj.parent.localToGlobal(new Point(displayObj.x, displayObj.y));
					
					b = createCircle
					(
						globalPosition.x + (displayObj.width  * REGISTRATION.x), 
						globalPosition.y + (displayObj.height * REGISTRATION.y), 
						displayObj.width * 0.5, properties
					);
					break;
				}
					
				case SQUARE:
				{
					currentRotation 	= displayObj.rotation;
					bounds				= displayObj.getBounds(displayObj.parent);
					displayObj.rotation = 0;
					
					globalPosition = displayObj.parent.localToGlobal(new Point(bounds.x, bounds.y));
					
					properties.angle = currentRotation * Math.PI / 180;
					
					b = createSquare
					(						
						globalPosition.x + (bounds.width  * REGISTRATION.x), 
						globalPosition.y + (bounds.height * REGISTRATION.y),
						displayObj.width, 
						displayObj.height, 
						properties
					);
					break;
				}
					
				case POLYGON:
				{
					currentRotation 	= displayObj.rotation;
					bounds				= displayObj.getBounds(displayObj.parent);
					displayObj.rotation = 0;					
					globalPosition 		= displayObj.parent.localToGlobal(new Point(bounds.x, bounds.y));
					properties.angle 	= currentRotation * Math.PI / 180;
					
					offsetX = (displayObj.width  * -REGISTRATION.x) / RATIO+2;
					offsetY = (displayObj.height * -REGISTRATION.y) / RATIO+2;
					
					b = createPolygon( globalPosition.x + (bounds.width  * REGISTRATION.x), 
									   globalPosition.y + (bounds.height * REGISTRATION.y),
									   properties.vertices, properties );
					
					break;
				}
					
				default:
				{
					break;
				}
			}
			
			var po:PhysicsObject = new PhysicsObject(b, displayObj, properties)
			po.offsetX = offsetX;
			po.offsetY = offsetY;
			po.name	   = displayObj.name;
			
			b.SetUserData( po );
			bodyHash[ displayObj ] = b;
			updateBody( b );
				
			return po;
		}
		
		/**
		 * Removed physics properties from the supplied display object 
		 * @param displayObj
		 * 
		 */		
		public function removePhysics(displayObj:*):void
		{
			bodyDestroyQueue.push( bodyHash[ displayObj ] );
		}
		
		/**
		 * Removes a joint 
		 * @param joint
		 * 
		 */		
		public function removeJoint(joint:b2Joint):void
		{
			jointDestroyQueue.push( joint );
		}
		
		/* DISPLAY OBJECT UPDATE */
		
		/**
		 * @private 
		 * @param body
		 * 
		 */		
		public function updateBody(body:b2Body):void
		{
			var displayObject:* 	= getDisplayObject( body );
			var localPosition:Point = displayObject.parent.globalToLocal(new Point(body.GetPosition().x * RATIO, body.GetPosition().y * RATIO));			
			var newX:Number 		= localPosition.x;
			var newY:Number 		= localPosition.y;
			var newRotation:Number 	= body.GetAngle();
			
			var matrix:Matrix = displayObject.transform.matrix;
			matrix = applyTransformation
				(
					newX, 
					newY, 
					PhysicsObject( body.GetUserData() ).offsetX, 
					PhysicsObject( body.GetUserData() ).offsetY, 
					newRotation, 
					displayObject.scaleX, 
					displayObject.scaleY
				);	
			
			displayObject.transform.matrix = matrix;
		}
		
		private function applyTransformation(x:Number, y:Number, offsetX:Number, offsetY:Number, rotation:Number, scaleX:Number, scaleY:Number):Matrix 
		{
			var matrix:Matrix = new Matrix();
			matrix.scale(scaleX, scaleY);
			matrix.translate(offsetX, offsetY);
			matrix.rotate(rotation);
			matrix.translate(x, y);
			return matrix;
		}		
		
		/* CREATIONAL */
		
		/**
		 * Creates a physics body in a circular form
		 * @param numX horizontal position
		 * @param numY vertical position
		 * @param radius radius of the circle
		 * @param physicsProperties An instance of the PhysicsProperties class. This class holds all the new physics properties that will be applied to the physics body
		 * @return the physics body
		 * 
		 */		
		public function createCircle(numX:Number, numY:Number, radius:Number, physicsProperties:PhysicsProperties):b2Body 
		{
			var body:b2Body = BodyFactory.createCircle(numX, numY, radius, physicsProperties);			
			bodies.push( body );			
			return body;
		}
		
		/**
		 * Creates a physics body in a box form
		 * @param numX horizontal position
		 * @param numY vertical position
		 * @param numWidth the width of the box
		 * @param numHeight the height of the box
		 * @param physicsProperties An instance of the PhysicsProperties class. This class holds all the new physics properties that will be applied to the physics body
		 * @return the physics body
		 * 
		 */		
		public function createSquare(numX:Number, numY:Number, numWidth:Number, numHeight:Number, physicsProperties:PhysicsProperties):b2Body 
		{
			var body:b2Body = BodyFactory.createSquare(numX, numY, numWidth, numHeight, physicsProperties);			
			bodies.push( body );			
			return body;
		}
		
		/**
		 * Creates a physics body in tho form of the vertices supplied
		 * @param numX horizontal position
		 * @param numY vertical position
		 * @param vertices a Vector of b2Vec2 instances holding the coordinates of each vector in meters. Use the com.reyco1.physinjector.geom.PointSorter
		 * @param physicsProperties An instance of the PhysicsProperties class. This class holds all the new physics properties that will be applied to the physics body
		 * @return the physics body
		 * 
		 */		
		public function createPolygon(numX:Number, numY:Number, vertices:Vector.<b2Vec2>, physicsProperties:PhysicsProperties):b2Body 
		{
			var body:b2Body = BodyFactory.createPolygon(numX, numY, vertices, physicsProperties);			
			bodies.push( body );			
			return body;
		}
		
		/* PUBLIC PROPERTIES */
		
		/**
		 * Specifies if dragging is allowed or not 
		 * @param val
		 * 
		 */		
		public function set allowDrag(val:Boolean):void
		{
			draggingAllowed = val;
			if(draggingAllowed)
			{
				stage.addEventListener(MouseEvent.MOUSE_DOWN, dragManager.startDrag);
				stage.addEventListener(MouseEvent.MOUSE_UP,   dragManager.stopDrag);
			}
			else
			{
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, dragManager.startDrag);
				stage.removeEventListener(MouseEvent.MOUSE_UP,   dragManager.stopDrag);
			}			
		}
		
		/**
		 * @private 
		 * @return 
		 * 
		 */		
		public function get allowDrag():Boolean
		{
			return draggingAllowed;
		}
		
		/* PUBLIC METHODS */
		
		
		/**
		 * returns the physics body instance associated with the supplied display object 
		 * @param displayObject
		 * @return 
		 * 
		 */
		public function getBody(displayObject:*):b2Body
		{
			return bodyHash[ displayObject ];
		}	
		
		/**
		 * Returns the PhysicsObject instance associated with the supplied display object 
		 * @param displayObject
		 * @return 
		 * 
		 */		
		public function getPhysicsObject(displayObject:*):PhysicsObject
		{
			return getBody( displayObject ).GetUserData() as PhysicsObject;
		}
		
		/**
		 * Returns the display object associated witht he supplied physics body 
		 * @param body
		 * @return 
		 * 
		 */		
		public function getDisplayObject(body:b2Body):*
		{
			return PhysicsObject(body.GetUserData()).displayObject;
		}
		
		/**
		 * Destroys a physics body 
		 * @param b
		 * 
		 */		
		private function destroyBody(b:b2Body):void 
		{
			WORLD.DestroyBody( b );
		}
		
		/**
		 * Destroys a joint 
		 * @param j
		 * 
		 */		
		private function destroyJoint(j:b2Joint):void 
		{
			WORLD.DestroyJoint( j );
		}
		
		/**
		 * Sets the gravity for the similation 
		 * @param x
		 * @param y
		 * 
		 */		
		public function setGravity(x:Number, y:Number):void 
		{
			defaultGravity.x = x;
			defaultGravity.y = y;
			WORLD.SetGravity( defaultGravity );
		}
		
		/* CONTACT */
		
		protected function handleContactBegin(event:ContactEvent):void
		{
			if(onContactBegin != null)
				onContactBegin.apply(null, [event.bodyA, event.bodyB, event.fixtureA, event.fixtureB]);
		}
		
		protected function handleContactEnd(event:ContactEvent):void
		{
			if(onContactEnd != null)
				onContactEnd.apply(null, [event.bodyA, event.bodyB, event.fixtureA, event.fixtureB]);
		}
		
		/* CLEAR */
		
		/**
		 * Clears all physics bodies and disposes this instance of the PhysicsInjector 
		 * 
		 */		
		public function dispose():void
		{
			allowDrag = false;
			dragManager.destroy();
			
			if(debugDrawManager)
				debugDrawManager.dispose();
			
			if(bodies)
			{
				var b:b2Body;
				while(bodies.length > 0)
				{
					
					b = bodies.splice(0, 1)[0];
					PhysicsObject( b.GetUserData() ).dispose();
					destroyBody( b );
				}
				b = null;
			}			
			
			if(joints)
			{
				while(joints.length > 0)
				{
					destroyJoint( joints.splice(0, 1)[0] );
				}
			}
			
			WORLD 		= null;
			contacts 	= null;
			bodies		= null;
			joints		= null;
			bodyHash	= null;
		}
		
		/* UPDATE */
		
		/**
		 * Updates the Box2D physcis core engine 
		 * 
		 */		
		public function update():void
		{			
			WORLD.Step(1 / stage.frameRate, 10, 10);
			WORLD.ClearForces();	
			
			while(bodyDestroyQueue.length > 0)
			{
				var b:b2Body = bodyDestroyQueue.splice(0, 1)[0];
				delete bodyHash[ PhysicsObject( b.GetUserData() ).displayObject ];
				PhysicsObject( b.GetUserData() ).dispose();
				destroyBody( bodies.splice(bodies.indexOf( b ), 1)[0] );
				b = null;
			}
			
			if(dragManager)
				dragManager.update();
			
			for (var a:int = 0; a < bodies.length; a++) 
			{
				if(bodies[a].GetType() == b2Body.b2_dynamicBody && bodies[a].GetUserData() != null)
				{
					updateBody( bodies[a] );
				}
			}
			
			while(jointDestroyQueue.length > 0)
			{
				destroyJoint( jointDestroyQueue.splice(0, 1)[0] );
			}
			
			if(debugDrawManager)
				debugDrawManager.update();
			
			juggler.update();
		}
	}
}