package com.reyco1.physinjector
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	
	import com.reyco1.physinjector.contact.ContactListener;
	import com.reyco1.physinjector.contact.ContactManager;
	import com.reyco1.physinjector.data.PhysicsObject;
	import com.reyco1.physinjector.data.PhysicsProperties;
	import com.reyco1.physinjector.factory.BodyFactory;
	import com.reyco1.physinjector.geom.DynamicRegistration;
	import com.reyco1.physinjector.manager.DebugDrawManager;
	import com.reyco1.physinjector.manager.DragManager;
	import com.reyco1.physinjector.manager.Juggler;
	import com.reyco1.physinjector.manager.Utils;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * Main class which gets the Box2D engine ready and started 
	 * @author Reynaldo
	 * 
	 */	
	public class PhysInjector extends EventDispatcher implements IEventDispatcher
	{
		public static var   WORLD_SCALE:Number = 70;
		
		public static const SQUARE:int   = 0;
		public static const CIRCLE:int   = 1;
		public static const POLYGON:int  = 2;
		
		public static var WORLD:b2World;
		public static var REGISTRATION_RATIO:Point =  new Point(0.5, 0.5);
		
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
			defaultGravity 	     = gravity ? gravity : new b2Vec2(0.0, 40);
			this.draggingAllowed = draggingAllowed;
			this.stage		  	 = stage;
			
			bodyHash		  = new Dictionary();
			bodies			  = new Vector.<b2Body>();
			joints			  = new Vector.<b2Joint>();
			bodyDestroyQueue  = new Vector.<b2Body>();
			jointDestroyQueue = new Vector.<b2Joint>();
			dragManager		  = new DragManager(stage);
			WORLD	  		  = new b2World( defaultGravity, true );
			
			allowDrag = draggingAllowed;
			
			if(debugDraw != null)
			{
				debugDrawManager = new DebugDrawManager(debugDraw);
			}
			
			juggler = new Juggler();
			
			ContactManager.init(this);
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
			var currentRotation:Number 	= 0;
			var po:PhysicsObject		= null;
			var globalCenter:Point		= null;
			var b:b2Body				= null;
			
			if(displayObj.rotation != 0)
			{
				currentRotation = displayObj.rotation
				displayObj.rotation = 0;
			}
			
			if(!properties)
				properties = new PhysicsProperties();
			
			properties.pivot = DynamicRegistration.getRegistrationOffset( displayObj, REGISTRATION_RATIO );
			properties.angle = Utils.degreesToRadians( currentRotation );
			
			globalCenter = DynamicRegistration.getGlobalDisplayObjectCenter( displayObj );
			
			switch(type)
			{
				case CIRCLE:
					b = createCircle
					(
						globalCenter.x, 
						globalCenter.y, 
						displayObj.width * 0.5, 
						properties
					);
					break;
				
				case SQUARE:
					b = createSquare
					(						
						globalCenter.x, 
						globalCenter.y,
						displayObj.width, 
						displayObj.height, 
						properties
					);
					break;
				
				case POLYGON:
					properties.pivot = new Point(properties.pivot.x / WORLD_SCALE, properties.pivot.y / WORLD_SCALE);
					
					b = createPolygon
					( 
						globalCenter.x, 
						globalCenter.y,
						properties.vertices, 
						properties 
					);
					break;
			}
			
			po = new PhysicsObject(b, displayObj, properties);
			po.name = properties.name;
			
			b.SetUserData( po );
			bodyHash[ displayObj ] = b;
			updateDisplayObjectPosition( b );
			
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
		public function updateDisplayObjectPosition(body:b2Body):void
		{
			var physObject:PhysicsObject = PhysicsObject( body.GetUserData() ) as PhysicsObject;
			var displayObject:* 		 = physObject.displayObject;
			var localPosition:Point 	 = Utils.b2Vec2ToPoint( body.GetPosition() );
			var newX:Number 			 = localPosition.x;
			var newY:Number 			 = localPosition.y;
			var newRotation:Number 		 = Utils.radiansToDegrees( body.GetAngle() );
			
			DynamicRegistration.move(displayObject, physObject.physicsProperties.pivot, newX, newY)
			DynamicRegistration.rotate(displayObject, physObject.physicsProperties.pivot, newRotation);			
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
		 * @return PhysicsObject
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
		 * 
		 * @param name Returns a PhysicsObject based on the name provided. If the name of the display ogject or physics object is matched.
		 * @return PhysicsObject
		 * 
		 */		
		public function getPhysicsObjectByName(name:String):PhysicsObject
		{
			for (var displayObject:* in bodyHash)
			{
				if(displayObject.name == name || getPhysicsObject(displayObject).name == name)
					return getPhysicsObject(displayObject);
			}
			return null;
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
			
			while(jointDestroyQueue.length > 0)
			{
				destroyJoint( jointDestroyQueue.splice(0, 1)[0] );
			}
			
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
					updateDisplayObjectPosition( bodies[a] );
				}
			}
			
			if(debugDrawManager)
				debugDrawManager.update();
			
			juggler.update();
		}
	}
}