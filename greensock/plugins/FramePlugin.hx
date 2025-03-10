/**
 * VERSION: 12.01
 * DATE: 2012-06-25
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
**/

package com.greensock.plugins;

import com.greensock.TweenLite;
import openfl.display.MovieClip;

/**
	* [AS3/AS2 only] Tweens a MovieClip to a particular frame number. <br /><br />
	* 
	* <p><b>USAGE:</b></p>
	* <listing version="3.0">
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.FramePlugin;
	TweenPlugin.activate([FramePlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

	TweenLite.to(mc, 1, {frame:125}); 
	</listing>
	* 
	* <p>Note: When tweening the frames of a MovieClip, any audio that is embedded on the MovieClip's timeline (as "stream") will not be played. 
	* Doing so would be impossible because the tween might speed up or slow down the MovieClip to any degree.</p>
	* 
	* <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
	* 
	* @author Jack Doyle, jack@greensock.com
 */
class FramePlugin extends TweenPlugin {
	/** @private **/
	public static inline var API:Float = 2; // If the API/Framework for plugins changes in the future, this number helps determine compatibility

	/** @private **/
	public var frame:Int;

	/** @private **/
	private var _target:MovieClip;

	/** @private **/
	public function new() {
		super("frame,frameLabel,frameForward,frameBackward");
	}

	/** @private **/
	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		if (!(Std.isOfType(target, MovieClip)) || Math.isNaN(value)) {
			return false;
		}
		_target = try cast(target, MovieClip) catch (e:Dynamic) null;
		this.frame = _target.currentFrame;
		_addTween(this, "frame", this.frame, value, "frame", true);
		return true;
	}

	/** @private **/
	override public function setRatio(v:Float):Void {
		super.setRatio(v);
		if (this.frame != _target.currentFrame) {
			_target.gotoAndStop(this.frame);
		}
	}
}
