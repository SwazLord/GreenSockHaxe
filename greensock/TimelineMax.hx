package com.greensock;

import openfl.events.IEventDispatcher;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import com.greensock.core.Animation;
import com.greensock.easing.Ease;
import com.greensock.events.TweenEvent;

class TimelineMax extends TimelineLite implements IEventDispatcher {
	public static inline var version:String = "12.1.5";

	private static var _listenerLookup:Dynamic = {
		onCompleteListener: TweenEvent.COMPLETE,
		onUpdateListener: TweenEvent.UPDATE,
		onStartListener: TweenEvent.START,
		onRepeatListener: TweenEvent.REPEAT,
		onReverseCompleteListener: TweenEvent.REVERSE_COMPLETE
	};

	private static var _easeNone:Ease = new Ease(null, null, 1, 0);

	private var _repeat:Int;
	private var _repeatDelay:Float;
	private var _cycle:Int = 0;
	private var _locked:Bool = false;
	private var _dispatcher:EventDispatcher;
	private var _hasUpdateListener:Bool = false;
	private var _yoyo:Bool = false;

	public function new(?vars:Dynamic) {
		super(vars);
		_repeat = vars.repeat == null ? 0 : vars.repeat;
		_repeatDelay = vars.repeatDelay == null ? 0 : vars.repeatDelay;
		_yoyo = vars.yoyo == true;
		_dirty = true;
		if (vars.onCompleteListener != null || vars.onUpdateListener != null || vars.onStartListener != null || vars.onRepeatListener != null
			|| vars.onReverseCompleteListener != null) {
			_initDispatcher();
		}
	}

	override public function invalidate():Dynamic {
		_yoyo = vars.yoyo == true;
		_repeat = vars.repeat == null ? 0 : vars.repeat;
		_repeatDelay = vars.repeatDelay == null ? 0 : vars.repeatDelay;
		_hasUpdateListener = false;
		_initDispatcher();
		_uncache(true);
		return super.invalidate();
	}

	public function addCallback(callback:Void->Void, position:Dynamic, ?params:Array<Dynamic>):TimelineMax {
		return cast add(TweenLite.delayedCall(0, callback, params), position);
	}

	public function removeCallback(callback:Void->Void, ?position:Dynamic):TimelineMax {
		if (callback != null) {
			if (position == null) {
				_kill(null, callback);
			} else {
				var a:Array<Dynamic> = getTweensOf(callback, false);
				var i:Int = a.length;
				var time:Float = _parseTimeOrLabel(position);
				while (--i >= 0) {
					if (a[i]._startTime == time) {
						a[i]._enabled(false, false);
					}
				}
			}
		}
		return this;
	}

	public function tweenTo(position:Dynamic, ?vars:Dynamic):TweenLite {
		vars = vars == null ? {} : vars;
		var copy:Dynamic = {
			ease: _easeNone,
			overwrite: vars.delay == null ? 2 : 1,
			useFrames: usesFrames(),
			immediateRender: false
		};
		for (p in Reflect.fields(vars)) {
			Reflect.setField(copy, p, Reflect.field(vars, p));
		}
		copy.time = _parseTimeOrLabel(position);
		var duration:Float = (Math.abs(copy.time - _time) / _timeScale) ?? 0.001;
		var t:TweenLite = new TweenLite(this, duration, copy);
		copy.onStart = function():Void {
			t.target.paused(true);
			if (t.vars.time != t.target.time() && duration == t.duration()) {
				t.duration(Math.abs(t.vars.time - t.target.time()) / t.target._timeScale);
			}
			if (vars.onStart != null) {
				vars.onStart(vars.onStartParams);
			}
		}
		return t;
	}

	public function tweenFromTo(fromPosition:Dynamic, toPosition:Dynamic, ?vars:Dynamic):TweenLite {
		vars = vars == null ? {} : vars;
		fromPosition = _parseTimeOrLabel(fromPosition);
		vars.startAt = {onComplete: seek, onCompleteParams: [fromPosition]};
		vars.immediateRender = vars.immediateRender != false;
		var t:TweenLite = tweenTo(toPosition, vars);
		return cast t.duration(Math.abs(t.vars.time - fromPosition) / _timeScale ?? 0.001);
	}

	override public function render(time:Float, suppressEvents:Bool = false, force:Bool = false):Void {
		if (_gc) {
			_enabled(true, false);
		}

		var totalDur:Float = (!_dirty) ? _totalDuration : totalDuration();
		var prevTime:Float = _time;
		var prevTotalTime:Float = _totalTime;
		var prevStart:Float = _startTime;
		var prevTimeScale:Float = _timeScale;
		var prevRawPrevTime:Float = _rawPrevTime;
		var prevPaused:Bool = _paused;
		var prevCycle:Int = _cycle;

		var tween:Animation = null;
		var isComplete:Bool = false;
		var next:Animation = null;
		var dur:Float = 0;
		var callback:String = null;
		var internalForce:Bool = false;

		if (time >= totalDur) {
			if (!_locked) {
				_totalTime = totalDur;
				_cycle = _repeat;
			}
			if (!_reversed)
				if (!_hasPausedChild()) {
					isComplete = true;
					callback = "onComplete";
					if (_duration == 0)
						if (time == 0 || _rawPrevTime < 0 || _rawPrevTime == Animation._tinyNum)
							if (_rawPrevTime != time && _first != null) {
								internalForce = true;
								if (_rawPrevTime > Animation._tinyNum) {
									callback = "onReverseComplete";
								}
							}
				}
			_rawPrevTime = (_duration != 0 || !suppressEvents || time != 0 || _rawPrevTime == time) ? time : Animation._tinyNum;
			if (_yoyo && (_cycle & 1) != 0) {
				_time = time = 0;
			} else {
				_time = _duration;
				time = _duration + 0.0001;
			}
		} else if (time < 0.0000001) {
			if (!_locked) {
				_totalTime = _cycle = 0;
			}
			_time = 0;
			if (prevTime != 0
				|| (_duration == 0
					&& _rawPrevTime != Animation._tinyNum
					&& (_rawPrevTime > 0 || (time < 0 && _rawPrevTime >= 0))
					&& !_locked)) {
				callback = "onReverseComplete";
				isComplete = _reversed;
			}
			if (time < 0) {
				_active = false;
				if (_rawPrevTime >= 0 && _first != null) {
					internalForce = true;
				}
				_rawPrevTime = time;
			} else {
				_rawPrevTime = (_duration != 0 || !suppressEvents || time != 0 || _rawPrevTime == time) ? time : Animation._tinyNum;
				time = 0;
				if (!_initted) {
					internalForce = true;
				}
			}
		} else {
			if (_duration == 0 && _rawPrevTime < 0) {
				internalForce = true;
			}
			_time = _rawPrevTime = time;
			if (!_locked) {
				_totalTime = time;
				if (_repeat != 0) {
					var cycleDuration:Float = _duration + _repeatDelay;
					_cycle = Math.floor(_totalTime / cycleDuration);
					if (_cycle != 0)
						if (_cycle == _totalTime / cycleDuration) {
							_cycle--;
						}
					_time = _totalTime - (_cycle * cycleDuration);
					if (_yoyo)
						if ((_cycle & 1) != 0) {
							_time = _duration - _time;
						}
					if (_time > _duration) {
						_time = _duration;
						time = _duration + 0.0001;
					} else if (_time < 0) {
						_time = time = 0;
					} else {
						time = _time;
					}
				}
			}
		}

		if (_cycle != prevCycle)
			if (!_locked) {
				var backwards:Bool = (_yoyo && (prevCycle & 1) != 0),
					wrap:Bool = (backwards == (_yoyo && (_cycle & 1) != 0)),
					recTotalTime:Float = _totalTime,
					recCycle:Int = _cycle,
					recRawPrevTime:Float = _rawPrevTime,
					recTime:Float = _time;

				_totalTime = prevCycle * _duration;
				if (_cycle < prevCycle) {
					backwards = !backwards;
				} else {
					_totalTime += _duration;
				}
				_time = prevTime;

				_rawPrevTime = prevRawPrevTime;
				_cycle = prevCycle;
				_locked = true;
				prevTime = (backwards) ? 0 : _duration;
				render(prevTime, suppressEvents, false);
				if (!suppressEvents)
					if (!_gc) {
						if (vars.onRepeat != null) {
							vars.onRepeat(vars.onRepeatParams);
						}
						if (_dispatcher != null) {
							_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
						}
					}
				if (wrap) {
					prevTime = (backwards) ? _duration + 0.0001 : -0.0001;
					render(prevTime, true, false);
				}
				_locked = false;
				if (_paused && !prevPaused) {
					return;
				}
				_time = recTime;
				_totalTime = recTotalTime;
				_cycle = recCycle;
				_rawPrevTime = recRawPrevTime;
			}

		if ((_time == prevTime || _first == null) && !force && !internalForce) {
			if (prevTotalTime != _totalTime)
				if (_onUpdate != null)
					if (!suppressEvents) { // so that onUpdate fires even during the repeatDelay - as long as the totalTime changed, we should trigger onUpdate.
						_onUpdate(vars.onUpdateParams);
					}
			return;
		} else if (!_initted) {
			_initted = true;
		}

		if (!_active)
			if (!_paused && _totalTime != prevTotalTime && time > 0) {
				_active = true;
			}

		if (prevTotalTime == 0)
			if (_totalTime != 0)
				if (!suppressEvents) {
					if (vars.onStart != null) {
						vars.onStart(vars.onStartParams);
					}
					if (_dispatcher != null) {
						_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
					}
				}

		if (_time >= prevTime) {
			tween = _first;
			while (tween != null) {
				next = tween._next;
				if (_paused && !prevPaused) {
					break;
				} else if (tween._active || (tween._startTime <= _time && !tween._paused && !tween._gc)) {
					if (!tween._reversed) {
						tween.render((time - tween._startTime) * tween._timeScale, suppressEvents, force);
					} else {
						tween.render(((!tween._dirty) ? tween._totalDuration : tween.totalDuration()) - ((time - tween._startTime) * tween._timeScale),
							suppressEvents, force);
					}
				}
				tween = next;
			}
		} else {
			tween = _last;
			while (tween != null) {
				next = tween._prev;
				if (_paused && !prevPaused) {
					break;
				} else if (tween._active || (tween._startTime <= prevTime && !tween._paused && !tween._gc)) {
					if (!tween._reversed) {
						tween.render((time - tween._startTime) * tween._timeScale, suppressEvents, force);
					} else {
						tween.render(((!tween._dirty) ? tween._totalDuration : tween.totalDuration()) - ((time - tween._startTime) * tween._timeScale),
							suppressEvents, force);
					}
				}
				tween = next;
			}
		}

		if (_onUpdate != null)
			if (!suppressEvents) {
				_onUpdate(vars.onUpdateParams);
			}
		if (_hasUpdateListener)
			if (!suppressEvents) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
			}

		if (callback != null)
			if (!_locked)
				if (!_gc)
					if (prevStart == _startTime || prevTimeScale != _timeScale)
						if (_time == 0 || totalDur >= totalDuration()) { // if one of the tweens that was rendered altered this timeline's startTime (like if an onComplete reversed the timeline), it probably isn't complete. If it is, don't worry, because whatever call altered the startTime would complete if it was necessary at the new time. The only exception is the timeScale property. Also check _gc because there's a chance that kill() could be called in an onUpdate
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
									_dispatcher.dispatchEvent(new TweenEvent(((callback == "onComplete") ? TweenEvent.COMPLETE : TweenEvent.REVERSE_COMPLETE)));
								}
							}
						}
	}

	public function getActive(nested:Bool = true, tweens:Bool = true, timelines:Bool = false):Array<Dynamic> {
		var a:Array<Dynamic> = [], all:Array<Dynamic> = getChildren(nested, tweens, timelines), cnt:Int = 0, l:Int = all.length, i:Int, tween:Animation;
		for (i in 0...l) {
			tween = all[i];
			if (!tween._paused)
				if (tween._timeline._time >= tween._startTime)
					if (tween._timeline._time < tween._startTime + tween._totalDuration / tween._timeScale)
						if (!_getGlobalPaused(tween._timeline)) {
							a[cnt++] = tween;
						}
		}
		return a;
	}

	private static function _getGlobalPaused(tween:Animation):Bool {
		while (tween != null) {
			if (tween._paused) {
				return true;
			}
			tween = tween._timeline;
		}
		return false;
	}

	public function getLabelAfter(?time:Float):String {
		if (time == null) {
			time = _time;
		}
		var labels:Array<{time:Float, name:String}> = getLabelsArray(), l:Int = labels.length, i:Int;
		for (i in 0...l) {
			if (labels[i].time > time) {
				return labels[i].name;
			}
		}
		return null;
	}

	public function getLabelBefore(time:Float):String {
		if (time == null) {
			time = _time;
		}
		var labels:Array<{time:Float, name:String}> = getLabelsArray(),
			i:Int = labels.length;
		while (--i >= 0) {
			if (labels[i].time < time) {
				return labels[i].name;
			}
		}
		return null;
	}

	public function getLabelsArray():Array<{time:Float, name:String}> {
		var a:Array<{time:Float, name:String}> = [], cnt:Int = 0, p:String;
		for (p in Reflect.fields(_labels)) {
			a[cnt++] = {time: _labels.get(p), name: p};
		}
		a.sort(function(a, b) return Reflect.compare(a.time, b.time));
		return a;
	}

	private function _initDispatcher():Bool {
		var found:Bool = false, p:String;
		for (p in Reflect.fields(_listenerLookup)) {
			if (Reflect.hasField(vars, p)) {
				if (Reflect.field(vars, p) != null) {
					if (_dispatcher == null) {
						_dispatcher = new EventDispatcher(this);
					}
					_dispatcher.addEventListener(_listenerLookup.get(p), Reflect.field(vars, p), false, 0, true);
					found = true;
				}
			}
		}
		return found;
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

	/* public function addEventListener(type:String, listener:Event->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		if (_dispatcher == null) {
			_dispatcher = new EventDispatcher(this);
		}
		if (type == TweenEvent.UPDATE) {
			_hasUpdateListener = true;
		}
		_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}*/
	public function removeEventListener<T>(type:String, listener:T->Void, useCapture:Bool = false):Void {
		if (_dispatcher != null) {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
	}

	public function hasEventListener(type:String):Bool {
		return (_dispatcher == null) ? false : _dispatcher.hasEventListener(type);
	}

	public function willTrigger(type:String):Bool {
		return (_dispatcher == null) ? false : _dispatcher.willTrigger(type);
	}

	public function dispatchEvent(event:Event):Bool {
		return (_dispatcher == null) ? false : _dispatcher.dispatchEvent(event);
	}

	override public function progress(?value:Float, suppressEvents:Bool = false):Float {
		return (Math.isNaN(value)) ? _time / duration() : totalTime(duration() * (((_yoyo && (_cycle & 1) != 0) ? 1 - value : value)
			+ (_cycle * (_duration + _repeatDelay))), suppressEvents);
	}

	override public function totalProgress(?value:Float, suppressEvents:Bool = true):Float {
		return (Math.isNaN(value)) ? _totalTime / totalDuration() : totalTime(totalDuration() * value, suppressEvents);
	}

	override public function totalDuration(?value:Float):Dynamic {
		if (Math.isNaN(value)) {
			if (_dirty) {
				super.totalDuration();
				_totalDuration = (_repeat == -1) ? 999999999999 : _duration * (_repeat + 1) + (_repeatDelay * _repeat);
			}
			return _totalDuration;
		}
		return (_repeat == -1) ? this : duration((value - (_repeat * _repeatDelay)) / (_repeat + 1));
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
			value = (_duration - value) + (_cycle * (_duration + _repeatDelay));
		} else if (_repeat != 0) {
			value += _cycle * (_duration + _repeatDelay);
		}
		return totalTime(value, suppressEvents);
	}

	public function repeat(value:Int = 0):Float {
		if (value == 0) {
			return _repeat;
		}
		_repeat = value;
		return _uncache(true);
	}

	public function repeatDelay(value:Float = 0):Float {
		if (value == 0) {
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

	public function currentLabel(value:String = null):Dynamic {
		if (value == null) {
			return getLabelBefore(_time + 0.00000001);
		}
		return seek(value, true);
	}
}
