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
		
		public static function pointTob2Vec2(pnt:Point):b2Vec2
		{
			return new b2Vec2(pnt.x / PhysInjector.WORLD_SCALE, pnt.y / PhysInjector.WORLD_SCALE);
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
	}
}