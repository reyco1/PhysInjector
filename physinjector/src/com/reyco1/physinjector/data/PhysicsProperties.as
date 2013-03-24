package com.reyco1.physinjector.data
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import com.reyco1.physinjector.events.PhysicsPropertyChangeEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class PhysicsProperties extends EventDispatcher
	{
		// body definition		
		private var _active:Boolean			= true;
		private var _allowSleep:Boolean 	= true;		
		private var _angle:Number			= 0.0;
		private var _angularDamping:Number 	= 0.2;
		private var _angularVelocity:Number = 0.0;
		private var _awake:Boolean			= true;
		private var _isBullet:Boolean 	 	= false;
		private var _rotationFixed:Boolean 	= false;
		private var _linearDamping:Number  	= 0.2; 
		private var _linearVelocity:b2Vec2  = new b2Vec2();
		private var _isDynamic:Boolean 	   	= true;
		
		// fixture definition
		private var _density:Number 		= 1.0;
		private var _friction:Number 		= 0.5;
		private var _restitution:Number 	= 0.2;		
		private var _maskBits:uint 		 	= 0x0002;
		private var _categoryBits:uint 	 	= 0x0002;
		private var _isDraggable:Boolean 	= true;		
		private var _isSensor:Boolean 	 	= false;
		
		private var _vertices:Vector.<b2Vec2>;
		
		public function PhysicsProperties(quickProps:Object = null)
		{
			if(quickProps)
			{
				for(var prop:String in quickProps)
				{
					if(this.hasOwnProperty(prop))
					{
						this[prop] = quickProps[prop];
					}
				}
			}
		}

		public function get rotationFixed():Boolean
		{
			return _rotationFixed;
		}

		public function set rotationFixed(value:Boolean):void
		{
			_rotationFixed = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "IsFixedRotation", value));
		}

		public function get isDynamic():Boolean
		{
			return _isDynamic;
		}

		public function set isDynamic(value:Boolean):void
		{
			_isDynamic = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetType", value ? b2Body.b2_dynamicBody : b2Body.b2_staticBody));
		}

		public function get isSensor():Boolean
		{
			return _isSensor;
		}

		public function set isSensor(value:Boolean):void
		{
			_isSensor = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetSensor", value, "fixtureDef"));
		}

		public function get isBullet():Boolean
		{
			return _isBullet;
		}

		public function set isBullet(value:Boolean):void
		{
			_isBullet = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "IsBullet", value));
		}

		public function get allowSleep():Boolean
		{
			return _allowSleep;
		}

		public function set allowSleep(value:Boolean):void
		{
			_allowSleep = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "IsSleepingAllowed", value));
		}

		public function get angularDamping():Number
		{
			return _angularDamping;
		}

		public function set angularDamping(value:Number):void
		{
			_angularDamping = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetAngularDamping", value));
		}

		public function get linearDamping():Number
		{
			return _linearDamping;
		}

		public function set linearDamping(value:Number):void
		{
			_linearDamping = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetLinearDamping", value));
		}

		public function get restitution():Number
		{
			return _restitution;
		}

		public function set restitution(value:Number):void
		{
			_restitution = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetRestitution", value, "fixtureDef"));
		}

		public function get friction():Number
		{
			return _friction;
		}

		public function set friction(value:Number):void
		{
			_friction = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetFriction", value, "fixtureDef"));
		}

		public function get density():Number
		{
			return _density;
		}

		public function set density(value:Number):void
		{
			_density = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetDensity", value, "fixtureDef"));
		}

		public function get angle():Number
		{
			return _angle;
		}

		public function set angle(value:Number):void
		{
			_angle = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetAngle", value));
		}

		public function get angularVelocity():Number
		{
			return _angularVelocity;
		}

		public function set angularVelocity(value:Number):void
		{
			_angularVelocity = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetAngularVelocity", value));
		}

		public function get linearVelocity():b2Vec2
		{
			return _linearVelocity;
		}

		public function set linearVelocity(value:b2Vec2):void
		{
			_linearVelocity = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "SetLinearVelocity", value));
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "IsActive", value));
		}

		public function get awake():Boolean
		{
			return _awake;
		}

		public function set awake(value:Boolean):void
		{
			_awake = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "IsAwake", value));
		}
		
		public function get isDraggable():Boolean
		{
			return _isDraggable;
		}
		
		public function set isDraggable(value:Boolean):void
		{
			_isDraggable = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "isDraggable", value, "custom"));
		}
		
		public function get categoryBits():uint
		{
			return _categoryBits;
		}
		
		public function set categoryBits(value:uint):void
		{
			_categoryBits = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "categoryBits", value, "custom"));
		}
		
		public function get maskBits():uint
		{
			return _maskBits;
		}
		
		public function set maskBits(value:uint):void
		{
			_maskBits = value;
			dispatchEvent(new PhysicsPropertyChangeEvent(PhysicsPropertyChangeEvent.CHANGE, "maskBits", value, "custom"));
		}

		public function get vertices():Vector.<b2Vec2>
		{
			return _vertices;
		}

		public function set vertices(value:Vector.<b2Vec2>):void
		{
			_vertices = value;
		}


	}
}