package com.reyco1.physinjector
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import com.reyco1.physinjector.data.PhysicsObject;
	import com.reyco1.physinjector.data.PhysicsProperties;
	
	import flash.display.Stage;
	
	public class StarlingPhysInjector extends PhysInjector
	{
		public function StarlingPhysInjector(stage:Stage, gravity:b2Vec2=null, draggingAllowed:Boolean=false, debugDraw:*=null)
		{
			super(stage, gravity, draggingAllowed, debugDraw);
		}
		
		override public function updateBody(bb:b2Body):void
		{
			var sprite:*  = getDisplayObject( bb );
			var newX:Number 		= bb.GetPosition().x * PhysInjector.RATIO;
			var newY:Number 		= bb.GetPosition().y * PhysInjector.RATIO;
			var newRotation:Number 	= bb.GetAngle();
			
			sprite.x = newX;
			sprite.y = newY;
			sprite.rotation = newRotation;
		}
		
		override public function injectPhysics(displayObj:*, type:int, properties:PhysicsProperties = null):PhysicsObject
		{
			var b:b2Body;
			var currentRotation:Number;
			
			if(properties == null)
				properties = new PhysicsProperties();
			
			switch(type)
			{
				case CIRCLE:
				{
					b = createCircle
						(
							displayObj.x, 
							displayObj.y, 
							displayObj.width * 0.5, 
							properties
						);
					break;
				}
					
				case SQUARE:
				{
					currentRotation 	= displayObj.rotation;
					displayObj.rotation = 0;					
					properties.angle 	= currentRotation;
					
					b = createSquare
						(						
							displayObj.x, 
							displayObj.y,
							displayObj.width, 
							displayObj.height, 
							properties
						);
					break;
				}
					
				case POLYGON:
				{
					currentRotation 	= displayObj.rotation;
					displayObj.rotation = 0;					
					properties.angle 	= currentRotation;
					
					b = createPolygon
						( 
							displayObj.x, 
							displayObj.x,
							properties.vertices, 
							properties 
						);
					
					break;
				}
					
				default:
				{
					break;
				}
			}
			
			var po:PhysicsObject = new PhysicsObject(b, displayObj, properties)
			po.offsetX = 0;
			po.offsetY = 0;
			po.name	   = displayObj.name;
			
			b.SetUserData( po );
			bodyHash[ displayObj ] = b;
			updateBody( b );
			
			return po;
		}
	}
}