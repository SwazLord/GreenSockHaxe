package com.greensock;

import haxe.Constraints.Function;
import com.greensock.core.Animation;
import com.greensock.easing.Ease;
import com.greensock.events.TweenEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

class TimelineMax extends TimelineLite implements IEventDispatcher
{
    
    private static var _easeNone : Ease = new Ease(null, null, 1, 0);
    
    public static inline var version : String = "12.1.5";
    
    private static var _listenerLookup : Dynamic = {
            onCompleteListener : TweenEvent.COMPLETE,
            onUpdateListener : TweenEvent.UPDATE,
            onStartListener : TweenEvent.START,
            onRepeatListener : TweenEvent.REPEAT,
            onReverseCompleteListener : TweenEvent.REVERSE_COMPLETE
        };
    
    
    private var _dispatcher : EventDispatcher;
    
    private var _yoyo : Bool;
    
    private var _hasUpdateListener : Bool;
    
    private var _cycle : Int = 0;
    
    private var _locked : Bool;
    
    private var _repeatDelay : Float;
    
    private var _repeat : Int;
    
    public function new(vars : Dynamic = null)
    {
        super(vars);
        _repeat = (as3hx.Compat.parseInt(this.vars.repeat) || 0) ? 1 : 0;
        _repeatDelay = as3hx.Compat.parseFloat(this.vars.repeatDelay) || 0;
        _yoyo = this.vars.yoyo == true;
        _dirty = true;
        if (this.vars.onCompleteListener || this.vars.onUpdateListener || this.vars.onStartListener || this.vars.onRepeatListener || this.vars.onReverseCompleteListener)
        {
            _initDispatcher();
        }
    }
    
    private static function _getGlobalPaused(tween : Animation) : Bool
    {
        while (tween)
        {
            if (tween._paused)
            {
                return true;
            }
            tween = tween._timeline;
        }
        return false;
    }
    
    public function dispatchEvent(event : Event) : Bool
    {
        return (_dispatcher == null) ? cast(false, Bool) : cast(_dispatcher.dispatchEvent(event), Bool);
    }
    
    public function currentLabel(value : String = null) : Dynamic
    {
        if (!arguments.length)
        {
            return getLabelBefore(_time + 1e-8);
        }
        return seek(value, true);
    }
    
    public function hasEventListener(type : String) : Bool
    {
        return (_dispatcher == null) ? cast(false, Bool) : cast(_dispatcher.hasEventListener(type), Bool);
    }
    
    public function removeEventListener(type : String, listener : Function, useCapture : Bool = false) : Void
    {
        if (_dispatcher != null)
        {
            _dispatcher.removeEventListener(type, listener, useCapture);
        }
    }
    
    public function addCallback(callback : Function, position : Dynamic, params : Array<Dynamic> = null) : TimelineMax
    {
        return try cast(add(TweenLite.delayedCall(0, callback, params), position), TimelineMax) catch(e:Dynamic) null;
    }
    
    public function tweenFromTo(fromPosition : Dynamic, toPosition : Dynamic, vars : Dynamic = null) : TweenLite
    {
        vars = vars || { };
        fromPosition = _parseTimeOrLabel(fromPosition);
        vars.startAt = {
                    onComplete : seek,
                    onCompleteParams : [fromPosition]
                };
        vars.immediateRender = vars.immediateRender != false;
        var t : TweenLite = tweenTo(toPosition, vars);
        return try cast(t.duration(as3hx.Compat.parseFloat(Math.abs(t.vars.time - fromPosition) / _timeScale) || 0.001), TweenLite) catch(e:Dynamic) null;
    }
    
    public function addEventListener(type : String, listener : Function, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        if (_dispatcher == null)
        {
            _dispatcher = new EventDispatcher(this);
        }
        if (type == TweenEvent.UPDATE)
        {
            _hasUpdateListener = true;
        }
        _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    public function tweenTo(position : Dynamic, vars : Dynamic = null) : TweenLite
    {
        var p : String = null;
        var duration : Float = Math.NaN;
        var t : TweenLite = null;
        vars = vars || { };
        var copy : Dynamic = {
            ease : _easeNone,
            overwrite : ((cast(vars.delay, Bool)) ? 2 : 1),
            useFrames : usesFrames(),
            immediateRender : false
        };
        for (p in Reflect.fields(vars))
        {
            Reflect.setField(copy, p, Reflect.field(vars, p));
        }
        copy.time = _parseTimeOrLabel(position);
        duration = as3hx.Compat.parseFloat(Math.abs(as3hx.Compat.parseFloat(copy.time) - _time) / _timeScale) || 0.001;
        t = new TweenLite(this, duration, copy);
        copy.onStart = function() : Void
                {
                    t.target.paused(true);
                    if (t.vars.time != t.target.time() && duration == t.duration())
                    {
                        t.duration(Math.abs(t.vars.time - t.target.time()) / t.target._timeScale);
                    }
                    if (vars.onStart)
                    {
                        vars.onStart.apply(null, vars.onStartParams);
                    }
                };
        return t;
    }
    
    public function repeat(value : Float = 0) : Dynamic
    {
        if (!arguments.length)
        {
            return _repeat;
        }
        _repeat = as3hx.Compat.parseInt(value);
        return _uncache(true);
    }
    
    public function getLabelBefore(time : Float = Math.NaN) : String
    {
        if (!time)
        {
            if (time != 0)
            {
                time = _time;
            }
        }
        var labels : Array<Dynamic> = getLabelsArray();
        var i : Int = labels.length;
        while (--i > -1)
        {
            if (labels[i].time < time)
            {
                return labels[i].name;
            }
        }
        return null;
    }
    
    public function willTrigger(type : String) : Bool
    {
        return (_dispatcher == null) ? cast(false, Bool) : cast(_dispatcher.willTrigger(type), Bool);
    }
    
    override public function totalProgress(value : Float = Math.NaN, suppressEvents : Bool = true) : Dynamic
    {
        return !(arguments.length) ? _totalTime / totalDuration() : totalTime(totalDuration() * value, suppressEvents);
    }
    
    public function getLabelsArray() : Array<Dynamic>
    {
        var p : Dynamic = null;
        var a : Array<Dynamic> = [];
        var cnt : Int = 0;
        for (p in Reflect.fields(_labels))
        {
            var _loc6_ : Dynamic = cnt++;
            Reflect.setField(a, Std.string(_loc6_), {
                time : Reflect.field(_labels, Std.string(p)),
                name : p
            });
        }
        a.sortOn("time", Array.NUMERIC);
        return a;
    }
    
    override public function render(time : Float, suppressEvents : Bool = false, force : Bool = false) : Void
    {
        var tween : Animation = null;
        var isComplete : Bool = false;
        var next : Animation = null;
        var dur : Float = Math.NaN;
        var callback : String = null;
        var internalForce : Bool = false;
        var cycleDuration : Float = Math.NaN;
        var backwards : Bool = false;
        var wrap : Bool = false;
        var recTotalTime : Float = Math.NaN;
        var recCycle : Int = 0;
        var recRawPrevTime : Float = Math.NaN;
        var recTime : Float = Math.NaN;
        if (_gc)
        {
            _enabled(true, false);
        }
        var totalDur : Float = !(_dirty) ? as3hx.Compat.parseFloat(_totalDuration) : as3hx.Compat.parseFloat(totalDuration());
        var prevTime : Float = _time;
        var prevTotalTime : Float = _totalTime;
        var prevStart : Float = _startTime;
        var prevTimeScale : Float = _timeScale;
        var prevRawPrevTime : Float = _rawPrevTime;
        var prevPaused : Bool = _paused;
        var prevCycle : Int = _cycle;
        if (time >= totalDur)
        {
            if (!_locked)
            {
                _totalTime = totalDur;
                _cycle = _repeat;
            }
            if (!_reversed)
            {
                if (!_hasPausedChild())
                {
                    isComplete = true;
                    callback = "onComplete";
                    if (_duration == 0)
                    {
                        if (time == 0 || _rawPrevTime < 0 || _rawPrevTime == _tinyNum)
                        {
                            if (_rawPrevTime != time && _first != null)
                            {
                                internalForce = true;
                                if (_rawPrevTime > _tinyNum)
                                {
                                    callback = "onReverseComplete";
                                }
                            }
                        }
                    }
                }
            }
            _rawPrevTime = _duration || !(suppressEvents || time != 0 || _rawPrevTime == time) ? time : as3hx.Compat.parseFloat(_tinyNum);
            if (_yoyo && (_cycle & 1) != 0)
            {
                _time = time = 0;
            }
            else
            {
                _time = _duration;
                time = _duration + 0.0001;
            }
        }
        else if (time < 1e-7)
        {
            if (!_locked)
            {
                _totalTime = _cycle = 0;
            }
            _time = 0;
            if (prevTime != 0 || _duration == 0 && _rawPrevTime != _tinyNum && (_rawPrevTime > 0 || time < 0 && _rawPrevTime >= 0) && !_locked)
            {
                callback = "onReverseComplete";
                isComplete = _reversed;
            }
            if (time < 0)
            {
                _active = false;
                if (_rawPrevTime >= 0 && _first)
                {
                    internalForce = true;
                }
                _rawPrevTime = time;
            }
            else
            {
                _rawPrevTime = _duration || !(suppressEvents || time != 0 || _rawPrevTime == time) ? time : as3hx.Compat.parseFloat(_tinyNum);
                time = 0;
                if (!_initted)
                {
                    internalForce = true;
                }
            }
        }
        else
        {
            if (_duration == 0 && _rawPrevTime < 0)
            {
                internalForce = true;
            }
            _time = _rawPrevTime = time;
            if (!_locked)
            {
                _totalTime = time;
                if (_repeat != 0)
                {
                    cycleDuration = _duration + _repeatDelay;
                    _cycle = as3hx.Compat.parseInt(_totalTime / cycleDuration) >> 0;
                    if (_cycle != 0)
                    {
                        if (_cycle == _totalTime / cycleDuration)
                        {
                            --_cycle;
                        }
                    }
                    _time = _totalTime - _cycle * cycleDuration;
                    if (_yoyo)
                    {
                        if ((_cycle & 1) != 0)
                        {
                            _time = _duration - _time;
                        }
                    }
                    if (_time > _duration)
                    {
                        _time = _duration;
                        time = _duration + 0.0001;
                    }
                    else if (_time < 0)
                    {
                        _time = time = 0;
                    }
                    else
                    {
                        time = _time;
                    }
                }
            }
        }
        if (_cycle != prevCycle)
        {
            if (!_locked)
            {
                backwards = _yoyo && (prevCycle & 1) != 0;
                wrap = backwards == (_yoyo && (_cycle & 1) != 0);
                recTotalTime = _totalTime;
                recCycle = _cycle;
                recRawPrevTime = _rawPrevTime;
                recTime = _time;
                _totalTime = prevCycle * _duration;
                if (_cycle < prevCycle)
                {
                    backwards = !backwards;
                }
                else
                {
                    _totalTime += _duration;
                }
                _time = prevTime;
                _rawPrevTime = prevRawPrevTime;
                _cycle = prevCycle;
                _locked = true;
                prevTime = !!(backwards) ? 0 : as3hx.Compat.parseFloat(_duration);
                render(prevTime, suppressEvents, false);
                if (!suppressEvents)
                {
                    if (!_gc)
                    {
                        if (vars.onRepeat)
                        {
                            vars.onRepeat.apply(null, vars.onRepeatParams);
                        }
                        if (_dispatcher != null)
                        {
                            _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
                        }
                    }
                }
                if (wrap)
                {
                    prevTime = !!(backwards) ? as3hx.Compat.parseFloat(_duration + 0.0001) : -0.0001;
                    render(prevTime, true, false);
                }
                _locked = false;
                if (_paused && !prevPaused)
                {
                    return;
                }
                _time = recTime;
                _totalTime = recTotalTime;
                _cycle = recCycle;
                _rawPrevTime = recRawPrevTime;
            }
        }
        if ((_time == prevTime || !_first) && !force && !internalForce)
        {
            if (prevTotalTime != _totalTime)
            {
                if (_onUpdate != null)
                {
                    if (!suppressEvents)
                    {
                        _onUpdate.apply(vars.onUpdateScope || this, vars.onUpdateParams);
                    }
                }
            }
            return;
        }
        if (!_initted)
        {
            _initted = true;
        }
        if (!_active)
        {
            if (!_paused && _totalTime != prevTotalTime && time > 0)
            {
                _active = true;
            }
        }
        if (prevTotalTime == 0)
        {
            if (_totalTime != 0)
            {
                if (!suppressEvents)
                {
                    if (vars.onStart)
                    {
                        vars.onStart.apply(this, vars.onStartParams);
                    }
                    if (_dispatcher != null)
                    {
                        _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
                    }
                }
            }
        }
        if (_time >= prevTime)
        {
            tween = _first;
            while (tween)
            {
                next = tween._next;
                if (_paused && !prevPaused)
                {
                    break;
                }
                if (tween._active || tween._startTime <= _time && !tween._paused && !tween._gc)
                {
                    if (!tween._reversed)
                    {
                        tween.render((time - tween._startTime) * tween._timeScale, suppressEvents, force);
                    }
                    else
                    {
                        tween.render((!(tween._dirty) ? tween._totalDuration : tween.totalDuration()) - (time - tween._startTime) * tween._timeScale, suppressEvents, force);
                    }
                }
                tween = next;
            }
        }
        else
        {
            tween = _last;
            while (tween)
            {
                next = tween._prev;
                if (_paused && !prevPaused)
                {
                    break;
                }
                if (tween._active || tween._startTime <= prevTime && !tween._paused && !tween._gc)
                {
                    if (!tween._reversed)
                    {
                        tween.render((time - tween._startTime) * tween._timeScale, suppressEvents, force);
                    }
                    else
                    {
                        tween.render((!(tween._dirty) ? tween._totalDuration : tween.totalDuration()) - (time - tween._startTime) * tween._timeScale, suppressEvents, force);
                    }
                }
                tween = next;
            }
        }
        if (_onUpdate != null)
        {
            if (!suppressEvents)
            {
                _onUpdate.apply(null, vars.onUpdateParams);
            }
        }
        if (_hasUpdateListener)
        {
            if (!suppressEvents)
            {
                _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
            }
        }
        if (callback != null)
        {
            if (!_locked)
            {
                if (!_gc)
                {
                    if (prevStart == _startTime || prevTimeScale != _timeScale)
                    {
                        if (_time == 0 || totalDur >= totalDuration())
                        {
                            if (isComplete)
                            {
                                if (_timeline.autoRemoveChildren)
                                {
                                    _enabled(false, false);
                                }
                                _active = false;
                            }
                            if (!suppressEvents)
                            {
                                if (Reflect.field(vars, callback) != null)
                                {
                                    Reflect.field(vars, callback).apply(null, Reflect.field(vars, Std.string(callback + "Params")));
                                }
                                if (_dispatcher != null)
                                {
                                    _dispatcher.dispatchEvent(new TweenEvent((callback == "onComplete") ? TweenEvent.COMPLETE : TweenEvent.REVERSE_COMPLETE));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public function removeCallback(callback : Function, position : Dynamic = null) : TimelineMax
    {
        var a : Array<Dynamic> = null;
        var i : Int = 0;
        var time : Float = Math.NaN;
        if (callback != null)
        {
            if (position == null)
            {
                _kill(null, callback);
            }
            else
            {
                a = getTweensOf(callback, false);
                i = a.length;
                time = _parseTimeOrLabel(position);
                while (--i > -1)
                {
                    if (a[i]._startTime == time)
                    {
                        a[i]._enabled(false, false);
                    }
                }
            }
        }
        return this;
    }
    
    public function yoyo(value : Bool = false) : Dynamic
    {
        if (!arguments.length)
        {
            return _yoyo;
        }
        _yoyo = value;
        return this;
    }
    
    override public function progress(value : Float = Math.NaN, suppressEvents : Bool = false) : Dynamic
    {
        return !(arguments.length) ? _time / duration() : totalTime(duration() * ((_yoyo && (_cycle & 1) != 0) ? 1 - value : value) + _cycle * (_duration + _repeatDelay), suppressEvents);
    }
    
    public function repeatDelay(value : Float = 0) : Dynamic
    {
        if (!arguments.length)
        {
            return _repeatDelay;
        }
        _repeatDelay = value;
        return _uncache(true);
    }
    
    override public function time(value : Float = Math.NaN, suppressEvents : Bool = false) : Dynamic
    {
        if (!arguments.length)
        {
            return _time;
        }
        if (_dirty)
        {
            totalDuration();
        }
        if (value > _duration)
        {
            value = _duration;
        }
        if (_yoyo && (_cycle & 1) != 0)
        {
            value = _duration - value + _cycle * (_duration + _repeatDelay);
        }
        else if (_repeat != 0)
        {
            value += _cycle * (_duration + _repeatDelay);
        }
        return totalTime(value, suppressEvents);
    }
    
    private function _initDispatcher() : Bool
    {
        var p : Dynamic = null;
        var found : Bool = false;
        for (p in Reflect.fields(_listenerLookup))
        {
            if (Lambda.has(vars, p))
            {
                if (Std.is(Reflect.field(vars, Std.string(p)), Function))
                {
                    if (_dispatcher == null)
                    {
                        _dispatcher = new EventDispatcher(this);
                    }
                    _dispatcher.addEventListener(Reflect.field(_listenerLookup, Std.string(p)), Reflect.field(vars, Std.string(p)), false, 0, true);
                    found = true;
                }
            }
        }
        return found;
    }
    
    override public function invalidate() : Dynamic
    {
        _yoyo = cast(this.vars.yoyo == true, Bool);
        _repeat = (as3hx.Compat.parseInt(this.vars.repeat) || 0) ? 1 : 0;
        _repeatDelay = as3hx.Compat.parseFloat(this.vars.repeatDelay) || 0;
        _hasUpdateListener = false;
        _initDispatcher();
        _uncache(true);
        return super.invalidate();
    }
    
    public function getActive(nested : Bool = true, tweens : Bool = true, timelines : Bool = false) : Array<Dynamic>
    {
        var i : Int = 0;
        var tween : Animation = null;
        var a : Array<Dynamic> = [];
        var all : Array<Dynamic> = getChildren(nested, tweens, timelines);
        var cnt : Int = 0;
        var l : Int = all.length;
        for (i in 0...l)
        {
            tween = all[i];
            if (!tween._paused)
            {
                if (tween._timeline._time >= tween._startTime)
                {
                    if (tween._timeline._time < tween._startTime + tween._totalDuration / tween._timeScale)
                    {
                        if (!_getGlobalPaused(tween._timeline))
                        {
                            var _loc10_ : Dynamic = cnt++;
                            Reflect.setField(a, Std.string(_loc10_), tween);
                        }
                    }
                }
            }
        }
        return a;
    }
    
    public function getLabelAfter(time : Float = Math.NaN) : String
    {
        var i : Int = 0;
        if (!time)
        {
            if (time != 0)
            {
                time = _time;
            }
        }
        var labels : Array<Dynamic> = getLabelsArray();
        var l : Int = labels.length;
        for (i in 0...l)
        {
            if (labels[i].time > time)
            {
                return labels[i].name;
            }
        }
        return null;
    }
    
    override public function totalDuration(value : Float = Math.NaN) : Dynamic
    {
        if (!arguments.length)
        {
            if (_dirty)
            {
                super.totalDuration();
                _totalDuration = _repeat == -(1) ? 999999999999 : as3hx.Compat.parseFloat(_duration * (_repeat + 1) + _repeatDelay * _repeat);
            }
            return _totalDuration;
        }
        return _repeat == -(1) ? this : duration((value - _repeat * _repeatDelay) / (_repeat + 1));
    }
}

