package com.greensock.core;

import haxe.Constraints.Function;
import flash.display.Shape;
import flash.events.Event;

class Animation
{
    
    private static var _tinyNum : Float = 1e-10;
    
    public static var _rootFramesTimeline : SimpleTimeline;
    
    public static var _rootTimeline : SimpleTimeline;
    
    public static var ticker : Shape = new Shape();
    
    private static var _rootFrame : Float = -1;
    
    private static var _tickEvent : Event = new Event("tick");
    
    public static inline var version : String = "12.1.1";
    
    
    public var _delay : Float;
    
    public var _prev : Animation;
    
    public var _reversed : Bool;
    
    public var _active : Bool;
    
    public var _timeline : SimpleTimeline;
    
    public var _rawPrevTime : Float;
    
    public var data;
    
    public var vars : Dynamic;
    
    public var _totalTime : Float;
    
    public var _time : Float;
    
    public var timeline : SimpleTimeline;
    
    public var _initted : Bool;
    
    public var _paused : Bool;
    
    public var _startTime : Float;
    
    public var _dirty : Bool;
    
    public var _next : Animation;
    
    private var _onUpdate : Function;
    
    public var _pauseTime : Float;
    
    public var _duration : Float;
    
    public var _totalDuration : Float;
    
    public var _gc : Bool;
    
    public var _timeScale : Float;
    
    public function new(duration : Float = 0, vars : Dynamic = null)
    {
        super();
        this.vars = vars || { };
        if (this.vars._isGSVars)
        {
            this.vars = this.vars.vars;
        }
        _duration = _totalDuration = duration || 0;
        _delay = as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(this.vars.delay)) || 0;
        _timeScale = 1;
        _totalTime = _time = 0;
        data = this.vars.data;
        _rawPrevTime = -1;
        if (_rootTimeline == null)
        {
            if (_rootFrame != -1)
            {
                return;
            }
            _rootFrame = 0;
            _rootFramesTimeline = new SimpleTimeline();
            _rootTimeline = new SimpleTimeline();
            _rootTimeline._startTime = Math.round(haxe.Timer.stamp() * 1000) / 1000;
            _rootFramesTimeline._startTime = 0;
            _rootTimeline._active = _rootFramesTimeline._active = true;
            ticker.addEventListener("enterFrame", _updateRoot, false, 0, true);
        }
        var tl : SimpleTimeline = (cast(this.vars.useFrames, Bool)) ? _rootFramesTimeline : _rootTimeline;
        tl.add(this, tl._time);
        _reversed = this.vars.reversed == true;
        if (this.vars.paused)
        {
            paused(true);
        }
    }
    
    public static function _updateRoot(event : Event = null) : Void
    {
        ++_rootFrame;
        _rootTimeline.render((Math.round(haxe.Timer.stamp() * 1000) / 1000 - _rootTimeline._startTime) * _rootTimeline._timeScale, false, false);
        _rootFramesTimeline.render((_rootFrame - _rootFramesTimeline._startTime) * _rootFramesTimeline._timeScale, false, false);
        ticker.dispatchEvent(_tickEvent);
    }
    
    public function delay(value : Float = Math.NaN) : Dynamic
    {
        if (!arguments.length)
        {
            return _delay;
        }
        if (_timeline.smoothChildTiming)
        {
            startTime(_startTime + value - _delay);
        }
        _delay = value;
        return this;
    }
    
    public function totalDuration(value : Float = Math.NaN) : Dynamic
    {
        _dirty = false;
        return !(arguments.length) ? _totalDuration : duration(value);
    }
    
    public function _enabled(enabled : Bool, ignoreTimeline : Bool = false) : Bool
    {
        _gc = !enabled;
        _active = cast(enabled && !_paused && _totalTime > 0 && _totalTime < _totalDuration, Bool);
        if (!ignoreTimeline)
        {
            if (enabled && timeline == null)
            {
                _timeline.add(this, _startTime - _delay);
            }
            else if (!enabled && timeline != null)
            {
                _timeline._remove(this, true);
            }
        }
        return false;
    }
    
    public function timeScale(value : Float = Math.NaN) : Dynamic
    {
        var t : Float = Math.NaN;
        if (!arguments.length)
        {
            return _timeScale;
        }
        value = value || 0.000001;
        if (_timeline != null && _timeline.smoothChildTiming)
        {
            t = ((_pauseTime != 0 && !Math.isNaN(_pauseTime)) || _pauseTime == 0) ? _pauseTime : as3hx.Compat.parseFloat(_timeline._totalTime);
            _startTime = t - (t - _startTime) * _timeScale / value;
        }
        _timeScale = value;
        return _uncache(false);
    }
    
    private function _swapSelfInParams(params : Array<Dynamic>) : Array<Dynamic>
    {
        var i : Int = params.length;
        var copy : Array<Dynamic> = params.copy();
        while (--i > -1)
        {
            if (params[i] == "{self}")
            {
                copy[i] = this;
            }
        }
        return copy;
    }
    
    public function totalProgress(value : Float = Math.NaN, suppressEvents : Bool = false) : Dynamic
    {
        return !(arguments.length) ? _time / duration() : totalTime(duration() * value, suppressEvents);
    }
    
    public function duration(value : Float = Math.NaN) : Dynamic
    {
        if (!arguments.length)
        {
            _dirty = false;
            return _duration;
        }
        _duration = _totalDuration = value;
        _uncache(true);
        if (_timeline.smoothChildTiming)
        {
            if (_time > 0)
            {
                if (_time < _duration)
                {
                    if (value != 0)
                    {
                        totalTime(_totalTime * (value / _duration), true);
                    }
                }
            }
        }
        return this;
    }
    
    public function restart(includeDelay : Bool = false, suppressEvents : Bool = true) : Dynamic
    {
        reversed(false);
        paused(false);
        return totalTime(!!(includeDelay) ? -_delay : 0, suppressEvents, true);
    }
    
    public function render(time : Float, suppressEvents : Bool = false, force : Bool = false) : Void
    {
    }
    
    public function resume(from : Dynamic = null, suppressEvents : Bool = true) : Dynamic
    {
        if (from != null)
        {
            seek(from, suppressEvents);
        }
        return paused(false);
    }
    
    public function paused(value : Bool = false) : Dynamic
    {
        var raw : Float = Math.NaN;
        var elapsed : Float = Math.NaN;
        if (!arguments.length)
        {
            return _paused;
        }
        if (value != _paused)
        {
            if (_timeline != null)
            {
                raw = _timeline.rawTime();
                elapsed = raw - _pauseTime;
                if (!value && _timeline.smoothChildTiming)
                {
                    _startTime += elapsed;
                    _uncache(false);
                }
                _pauseTime = !!(value) ? raw : as3hx.Compat.parseFloat(Math.NaN);
                _paused = value;
                _active = !value && _totalTime > 0 && _totalTime < _totalDuration;
                if (!value && elapsed != 0 && _initted && duration() != 0)
                {
                    render(!!(_timeline.smoothChildTiming) ? _totalTime : as3hx.Compat.parseFloat((raw - _startTime) / _timeScale), true, true);
                }
            }
        }
        if (_gc && !value)
        {
            _enabled(true, false);
        }
        return this;
    }
    
    public function totalTime(time : Float = Math.NaN, suppressEvents : Bool = false, uncapped : Bool = false) : Dynamic
    {
        var tl : SimpleTimeline = null;
        if (!arguments.length)
        {
            return _totalTime;
        }
        if (_timeline != null)
        {
            if (time < 0 && !uncapped)
            {
                time += totalDuration();
            }
            if (_timeline.smoothChildTiming)
            {
                if (_dirty)
                {
                    totalDuration();
                }
                if (time > _totalDuration && !uncapped)
                {
                    time = _totalDuration;
                }
                tl = _timeline;
                _startTime = (!!(_paused) ? _pauseTime : tl._time) - (!(_reversed) ? time : _totalDuration - time) / _timeScale;
                if (!_timeline._dirty)
                {
                    _uncache(false);
                }
                if (tl._timeline != null)
                {
                    while (tl._timeline)
                    {
                        if (tl._timeline._time != (tl._startTime + tl._totalTime) / tl._timeScale)
                        {
                            tl.totalTime(tl._totalTime, true);
                        }
                        tl = tl._timeline;
                    }
                }
            }
            if (_gc)
            {
                _enabled(true, false);
            }
            if (_totalTime != time || _duration == 0)
            {
                render(time, suppressEvents, false);
            }
        }
        return this;
    }
    
    public function play(from : Dynamic = null, suppressEvents : Bool = true) : Dynamic
    {
        if (from != null)
        {
            seek(from, suppressEvents);
        }
        reversed(false);
        return paused(false);
    }
    
    public function invalidate() : Dynamic
    {
        return this;
    }
    
    public function progress(value : Float = Math.NaN, suppressEvents : Bool = false) : Dynamic
    {
        return !(arguments.length) ? _time / duration() : totalTime(duration() * value, suppressEvents);
    }
    
    public function _kill(vars : Dynamic = null, target : Dynamic = null) : Bool
    {
        return _enabled(false, false);
    }
    
    public function reversed(value : Bool = false) : Dynamic
    {
        if (!arguments.length)
        {
            return _reversed;
        }
        if (value != _reversed)
        {
            _reversed = value;
            totalTime(_timeline && !(_timeline.smoothChildTiming) ? as3hx.Compat.parseFloat(totalDuration() - _totalTime) : _totalTime, true);
        }
        return this;
    }
    
    public function startTime(value : Float = Math.NaN) : Dynamic
    {
        if (!arguments.length)
        {
            return _startTime;
        }
        if (value != _startTime)
        {
            _startTime = value;
            if (timeline != null)
            {
                if (timeline._sortChildren)
                {
                    timeline.add(this, value - _delay);
                }
            }
        }
        return this;
    }
    
    private function _uncache(includeSelf : Bool) : Dynamic
    {
        var tween : Animation = !!(includeSelf) ? this : timeline;
        while (tween)
        {
            tween._dirty = true;
            tween = tween.timeline;
        }
        return this;
    }
    
    public function isActive() : Bool
    {
        var rawTime : Float = Math.NaN;
        var tl : SimpleTimeline = _timeline;
        return tl == null || !_gc && !_paused && tl.isActive() && (rawTime = tl.rawTime()) >= _startTime && rawTime < _startTime + totalDuration() / _timeScale;
    }
    
    public function time(value : Float = Math.NaN, suppressEvents : Bool = false) : Dynamic
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
        return totalTime(value, suppressEvents);
    }
    
    public function kill(vars : Dynamic = null, target : Dynamic = null) : Dynamic
    {
        _kill(vars, target);
        return this;
    }
    
    public function reverse(from : Dynamic = null, suppressEvents : Bool = true) : Dynamic
    {
        if (from != null)
        {
            seek(from || totalDuration(), suppressEvents);
        }
        reversed(true);
        return paused(false);
    }
    
    public function seek(time : Dynamic, suppressEvents : Bool = true) : Dynamic
    {
        return totalTime(as3hx.Compat.parseFloat(time), suppressEvents);
    }
    
    public function pause(atTime : Dynamic = null, suppressEvents : Bool = true) : Dynamic
    {
        if (atTime != null)
        {
            seek(atTime, suppressEvents);
        }
        return paused(true);
    }
    
    public function eventCallback(type : String, callback : Function = null, params : Array<Dynamic> = null) : Dynamic
    {
        if (type == null)
        {
            return null;
        }
        if (type.substr(0, 2) == "on")
        {
            if (arguments.length == 1)
            {
                return Reflect.field(vars, type);
            }
            if (callback == null)
            {
                Reflect.deleteField(vars, type);
            }
            else
            {
                Reflect.setField(vars, type, callback);
                Reflect.setField(vars, Std.string(type + "Params"), "Params");
            }
            if (type == "onUpdate")
            {
                _onUpdate = callback;
            }
        }
        return this;
    }
}

