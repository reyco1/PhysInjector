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
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.Definitions;
	import com.reyco1.physinjector.data.PhysicsProperties;
	import com.reyco1.physinjector.manager.Utils;
	
	import flash.geom.Point;

	public class EdgeFactory
	{
		public static function createEdge(start:Point, end:Point, properties:PhysicsProperties):b2Body
		{
			var shape:b2PolygonShape = b2PolygonShape.AsEdge(Utils.pointTob2Vec2(start), Utils.pointTob2Vec2(start));
			var definitions:Definitions = new Definitions(shape, properties);
			var body:b2Body = PhysInjector.WORLD.CreateBody( definitions.bodyDef );
			body.CreateFixture( definitions.fixtureDef );
			return body;
		}
		
		public static function createCubicBezierCurve(anchorPoint1:Point, controlPoint1:Point, controlPoint2:Point, anchorPoint2:Point, segmentCount:int = 24, properties:PhysicsProperties = null):void
		{
			var props:PhysicsProperties = properties == null ? new PhysicsProperties({restitution:0, density:10, friction:0, isDynamic:false}) : properties;	
			var definitions:Definitions = new Definitions(null, props);
			
			var step:Number 			= 1/segmentCount;
			var anchor1:b2Vec2 			= Utils.pointTob2Vec2( anchorPoint1  );
			var control1:b2Vec2   		= Utils.pointTob2Vec2( controlPoint1 );
			var control2:b2Vec2   		= Utils.pointTob2Vec2( controlPoint2 );
			var anchor2:b2Vec2   		= Utils.pointTob2Vec2( anchorPoint2  );	
			var previousPoint:b2Vec2	= anchor1;
			
			var posx:Number;
			var posy:Number;
			var shape:b2PolygonShape;
			var edge:b2Body;
			var temp:b2Vec2;
			
			for (var u:Number = 0; u <= 1; u += step) 
			{ 
				posx  = Math.pow(u,3)*(anchor2.x+3*(control1.x-control2.x)-anchor1.x)+3*Math.pow(u,2)*(anchor1.x-2*control1.x+control2.x)+3*u*(control1.x-anchor1.x)+anchor1.x;
				posy  = Math.pow(u,3)*(anchor2.y+3*(control1.y-control2.y)-anchor1.y)+3*Math.pow(u,2)*(anchor1.y-2*control1.y+control2.y)+3*u*(control1.y-anchor1.y)+anchor1.y;
				
				temp  = new b2Vec2(posx, posy);
				
				shape = b2PolygonShape.AsEdge(previousPoint, temp);
				definitions.fixtureDef.shape = shape;
				edge = PhysInjector.WORLD.CreateBody( definitions.bodyDef );
				edge.CreateFixture( definitions.fixtureDef );
				
				previousPoint = temp;
			} 
			
			shape = b2PolygonShape.AsEdge(previousPoint, anchor2);
			definitions.fixtureDef.shape = shape;
			edge = PhysInjector.WORLD.CreateBody( definitions.bodyDef );
			edge.CreateFixture( definitions.fixtureDef );
		}
	}
}