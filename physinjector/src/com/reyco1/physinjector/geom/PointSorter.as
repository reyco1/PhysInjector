package com.reyco1.physinjector.geom
{
	import Box2D.Common.Math.b2Vec2;
	
	import com.reyco1.physinjector.PhysInjector;
	
	import flash.utils.Dictionary;

	public class PointSorter
	{
		private static var center:Object;
		private static var points:Dictionary = new Dictionary();
		
		public static function sort(vertices:Array):Array
		{
			center = getMidpoint(vertices);
			
			for (var i:int = 0; i < vertices.length; ++i) 
			{
				vertices[i].angle = getRadian(vertices[i].x, vertices[i].y, center);
			}
			
			vertices.sortOn("angle", Array.NUMERIC);
			
			return vertices;
		}
		
		public static function parse(array:Array, id:String):Vector.<b2Vec2>
		{
			if(points[id])
				return points[id];
			
			array = sort( array );
			
			points[id] = new Vector.<b2Vec2>();
			for (var a:int = 0; a < array.length; a++) 
			{
				points[id].push(new b2Vec2(array[a].x / PhysInjector.RATIO, array[a].y / PhysInjector.RATIO));
			}
			return points[id];
		}
		
		private static function getMidpoint(group:Array):Object
		{
			var p:Object = new Object();
			var globalEquivalent:Object;
			var tempX:Number = 0;
			var tempY:Number = 0;
			
			for(var a:int = 0; a<group.length; a++)
			{
				globalEquivalent = {x:group[a].x, y:group[a].y};
				tempX += globalEquivalent.x;
				tempY += globalEquivalent.y;
			}
			
			p.x = tempX / group.length;
			p.y = tempY / group.length;			
			
			return p;
		}
		
		private static function getRadian (x2:Number, y2:Number, center:Object):Number
		{
			var dx:Number = center.x - x2;
			var dy:Number = center.y - y2;
			return degrees(Math.atan2(dy,dx));
		}
		
		private static function degrees(radians:Number):Number
		{
			return radians * 180/Math.PI;
		}
	}
}