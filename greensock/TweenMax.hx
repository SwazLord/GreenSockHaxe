package com.greensock;

import openfl.events.EventType;
import openfl.utils.Function;
import openfl.events.IEventDispatcher;
import com.greensock.core.Animation;
import com.greensock.core.PropTween;
import com.greensock.core.SimpleTimeline;
import com.greensock.events.TweenEvent;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.EndArrayPlugin;
import com.greensock.plugins.FramePlugin;
import com.greensock.plugins.RemoveTintPlugin;
import com.greensock.plugins.TintPlugin;
import com.greensock.plugins.VisiblePlugin;
import com.greensock.plugins.VolumePlugin;
import com.greensock.plugins.BevelFilterPlugin;
import com.greensock.plugins.BezierPlugin;
import com.greensock.plugins.BezierThroughPlugin;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.ColorMatrixFilterPlugin;
import com.greensock.plugins.ColorTransformPlugin;
import com.greensock.plugins.DropShadowFilterPlugin;
import com.greensock.plugins.FrameLabelPlugin;
import com.greensock.plugins.GlowFilterPlugin;
import com.greensock.plugins.HexColorsPlugin;
import com.greensock.plugins.RoundPropsPlugin;
import com.greensock.plugins.ShortRotationPlugin;
import com.greensock.plugins.TweenPlugin;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class TweenMax extends TweenLite implements IEventDispatcher {
	public static var ticker:Shape = Animation.ticker;

	public static var allFromTo:Function = staggerFromTo;
	public static inline var version:String = "12.1.5";

	private static var _listenerLookup:Dynamic = {
		onCompleteListener: TweenEvent.COMPLETE,
		onUpdateListener: TweenEvent.UPDATE,
		onStartListener: TweenEvent.START,
		onRepeatListener: TweenEvent.REPEAT,
		onReverseCompleteListener: TweenEvent.REVERSE_COMPLETE
	};

	public static var allFrom:Function = staggerFrom;
	public static var allTo:Function = staggerTo;

	private static var TweenMax_static_initializer = {
		TweenPlugin.activate([
			// ACTIVATE (OR DEACTIVATE) PLUGINS HERE...
			AutoAlphaPlugin, // tweens alpha and then toggles "visible" to false if/when alpha is zero
			EndArrayPlugin, // tweens numbers in an Array
			FramePlugin, // tweens MovieClip frames
			RemoveTintPlugin, // allows you to remove a tint
			TintPlugin, // tweens tints
			VisiblePlugin, // tweens a target's "visible" property
			VolumePlugin, // tweens the volume of a MovieClip or SoundChannel or anything with a "soundTransform" property
			BevelFilterPlugin, // tweens BevelFilters
			BezierPlugin, // enables bezier tweening
			BezierThroughPlugin, // enables bezierThrough tweening
			BlurFilterPlugin, // tweens BlurFilters
			ColorMatrixFilterPlugin, // tweens ColorMatrixFilters (including hue, saturation, colorize, contrast, brightness, and threshold)
			ColorTransformPlugin, // tweens advanced color properties like exposure, brightness, tintAmount, redOffset, redMultiplier, etc.
			DropShadowFilterPlugin, // tweens DropShadowFilters
			FrameLabelPlugin, // tweens a MovieClip to particular label
			GlowFilterPlugin, // tweens GlowFilters
			HexColorsPlugin, // tweens hex colors
			RoundPropsPlugin, // enables the roundProps special property for rounding values
			ShortRotationPlugin // tweens rotation values in the shortest direction
		]);
		true;
	}

	private var _dispatcher:EventDispatcher;

	public var _yoyo:Bool = false;

	private var _hasUpdateListener:Bool = false;
	private var _cycle:Int = 0;
	private var _repeatDelay:Float = 0;
	private var _repeat:Int = 0;

	public function new(target:Dynamic, duration:Float, vars:Dynamic) {
		super(target, duration, vars);
		_yoyo = vars.yoyo == true;
		_repeat = Std.parseInt(vars.repeat);
		_repeatDelay = vars.repeatDelay == null ? 0 : vars.repeatDelay;
		_dirty = true;
		if (vars.onCompleteListener != null || vars.onUpdateListener != null || vars.onStartListener != null || vars.onRepeatListener != null
			|| vars.onReverseCompleteListener != null) {
			_initDispatcher();
			if (_duration == 0) {
				if (_delay == 0) {
					if (vars.immediateRender) {
						_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
						_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
					}
				}
			}
		}
	}

	public static function resumeAll(tweens:Bool = true, delayedCalls:Bool = true, timelines:Bool = true):Void {
		_changePause(false, tweens, delayedCalls, timelines);
	}

	public static function fromTo(target:Dynamic, duration:Float, fromVars:Dynamic, toVars:Dynamic):TweenMax {
		toVars = TweenLite._prepVars(toVars, false);
		fromVars = TweenLite._prepVars(fromVars, false);
		toVars.startAt = fromVars;
		toVars.immediateRender = toVars.immediateRender != false && fromVars.immediateRender != false;
		return new TweenMax(target, duration, toVars);
	}

	public static function staggerTo(targets:Array<Dynamic>, duration:Float, vars:Dynamic, stagger:Float = 0, onCompleteAll:Void->Void = null,
			onCompleteAllParams:Array<Dynamic> = null):Array<TweenMax> {
		vars = TweenLite._prepVars(vars, false);
		var a:Array<TweenMax> = [];
		var l:Int = targets.length;
		var delay:Float = vars.delay == null ? 0 : vars.delay;
		for (i in 0...l) {
			var copy:Dynamic = {};
			for (p in Reflect.fields(vars)) {
				Reflect.setField(copy, p, Reflect.field(vars, p));
			}
			copy.delay = delay;
			if (i == l - 1) {
				if (onCompleteAll != null) {
					copy.onComplete = function():Void {
						if (vars.onComplete != null) {
							vars.onComplete(vars.onCompleteParams);
						}
						// onCompleteAll(onCompleteAllParams);
						Reflect.callMethod(null, onCompleteAll, onCompleteAllParams);
					}
				}
			}
			a[i] = new TweenMax(targets[i], duration, copy);
			delay += stagger;
		}
		return a;
	}

	public static function pauseAll(tweens:Bool = true, delayedCalls:Bool = true, timelines:Bool = true):Void {
		_changePause(true, tweens, delayedCalls, timelines);
	}

	public static function staggerFromTo(targets:Array<Dynamic>, duration:Float, fromVars:Dynamic, toVars:Dynamic, stagger:Float = 0,
			onCompleteAll:Void->Void = null, onCompleteAllParams:Array<Dynamic> = null):Array<TweenMax> {
		toVars = TweenLite._prepVars(toVars, false);
		fromVars = TweenLite._prepVars(fromVars, false);
		toVars.startAt = fromVars;
		toVars.immediateRender = toVars.immediateRender != false && fromVars.immediateRender != false;
		return staggerTo(targets, duration, toVars, stagger, onCompleteAll, onCompleteAllParams);
	}

	public static function getTweensOf(target:Dynamic, onlyActive:Bool = false):Array<Dynamic> {
		return TweenLite.getTweensOf(target, onlyActive);
	}

	public static function killTweensOf(target:Dynamic, onlyActive:Dynamic = false, vars:Dynamic = null):Void {
		TweenLite.killTweensOf(target, onlyActive, vars);
	}

	public static function delayedCall(delay:Float, callback:Void->Void, params:Array<Dynamic> = null, useFrames:Bool = false):TweenMax {
		return new TweenMax(callback, 0, {
			"delay": delay,
			"onComplete": callback,
			"onCompleteParams": params,
			"onReverseComplete": callback,
			"onReverseCompleteParams": params,
			"immediateRender": false,
			"useFrames": useFrames,
			"overwrite": 0
		});
	}

	public static function isTweening(target:Dynamic):Bool {
		return TweenLite.getTweensOf(target, true).length > 0;
	}

	public static function killAll(complete:Bool = false, tweens:Bool = true, delayedCalls:Bool = true, timelines:Bool = true):Void {
		var isDC:Bool = false;
		var tween:Animation = null;
		var a:Array<Animation> = getAllTweens(timelines);
		var l:Int = a.length;
		var allTrue:Bool = tweens && delayedCalls && timelines;
		for (i in 0...l) {
			tween = a[i];
			isDC = Std.isOfType(tween, TweenLite) && Reflect.getProperty(Reflect.getProperty(tween, "vars"), "onComplete") == tween;
			if (allTrue || Std.isOfType(tween, SimpleTimeline) || (isDC && delayedCalls) || (tweens && !isDC)) {
				if (complete) {
					tween.totalTime(tween._reversed ? 0 : tween.totalDuration());
				} else {
					tween._enabled(false, false);
				}
			}
		}
	}

	public static function killChildTweensOf(parent:DisplayObjectContainer, complete:Bool = false):Void {
		var a:Array<Dynamic> = getAllTweens(false);
		var l:Int = a.length;
		for (i in 0...l) {
			if (_containsChildOf(parent, a[i].target)) {
				if (complete) {
					a[i].totalTime(a[i].totalDuration());
				} else {
					a[i]._enabled(false, false);
				}
			}
		}
	}

	private static function _changePause(pause:Bool, tweens:Bool = true, delayedCalls:Bool = false, timelines:Bool = true):Void {
		var isDC:Bool = false;
		var tween:Animation = null;
		var a:Array<Animation> = getAllTweens(timelines);
		var allTrue:Bool = tweens && delayedCalls && timelines;
		var i:Int = a.length;
		while (--i >= 0) {
			tween = a[i];
			isDC = Std.isOfType(tween, TweenLite) && Reflect.getProperty(Reflect.getProperty(tween, "vars"), "onComplete") == tween;
			if (allTrue || Std.isOfType(tween, SimpleTimeline) || isDC && delayedCalls || tweens && !isDC) {
				tween.paused(pause);
			}
		}
	}

	public static function set(target:Dynamic, vars:Dynamic):TweenMax {
		return new TweenMax(target, 0, vars);
	}

	public static function from(target:Dynamic, duration:Float, vars:Dynamic):TweenMax {
		vars = TweenLite._prepVars(vars, true);
		vars.runBackwards = true;
		return new TweenMax(target, duration, vars);
	}

	public static function killDelayedCallsTo(func:Void->Void):Void {
		TweenLite.killTweensOf(func);
	}

	public static function globalTimeScale(?value:Float):Float {
		if (value == null) {
			return Animation._rootTimeline == null ? 1 : Animation._rootTimeline._timeScale;
		}
		value = value == 0 ? 0.0001 : value;
		if (Animation._rootTimeline == null) {
			TweenLite.to({}, 0, {});
		}
		var tl:SimpleTimeline = Animation._rootTimeline;
		var t:Float = (Math.round(haxe.Timer.stamp() * 1000) / 1000);
		tl._startTime = t - (t - tl._startTime) * tl._timeScale / value;
		tl = Animation._rootFramesTimeline;
		t = Animation._rootFrame;
		tl._startTime = t - (t - tl._startTime) * tl._timeScale / value;
		Animation._rootFramesTimeline._timeScale = Animation._rootTimeline._timeScale = value;
		return value;
	}

	public static function getAllTweens(includeTimelines:Bool = false):Array<Animation> {
		var a:Array<Animation> = _getChildrenOf(Animation._rootTimeline, includeTimelines);
		return a.concat(_getChildrenOf(Animation._rootFramesTimeline, includeTimelines));
	}

	private static function _getChildrenOf(timeline:SimpleTimeline, includeTimelines:Bool):Array<Animation> {
		if (timeline == null) {
			return [];
		}
		var a:Array<Animation> = [];
		var cnt:Int = 0;
		var tween:Animation = timeline._first;
		while (tween != null) {
			if (Std.isOfType(tween, TweenLite)) {
				a[cnt++] = tween;
			} else {
				if (includeTimelines) {
					a[cnt++] = tween;
				}
				a = a.concat(_getChildrenOf(cast(tween, SimpleTimeline), includeTimelines));
				cnt = a.length;
			}
			tween = tween._next;
		}
		return a;
	}

	private static function _containsChildOf(parent:DisplayObjectContainer, obj:Dynamic):Bool {
		if (Std.isOfType(obj, Array)) {
			for (o in cast(obj, Array<Dynamic>)) {
				if (_containsChildOf(parent, o)) {
					return true;
				}
			}
		} else if (Std.isOfType(obj, DisplayObject)) {
			var curParent:DisplayObjectContainer = cast(obj, DisplayObject).parent;
			while (curParent != null) {
				if (curParent == parent) {
					return true;
				}
				curParent = curParent.parent;
			}
		}
		return false;
	}

	public static function staggerFrom(targets:Array<Dynamic>, duration:Float, vars:Dynamic, stagger:Float = 0, onCompleteAll:Void->Void = null,
			onCompleteAllParams:Array<Dynamic> = null):Array<TweenMax> {
		vars = TweenLite._prepVars(vars, true);
		vars.runBackwards = true;
		if (vars.immediateRender != false) {
			vars.immediateRender = true;
		}
		return staggerTo(targets, duration, vars, stagger, onCompleteAll, onCompleteAllParams);
	}

	public static function to(target:Dynamic, duration:Float, vars:Dynamic):TweenMax {
		return new TweenMax(target, duration, vars);
	}

	public function dispatchEvent(event:Event):Bool {
		return _dispatcher == null ? false : _dispatcher.dispatchEvent(event);
	}

	override public function invalidate():Dynamic {
		_yoyo = vars.yoyo == true;
		_repeat = Std.parseInt(vars.repeat);
		_repeatDelay = vars.repeatDelay == null ? 0 : vars.repeatDelay;
		_hasUpdateListener = false;
		_initDispatcher();
		_uncache(true);
		return super.invalidate();
	}

	public function removeEventListener<T>(type:String, listener:T->Void, useCapture:Bool = false):Void {
		if (_dispatcher != null) {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
	}

	public function addEventListener<T>(type:String, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		if (_dispatcher == null) {
			_dispatcher = new EventDispatcher(this);
		}
		if (type == TweenEvent.UPDATE) {
			_hasUpdateListener = true;
		}
		_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function willTrigger(type:String):Bool {
		return _dispatcher == null ? false : _dispatcher.willTrigger(type);
	}

	override public function duration(?value:Float):Dynamic {
		if (Math.isNaN(value)) {
			return _duration;
		}
		return super.duration(value);
	}

	override public function time(?value:Float, suppressEvents:Bool = false):Float {
		if (value == null) {
			return _time;
		}
		if (_dirty) {
			totalDuration();
		}
		if (value > _duration) {
			value = _duration;
		}
		if (_yoyo && (_cycle & 1) != 0) {
			value = _duration - value + _cycle * (_duration + _repeatDelay);
		} else if (_repeat != 0) {
			value += _cycle * (_duration + _repeatDelay);
		}
		return totalTime(value, suppressEvents);
	}

	override public function render(time:Float, suppressEvents:Bool = false, force:Bool = false):Void {
		var isComplete:Bool = false;
		var callback:String = null;
		var pt:PropTween = null;
		var rawPrevTime:Float = Math.NaN;
		var cycleDuration:Float = Math.NaN;
		var r:Float = Math.NaN;
		var type:Int = 0;
		var pow:Int = 0;
		if (!_initted) {
			if (_duration == 0 && vars.repeat) {
				invalidate();
			}
		}
		var totalDur:Float = !_dirty ? _totalDuration : totalDuration();
		var prevTime:Float = _time;
		var prevTotalTime:Float = _totalTime;
		var prevCycle:Float = _cycle;
		if (time >= totalDur) {
			_totalTime = totalDur;
			_cycle = _repeat;
			if (_yoyo && (_cycle & 1) != 0) {
				_time = 0;
				ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
			} else {
				_time = _duration;
				ratio = _ease._calcEnd ? _ease.getRatio(1) : 1;
			}
			if (!_reversed) {
				isComplete = true;
				callback = "onComplete";
			}
			if (_duration == 0) {
				rawPrevTime = _rawPrevTime;
				if (_startTime == _timeline._duration) {
					time = 0;
				}
				if (time == 0 || rawPrevTime < 0 || rawPrevTime == Animation._tinyNum) {
					if (rawPrevTime != time) {
						force = true;
						if (rawPrevTime > Animation._tinyNum) {
							callback = "onReverseComplete";
						}
					}
				}
				_rawPrevTime = rawPrevTime = !suppressEvents || time != 0 || _rawPrevTime == time ? time : Animation._tinyNum;
			}
		} else if (time < 1e-7) {
			_totalTime = _time = _cycle = 0;
			ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
			if (prevTotalTime != 0 || _duration == 0 && _rawPrevTime > 0 && _rawPrevTime != Animation._tinyNum) {
				callback = "onReverseComplete";
				isComplete = _reversed;
			}
			if (time < 0) {
				_active = false;
				if (_duration == 0) {
					if (_rawPrevTime >= 0) {
						force = true;
					}
					_rawPrevTime = rawPrevTime = !suppressEvents || time != 0 || _rawPrevTime == time ? time : Animation._tinyNum;
				}
			} else if (!_initted) {
				force = true;
			}
		} else {
			_totalTime = _time = time;
			if (_repeat != 0) {
				cycleDuration = _duration + _repeatDelay;
				_cycle = Math.floor(_totalTime / cycleDuration);
				if (_cycle != 0) {
					if (_cycle == _totalTime / cycleDuration) {
						_cycle--;
					}
				}
				_time = _totalTime - _cycle * cycleDuration;
				if (_yoyo) {
					if ((_cycle & 1) != 0) {
						_time = _duration - _time;
					}
				}
				if (_time > _duration) {
					_time = _duration;
				} else if (_time < 0) {
					_time = 0;
				}
			}
			if (_easeType != null) {
				r = _time / _duration;
				type = _easeType;
				pow = _easePower;
				if (type == 1 || type == 3 && r >= 0.5) {
					r = 1 - r;
				}
				if (type == 3) {
					r *= 2;
				}
				if (pow == 1) {
					r *= r;
				} else if (pow == 2) {
					r *= r * r;
				} else if (pow == 3) {
					r *= r * r * r;
				} else if (pow == 4) {
					r *= r * r * r * r;
				}
				if (type == 1) {
					ratio = 1 - r;
				} else if (type == 2) {
					ratio = r;
				} else if (_time / _duration < 0.5) {
					ratio = r / 2;
				} else {
					ratio = 1 - r / 2;
				}
			} else {
				ratio = _ease.getRatio(_time / _duration);
			}
		}
		if (prevTime == _time && !force && _cycle == prevCycle) {
			if (prevTotalTime != _totalTime) {
				if (_onUpdate != null) {
					if (!suppressEvents) {
						_onUpdate(vars.onUpdateParams);
					}
				}
			}
			return;
		}
		if (!_initted) {
			_init();
			if (!_initted || _gc) {
				return;
			}
			if (_time != null && !isComplete) {
				ratio = _ease.getRatio(_time / _duration);
			} else if (isComplete && _ease._calcEnd) {
				ratio = _ease.getRatio(_time == 0 ? 0 : 1);
			}
		}
		if (!_active) {
			if (!_paused && _time != prevTime && time >= 0) {
				_active = true;
			}
		}
		if (prevTotalTime == 0) {
			if (_startAt != null) {
				if (time >= 0) {
					_startAt.render(time, suppressEvents, force);
				} else if (callback == null) {
					callback = "_dummyGS";
				}
			}
			if (_totalTime != 0 || _duration == 0) {
				if (!suppressEvents) {
					if (vars.onStart != null) {
						vars.onStart(vars.onStartParams);
					}
					if (_dispatcher != null) {
						_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
					}
				}
			}
		}
		pt = _firstPT;
		while (pt != null) {
			if (pt.f) {
				pt.t.setField(pt.p, pt.c * ratio + pt.s);
			} else {
				Reflect.setField(pt.t, pt.p, pt.c * ratio + pt.s);
			}
			pt = pt._next;
		}
		if (_onUpdate != null) {
			if (time < 0 && _startAt != null && _startTime != 0) {
				_startAt.render(time, suppressEvents, force);
			}
			if (!suppressEvents) {
				if (_totalTime != prevTotalTime || isComplete) {
					_onUpdate(vars.onUpdateParams);
				}
			}
		}
		if (_hasUpdateListener) {
			if (time < 0 && _startAt != null && _onUpdate == null && _startTime != 0) {
				_startAt.render(time, suppressEvents, force);
			}
			if (!suppressEvents) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
			}
		}
		if (_cycle != prevCycle) {
			if (!suppressEvents) {
				if (!_gc) {
					if (vars.onRepeat != null) {
						vars.onRepeat(vars.onRepeatParams);
					}
					if (_dispatcher != null) {
						_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
					}
				}
			}
		}
		if (callback != null) {
			if (!_gc) {
				if (time < 0 && _startAt != null && _onUpdate == null && !_hasUpdateListener && _startTime != 0) {
					_startAt.render(time, suppressEvents, true);
				}
				if (isComplete) {
					if (_timeline.autoRemoveChildren) {
						_enabled(false, false);
					}
					_active = false;
				}
				if (!suppressEvents) {
					if (Reflect.getProperty(vars, callback) != null) {
						Reflect.callMethod(null, Reflect.getProperty(vars, callback), Reflect.getProperty(vars, callback + "Params"));
					}
					if (_dispatcher != null) {
						_dispatcher.dispatchEvent(new TweenEvent(callback == "onComplete" ? TweenEvent.COMPLETE : TweenEvent.REVERSE_COMPLETE));
					}
				}
				if (_duration == 0 && _rawPrevTime == Animation._tinyNum && rawPrevTime != Animation._tinyNum) {
					_rawPrevTime = 0;
				}
			}
		}
	}

	override public function totalProgress(?value:Float, suppressEvents:Bool = false):Float {
		return Math.isNaN(value) ? _totalTime / totalDuration() : totalTime(totalDuration() * value, suppressEvents);
	}

	public function repeat(value:Int = 0):Int {
		if (value == 0) {
			return _repeat;
		}
		_repeat = value;
		return _uncache(true);
	}

	public function updateTo(vars:Dynamic, resetDuration:Bool = false):TweenMax {
		var prevTime:Float = Math.NaN;
		var inv:Float = Math.NaN;
		var pt:PropTween = null;
		var endValue:Float = Math.NaN;
		var curRatio:Float = ratio;
		if (resetDuration) {
			if (_startTime < _timeline._time) {
				_startTime = _timeline._time;
				_uncache(false);
				if (_gc) {
					_enabled(true, false);
				} else {
					_timeline.insert(this, _startTime - _delay);
				}
			}
		}
		for (p in Reflect.fields(vars)) {
			Reflect.setField(this.vars, p, Reflect.field(vars, p));
		}
		if (_initted) {
			if (resetDuration) {
				_initted = false;
			} else {
				if (_gc) {
					_enabled(true, false);
				}
				if (_notifyPluginsOfEnabled) {
					if (_firstPT != null) {
						TweenLite._onPluginEvent("_onDisable", this);
					}
				}
				if (_time / _duration > 0.998) {
					prevTime = _time;
					render(0, true, false);
					_initted = false;
					render(prevTime, true, false);
				} else if (_time > 0) {
					_initted = false;
					_init();
					inv = 1 / (1 - curRatio);
					pt = _firstPT;
					while (pt != null) {
						endValue = pt.s + pt.c;
						pt.c *= inv;
						pt.s = endValue - pt.c;
						pt = pt._next;
					}
				}
			}
		}
		return this;
	}

	public function repeatDelay(?value:Float):Float {
		if (value == null) {
			return _repeatDelay;
		}
		_repeatDelay = value;
		return _uncache(true);
	}

	public function yoyo(value:Bool = false):Dynamic {
		if (!value) {
			return _yoyo;
		}
		_yoyo = value;
		return this;
	}

	override public function progress(?value:Float, suppressEvents:Bool = false):Float {
		return Math.isNaN(value) ? _time / duration() : totalTime(duration() * ((_yoyo && (_cycle & 1) != 0) ? 1 - value : value)
			+ _cycle * (_duration + _repeatDelay), suppressEvents);
	}

	private function _initDispatcher():Bool {
		var found:Bool = false;
		for (p in Reflect.fields(_listenerLookup)) {
			if (Reflect.hasField(vars, p)) {
				if (Reflect.field(vars, p) != null) {
					if (_dispatcher == null) {
						_dispatcher = new EventDispatcher(this);
					}
					_dispatcher.addEventListener(Reflect.field(_listenerLookup, p), Reflect.field(vars, p), false, 0, true);
					found = true;
				}
			}
		}
		return found;
	}

	override public function totalDuration(?value:Float):Dynamic {
		if (value == null) {
			if (_dirty) {
				_totalDuration = _repeat == -1 ? 999999999999 : _duration * (_repeat + 1) + _repeatDelay * _repeat;
				_dirty = false;
			}
			return _totalDuration;
		}
		return _repeat == -1 ? this : duration((value - _repeat * _repeatDelay) / (_repeat + 1));
	}

	public function hasEventListener(type:String):Bool {
		return _dispatcher == null ? false : _dispatcher.hasEventListener(type);
	}
}
