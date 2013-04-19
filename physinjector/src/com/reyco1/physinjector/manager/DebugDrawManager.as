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
	import Box2D.Dynamics.b2DebugDraw;
	
	import com.reyco1.physinjector.PhysInjector;
	
	import flash.display.Sprite;

	public class DebugDrawManager
	{
		public var debugSprite:Sprite
		public static var DEBUG_DRAW:b2DebugDraw;
		
		public function DebugDrawManager(drawContainer:Sprite, fillAlpha:Number = 0.5, lineThickness:Number = 1)
		{
			DEBUG_DRAW = new b2DebugDraw();
			DEBUG_DRAW.SetSprite(drawContainer);
			DEBUG_DRAW.SetDrawScale(PhysInjector.WORLD_SCALE);
			DEBUG_DRAW.SetFillAlpha(fillAlpha);
			DEBUG_DRAW.SetLineThickness(lineThickness);
			DEBUG_DRAW.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit); // | b2DebugDraw.e_centerOfMassBit
			PhysInjector.WORLD.SetDebugDraw(DEBUG_DRAW);
			
			debugSprite = drawContainer;
			
			debugSprite.mouseEnabled = debugSprite.mouseChildren = false;
		}
		
		public function update():void
		{
			PhysInjector.WORLD.DrawDebugData();
			debugSprite.parent.setChildIndex(debugSprite, debugSprite.parent.numChildren-1);
		}
		
		public function dispose():void
		{
			debugSprite.parent.removeChild(debugSprite);
			debugSprite = null;
		}
	}
}