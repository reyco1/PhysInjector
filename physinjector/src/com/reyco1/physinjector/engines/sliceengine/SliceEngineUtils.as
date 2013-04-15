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
			
			var mcBMPD:BitmapData = new BitmapData(physicsObject.displayObject.width, physicsObject.displayObject.height, true, 0x00000000);
			var mcBMP:Bitmap = new Bitmap(mcBMPD, "auto", true);
			mcBMPD.draw(physicsObject.displayObject, mat, null, null);
			
			physicsObject.displayObject.rotation = oldRotation;
			
			return mcBMP;
		}
		
		public static function createSlicedTexture(verticesVec:Vector.<b2Vec2>, texture:Bitmap):*
		{
			var sprite:*;
			var container:*;
			if(!PhysInjector.STARLING)
			{
				var shape:Shape = new Shape();
				var verts:Vector.<Point> = Utils.b2Vec2VectorToPointVector(verticesVec);
				var centerPoint:Object = PointSorter.getMidpoint(verts);
				
				var m:Matrix = new Matrix();
				m.tx = -texture.width  * 0.5;
				m.ty = -texture.height * 0.5;
				
				Shape(shape).graphics.beginBitmapFill(texture.bitmapData, m, true, true);				
				shape.graphics.moveTo(verticesVec[0].x * PhysInjector.WORLD_SCALE, verticesVec[0].y * PhysInjector.WORLD_SCALE);
				
				for (var i:int=1; i<verticesVec.length; i++) 
					shape.graphics.lineTo(verticesVec[i].x * PhysInjector.WORLD_SCALE, verticesVec[i].y * PhysInjector.WORLD_SCALE);
				
				shape.graphics.lineTo(verticesVec[0].x * PhysInjector.WORLD_SCALE, verticesVec[0].y * PhysInjector.WORLD_SCALE);
				shape.graphics.endFill();
				
				
				var center:Shape = new Shape();
				center.graphics.lineStyle(1);
				center.graphics.beginFill(0xFF0000);
				center.graphics.drawCircle(0, 0, 3);
				center.graphics.endFill();					
				
				sprite = new Sprite();
				sprite.addChild( shape );
			}
			else
			{
				throw new Error("As of this current version, the SliceEngine does not work with Starling.")
			}
			return sprite;
		}
	}
}