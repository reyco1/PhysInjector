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
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2FixtureDef;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.Definitions;
	import com.reyco1.physinjector.data.PhysicsProperties;
	import com.reyco1.physinjector.geom.Separator;
	
	import flash.utils.Dictionary;

	public class BodyFactory
	{
		private static var physicsEditorInstances:Dictionary = new Dictionary();
		
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
			var staus:int = sep.Validate(vertices);
			if(staus != 0)
				throw new Error("The Separator could not validate the vertices! status: " + staus);
			sep.Separate(body, definitions.fixtureDef, vertices, PhysInjector.WORLD_SCALE);
			
			return body;
		}
		
		public static function createFromPhysicsEditor(numX:Number, numY:Number, properties:PhysicsProperties):b2Body
		{
			var physClass:Object;
			
			var definitions:Definitions = new Definitions(null, properties);
			definitions.bodyDef.position.Set(numX / PhysInjector.WORLD_SCALE, numY / PhysInjector.WORLD_SCALE);	
			
			var body:b2Body = PhysInjector.WORLD.CreateBody(definitions.bodyDef);
			
			if(physicsEditorInstances[properties.physicsEditorClass])
			{
				physClass = physicsEditorInstances[properties.physicsEditorClass];
			}
			else
			{
				physicsEditorInstances[properties.physicsEditorClass] = new properties.physicsEditorClass() as Object;
				physClass = physicsEditorInstances[properties.physicsEditorClass];
				physClass["ptm_ratio"] = PhysInjector.WORLD_SCALE;
			}
			
			if(!physClass.hasOwnProperty("dict"))
				throw new Error("Make sure that the \"dict\" property in your PhysicsData class is set to \"public\".");	
			
			if(properties.physicsEditorName == "")
				throw new Error("Make sure that the \"physicsEditorName\" property in your PhysicsProperties class is set to the proper name found in the PysicsEditor class.");
			
			var fixtures:Array = physClass.dict[properties.physicsEditorName];
			
			for (var f:int = 0; f < fixtures.length; f++) 
			{
				var fixture:Array = fixtures[f];
				var fixtureDef:b2FixtureDef = Definitions.getFixtureDef(properties);
				
				if(fixture[7] == "POLYGON")
				{                    
					var p:Number;
					var polygons:Array = fixture[8];
					for(p = 0; p < polygons.length; p++)
					{
						var polygonShape:b2PolygonShape = new b2PolygonShape();
						polygonShape.SetAsArray(polygons[p], polygons[p].length);
						fixtureDef.shape = polygonShape;
						
						body.CreateFixture(fixtureDef);
					}
				}
				else if(fixture[7] == "CIRCLE")
				{
					var circleShape:b2CircleShape = new b2CircleShape(fixture[9]);                    
					circleShape.SetLocalPosition(fixture[8]);
					fixtureDef.shape = circleShape;
					body.CreateFixture(fixtureDef);                    
				}
			}
			
			return body;
		}
	}
}