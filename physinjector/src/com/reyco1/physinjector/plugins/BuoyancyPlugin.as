// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.reyco1.physinjector.plugins
{
	import Box2D.Dynamics.Controllers.b2BuoyancyController;
	import Box2D.Dynamics.Controllers.b2ControllerEdge;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.PhysicsObject;
	import com.reyco1.physinjector.manager.DebugDrawManager;
	import com.reyco1.physinjector.manager.Utils;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BuoyancyPlugin
	{
		private var injector:PhysInjector;
		private var displayObject:*;
		public  var globalb2Rect:Rectangle;
		public  var globalRect:Rectangle;
		private var buoyancyController:b2BuoyancyController;
		
		private var _active:Boolean;
		private var _useDensity:Boolean;
		private var _density:Number;
		private var _linearDrag:Number;
		private var _angularDrag:Number;
		
		public function BuoyancyPlugin(displayObject:*, injector:PhysInjector, linearDrag:Number = 5.0, angularDrag:Number = 2.0, density:Number = 2.0, useDensity:Boolean = true)
		{
			this.injector 		= injector;
			this.displayObject 	= displayObject;
			_useDensity			= true;
			_active				= true;
			
			invalidateRects();
			
			buoyancyController = new b2BuoyancyController();	
			buoyancyController.normal.Set(0,-1);
			buoyancyController.useDensity  = _useDensity  = useDensity;
			buoyancyController.linearDrag  = _linearDrag  = linearDrag;
			buoyancyController.angularDrag = _angularDrag = angularDrag;
			
			if(useDensity)
				buoyancyController.density = _density = density;
			
			PhysInjector.WORLD.AddController(buoyancyController);
			
			injector.juggler.subscribe( update );
		}
		
		public function update():void
		{
			if(_active)
			{
				invalidateRects();
				
				buoyancyController.offset = -globalb2Rect.y;
				
				var currentBodyControllers:b2ControllerEdge;
				var tempObject:PhysicsObject;
				var tempDispObj:*;
				
				for (var a:int = 0; a < injector.bodies.length; a++) 
				{
					currentBodyControllers = injector.bodies[a].GetControllerList();
					if (currentBodyControllers != null) 
					{
						buoyancyController.RemoveBody( injector.bodies[a] );
					}
					
					tempObject  = PhysicsObject( injector.bodies[a].GetUserData() );
					tempDispObj = tempObject.displayObject;
					
					if( Utils.pointIsWithinRectangle(tempObject.getDisplayObjectCenterPoint(), globalRect) )
					{
						buoyancyController.AddBody( injector.bodies[a] );
					}
				}
				
				tempObject  = null;
				tempDispObj = null;	
				currentBodyControllers = null;
			}
			
			//buoyancyController.Draw( DebugDrawManager.DEBUG_DRAW );
		}
		
		private function invalidateRects():void
		{
			var localRect:Rectangle = displayObject.getBounds(displayObject.parent);
			var globalPos:Point 	= displayObject.parent.localToGlobal(new Point(localRect.x, localRect.y));
			
			globalb2Rect = new Rectangle(globalPos.x / PhysInjector.WORLD_SCALE, globalPos.y / PhysInjector.WORLD_SCALE, 
				localRect.width  / PhysInjector.WORLD_SCALE, localRect.height / PhysInjector.WORLD_SCALE);
			
			globalRect = new Rectangle(globalPos.x, globalPos.y, localRect.width, localRect.height);
		}		
		
		public function dispose():void
		{
			injector.juggler.unsubscribe( update );
			
			for (var a:int = 0; a < injector.bodies.length; a++) 
			{
				var currentBodyControllers:b2ControllerEdge = injector.bodies[a].GetControllerList();
				if (currentBodyControllers != null) 
				{
					buoyancyController.RemoveBody( injector.bodies[a] );
				}
			}
			
			PhysInjector.WORLD.RemoveController(buoyancyController);
			
			buoyancyController.Clear();
			
			buoyancyController = null;
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
		}

		public function get useDensity():Boolean
		{
			return _useDensity;
		}

		public function set useDensity(value:Boolean):void
		{
			_useDensity = value;
			buoyancyController.useDensity = value;
		}

		public function get density():Number
		{
			return _density;
		}

		public function set density(value:Number):void
		{
			_density = value;
			buoyancyController.density = value;
		}

		public function get linearDrag():Number
		{
			return _linearDrag;
		}

		public function set linearDrag(value:Number):void
		{
			_linearDrag = value;
			buoyancyController.linearDrag = value;
		}

		public function get angularDrag():Number
		{
			return _angularDrag;
		}

		public function set angularDrag(value:Number):void
		{
			_angularDrag = value;
			buoyancyController.angularDrag = value;
		}


	}
}