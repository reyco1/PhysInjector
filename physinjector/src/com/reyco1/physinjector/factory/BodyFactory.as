package com.reyco1.physinjector.factory
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.Definitions;
	import com.reyco1.physinjector.data.PhysicsProperties;
	import com.reyco1.physinjector.geom.Separator;

	public class BodyFactory
	{
		public static function createCircle(numX:Number, numY:Number, radius:Number, properties:PhysicsProperties):b2Body 
		{
			var circle:b2CircleShape = new b2CircleShape(radius / PhysInjector.WORLD_SCALE);
			
			var definitions:Definitions = new Definitions(circle, properties);
			definitions.bodyDef.position.Set(numX / PhysInjector.WORLD_SCALE, numY / PhysInjector.WORLD_SCALE);
			
			var body:b2Body = PhysInjector.WORLD.CreateBody(definitions.bodyDef);
			body.CreateFixture(definitions.fixtureDef);
			
			return body;
		}
		
		public static function createSquare(numX:Number, numY:Number, numWidth:Number, numHeight:Number, properties:PhysicsProperties):b2Body 
		{
			var box:b2PolygonShape = new b2PolygonShape();
			box.SetAsBox( (numWidth * 0.5) / PhysInjector.WORLD_SCALE, (numHeight * 0.5) / PhysInjector.WORLD_SCALE );
			
			var definitions:Definitions = new Definitions(box, properties);
			definitions.bodyDef.position.Set(numX / PhysInjector.WORLD_SCALE, numY / PhysInjector.WORLD_SCALE);
			
			var body:b2Body = PhysInjector.WORLD.CreateBody(definitions.bodyDef);
			body.CreateFixture(definitions.fixtureDef);
			
			return body;
		}
		
		public static function createPolygon(numX:Number, numY:Number, vertices:Vector.<b2Vec2>, properties:PhysicsProperties):b2Body 
		{
			var definitions:Definitions = new Definitions(null, properties);
			definitions.bodyDef.position.Set(numX / PhysInjector.WORLD_SCALE, numY / PhysInjector.WORLD_SCALE);			
			
			var body:b2Body = PhysInjector.WORLD.CreateBody(definitions.bodyDef);
			
			var sep:Separator = new Separator();
			if(sep.Validate(vertices) != 0)
				throw new Error("The Separator could not validate the vertices!");
			sep.Separate(body, definitions.fixtureDef, vertices, PhysInjector.WORLD_SCALE);
			
			return body;
		}
	}
}