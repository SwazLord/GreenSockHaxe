/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
**/

package com.greensock.plugins;

import com.greensock.TweenLite;

/**
 * @private
 * [AS3/AS2 only] LEGACY
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class BezierThroughPlugin extends BezierPlugin {
	/** @private **/
	public static inline var API:Float = 2; // If the API/Framework for plugins changes in the future, this number helps determine compatibility

	/** @private **/
	public function new() {
		super();
		_propName = "bezierThrough";
	}

	/** @private **/
	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		if (Std.isOfType(value, Array)) {
			value = {
				values: value
			};
		}
		value.type = "thru";
		return super._onInitTween(target, value, tween);
	}
}
