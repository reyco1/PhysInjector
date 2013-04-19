// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.reyco1.physinjector.engines
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.Definitions;
	import com.reyco1.physinjector.data.PhysicsObject;
	import com.reyco1.physinjector.data.PhysicsProperties;
	import com.reyco1.physinjector.engines.sliceengine.SliceData;
	import com.reyco1.physinjector.engines.sliceengine.SliceEngineUtils;
	import com.reyco1.physinjector.geom.DynamicRegistration;
	import com.reyco1.physinjector.geom.PointSorter;
	import com.reyco1.physinjector.manager.Utils;
	
	import flash.display.Sprite;
	import flash.geom.Point;

	public class SliceEngine
	{
		public  var autoAddResultingSlices:Boolean = false;
		
		private var injector:PhysInjector;
		private var lineStartEndPoints:Vector.<b2Vec2>;
		private var intersecting:Boolean;
		private var objectsWithEnterPoints:Vector.<PhysicsObject>;
		
		public function SliceEngine(injector:PhysInjector)
		{
			this.injector = injector;
			intersecting  = false;
			
			injector.juggler.subscribe( update );			
		}
		
		public function add(physicsObject:PhysicsObject):void
		{
			var sliceData:SliceData = new SliceData();
			sliceData.vertices 	 	= SliceEngineUtils.getVertices(physicsObject);
			sliceData.texture	 	= SliceEngineUtils.getBitmapTexture(physicsObject);	
			
			physicsObject.sliceData = sliceData;
		}
		
		public function intersect(points:Vector.<Point>):void
		{
			objectsWithEnterPoints  = new Vector.<PhysicsObject>();
			lineStartEndPoints 		= Utils.pointVectorTob2Vec2Vector( points );
			intersecting 			= true;
		}		
		
		private function update():void
		{
			if(lineStartEndPoints && intersecting)
			{
				PhysInjector.WORLD.RayCast(intersection, lineStartEndPoints[0], lineStartEndPoints[1]);
				PhysInjector.WORLD.RayCast(intersection, lineStartEndPoints[1], lineStartEndPoints[0]);
				
				lineStartEndPoints 	= null;
				intersecting 		= false;
			}
		}
		
		private function intersection(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):Number
		{
			var affectedBody:PhysicsObject = fixture.GetBody().GetUserData() as PhysicsObject;
			var sliceData:SliceData = affectedBody.sliceData as SliceData;
			var index:int;
			
			if(sliceData)
			{
				index = objectsWithEnterPoints.indexOf(affectedBody);
				
				if(index != -1)
				{
					objectsWithEnterPoints.splice(index, 1);
					
					sliceData.exitPoint = point;
					createSlices(affectedBody, sliceData.entryPoint, point.Copy());
				}
				else
				{
					objectsWithEnterPoints.push( affectedBody );
					sliceData.entryPoint = point;
				}
			}			
			
			return 1;
		}
		
		private function createSlices(affectedBody:PhysicsObject, A:b2Vec2, B:b2Vec2):void 
		{
			var verticesVec:Vector.<b2Vec2> 	= SliceEngineUtils.getVertices( affectedBody );
			var numVertices:int 				= verticesVec.length;				
			var shape1Vertices:Vector.<b2Vec2> 	= new Vector.<b2Vec2>();
			var shape2Vertices:Vector.<b2Vec2> 	= new Vector.<b2Vec2>();
			var parent:* 						= affectedBody.displayObject.parent;
			
			A = affectedBody.body.GetLocalPoint(A);
			B = affectedBody.body.GetLocalPoint(B);
			
			shape1Vertices.push( A );
			shape1Vertices.push( B );
			shape2Vertices.push( A );
			shape2Vertices.push( B );
			
			for (var i:int = 0; i < numVertices; i++) 
			{
				var currentPoint:b2Vec2 = verticesVec[i];
				
				var diffFromEntryPoint:b2Vec2 = b2Math.SubtractVV(currentPoint, new b2Vec2(A.x, A.y));
				var diffFromExitPoint:b2Vec2  = b2Math.SubtractVV(currentPoint, new b2Vec2(B.x, B.y));
				
				if((diffFromEntryPoint.x == 0 && diffFromEntryPoint.y == 0) || (diffFromExitPoint.x == 0 && diffFromExitPoint.y == 0))
					continue;
				
				var d:Number = PointSorter.det(A.x, A.y, B.x, B.y, verticesVec[i].x, verticesVec[i].y);
				
				if(d > 0)
					shape1Vertices.push(verticesVec[i]);
				else
					shape2Vertices.push(verticesVec[i]);
			}
			
			shape1Vertices = PointSorter.arrangeClockwise( shape1Vertices );
			shape2Vertices = PointSorter.arrangeClockwise( shape2Vertices );
			
			var slice1:Sprite = SliceEngineUtils.createSlicedTexture(shape1Vertices, SliceData(affectedBody.sliceData).texture) as Sprite;
			var slice2:Sprite = SliceEngineUtils.createSlicedTexture(shape2Vertices, SliceData(affectedBody.sliceData).texture) as Sprite;
			
			parent.addChild( slice1 );
			parent.addChild( slice2 );
			
			var data:Object = {};
			data.body 		= affectedBody.body;
			data.x 			= affectedBody.x
			data.y 			= affectedBody.y
			data.rotation 	= affectedBody.rotation;
			data.texture 	= affectedBody.sliceData["texture"];
			data.slice 		= slice1;
			data.vertices 	= shape1Vertices;
			
			var data2:Object= {};
			data2.body 		= affectedBody.body;
			data2.x 		= affectedBody.x
			data2.y 		= affectedBody.y
			data2.rotation 	= affectedBody.rotation;
			data2.texture 	= affectedBody.sliceData["texture"];
			data2.slice 	= slice2;
			data2.vertices 	= shape2Vertices;
			
			createSlice( data  );			
			createSlice( data2 );	
			
			injector.quickDispose( affectedBody, true );
		}
		
		private function createSlice(data:Object):void
		{
			var properties:PhysicsProperties = Definitions.createPhysicsPropertiesFromb2Body( data.body );			
			var currentRotation:Number 		 = 0;
			var po:PhysicsObject			 = null;
			var globalCenter:Point			 = null;
			var b:b2Body					 = null;
			
			if(data.rotation != 0)
			{
				currentRotation = data.rotation;
				data.rotation = 0;
			}
			
			if(!properties)
				properties = new PhysicsProperties();
			
			properties.virtualCenterRegPoint 	= DynamicRegistration.getRegistrationOffset( data.slice, new Point(0.5, 0.5) );
			properties.virtualTopLeftRegPoint 	= DynamicRegistration.getRegistrationOffset( data.slice, new Point(0, 0) );
			properties.angle 					= PhysInjector.STARLING ? currentRotation : Utils.degreesToRadians( currentRotation );
			properties.virtualCenterRegPoint  	= new Point(0, 0);
			properties.awake					= true;
			
			globalCenter = DynamicRegistration.getGlobalDisplayObjectCenter( data.slice );
			
			data.slice.x 		= data.x;
			data.slice.y 		= data.y;
			data.slice.rotation = data.rotation;
			
			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsVector(data.vertices);			
			
			var def:Definitions = new Definitions(polyShape, properties);
			def.bodyDef.position.SetV(data.body.GetPosition());
			
			var body:b2Body = PhysInjector.WORLD.CreateBody(def.bodyDef);
			body.SetAngle(data.body.GetAngle());
			body.CreateFixture(def.fixtureDef);
			
			injector.bodies.push( body );
			
			var physObj:PhysicsObject = injector.registerPhysicsObject(body, data.slice, properties);
			
			if(autoAddResultingSlices)			
				physObj.sliceData = new SliceData(data.vertices, data.texture);
		}
		
		public function dispose():void
		{
			injector.juggler.unsubscribe( update );	
			
			injector 				= null;
			lineStartEndPoints 		= null;
			objectsWithEnterPoints 	= null
		}
	}
}