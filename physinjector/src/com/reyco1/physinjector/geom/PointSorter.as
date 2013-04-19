// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.reyco1.physinjector.geom
{
	import Box2D.Common.Math.b2Vec2;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.manager.Utils;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class PointSorter
	{
		private static var center:Point;
		private static var points:Dictionary = new Dictionary();		
		
		public static function arrangeClockwise(vec:Vector.<b2Vec2>):Vector.<b2Vec2>
		{
			var n:int  = vec.length;
			var i1:int = 1;
			var i2:int = n-1;
			var d:Number;
			
			var tempVec:Vector.<b2Vec2> = new Vector.<b2Vec2>(n);
			var C:b2Vec2;
			var D:b2Vec2;
			
			vec.sort(comp1);			
			
			tempVec[0] 	= vec[0];
			C 			= vec[0];
			D 			= vec[n-1];
			
			for(var i:int = 1; i<n-1; i++)
			{
				d = det(C.x, C.y, D.x, D.y, vec[i].x, vec[i].y);
				if(d<0) 
					tempVec[i1++] = vec[i];
				else 
					tempVec[i2--] = vec[i];
			}
			
			tempVec[i1] = vec[n-1];
			
			return tempVec;
		}
		
		public static function parse(array:Array, id:String):Vector.<b2Vec2>
		{
			if(points[id])
				return points[id];
			
			array = sort( array );
			
			points[id] = new Vector.<b2Vec2>();
			for (var a:int = 0; a < array.length; a++) 
			{
				points[id].push(new b2Vec2(array[a].x / PhysInjector.WORLD_SCALE, array[a].y / PhysInjector.WORLD_SCALE));
			}
			return points[id];
		}
		
		public static function comp1(a:b2Vec2, b:b2Vec2):Number
		{
			if(a.x>b.x) 
				return 1;
			else if(a.x<b.x) 
				return -1;			
			return 0;
		}
		
		public static function det(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number):Number
		{
			return x1*y2+x2*y3+x3*y1-y1*x2-y2*x3-y3*x1;   
		}
		
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
		
		public static function getMidpoint(groupArrayOrVetor:*):Point
		{
			var p:Point = new Point();
			var globalEquivalent:Object;
			var tempX:Number = 0;
			var tempY:Number = 0;
			
			for(var a:int = 0; a<groupArrayOrVetor.length; a++)
			{
				globalEquivalent = {x:groupArrayOrVetor[a].x, y:groupArrayOrVetor[a].y};
				tempX += globalEquivalent.x;
				tempY += globalEquivalent.y;
			}
			
			p.x = tempX / groupArrayOrVetor.length;
			p.y = tempY / groupArrayOrVetor.length;			
			
			return p;
		}
		
		public static function getRadian (x2:Number, y2:Number, center:Object):Number
		{
			var dx:Number = center.x - x2;
			var dy:Number = center.y - y2;
			return Utils.radiansToDegrees(Math.atan2(dy,dx));
		}
	}
}