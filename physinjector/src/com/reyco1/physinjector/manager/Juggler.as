package com.reyco1.physinjector.manager
{
	public class Juggler
	{
		private var subscribers:Vector.<Object> = new <Object>[];
		
		public function Juggler():void
		{
			
		}
		
		public function subscribe(callback:Function):void 
		{
			if (subscribers.length > 0) 
			{
				for (var i:int = 0; i < subscribers.length; i++) 
				{
					var object:Object = subscribers[i];
					
					if (object.callback == callback) 
					{
						object.subscribed = true;
						break;
					}
					else if (i == subscribers.length - 1) 
					{
						subscribers.push( { callback:callback, subscribed:true } );
					}
				}
			}
			else 
			{
				subscribers.push( { callback:callback, subscribed:true } );
			}
		}
		
		public function unsubscribe(callback:Function):void 
		{
			for each (var object:Object in subscribers) 
			{
				if (object.callback == callback) 
				{
					object.subscribed = false;
					break;
				}
			}
		}
		
		public function update():void
		{
			var object:Object;
			
			for each (object in subscribers) 
			{
				if (object.subscribed) 
				{
					object.callback();
				}
			}
			
			for (var i:int = subscribers.length - 1; i >= 0; i--) 
			{
				object = subscribers[i];
				
				if (!object.subscribed) 
				{
					subscribers.splice(i, 1);
				}
			}
		}
	}
}