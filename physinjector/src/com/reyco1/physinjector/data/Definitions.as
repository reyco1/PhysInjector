// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

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
			this.shape 	= shape;			
			bodyDef 	= getBodyDef(properties);			
			fixtureDef	= getFixtureDef(properties);
			fixtureDef.shape = shape;
		}
		
		public static function getFixtureDef(properties:PhysicsProperties):b2FixtureDef
		{
			var fixtureDef:b2FixtureDef		= new b2FixtureDef();
			fixtureDef.density 		    	= properties.density;
			fixtureDef.friction 			= properties.friction;
			fixtureDef.restitution 	    	= properties.restitution;
			fixtureDef.filter.groupIndex	= properties.groupIndex;
			fixtureDef.filter.categoryBits 	= properties.categoryBits;
			fixtureDef.filter.maskBits 		= properties.maskBits;
			fixtureDef.isSensor				= properties.isSensor;
			
			return fixtureDef;
		}
		
		public static function getBodyDef(properties:PhysicsProperties):b2BodyDef
		{
			var bodyDef:b2BodyDef			= new b2BodyDef();
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
			
			return bodyDef;
		}
		
		public static function createPhysicsPropertiesFromb2Body(body:b2Body):PhysicsProperties
		{
			var pp:PhysicsProperties = new PhysicsProperties();
			
			pp.active			= body.IsActive();
			pp.allowSleep		= body.IsSleepingAllowed();
			pp.angle			= body.GetAngle();
			pp.angularDamping 	= body.GetAngularDamping();
			pp.angularVelocity 	= body.GetAngularVelocity();
			pp.awake			= body.IsAwake();
			pp.isBullet			= body.IsBullet();
			pp.rotationFixed	= body.IsFixedRotation();
			pp.linearDamping	= body.GetLinearDamping();
			pp.linearVelocity	= body.GetLinearVelocity();
			pp.isDynamic		= body.GetType() == b2Body.b2_dynamicBody;
			
			pp.density 			= body.GetFixtureList().GetDensity();
			pp.friction 		= body.GetFixtureList().GetFriction();
			pp.restitution 		= body.GetFixtureList().GetRestitution();
			pp.groupIndex 		= body.GetFixtureList().GetFilterData().groupIndex;
			pp.categoryBits 	= body.GetFixtureList().GetFilterData().categoryBits;
			pp.maskBits 		= body.GetFixtureList().GetFilterData().maskBits;
			pp.isSensor 		= body.GetFixtureList().IsSensor();
			
			return pp;
		}
	}
}