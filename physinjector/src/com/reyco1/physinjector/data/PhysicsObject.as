package com.reyco1.physinjector.data
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.events.PhysicsPropertyChangeEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	public class PhysicsObject extends EventDispatcher
	{
		private var _physicsProperties:PhysicsProperties;
		private var _fixture:b2Fixture;
		private var _shape:b2Shape;
		private var _body:b2Body;
		private var _displayObject:*;
		private var _id:*;		
		private var _x:Number;
		private var _y:Number;
		private var _name:String;
		private var _data:Object;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _hideSkin:Boolean;
		
		private var loc:b2Vec2;
		
		public function PhysicsObject(body:b2Body, displayObject:*, physicsProperties:PhysicsProperties = null)
		{
			_body = body;
			_displayObject = displayObject;
			
			this.physicsProperties = physicsProperties ? physicsProperties : new PhysicsProperties();
		}
		
		// pulic methods

		public function getDisplayObjectCenterPoint():Point
		{
			var localPoint:Point = new Point(_displayObject.x + (_displayObject.width * 0.5), _displayObject.y + (_displayObject.height * 0.5));
			return _displayObject.parent.localToGlobal( localPoint );
		}
		
		public function getPointOnDisplayObject(point:Point):Point
		{
			var localPoint:Point = new Point(_displayObject.x + (_displayObject.width * point.x), _displayObject.y + (_displayObject.height * point.y));
			return _displayObject.parent.localToGlobal( localPoint );
		}
		
		public function move(x:Number, y:Number):void
		{
			var localPoint:Point = _displayObject.parent.localToGlobal( new Point(x, y) );
			loc = new b2Vec2(localPoint.x/PhysInjector.RATIO, (localPoint.y/PhysInjector.RATIO));
			body.SetPosition(loc);
		}
		
		// event handlers
		
		protected function handlePropertyChange(event:PhysicsPropertyChangeEvent):void
		{
			switch(event.host)
			{
				case "bodyDef":
					body[event.property].call(body, event.value);
					break;
				
				case "fixtureDef":
					body.GetFixtureList()[event.property].call(body, event.value);
					break;
				
				case "custom":
					break;
			}
			
			dispatchEvent( event.clone() as PhysicsPropertyChangeEvent );
		}
		
		// properties
		
		public function get displayObject():*
		{
			return _displayObject;
		}

		public function get body():b2Body
		{
			return _body;
		}

		public function get id():*
		{
			return _id;
		}

		public function set id(value:*):void
		{
			_id = value;
		}

		public function get physicsProperties():PhysicsProperties
		{
			return _physicsProperties;
		}

		public function set physicsProperties(value:PhysicsProperties):void
		{
			_physicsProperties = value;
			_physicsProperties.addEventListener(PhysicsPropertyChangeEvent.CHANGE, handlePropertyChange);
		}

		public function get y():Number
		{
			_y = body.GetPosition().y * PhysInjector.RATIO;
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
			loc = body.GetPosition();
			loc.y = value / PhysInjector.RATIO;
			body.SetPosition( loc );
		}

		public function get x():Number
		{
			_x = body.GetPosition().x * PhysInjector.RATIO;
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
			loc = body.GetPosition();
			loc.x = value / PhysInjector.RATIO;
			body.SetPosition( loc );
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get fixture():b2Fixture
		{
			return body.GetFixtureList();
		}

		public function get shape():b2Shape
		{
			return fixture.GetShape();
		}

		public function get offsetY():Number
		{
			return _offsetY;
		}

		public function set offsetY(value:Number):void
		{
			_offsetY = value;
		}

		public function get offsetX():Number
		{
			return _offsetX;
		}

		public function set offsetX(value:Number):void
		{
			_offsetX = value;
		}

		public function dispose():void
		{
			_physicsProperties 	= null;
			_fixture 			= null;
			_shape 				= null;
			_body 				= null;
			_displayObject 		= null;
			_id 				= null;	
			_data 				= null;			
			loc 				= null;
		}

		public function get hideSkin():Boolean
		{
			return _hideSkin;
		}

		public function set hideSkin(value:Boolean):void
		{
			_hideSkin = value;
			displayObject.visible = value;
		}

	}
}