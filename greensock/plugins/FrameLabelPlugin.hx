/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
**/

package com.greensock.plugins;

import com.greensock.TweenLite;
import openfl.display.MovieClip;

/**
	* [AS3/AS2 only] Tweens a MovieClip to a particular frame label. <br /><br />
	* 
	* <p><b>USAGE:</b></p>
	* <listing version="3.0">
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.FrameLabelPlugin; 
	TweenPlugin.activate([FrameLabelPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

	TweenLite.to(mc, 1, {frameLabel:"myLabel"}); 
	</listing>
	* 
	* <p>Note: When tweening the frames of a MovieClip, any audio that is embedded on the MovieClip's timeline (as "stream") will not be played. 
	* Doing so would be impossible because the tween might speed up or slow down the MovieClip to any degree.</p>
	* 
	* <b>Copyright 2014, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.
	* 
	* @author Jack Doyle, jack@greensock.com
 */
class FrameLabelPlugin extends FramePlugin {
	/** @private **/
	public static inline var API:Float = 2; // If the API/Framework for plugins changes in the future, this number helps determine compatibility

	/** @private **/
	public function new() {
		super();
		_propName = "frameLabel";
	}

	/** @private **/
	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		if (Std.isOfType(!tween.target, MovieClip)) {
			return false;
		}
		_target = try cast(target, MovieClip) catch (e:Dynamic) null;
		this.frame = _target.currentFrame;
		var labels:Array<Dynamic> = _target.currentLabels;
		var label:String = value;
		var endFrame:Int = _target.currentFrame;
		var i:Int = labels.length;
		while (--i > -1) {
			if (labels[i].name == label) {
				endFrame = labels[i].frame;
				break;
			}
		}
		if (this.frame != endFrame) {
			_addTween(this, "frame", this.frame, endFrame, "frame", true);
		}
		return true;
	}
}
