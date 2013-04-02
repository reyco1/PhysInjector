package com.reyco1.physinjector.manager
{
	import Box2D.Dynamics.b2DebugDraw;
	
	import com.reyco1.physinjector.PhysInjector;
	
	import flash.display.Sprite;

	public class DebugDrawManager
	{
		public var debugSprite:Sprite
		
		public function DebugDrawManager(drawContainer:Sprite, fillAlpha:Number = 0.5, lineThickness:Number = 1)
		{
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			dbgDraw.SetSprite(drawContainer);
			dbgDraw.SetDrawScale(PhysInjector.WORLD_SCALE);
			dbgDraw.SetFillAlpha(fillAlpha);
			dbgDraw.SetLineThickness(lineThickness);
			dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit); // | b2DebugDraw.e_centerOfMassBit
			PhysInjector.WORLD.SetDebugDraw(dbgDraw);
			
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