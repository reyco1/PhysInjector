package com.reyco1.physinjector.plugins
{
	import Box2D.Collision.b2Distance;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	
	import com.reyco1.physinjector.PhysInjector;
	
	public class Implosion
	{
		private var injector:PhysInjector;
		
		public function Implosion(injector:PhysInjector)
		{
			this.injector = injector;
		}
		
		public function initialize(x:Number, y:Number, coverage:Number = 200, impulseForce:Number = 30):void
		{
			for (var a:int = 0; a < injector.bodies.length; a++) 
			{
				var impOrigen:b2Vec2 = new b2Vec2(x/PhysInjector.RATIO, y/PhysInjector.RATIO);
				var bodyPosition:b2Vec2 = injector.bodies[a].GetPosition();
				
				var maxDistance:Number = coverage / PhysInjector.RATIO;
				var maxForce:int = impulseForce;
				var distance:Number;
				var strength:Number;
				var force:Number;
				var angle:Number;
				
				distance = b2Math.Distance(bodyPosition, impOrigen);
				
				if(distance > maxDistance) 
					distance = maxDistance - 0.01;
				
				strength = (maxDistance - distance) / maxDistance;
				force 	 = strength * maxForce;
				angle 	 = Math.atan2(impOrigen.y - bodyPosition.y, impOrigen.x - bodyPosition.x);
				
				var impulse:b2Vec2 = new b2Vec2( Math.cos(angle) * force, Math.sin(angle) * force);
				injector.bodies[a].ApplyImpulse(impulse, injector.bodies[a].GetPosition());
			}			
		}
		
		public function dispose():void
		{
			injector = null;
		}
	}
}