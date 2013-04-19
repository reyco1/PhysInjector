// =================================================================================================
//
//	PhysInjector
//	Copyright 2013 ReycoGames All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.reyco1.physinjector.events
{
	import flash.events.Event;
	
	public class EaseEvent extends Event
	{
		public static const START:String    = "EaseEvent.START";
		public static const UPDATE:String   = "EaseEvent.UPDATE";
		public static const COMPLETE:String = "EaseEvent.COMPLETE";
		
		public var details:Object;
		
		public function EaseEvent(type:String, details:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.details = details;
			super(type, bubbles, cancelable);
		}
	}
}