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
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.manager.Utils;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class DynamicRegistration
	{
			
		public static function move(target:*, registration:Point, x:Number = 0, y:Number = 0):void
		{
			registration = target.localToGlobal(registration);
			
			target.x += x - registration.x;
			target.y += y - registration.y;
		}
		
		public static function rotate(target:*, registration:Point, degrees:Number = 0):void
		{
			changePropertyOnRegistrationPoint(target, registration, "rotation", degrees);
		}
		
		public static function changePropertyOnRegistrationPoint(target:*, registration:Point, propertyName:String, value:Number):void
		{
			var a:Point = registration.clone();
			a = target.localToGlobal(a);
			a = target.parent.globalToLocal(a);
			
			if(PhysInjector.STARLING && propertyName == "rotation")
				target[propertyName] = Utils.degreesToRadians(value);
			else
				target[propertyName] = value;
			
			var b:Point = registration.clone();
			b = target.localToGlobal(b);
			b = target.parent.globalToLocal(b);
			
			target.x -= b.x - a.x;
			target.y -= b.y - a.y;
		}
		
		public static function getRegistrationOffset(target:*, pnt:Point):Point
		{
			var b1Bounds:Rectangle = PhysInjector.STARLING ? target.getBounds(target.parent) : target.getRect(target.parent);
			var regPoint:Point = new Point();			
			
			if(PhysInjector.STARLING)
			{
				regPoint = new Point((b1Bounds.x - target.x) + target.pivotX + b1Bounds.width * pnt.x, (b1Bounds.y - target.y) + target.pivotY + b1Bounds.height * pnt.y);
			}
			else
			{
				regPoint = new Point((b1Bounds.x - target.x) + b1Bounds.width * pnt.x, (b1Bounds.y - target.y) + b1Bounds.height * pnt.y);
			}			
			
			return regPoint;
		}
		
		public static function getGlobalDisplayObjectCenter(target:*):Point
		{
			var offset:Point = getRegistrationOffset(target, new Point(0.5, 0.5));
			var globalPoint:Point = target.parent.localToGlobal(new Point(target.x + offset.x, target.y + offset.y));
			
			return globalPoint;
		}
	
	}
}
