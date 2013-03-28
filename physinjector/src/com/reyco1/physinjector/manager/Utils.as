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
			return new Point(b2v2.x * PhysInjector.RATIO, b2v2.y * PhysInjector.RATIO);
		}
		
		public static function pointTob2Vec2(pnt:Point):b2Vec2
		{
			return new b2Vec2(pnt.x / PhysInjector.RATIO, pnt.y / PhysInjector.RATIO);
		}
		
		public static function degreesToRadians(degrees:Number):Number
		{
			return degrees * Math.PI / 180;
		}
		
		public static function radiansToDegrees(radians:Number):Number
		{
			return radians * 180 / Math.PI;
		}
	}
}