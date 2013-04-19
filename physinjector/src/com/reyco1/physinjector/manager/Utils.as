// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.reyco1.physinjector.manager
{
	import Box2D.Common.Math.b2Vec2;
	
	import com.reyco1.physinjector.PhysInjector;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Utils
	{
		public static function b2Vec2ToPoint(b2v2:b2Vec2):Point
		{
			return new Point(b2v2.x * PhysInjector.WORLD_SCALE, b2v2.y * PhysInjector.WORLD_SCALE);
		}
		
		public static function b2Vec2VectorToPointVector(b2Vec2Vector:Vector.<b2Vec2>):Vector.<Point>
		{
			var pntVector:Vector.<Point> = new Vector.<Point>();
			for (var a:int = 0; a < b2Vec2Vector.length; a++) 
			{
				pntVector.push( b2Vec2ToPoint(b2Vec2Vector[a]) );
			}
			return pntVector;
		}
		
		public static function pointTob2Vec2(pnt:Point):b2Vec2
		{
			return new b2Vec2(pnt.x / PhysInjector.WORLD_SCALE, pnt.y / PhysInjector.WORLD_SCALE);
		}
		
		public static function pointVectorTob2Vec2Vector(pointVector:Vector.<Point>):Vector.<b2Vec2>
		{
			var b2Vec2Vector:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for (var a:int = 0; a < pointVector.length; a++) 
			{
				b2Vec2Vector.push( pointTob2Vec2(pointVector[a]) );
			}
			return b2Vec2Vector;
		}
		
		public static function degreesToRadians(degrees:Number):Number
		{
			return degrees * Math.PI / 180;
		}
		
		public static function radiansToDegrees(radians:Number):Number
		{
			return radians * 180 / Math.PI;
		}
		
		public static function pointIsWithinRectangle(point:Point, rectangle:Rectangle):Boolean
		{
			var bool:Boolean = false;
			if(point.x >= rectangle.x &&
			   point.x <  rectangle.x + rectangle.width &&
			   point.y >= rectangle.y &&
			   point.y <  rectangle.y + rectangle.height)
			{
				bool = true;
			}
			return bool;
		}
		
		public static function normalize(value:Number, minimum:Number, maximum:Number):Number
		{
			return (value - minimum) / (maximum - minimum);
		}
		
		public static function interpolate(normValue:Number, minimum:Number, maximum:Number):Number
		{
			return minimum + (maximum - minimum) * normValue;
		}
		
		public static function map(value:Number, min1:Number, max1:Number, min2:Number, max2:Number):Number
		{
			return interpolate( normalize(value, min1, max1), min2, max2 );
		}
	}
}