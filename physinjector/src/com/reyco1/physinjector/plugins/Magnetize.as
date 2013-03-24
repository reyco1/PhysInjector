package com.reyco1.physinjector.plugins
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import com.reyco1.physinjector.PhysInjector;

	public class Magnetize
	{
		private var injector:PhysInjector;
		private var subscribers:Vector.<b2Body>;
		private var mainBody:b2Body;
		private var intensity:Number;
		private var _active:Boolean;
		private var coverage:Number;
		
		public function Magnetize(displayObject:*, injector:PhysInjector, intensity:Number = 5, coverage:Number = 100)
		{
			this.injector 	= injector;
			this.intensity	= intensity;
			this.coverage	= coverage / PhysInjector.RATIO;
			subscribers 	= new Vector.<b2Body>();
			mainBody 		= injector.getBody( displayObject );			
			
			injector.juggler.subscribe( update );
		}
		
		public function subscribe(displayObject:*):void
		{
			if( subscribers.indexOf(injector.getBody(displayObject)) == -1 )
				subscribers.push( injector.getBody(displayObject) );
		}
		
		public function unsubscribe(displayObject:*):void
		{
			if( subscribers.indexOf(injector.getBody(displayObject)) != -1 )
				subscribers.splice( subscribers.indexOf(injector.getBody(displayObject)), 1 );
		}
		
		private function update():void
		{
			if(_active)
			{
				var mainBodyOrigen:b2Vec2 = mainBody.GetPosition();
				for (var a:int = 0; a < subscribers.length; a++) 
				{
					if(subscribers[a] == null)
					{
						subscribers.splice(a, 1);
						break;
					}
					
					var bodyPosition:b2Vec2 = subscribers[a].GetPosition();
					var distance:Number 	= b2Math.Distance(bodyPosition, mainBodyOrigen);
					
					if(distance < coverage)
					{
						var angle:Number 		= Math.atan2(mainBodyOrigen.y - bodyPosition.y, mainBodyOrigen.x - bodyPosition.x);
						var currVel:b2Vec2 		= subscribers[a].GetLinearVelocity();
						var dir:b2Vec2			= new b2Vec2();
						
						dir.x = currVel.x + intensity * Math.cos(angle);
						dir.y = currVel.y + intensity * Math.sin(angle);
						
						subscribers[a].SetLinearVelocity(dir);
					}
				}		
			}
		}
		
		public function dispose():void
		{
			injector.juggler.unsubscribe( update );
			injector 	= null;
			subscribers = null;
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
		}

	}
}