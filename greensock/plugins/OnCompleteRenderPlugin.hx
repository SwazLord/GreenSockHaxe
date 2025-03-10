/**
 * VERSION: 12.0
 * DATE: 2012-08-27
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
**/

package com.greensock.plugins;

import haxe.Constraints.Function;
import com.greensock.TweenLite;
import openfl.display.DisplayObject;
import openfl.events.Event;

/**
	* [AS3 only] Calls a function as soon as the tween completes AND the final frame actually renders to the screen.  
	* It accomplishes this by waiting until the next <code>ENTER_FRAME</code> event gets dispatched before calling the function.
	* (a regular onComplete gets called as soon as the tween sets its final values but before things are rendered graphically to the screen).
	* 
	* <p><strong>USAGE:</strong></p>
	* <listing version="3.0">
	import com.greensock.TweenLite; 
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.OnCompleteRenderPlugin;
	TweenPlugin.activate([OnCompleteRenderPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

	TweenLite.to(mc, 1, {x:100, onCompleteRender:myFunc});  //tweens horizontal and vertical scale simultaneously
	</listing>
	* 
	* <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
	* 
	* @author Jack Doyle, jack@greensock.com
 */
class OnCompleteRenderPlugin extends TweenPlugin {
	/** @private **/
	public static inline var API:Float = 2;

	/** @private **/
	private var _target:DisplayObject;

	/** @private **/
	private var _func:Function;

	/** @private **/
	private var _tween:TweenLite;

	/** @private **/
	public function new() {
		super("onCompleteRender,onCompleteRenderParams");
		TweenLite._plugins.onCompleteRenderParams = OnCompleteRenderPlugin;
	}

	/** @private **/
	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		if (Std.isOfType(value, Array)) {
			return true;
		} else if (!(Std.isOfType(target, DisplayObject))) {
			trace("Error: onCompleteRender was used on a tween whose target is not a DisplayObject");
			return false;
		}
		_target = try cast(target, DisplayObject) catch (e:Dynamic) null;
		_func = value;
		_tween = tween;
		return true;
	}

	private function _enterFrameHandler(event:Event):Void {
		_target.removeEventListener("enterFrame", _enterFrameHandler);
		Reflect.callMethod(null, _func, _tween.vars.onCompleteRenderParams);
	}

	/** @private **/
	override public function setRatio(v:Float):Void {
		if (v == 1 || v == 0) {
			if (_func != null) {
				if (_tween._time == _tween._duration && _tween.data != "isFromStart")
					// if _func is null, this plugin was used to init the onCompleteRenderParams, so just ignore it (we'll reference it in the onCompleteRender instance instead).
				{
					_target.addEventListener("enterFrame", _enterFrameHandler, false, 100, true);
				}
			}
		}
	}
}
