package com.reyco1.physinjector.factory
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.PhysicsProperties;
	import com.reyco1.physinjector.geom.Separator;
	
	import flash.geom.Point;

	public class BodyFactory
	{
		public static function createCircle(numX:Number, numY:Number, radius:Number, properties:PhysicsProperties):b2Body 
		{
			var circle:b2CircleShape = new b2CircleShape(radius / PhysInjector.RATIO);
			
			var completeDefinition:Object = parsePhysicsProperties( circle, properties );
			completeDefinition.bodyDef.position.Set(numX / PhysInjector.RATIO, numY / PhysInjector.RATIO);
			
			var body:b2Body = PhysInjector.WORLD.CreateBody(completeDefinition.bodyDef);
			body.CreateFixture(completeDefinition.fixture);
			
			return body;
		}
		
		public static function createSquare(numX:Number, numY:Number, numWidth:Number, numHeight:Number, properties:PhysicsProperties):b2Body 
		{
			var box:b2PolygonShape = new b2PolygonShape();
			box.SetAsBox( (numWidth * 0.5) / PhysInjector.RATIO, (numHeight * 0.5) / PhysInjector.RATIO );
			
			var completeDefinition:Object = parsePhysicsProperties( box, properties );
			completeDefinition.bodyDef.position.Set(numX / PhysInjector.RATIO, numY / PhysInjector.RATIO);
			
			var body:b2Body = PhysInjector.WORLD.CreateBody(completeDefinition.bodyDef);
			body.CreateFixture(completeDefinition.fixture);
			
			return body;
		}
		
		public static function createPolygon(numX:Number, numY:Number, vertices:Vector.<b2Vec2>, properties:PhysicsProperties):b2Body 
		{
			var completeDefinition:Object = parsePhysicsProperties( null, properties );
			completeDefinition.bodyDef.position.Set(numX / PhysInjector.RATIO, numY / PhysInjector.RATIO);			
			
			var body:b2Body = PhysInjector.WORLD.CreateBody(completeDefinition.bodyDef);
			
			var sep:Separator = new Separator();
			if(sep.Validate(vertices) != 0)
				throw new Error("The Separator could not validate the vertices!");
			sep.Separate(body, completeDefinition.fixture, vertices, PhysInjector.RATIO);
			
			return body;
		}
		
		private static function parsePhysicsProperties(shapeDefinition:*, properties:PhysicsProperties):Object
		{
			var bodyDef:b2BodyDef 		= new b2BodyDef();
			bodyDef.active				= properties.active;
			bodyDef.allowSleep 			= properties.allowSleep;
			bodyDef.angle				= properties.angle;
			bodyDef.angularDamping 		= properties.angularDamping;
			bodyDef.angularVelocity 	= properties.angularVelocity;
			bodyDef.awake				= properties.awake;
			bodyDef.bullet 				= properties.isBullet;
			bodyDef.fixedRotation 		= properties.rotationFixed;
			bodyDef.linearDamping 		= properties.linearDamping;
			bodyDef.linearVelocity 		= properties.linearVelocity;
			bodyDef.type 				= properties.isDynamic ? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
			
			var fixture:b2FixtureDef   	= new b2FixtureDef();
			fixture.shape 			   	= shapeDefinition;
			fixture.density 		    = properties.density;
			fixture.friction 		    = properties.friction;
			fixture.restitution 	    = properties.restitution;
			fixture.filter.categoryBits = properties.categoryBits;
			fixture.filter.maskBits 	= properties.maskBits;
			fixture.isSensor			= properties.isSensor;
			
			return {bodyDef:bodyDef, fixture:fixture};
		}
	}
}