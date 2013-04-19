// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.reyco1.physinjector.factory
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.b2Body;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.manager.Utils;
	
	import flash.geom.Point;

	public class JointFactory
	{
		public static function createWeldJoint(body1:b2Body, body2:b2Body):b2WeldJoint
		{
			var weldJointDef:b2WeldJointDef = new b2WeldJointDef();  
			weldJointDef.Initialize(body1, body2, body1.GetWorldCenter());
			
			var joint:b2WeldJoint = PhysInjector.WORLD.CreateJoint(weldJointDef) as b2WeldJoint;
			
			return joint;
		}
		
		public static function createPulleyJoint(body1:b2Body, body2:b2Body, bodyAnchorPoint1:Point, bodyAnchorPoint2:Point, worldAnchorPoint1:Point, worldAnchorPoint2:Point, ratio:Number):b2PulleyJoint
		{
			var groundAnchor1:b2Vec2 = Utils.pointTob2Vec2( worldAnchorPoint1 );
			var groundAnchor2:b2Vec2 = Utils.pointTob2Vec2( worldAnchorPoint2 );
			var anchor1:b2Vec2 = Utils.pointTob2Vec2( bodyAnchorPoint1 );
			var anchor2:b2Vec2 = Utils.pointTob2Vec2( bodyAnchorPoint2 );
			
			var jointDef:b2PulleyJointDef = new b2PulleyJointDef();  
			jointDef.Initialize(body1, body2, groundAnchor1, groundAnchor2, anchor1, anchor2, ratio);
			
			return PhysInjector.WORLD.CreateJoint(jointDef) as b2PulleyJoint;
		}
		
		public static function createLineJoint(body1:b2Body, body2:b2Body, anchorPoint:Point, axisPoint:Point, lowerTranslation:Number, upperTranslation:Number, collideConnected:Boolean, enableLimit:Boolean):b2LineJoint
		{
			var anchor:b2Vec2 = Utils.pointTob2Vec2( anchorPoint );
			var axis:b2Vec2 = new b2Vec2(axisPoint.x, axisPoint.y);
			
			var jointDef:b2LineJointDef = new b2LineJointDef();
			jointDef.lowerTranslation = lowerTranslation / PhysInjector.WORLD_SCALE;
			jointDef.upperTranslation = upperTranslation / PhysInjector.WORLD_SCALE;
			jointDef.collideConnected = collideConnected;
			jointDef.enableLimit = enableLimit;
			jointDef.Initialize(body1, body2, anchor, axis);
			
			var joint:b2LineJoint = PhysInjector.WORLD.CreateJoint(jointDef) as b2LineJoint;
			
			return joint;
		}
		
		public static function createGearJoint(body1:b2Body, body2:b2Body, joint1:b2Joint, joint2:b2Joint, ratio:Number):b2GearJoint
		{
			var gearJointDef:b2GearJointDef = new b2GearJointDef();
			gearJointDef.joint1 = joint1;  
			gearJointDef.joint2 = joint2;  
			gearJointDef.bodyA = body1; 
			gearJointDef.bodyB = body2;
			gearJointDef.ratio = ratio;
			
			var joint:b2GearJoint = PhysInjector.WORLD.CreateJoint(gearJointDef) as b2GearJoint;
			
			return joint;
		}
		
		public static function createRevoluteJoint(body1:b2Body, body2:b2Body, anchorPoint:Point, collideConnected:Boolean = false, enableLimit:Boolean = false, angleMin:Number = 0, angleMax:Number = 0):b2RevoluteJoint 
		{
			var anchor:b2Vec2 = Utils.pointTob2Vec2( anchorPoint );
			
			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.collideConnected = collideConnected;
			
			if (enableLimit) 
			{
				jointDef.enableLimit = enableLimit;
				jointDef.lowerAngle = angleMin;
				jointDef.upperAngle = angleMax;
			}
			
			jointDef.Initialize(body1, body2, anchor);
			
			var joint:b2RevoluteJoint = PhysInjector.WORLD.CreateJoint(jointDef) as b2RevoluteJoint;
			
			return joint;
		}
		
		public static function createPrismaticJoint(body1:b2Body, body2:b2Body, anchorPoint:Point, axisPoint:Point, lowerTranslation:Number, upperTranslation:Number, collideConnected:Boolean, enableLimit:Boolean, enableMotor:Boolean = false):b2PrismaticJoint 
		{
			var anchor:b2Vec2 = Utils.pointTob2Vec2( anchorPoint );
			var axis:b2Vec2 = new b2Vec2(axisPoint.x, axisPoint.y);
			
			var jointDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			jointDef.lowerTranslation = lowerTranslation / PhysInjector.WORLD_SCALE;
			jointDef.upperTranslation = upperTranslation / PhysInjector.WORLD_SCALE;
			jointDef.collideConnected = collideConnected;
			jointDef.enableLimit = enableLimit;
			jointDef.enableMotor = enableMotor;
			jointDef.Initialize(body1, body2, anchor, axis);
			
			var joint:b2PrismaticJoint = PhysInjector.WORLD.CreateJoint(jointDef) as b2PrismaticJoint;
			
			return joint;
		}
		
		public static function createRopeJoint(body1:b2Body, body2:b2Body, maxLength:Number = 100, collideConnected:Boolean = false):b2RopeJoint
		{
			var ropeJointDef:b2RopeJointDef = new b2RopeJointDef();
			ropeJointDef.bodyA = body1;
			ropeJointDef.bodyB = body2;
			ropeJointDef.localAnchorA = new b2Vec2(0,0);
			ropeJointDef.localAnchorB = new b2Vec2(0,0);
			ropeJointDef.maxLength = maxLength / PhysInjector.WORLD_SCALE;
			ropeJointDef.collideConnected = collideConnected;
			
			var joint:b2RopeJoint = PhysInjector.WORLD.CreateJoint( ropeJointDef ) as b2RopeJoint;
			
			return joint;
		}
		
		public static function createElasticJoint(body1:b2Body, maxStrength:Number = 6, collideConnected:Boolean = true):b2MouseJoint
		{
			var md:b2MouseJointDef = new b2MouseJointDef();
			md.bodyA 			   = PhysInjector.WORLD.GetGroundBody();
			md.bodyB 			   = body1;
			md.collideConnected    = true;
			md.maxForce 		   = maxStrength * 100 * body1.GetMass();
			md.frequencyHz		   = maxStrength * 100;
			
			var bodypos:b2Vec2 = body1.GetWorldCenter();			
			md.target.Set(bodypos.x, bodypos.y);
			
			var joint:b2MouseJoint = PhysInjector.WORLD.CreateJoint(md) as b2MouseJoint;
			body1.SetAwake(true);
			
			return joint;
		}
		
		public static function createDistanceJoint(body1:b2Body, body2:b2Body, anchorPoint1:Point, anchorPoint2:Point, collideConnected:Boolean):b2DistanceJoint 
		{
			var anchor01:b2Vec2 = Utils.pointTob2Vec2( anchorPoint1 );
			var anchor02:b2Vec2 = Utils.pointTob2Vec2( anchorPoint2 );
			
			var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
			jointDef.collideConnected = collideConnected;
			jointDef.Initialize(body1, body2, anchor01, anchor02);
			
			var joint:b2DistanceJoint = PhysInjector.WORLD.CreateJoint(jointDef) as b2DistanceJoint;
			
			return joint;
		}
	}
}