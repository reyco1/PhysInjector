package com.reyco1.physinjector.data
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;

	public class Definitions
	{
		public var shape:*;
		public var bodyDef:b2BodyDef;
		public var fixtureDef:b2FixtureDef;
		
		public function Definitions(shape:*, properties:PhysicsProperties)
		{
			this.shape 						= shape;
			
			bodyDef 						= new b2BodyDef();
			bodyDef.active					= properties.active;
			bodyDef.allowSleep 				= properties.allowSleep;
			bodyDef.angle					= properties.angle;
			bodyDef.angularDamping 			= properties.angularDamping;
			bodyDef.angularVelocity 		= properties.angularVelocity;
			bodyDef.awake					= properties.awake;
			bodyDef.bullet 					= properties.isBullet;
			bodyDef.fixedRotation 			= properties.rotationFixed;
			bodyDef.linearDamping 			= properties.linearDamping;
			bodyDef.linearVelocity 			= properties.linearVelocity;
			bodyDef.type 					= properties.isDynamic ? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
			
			fixtureDef						= new b2FixtureDef();
			fixtureDef.shape 				= shape;
			fixtureDef.density 		    	= properties.density;
			fixtureDef.friction 			= properties.friction;
			fixtureDef.restitution 	    	= properties.restitution;
			fixtureDef.filter.categoryBits 	= properties.categoryBits;
			fixtureDef.filter.maskBits 		= properties.maskBits;
			fixtureDef.isSensor				= properties.isSensor;
		}
	}
}