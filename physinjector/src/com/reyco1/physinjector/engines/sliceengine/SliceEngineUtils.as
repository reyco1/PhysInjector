// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.reyco1.physinjector.engines.sliceengine
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.PhysicsObject;
	import com.reyco1.physinjector.geom.PointSorter;
	import com.reyco1.physinjector.manager.Utils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;

	public class SliceEngineUtils
	{
		public static function getVertices(physicsObject:PhysicsObject):Vector.<b2Vec2>
		{
			var shapeType:* = physicsObject.shape.GetType();
			var vertices:Vector.<b2Vec2>;
			
			if(shapeType == 1)
				vertices = b2PolygonShape(physicsObject.shape).GetVertices();
			else
				throw new Error("The Slicing Engine is limited to only slicing polygons.");
			
			return vertices;
		}
		
		public static function getBitmapTexture(physicsObject:PhysicsObject):Bitmap
		{
			var registrationOffset:Point = physicsObject.physicsProperties.virtualTopLeftRegPoint;
			var oldRotation:Number 		 = physicsObject.displayObject.rotation;
			
			physicsObject.displayObject.rotation = 0;
			
			var mat:Matrix = new Matrix();
			mat.translate(-registrationOffset.x, -registrationOffset.y);
			
			var mcBMP:Bitmap;
			if(!PhysInjector.STARLING)
			{
				var mcBMPD:BitmapData = new BitmapData(physicsObject.displayObject.width, physicsObject.displayObject.height, true, 0x00000000);
				mcBMP = new Bitmap(mcBMPD, "auto", true);
				mcBMPD.draw(physicsObject.displayObject, mat, null, null);
			}
			else
			{
				throw new Error("As of this current version, the SliceEngine does not work with Starling.");
			}
			
			physicsObject.displayObject.rotation = oldRotation;
			
			return mcBMP;
		}
		
		public static function createSlicedTexture(verticesVec:Vector.<b2Vec2>, texture:Bitmap):*
		{
			var sprite:*;
			
			var shape:Shape 		 = new Shape();
			var verts:Vector.<Point> = Utils.b2Vec2VectorToPointVector(verticesVec);
			var centerPoint:Object 	 = PointSorter.getMidpoint(verts);
			
			var m:Matrix = new Matrix();
			m.tx = -texture.width  * 0.5;
			m.ty = -texture.height * 0.5;
			
			Shape(shape).graphics.beginBitmapFill(texture.bitmapData, m, true, true);				
			shape.graphics.moveTo(verts[0].x, verts[0].y);
			
			for (var i:int=1; i<verts.length; i++) 
				shape.graphics.lineTo(verts[i].x, verts[i].y);
			
			shape.graphics.lineTo(verts[0].x, verts[0].y);
			shape.graphics.endFill();			
			
			
			if(!PhysInjector.STARLING)
			{
				sprite = new Sprite();
				sprite.addChild( shape );
			}
			else
			{
				throw new Error("As of this current version, the SliceEngine does not work with Starling.");
				
				/*
				var mcBMPD:BitmapData = new BitmapData(shape.width, shape.height, true, 0x00000000);
				var mcBMP:Bitmap = new Bitmap(mcBMPD, "auto", true);
				mcBMPD.draw(shape);
				
				var ImageClass:* 	= getDefinitionByName("starling.display.Image");
				var TextureClass:* 	= getDefinitionByName("starling.textures.Texture");
				
				sprite = new ImageClass(TextureClass["fromBitmap"](mcBMP));
				*/
			}
			
			return sprite;
		}
	}
}