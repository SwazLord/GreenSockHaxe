package com.greensock.plugins;

import com.greensock.TweenLite;
import openfl.display.MovieClip;

class FrameForwardPlugin extends TweenPlugin {
	public static var API:Float = 2;

	private var _start:Int;
	private var _change:Int;
	private var _max:UInt;
	private var _target:Dynamic;
	private var _backward:Bool = false;

	public function new() {
		super("frameForward,frame,frameLabel,frameBackward");
	}

	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		_target = target;
		_start = _target.currentFrame;
		_max = _target.totalFrames;

		if (Std.isOfType(value, Float)) {
			_change = Std.int(value) - _start;
		} else if (Std.isOfType(value, String) && value.charAt(1) == "=") {
			_change = Std.parseInt(value.charAt(0) + "1") * Std.parseInt(value.substr(2));
		} else {
			_change = Std.int(value) ?? 0;
		}

		if (!_backward && _change < 0) {
			_change = ((_change + (_max * 99999)) % _max) + (Std.int(_change / _max) * _max);
		} else if (_backward && _change > 0) {
			_change = ((_change - (_max * 99999)) % _max) - (Std.int(_change / _max) * _max);
		}

		return true;
	}

	override public function setRatio(v:Float):Void {
		var frame:Float = (_change * v + _start) % _max;

		if (frame < 0.5 && frame >= -0.5) {
			frame = _max;
		} else if (frame < 0) {
			frame += _max;
		}

		frame = Std.int(frame + 0.5);

		if (frame != _target.currentFrame) {
			_target.gotoAndStop(frame);
		}
	}
}
