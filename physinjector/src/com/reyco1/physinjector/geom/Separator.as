/*
* Convex Separator for Box2D Flash
*
* This class has been written by Antoan Angelov. 
* It is designed to work with Erin Catto's Box2D physics library.
*
* Everybody can use this software for any purpose, under two restrictions:
* 1. You cannot claim that you wrote this software.
* 2. You can not remove or alter this notice.
*
*/

package com.reyco1.physinjector.geom
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2FixtureDef;
	
	public class Separator
	{
		public function Separator() {
		}
		
		/**
		 * Separates a non-convex polygon into convex polygons and adds them as fixtures to the <code>body</code> parameter.<br/>
		 * There are some rules you should follow (otherwise you might get unexpected results) :
		 * <ul>
		 * <li>This class is specifically for non-convex polygons. If you want to create a convex polygon, you don't need to use this class - Box2D's <code>b2PolygonShape</code> class allows you to create convex shapes with the <code>setAsArray()</code>/<code>setAsVector()</code> method.</li>
		 * <li>The vertices must be in clockwise order.</li>
		 * <li>No three neighbouring points should lie on the same line segment.</li>
		 * <li>There must be no overlapping segments and no "holes".</li>
		 * </ul> <p/>
		 * @param body The b2Body, in which the new fixtures will be stored.
		 * @param fixtureDef A b2FixtureDef, containing all the properties (friction, density, etc.) which the new fixtures will inherit.
		 * @param verticesVec The vertices of the non-convex polygon, in clockwise order.
		 * @param scale <code>[optional]</code> The scale which you use to draw shapes in Box2D. The bigger the scale, the better the precision. The default value is 30. 
		 * @see b2PolygonShape
		 * @see b2PolygonShape.SetAsArray()
		 * @see b2PolygonShape.SetAsVector()
		 * @see b2Fixture
		 * */
		
		public function Separate(body:b2Body,fixtureDef:b2FixtureDef,verticesVec:Vector.<b2Vec2>,scale:Number=30):void {
			var i:int,n:int=verticesVec.length,j:int,m:int;
			var vec:Vector.<b2Vec2>=new Vector.<b2Vec2>  ,figsVec:Array;
			var polyShape:b2PolygonShape;
			
			for (i=0; i<n; i++) {
				vec.push(new b2Vec2(verticesVec[i].x*scale,verticesVec[i].y*scale));
			}
			
			figsVec=calcShapes(vec);
			n=figsVec.length;
			
			for (i=0; i<n; i++) {
				verticesVec=new Vector.<b2Vec2>();
				vec=figsVec[i];
				m=vec.length;
				for (j=0; j<m; j++) {
					verticesVec.push(new b2Vec2(vec[j].x/scale,vec[j].y/scale));
				}
				
				polyShape=new b2PolygonShape();
				polyShape.SetAsVector(verticesVec);
				fixtureDef.shape=polyShape;
				body.CreateFixture(fixtureDef);
			}
		}
		
		/**
		 * Checks whether the vertices in <code>verticesVec</code> can be properly distributed into the new fixtures (more specifically, it makes sure there are no overlapping segments and the vertices are in clockwise order). 
		 * It is recommended that you use this method for debugging only, because it may cost more CPU usage.
		 * <p/>
		 * @param verticesVec The vertices to be validated.
		 * @return An integer which can have the following values:
		 * <ul>
		 * <li>0 if the vertices can be properly processed.</li>
		 * <li>1 If there are overlapping lines.</li>
		 * <li>2 if the points are <b>not</b> in clockwise order.</li>
		 * <li>3 if there are overlapping lines <b>and</b> the points are <b>not</b> in clockwise order.</li>
		 * </ul> 
		 * */
		
		public function Validate(verticesVec:Vector.<b2Vec2>):int {
			var i:int,n:int=verticesVec.length,j:int,j2:int,i2:int,i3:int,d:Number,ret:int=0;
			var fl:Boolean,fl2:Boolean=false;
			
			for (i=0; i<n; i++) {
				i2=(i<n-1)?i+1:0;
				i3=(i>0)?i-1:n-1;
				
				fl=false;
				for (j=0; j<n; j++) {
					if (((j!=i)&&j!=i2)) {
						if (! fl) {
							d=det(verticesVec[i].x,verticesVec[i].y,verticesVec[i2].x,verticesVec[i2].y,verticesVec[j].x,verticesVec[j].y);
							if ((d>0)) {
								fl=true;
							}
						}
						
						if ((j!=i3)) {
							j2=(j<n-1)?j+1:0;
							if (hitSegment(verticesVec[i].x,verticesVec[i].y,verticesVec[i2].x,verticesVec[i2].y,verticesVec[j].x,verticesVec[j].y,verticesVec[j2].x,verticesVec[j2].y)) {
								ret=1;
							}
						}
					}
				}
				
				if (! fl) {
					fl2=true;
				}
			}
			
			if (fl2) {
				if ((ret==1)) {
					ret=3;
				}
				else {
					ret=2;
				}
				
			}
			return ret;
		}
		
		private function calcShapes(verticesVec:Vector.<b2Vec2>):Array {
			var vec:Vector.<b2Vec2>;
			var i:int,n:int,j:int;
			var d:Number,t:Number,dx:Number,dy:Number,minLen:Number;
			var i1:int,i2:int,i3:int,p1:b2Vec2,p2:b2Vec2,p3:b2Vec2;
			var j1:int,j2:int,v1:b2Vec2,v2:b2Vec2,k:int,h:int;
			var vec1:Vector.<b2Vec2>,vec2:Vector.<b2Vec2>;
			var v:b2Vec2,hitV:b2Vec2;
			var isConvex:Boolean;
			var figsVec:Array=[],queue:Array=[];
			
			queue.push(verticesVec);
			
			while (queue.length) {
				vec=queue[0];
				n=vec.length;
				isConvex=true;
				
				for (i=0; i<n; i++) {
					i1=i;
					i2=(i<n-1)?i+1:i+1-n;
					i3=(i<n-2)?i+2:i+2-n;
					
					p1=vec[i1];
					p2=vec[i2];
					p3=vec[i3];
					
					d=det(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y);
					if ((d<0)) {
						isConvex=false;
						minLen=Number.MAX_VALUE;
						
						for (j=0; j<n; j++) {
							if (((j!=i1)&&j!=i2)) {
								j1=j;
								j2=(j<n-1)?j+1:0;
								
								v1=vec[j1];
								v2=vec[j2];
								
								v=hitRay(p1.x,p1.y,p2.x,p2.y,v1.x,v1.y,v2.x,v2.y);
								
								if (v) {
									dx=p2.x-v.x;
									dy=p2.y-v.y;
									t=dx*dx+dy*dy;
									
									if ((t<minLen)) {
										h=j1;
										k=j2;
										hitV=v;
										minLen=t;
									}
								}
							}
						}
						
						if ((minLen==Number.MAX_VALUE)) {
							err();
						}
						
						vec1=new Vector.<b2Vec2>  ;
						vec2=new Vector.<b2Vec2>  ;
						
						j1=h;
						j2=k;
						v1=vec[j1];
						v2=vec[j2];
						
						if (! pointsMatch(hitV.x,hitV.y,v2.x,v2.y)) {
							vec1.push(hitV);
						}
						if (! pointsMatch(hitV.x,hitV.y,v1.x,v1.y)) {
							vec2.push(hitV);
						}
						
						h=-1;
						k=i1;
						while (true) {
							if ((k!=j2)) {
								vec1.push(vec[k]);
							}
							else {
								if (((h<0)||h>=n)) {
									err();
								}
								if (! this.isOnSegment(v2.x,v2.y,vec[h].x,vec[h].y,p1.x,p1.y)) {
									vec1.push(vec[k]);
								}
								break;
							}
							
							h=k;
							if (((k-1)<0)) {
								k=n-1;
							}
							else {
								k--;
							}
						}
						
						vec1=vec1.reverse();
						
						h=-1;
						k=i2;
						while (true) {
							if ((k!=j1)) {
								vec2.push(vec[k]);
							}
							else {
								if (((h<0)||h>=n)) {
									err();
								}
								if (((k==j1)&&! this.isOnSegment(v1.x,v1.y,vec[h].x,vec[h].y,p2.x,p2.y))) {
									vec2.push(vec[k]);
								}
								break;
							}
							
							h=k;
							if (((k+1)>n-1)) {
								k=0;
							}
							else {
								k++;
							}
						}
						
						queue.push(vec1,vec2);
						queue.shift();
						
						break;
					}
				}
				
				if (isConvex) {
					figsVec.push(queue.shift());
				}
			}
			
			return figsVec;
		}
		
		private function hitRay(x1:Number,y1:Number,x2:Number,y2:Number,x3:Number,y3:Number,x4:Number,y4:Number):b2Vec2 {
			var t1:Number=x3-x1,t2:Number=y3-y1,t3:Number=x2-x1,t4:Number=y2-y1,t5:Number=x4-x3,t6:Number=y4-y3,t7:Number=t4*t5-t3*t6,a:Number;
			
			a=(((t5*t2)-t6*t1)/t7);
			var px:Number=x1+a*t3,py:Number=y1+a*t4;
			var b1:Boolean=isOnSegment(x2,y2,x1,y1,px,py);
			var b2:Boolean=isOnSegment(px,py,x3,y3,x4,y4);
			
			if ((b1&&b2)) {
				return new b2Vec2(px,py);
			}
			
			return null;
		}
		
		private function hitSegment(x1:Number,y1:Number,x2:Number,y2:Number,x3:Number,y3:Number,x4:Number,y4:Number):b2Vec2 {
			var t1:Number=x3-x1,t2:Number=y3-y1,t3:Number=x2-x1,t4:Number=y2-y1,t5:Number=x4-x3,t6:Number=y4-y3,t7:Number=t4*t5-t3*t6,a:Number;
			
			a=(((t5*t2)-t6*t1)/t7);
			var px:Number=x1+a*t3,py:Number=y1+a*t4;
			var b1:Boolean=isOnSegment(px,py,x1,y1,x2,y2);
			var b2:Boolean=isOnSegment(px,py,x3,y3,x4,y4);
			
			if ((b1&&b2)) {
				return new b2Vec2(px,py);
			}
			
			return null;
		}
		
		private function isOnSegment(px:Number,py:Number,x1:Number,y1:Number,x2:Number,y2:Number):Boolean {
			var b1:Boolean=((((x1+0.1)>=px)&&px>=x2-0.1)||(((x1-0.1)<=px)&&px<=x2+0.1));
			var b2:Boolean=((((y1+0.1)>=py)&&py>=y2-0.1)||(((y1-0.1)<=py)&&py<=y2+0.1));
			return ((b1&&b2)&&isOnLine(px,py,x1,y1,x2,y2));
		}
		
		private function pointsMatch(x1:Number,y1:Number,x2:Number,y2:Number):Boolean {
			var dx:Number=(x2>=x1)?x2-x1:x1-x2,dy:Number=(y2>=y1)?y2-y1:y1-y2;
			return ((dx<0.1)&&dy<0.1);
		}
		
		private function isOnLine(px:Number,py:Number,x1:Number,y1:Number,x2:Number,y2:Number):Boolean {
			if ((((x2-x1)>0.1)||x1-x2>0.1)) {
				var a:Number=(y2-y1)/(x2-x1),possibleY:Number=a*(px-x1)+y1,diff:Number=(possibleY>py)?possibleY-py:py-possibleY;
				return (diff<0.1);
			}
			
			return (((px-x1)<0.1)||x1-px<0.1);
		}
		
		private function det(x1:Number,y1:Number,x2:Number,y2:Number,x3:Number,y3:Number):Number {
			return x1*y2+x2*y3+x3*y1-y1*x2-y2*x3-y3*x1;
		}
		
		private function err():void {
			throw new Error("A problem has occurred. Use the Validate() method to see where the problem is.");
		}
	}
}