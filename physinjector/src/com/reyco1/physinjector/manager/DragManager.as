package com.reyco1.physinjector.manager
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.data.PhysicsObject;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class DragManager extends EventDispatcher
	{
		private var stage:Stage
		private var mouseXWorldPhys:Number;
		private var mouseYWorldPhys:Number;
		private var mouseJoint:b2MouseJoint;
		private var mousePVec:b2Vec2;
		
		public function DragManager(stage:Stage)
		{
			super();
			this.stage = stage;
			mousePVec = new b2Vec2();
		}
		
		public function startDrag(e:MouseEvent = null):void
		{
			mouseXWorldPhys = stage.mouseX / PhysInjector.RATIO;
			mouseYWorldPhys = stage.mouseY / PhysInjector.RATIO;	
			
			var body:b2Body = getBodyAtMouse();
			
			if( body && PhysicsObject(body.GetUserData() ).physicsProperties.isDraggable ) 
				createMouseJoint( body );
		}
		
		public function stopDrag(e:MouseEvent = null):void
		{
			destroyMouseJoint();
		}
		
		public function update():void
		{
			if(mouseJoint)
			{
				mouseXWorldPhys = stage.mouseX / PhysInjector.RATIO;
				mouseYWorldPhys = stage.mouseY / PhysInjector.RATIO;
				
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				mouseJoint.SetTarget(p2);
			}
		}
		
		private function createMouseJoint(body:b2Body):void
		{
			var md:b2MouseJointDef = new b2MouseJointDef();
			md.bodyA 			   = PhysInjector.WORLD.GetGroundBody();
			md.bodyB 			   = body;
			md.collideConnected    = true;
			md.maxForce 		   = 10000;
			
			md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
			
			mouseJoint = PhysInjector.WORLD.CreateJoint(md) as b2MouseJoint;
			body.SetAwake(true);		
		}
		
		private function destroyMouseJoint():void
		{
			if(mouseJoint)
			{
				PhysInjector.WORLD.DestroyJoint(mouseJoint);	
				mouseJoint = null;	
			}
		}
		
		private function getBodyAtMouse(includeStatic:Boolean = false):b2Body
		{
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			
			var body:b2Body = null;
			var fixture:b2Fixture;
			
			function getBodyCallback(fixture:b2Fixture):Boolean
			{
				var shape:b2Shape = fixture.GetShape();
				
				if (fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic)
				{
					var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(), mousePVec);
					
					if (inside)
					{
						body = fixture.GetBody();
						return false;
					}
				}
				
				return true;
			}
			
			PhysInjector.WORLD.QueryAABB(getBodyCallback, aabb);
			
			return body;
		}
		
		public function destroy():void
		{
			destroyMouseJoint();
			stage = null;
		}
	}
}