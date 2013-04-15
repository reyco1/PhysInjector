package com.reyco1.physinjector.engines.sliceengine
{
	import Box2D.Common.Math.b2Vec2;
	
	import flash.display.Bitmap;

	public class SliceData
	{
		public var vertices:Vector.<b2Vec2>;
		public var texture:Bitmap;
		public var entryPoint:b2Vec2;
		public var exitPoint:b2Vec2;
		
		public function SliceData(vertices:Vector.<b2Vec2> = null, texture:Bitmap = null)
		{
			this.vertices = vertices;
			this.texture  = texture;
		}
	}
}