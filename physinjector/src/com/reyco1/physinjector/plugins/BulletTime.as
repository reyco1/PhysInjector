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
	import com.reyco1.physinjector.data.WorldVariables;
	import com.reyco1.physinjector.events.EaseEvent;
	import com.reyco1.physinjector.manager.EaseManager;

	public class BulletTime
	{
		private var easeManager:EaseManager;
		
		public function BulletTime():void{}
		
		public function applyBulletTime(amount:Number, duration:Number = 1):void
		{
			if(easeManager)
				complete();
			
			easeManager = new EaseManager(duration * 1000, {bulletTime:WorldVariables.BULLET_TIME_FACTOR}, {bulletTime:amount});
			easeManager.addEventListener( EaseEvent.UPDATE, update );
			easeManager.addEventListener( EaseEvent.COMPLETE, complete );
		}
		
		public function removeBulletTime(duration:Number = 1):void
		{
			applyBulletTime(1, duration);
		}
		
		public function dispose():void
		{
			complete();
			WorldVariables.BULLET_TIME_FACTOR = 1;
		}
		
		protected function update(event:EaseEvent):void
		{
			WorldVariables.BULLET_TIME_FACTOR = event.details.bulletTime < 1 ? 1 : event.details.bulletTime;
			WorldVariables.BULLET_TIME_FACTOR = event.details.bulletTime > 100 ? 100 : event.details.bulletTime;
		}
		
		protected function complete(event:EaseEvent = null):void
		{
			if(easeManager)
			{
				easeManager.removeEventListener( EaseEvent.UPDATE, update );
				easeManager.removeEventListener( EaseEvent.COMPLETE, complete );
				easeManager.end();		
				easeManager = null;
			}
		}
	}
}