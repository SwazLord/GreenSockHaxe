/**
 * VERSION: 12.0
 * DATE: 2012-02-14
 * Haxe
 * UPDATES AND DOCS AT: http://www.greensock.com
**/

package com.greensock.plugins;

import com.greensock.TweenLite;

/**
 * To tween any rotation property of the target object in the shortest direction, use "shortRotation" 
 * For example, if `myObject.rotation` is currently 170 degrees and you want to tween it to -170 degrees, 
 * a normal rotation tween would travel a total of 340 degrees in the counter-clockwise direction, 
 * but if you use shortRotation, it would travel 20 degrees in the clockwise direction instead. You 
 * can define any number of rotation properties in the shortRotation object which makes 3D tweening
 * easier, like:
 * 
 * ```haxe
 * TweenMax.to(mc, 2, {shortRotation:{rotationX:-170, rotationY:35, rotationZ:200}});
 * ```
 * 
 * Normally shortRotation is defined in degrees, but if you prefer to have it work with radians instead,
 * simply set the `useRadians` special property to `true` like:
 * 
 * ```haxe
 * TweenMax.to(myCustomObject, 2, {shortRotation:{customRotationProperty:Math.PI, useRadians:true}});
 * ```
 * 
 * USAGE:
 * ```haxe
 * import com.greensock.TweenLite; 
 * import com.greensock.plugins.TweenPlugin; 
 * import com.greensock.plugins.ShortRotationPlugin; 
 * TweenPlugin.activate([ShortRotationPlugin]); //activation is permanent, so this line only needs to be run once.
 * 
 * TweenLite.to(mc, 1, {shortRotation:{rotation:-170}});
 *
 * //or for a 3D tween with multiple rotation values...
 * TweenLite.to(mc, 1, {shortRotation:{rotationX:-170, rotationY:35, rotationZ:10}}); 
 * ```
 * 
 * Copyright 2008-2014, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html or for Club GreenSock members, the software agreement that was issued with the membership.
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class ShortRotationPlugin extends TweenPlugin {
	/** If the API/Framework for plugins changes in the future, this number helps determine compatibility */
	public static inline var API:Float = 2;

	/** @private */
	public function new() {
		super("shortRotation");
		_overwriteProps.pop();
	}

	/** @private */
	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		if (Std.isOfType(value, Float)) {
			return false;
		}

		var useRadians:Bool = value.useRadians == true;
		var start:Float;

		for (p in Reflect.fields(value)) {
			if (p != "useRadians") {
				if (Reflect.isFunction(Reflect.field(target, p))) {
					// Check if getter method exists
					var getterMethod = p;
					if (p.indexOf("set") == 0 || !Reflect.hasField(target, "get" + p.substr(3))) {
						// Use the original method
					} else {
						// Use the getter method
						getterMethod = "get" + p.substr(3);
					}
					start = Reflect.callMethod(target, Reflect.field(target, getterMethod), []);
				} else {
					start = Reflect.field(target, p);
				}

				var endValue = Reflect.field(value, p);
				var end:Float;

				if (Std.isOfType(endValue, Float)) {
					end = endValue;
				} else {
					// Handle string values with relative notation (e.g., "+=90")
					var strValue:String = Std.string(endValue);
					end = start + Std.parseFloat(StringTools.replace(strValue, "=", ""));
				}

				_initRotation(target, p, start, end, useRadians);
			}
		}

		return true;
	}

	/** @private */
	public function _initRotation(target:Dynamic, p:String, start:Float, end:Float, useRadians:Bool = false):Void {
		var cap:Float = useRadians ? Math.PI * 2 : 360;
		var dif:Float = (end - start) % cap;

		if (dif != dif % (cap / 2)) {
			dif = (dif < 0) ? dif + cap : dif - cap;
		}

		_addTween(target, p, start, start + dif, p);
		_overwriteProps[_overwriteProps.length] = p;
	}
}
