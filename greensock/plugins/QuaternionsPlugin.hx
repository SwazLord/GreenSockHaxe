/**
 * VERSION: 12.0.1
 * DATE: 2013-12-26
 * AS3 
 * UPDATES AND DOCS AT: http://www.greensock.com
**/

package com.greensock.plugins;

import com.greensock.TweenLite;

/**
	* [AS3/AS2 only] Performs SLERP interpolation between 2 Quaternions. Each Quaternion should have x, y, z, and w properties.
	* Simply pass in an Object containing properties that correspond to your object's quaternion properties. 
	* For example, if your myCamera3D has an "orientation" property that's a Quaternion and you want to 
	* tween its values to x:1, y:0.5, z:0.25, w:0.5, you could do:<p><code>
	* 
	* 	TweenLite.to(myCamera3D, 2, {quaternions:{orientation:new Quaternion(0, 1, 0, 0)}});</code></p>
	* 	
	* <p>You can define as many quaternion properties as you want.</p>
	* 
	* <p><b>USAGE:</b></p>
	* <listing version="3.0">
	import com.greensock.TweenLite; 
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.QuaternionsPlugin; 
	TweenPlugin.activate([QuaternionsPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

	TweenLite.to(myCamera3D, 2, {quaternions:{orientation:new Quaternion(0, 1, 0, 0)}}); 
	</listing>
	* 
	* <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
	* 
	* @author Jack Doyle, jack@greensock.com
 */
class QuaternionsPlugin extends TweenPlugin {
	/** @private **/
	public static inline var API:Float = 2; // If the API/Framework for plugins changes in the future, this number helps determine compatibility

	/** @private **/
	private static var _RAD2DEG:Float = 180 / Math.PI; // precalculate for speed

	/** @private **/
	private var _target:Dynamic;

	/** @private **/
	private var _quaternions:Array<Dynamic> = [];

	/** @private **/
	public function new() {
		super("quaternions");
		_overwriteProps.pop();
	}

	/** @private **/
	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		if (value == null) {
			return false;
		}
		_target = target;
		for (p in Reflect.fields(value)) {
			_initQuaternion(Reflect.field(value, p), p);
		}
		return true;
	}

	/** @private **/
	public function _initQuaternion(end:Dynamic, p:String):Void {
		var angle:Float;
		var q1:Dynamic;
		var q2:Dynamic;
		var x1:Float;
		var x2:Float;
		var y1:Float;
		var y2:Float;
		var z1:Float;
		var z2:Float;
		var w1:Float;
		var w2:Float;
		var theta:Float;
		var isFunc:Bool = (Std.isOfType(Reflect.field(_target, p), Function));
		q1 = ((!isFunc)) ? Reflect.field(_target,
			p) : Reflect.field(_target, Std.string((((p.indexOf("set")
				|| !(Lambda.has(_target, "get" + p.substr(3))))) ? p : "get" + p.substr(3))))();
		q2 = end;
		x1 = q1.x;
		x2 = q2.x;
		y1 = q1.y;
		y2 = q2.y;
		z1 = q1.z;
		z2 = q2.z;
		w1 = q1.w;
		w2 = q2.w;
		angle = x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2;
		if (angle < 0) {
			x1 *= -1;
			y1 *= -1;
			z1 *= -1;
			w1 *= -1;
			angle *= -1;
		}
		if ((angle + 1) < 0.000001) {
			y2 = -y1;
			x2 = x1;
			w2 = -w1;
			z2 = z1;
		}
		theta = Math.acos(angle);
		_quaternions[_quaternions.length] = [q1, p, x1, x2, y1, y2, z1, z2, w1, w2, angle, theta, 1 / Math.sin(theta), isFunc];
		_overwriteProps[_overwriteProps.length] = p;
	}

	/** @private **/
	override public function _kill(lookup:Dynamic):Bool {
		var i:Int = _quaternions.length;
		while (--i > -1) {
			if (Reflect.field(lookup, Std.string(_quaternions[i][1])) != null) {
				_quaternions.splice(i, 1);
			}
		}
		return super._kill(lookup);
	}

	/** @private **/
	override public function setRatio(v:Float):Void {
		var i:Int = _quaternions.length;
		var q:Array<Dynamic>;
		var scale:Float;
		var invScale:Float;
		while (--i > -1) {
			q = _quaternions[i];
			if ((q[10] + 1) > 0.000001) {
				if ((1 - q[10]) >= 0.000001) {
					scale = Math.sin(q[11] * (1 - v)) * q[12];
					invScale = Math.sin(q[11] * v) * q[12];
				} else {
					scale = 1 - v;
					invScale = v;
				}
			} else {
				scale = Math.sin(Math.PI * (0.5 - v));
				invScale = Math.sin(Math.PI * v);
			}
			q[0].x = scale * q[2] + invScale * q[3];
			q[0].y = scale * q[4] + invScale * q[5];
			q[0].z = scale * q[6] + invScale * q[7];
			q[0].w = scale * q[8] + invScale * q[9];
			if (q[13] != null) {
				Reflect.field(_target, Std.string(q[1]))(q[0]);
			} else {
				Reflect.setField(_target, Std.string(q[1]), q[0]);
			}
		}
	}
}
