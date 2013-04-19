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
	import com.reyco1.physinjector.events.EaseEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class EaseManager extends EventDispatcher
	{
		private static var mainTimer:Timer = new Timer(10);
		
		private var duration:Number;
		private var startProps:Object;
		private var _endProps:Object;
		private var startTime:int;
		private var active:Boolean;
		private var ranges:Object;
		
		public function EaseManager(duration:Number, start:Object, end:Object, autoStart:Boolean = true)
		{
			this.duration 	= duration;
			this.startProps = start;
			this.endProps   = end;
			
			if(autoStart)
				startEase();
		}
		
		public function startEase():void
		{
			mainTimer.addEventListener(TimerEvent.TIMER, runtimeHandler, false, 0, true);
			if(!mainTimer.running)
				mainTimer.start();
			
			startTime = getTimer();
			active = true;
			
			dispatchEvent(new EaseEvent(EaseEvent.START,  startProps));
			dispatchEvent(new EaseEvent(EaseEvent.UPDATE, startProps));
		}
		
		protected function runtimeHandler(event:TimerEvent):void
		{
			var currentRuntime:int = getTimer() - startTime;
			
			if(currentRuntime >= duration)
			{
				end();
				return;
			}
			
			dispatchEvent(new EaseEvent(EaseEvent.UPDATE, update(currentRuntime)));
		}
		
		public function end():void
		{
			mainTimer.removeEventListener(TimerEvent.TIMER, runtimeHandler);
			if(!mainTimer.hasEventListener(TimerEvent.TIMER))
				mainTimer.stop();
			
			active = false;
			dispatchEvent(new EaseEvent(EaseEvent.COMPLETE, endProps));
		}
		
		private function update(runtime:int):Object
		{
			var updated:Object;
			
			if(startProps is Array)
				updated = [];
			else
				updated = {};
			
			for(var prop:String in ranges)
			{
				var startValue:Number = startProps[prop] as Number;
				var range:Number 	  = ranges[prop];
				updated[prop] 		  = easingFunction(runtime, startValue, range, duration);
			}
			
			return updated;
		}
		
		protected function get endProps():Object
		{
			return _endProps;
		}
		
		protected function set endProps(value:Object):void
		{
			ranges = {};
			for(var prop:String in value)
			{
				var startValue:Number = Number(startProps[prop]);
				var endValue:Number   = Number(value[prop]);
				var range:Number 	  = endValue - startValue;
				ranges[prop] = range;
			}
			_endProps = value;
		}
		
		private var easingFunction:Function = function(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * t / d + b;
		}
	}
}