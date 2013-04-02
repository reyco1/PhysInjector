package com.reyco1.physinjector
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import flash.display.Stage;
	
	public class StarlingPhysInjector extends PhysInjector
	{
		public function StarlingPhysInjector(stage:Stage, gravity:b2Vec2=null, draggingAllowed:Boolean=false, debugDraw:*=null)
		{
			super(stage, gravity, draggingAllowed, debugDraw);
		}
		
		override public function updateDisplayObjectPosition(bb:b2Body):void
		{
			var sprite:*  			= getDisplayObject( bb );
			var newX:Number 		= bb.GetPosition().x * PhysInjector.WORLD_SCALE;
			var newY:Number 		= bb.GetPosition().y * PhysInjector.WORLD_SCALE;
			var newRotation:Number 	= bb.GetAngle();
			
			sprite.x = newX;
			sprite.y = newY;
			sprite.rotation = newRotation;
		}
	}
}