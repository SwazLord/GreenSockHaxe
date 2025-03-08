package com.greensock;

import haxe.Constraints.Function;
import com.greensock.core.Animation;
import com.greensock.core.PropTween;
import com.greensock.core.SimpleTimeline;
import com.greensock.events.TweenEvent;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.BevelFilterPlugin;
import com.greensock.plugins.BezierPlugin;
import com.greensock.plugins.BezierThroughPlugin;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.ColorMatrixFilterPlugin;
import com.greensock.plugins.ColorTransformPlugin;
import com.greensock.plugins.DropShadowFilterPlugin;
import com.greensock.plugins.EndArrayPlugin;
import com.greensock.plugins.FrameLabelPlugin;
import com.greensock.plugins.FramePlugin;
import com.greensock.plugins.GlowFilterPlugin;
import com.greensock.plugins.HexColorsPlugin;
import com.greensock.plugins.RemoveTintPlugin;
import com.greensock.plugins.RoundPropsPlugin;
import com.greensock.plugins.ShortRotationPlugin;
import com.greensock.plugins.TintPlugin;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.VisiblePlugin;
import com.greensock.plugins.VolumePlugin;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

class TweenMax extends TweenLite implements IEventDispatcher
{
    
    public static var ticker : Shape = Animation.ticker;
    
    public static var allFromTo : Function = staggerFromTo;
    
    public static inline var version : String = "12.1.5";
    
    private static var _listenerLookup : Dynamic = {
            onCompleteListener : TweenEvent.COMPLETE,
            onUpdateListener : TweenEvent.UPDATE,
            onStartListener : TweenEvent.START,
            onRepeatListener : TweenEvent.REPEAT,
            onReverseCompleteListener : TweenEvent.REVERSE_COMPLETE
        };
    
    public static var allFrom : Function = staggerFrom;
    
    public static var allTo : Function = staggerTo;
    
    
    
    private var _dispatcher : EventDispatcher;
    
    public var _yoyo : Bool;
    
    private var _hasUpdateListener : Bool;
    
    private var _cycle : Int = 0;
    
    private var _repeatDelay : Float = 0;
    
    private var _repeat : Int = 0;
    
    public function new(target : Dynamic, duration : Float, vars : Dynamic)
    {
        super(target, duration, vars);
        _yoyo = this.vars.yoyo == true;
        _repeat = as3hx.Compat.parseInt(this.vars.repeat);
        _repeatDelay = as3hx.Compat.parseFloat(this.vars.repeatDelay) || 0;
        _dirty = true;
        if (this.vars.onCompleteListener || this.vars.onUpdateListener || this.vars.onStartListener || this.vars.onRepeatListener || this.vars.onReverseCompleteListener)
        {
            _initDispatcher();
            if (_duration == 0)
            {
                if (_delay == 0)
                {
                    if (this.vars.immediateRender)
                    {
                        _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
                        _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
                    }
                }
            }
        }
    }
    
    public static function resumeAll(tweens : Bool = true, delayedCalls : Bool = true, timelines : Bool = true) : Void
    {
        _changePause(false, tweens, delayedCalls, timelines);
    }
    
    public static function fromTo(target : Dynamic, duration : Float, fromVars : Dynamic, toVars : Dynamic) : TweenMax
    {
        toVars = _prepVars(toVars, false);
        fromVars = _prepVars(fromVars, false);
        toVars.startAt = fromVars;
        toVars.immediateRender = toVars.immediateRender != false && fromVars.immediateRender != false;
        return new TweenMax(target, duration, toVars);
    }
    
    public static function staggerTo(targets : Array<Dynamic>, duration : Float, vars : Dynamic, stagger : Float = 0, onCompleteAll : Function = null, onCompleteAllParams : Array<Dynamic> = null) : Array<Dynamic>
    {
        var copy : Dynamic = null;
        var i : Int = 0;
        var p : String = null;
        vars = _prepVars(vars, false);
        var a : Array<Dynamic> = [];
        var l : Int = targets.length;
        var delay : Float = as3hx.Compat.parseFloat(vars.delay) || 0;
        for (i in 0...l)
        {
            copy = { };
            for (p in Reflect.fields(vars))
            {
                Reflect.setField(copy, p, Reflect.field(vars, p));
            }
            copy.delay = delay;
            if (i == l - 1)
            {
                if (onCompleteAll != null)
                {
                    copy.onComplete = function() : Void
                            {
                                if (vars.onComplete)
                                {
                                    vars.onComplete.apply(null, arguments);
                                }
                                Reflect.callMethod(null, onCompleteAll, onCompleteAllParams);
                            };
                }
            }
            a[i] = new TweenMax(targets[i], duration, copy);
            delay += stagger;
        }
        return a;
    }
    
    public static function pauseAll(tweens : Bool = true, delayedCalls : Bool = true, timelines : Bool = true) : Void
    {
        _changePause(true, tweens, delayedCalls, timelines);
    }
    
    public static function staggerFromTo(targets : Array<Dynamic>, duration : Float, fromVars : Dynamic, toVars : Dynamic, stagger : Float = 0, onCompleteAll : Function = null, onCompleteAllParams : Array<Dynamic> = null) : Array<Dynamic>
    {
        toVars = _prepVars(toVars, false);
        fromVars = _prepVars(fromVars, false);
        toVars.startAt = fromVars;
        toVars.immediateRender = toVars.immediateRender != false && fromVars.immediateRender != false;
        return staggerTo(targets, duration, toVars, stagger, onCompleteAll, onCompleteAllParams);
    }
    
    public static function getTweensOf(target : Dynamic, onlyActive : Bool = false) : Array<Dynamic>
    {
        return TweenLite.getTweensOf(target, onlyActive);
    }
    
    public static function killTweensOf(target : Dynamic, onlyActive : Dynamic = false, vars : Dynamic = null) : Void
    {
        TweenLite.killTweensOf(target, onlyActive, vars);
    }
    
    public static function delayedCall(delay : Float, callback : Function, params : Array<Dynamic> = null, useFrames : Bool = false) : TweenMax
    {
        return new TweenMax(callback, 0, {
            delay : delay,
            onComplete : callback,
            onCompleteParams : params,
            onReverseComplete : callback,
            onReverseCompleteParams : params,
            immediateRender : false,
            useFrames : useFrames,
            overwrite : 0
        });
    }
    
    public static function isTweening(target : Dynamic) : Bool
    {
        return TweenLite.getTweensOf(target, true).length > 0;
    }
    
    public static function killAll(complete : Bool = false, tweens : Bool = true, delayedCalls : Bool = true, timelines : Bool = true) : Void
    {
        var isDC : Bool = false;
        var tween : Animation = null;
        var i : Int = 0;
        var a : Array<Dynamic> = getAllTweens(timelines);
        var l : Int = a.length;
        var allTrue : Bool = tweens && delayedCalls && timelines;
        for (i in 0...l)
        {
            tween = a[i];
            if (allTrue || Std.is(tween, SimpleTimeline) || (isDC = cast((tween), TweenLite).target == cast((tween), TweenLite).vars.onComplete) && delayedCalls || tweens && !isDC)
            {
                if (complete)
                {
                    tween.totalTime(!!(tween._reversed) ? 0 : as3hx.Compat.parseFloat(tween.totalDuration()));
                }
                else
                {
                    tween._enabled(false, false);
                }
            }
        }
    }
    
    public static function killChildTweensOf(parent : DisplayObjectContainer, complete : Bool = false) : Void
    {
        var i : Int = 0;
        var a : Array<Dynamic> = getAllTweens(false);
        var l : Int = a.length;
        for (i in 0...l)
        {
            if (_containsChildOf(parent, a[i].target))
            {
                if (complete)
                {
                    a[i].totalTime(a[i].totalDuration());
                }
                else
                {
                    a[i]._enabled(false, false);
                }
            }
        }
    }
    
    private static function _changePause(pause : Bool, tweens : Bool = true, delayedCalls : Bool = false, timelines : Bool = true) : Void
    {
        var isDC : Bool = false;
        var tween : Animation = null;
        var a : Array<Dynamic> = getAllTweens(timelines);
        var allTrue : Bool = tweens && delayedCalls && timelines;
        var i : Int = a.length;
        while (--i > -1)
        {
            tween = a[i];
            isDC = Std.is(tween, TweenLite) && cast((tween), TweenLite).target == tween.vars.onComplete;
            if (allTrue || Std.is(tween, SimpleTimeline) || isDC && delayedCalls || tweens && !isDC)
            {
                tween.paused(pause);
            }
        }
    }
    
    public static function set(target : Dynamic, vars : Dynamic) : TweenMax
    {
        return new TweenMax(target, 0, vars);
    }
    
    public static function from(target : Dynamic, duration : Float, vars : Dynamic) : TweenMax
    {
        vars = _prepVars(vars, true);
        vars.runBackwards = true;
        return new TweenMax(target, duration, vars);
    }
    
    public static function killDelayedCallsTo(func : Function) : Void
    {
        TweenLite.killTweensOf(func);
    }
    
    public static function globalTimeScale(value : Float = Math.NaN) : Float
    {
        if (!arguments.length)
        {
            return (_rootTimeline == null) ? 1 : as3hx.Compat.parseFloat(_rootTimeline._timeScale);
        }
        value = value || 0.0001;
        if (_rootTimeline == null)
        {
            TweenLite.to({ }, 0, { });
        }
        var tl : SimpleTimeline = _rootTimeline;
        var t : Float = Math.round(haxe.Timer.stamp() * 1000) / 1000;
        tl._startTime = t - (t - tl._startTime) * tl._timeScale / value;
        tl = _rootFramesTimeline;
        t = _rootFrame;
        tl._startTime = t - (t - tl._startTime) * tl._timeScale / value;
        _rootFramesTimeline._timeScale = _rootTimeline._timeScale = value;
        return value;
    }
    
    public static function getAllTweens(includeTimelines : Bool = false) : Array<Dynamic>
    {
        var a : Array<Dynamic> = _getChildrenOf(_rootTimeline, includeTimelines);
        return a.concat(_getChildrenOf(_rootFramesTimeline, includeTimelines));
    }
    
    private static function _getChildrenOf(timeline : SimpleTimeline, includeTimelines : Bool) : Array<Dynamic>
    {
        if (timeline == null)
        {
            return [];
        }
        var a : Array<Dynamic> = [];
        var cnt : Int = 0;
        var tween : Animation = timeline._first;
        while (tween)
        {
            if (Std.is(tween, TweenLite))
            {
                var _loc6_ : Dynamic = cnt++;
                Reflect.setField(a, Std.string(_loc6_), tween);
            }
            else
            {
                if (includeTimelines)
                {
                    _loc6_ = cnt++;
                    a[_loc6_] = tween;
                }
                a = a.concat(_getChildrenOf(cast((tween), SimpleTimeline), includeTimelines));
                cnt = a.length;
            }
            tween = tween._next;
        }
        return a;
    }
    
    private static function _containsChildOf(parent : DisplayObjectContainer, obj : Dynamic) : Bool
    {
        var i : Int = 0;
        var curParent : DisplayObjectContainer = null;
        if (Std.is(obj, Array))
        {
            i = obj.length;
            while (--i > -1)
            {
                if (_containsChildOf(parent, Reflect.field(obj, Std.string(i))))
                {
                    return true;
                }
            }
        }
        else if (Std.is(obj, DisplayObject))
        {
            curParent = obj.parent;
            while (curParent)
            {
                if (curParent == parent)
                {
                    return true;
                }
                curParent = curParent.parent;
            }
        }
        return false;
    }
    
    public static function staggerFrom(targets : Array<Dynamic>, duration : Float, vars : Dynamic, stagger : Float = 0, onCompleteAll : Function = null, onCompleteAllParams : Array<Dynamic> = null) : Array<Dynamic>
    {
        vars = _prepVars(vars, true);
        vars.runBackwards = true;
        if (vars.immediateRender != false)
        {
            vars.immediateRender = true;
        }
        return staggerTo(targets, duration, vars, stagger, onCompleteAll, onCompleteAllParams);
    }
    
    public static function to(target : Dynamic, duration : Float, vars : Dynamic) : TweenMax
    {
        return new TweenMax(target, duration, vars);
    }
    
    public function dispatchEvent(event : Event) : Bool
    {
        return (_dispatcher == null) ? cast(false, Bool) : cast(_dispatcher.dispatchEvent(event), Bool);
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
    
    public function removeEventListener(type : String, listener : Function, useCapture : Bool = false) : Void
    {
        if (_dispatcher != null)
        {
            _dispatcher.removeEventListener(type, listener, useCapture);
        }
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
    
    public function willTrigger(type : String) : Bool
    {
        return (_dispatcher == null) ? cast(false, Bool) : cast(_dispatcher.willTrigger(type), Bool);
    }
    
    override public function duration(value : Float = Math.NaN) : Dynamic
    {
        if (!arguments.length)
        {
            return this._duration;
        }
        return super.duration(value);
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
    
    override public function render(time : Float, suppressEvents : Bool = false, force : Bool = false) : Void
    {
        var isComplete : Bool = false;
        var callback : String = null;
        var pt : PropTween = null;
        var rawPrevTime : Float = Math.NaN;
        var cycleDuration : Float = Math.NaN;
        var r : Float = Math.NaN;
        var type : Int = 0;
        var pow : Int = 0;
        if (!_initted)
        {
            if (_duration == 0 && vars.repeat)
            {
                invalidate();
            }
        }
        var totalDur : Float = !(_dirty) ? as3hx.Compat.parseFloat(_totalDuration) : as3hx.Compat.parseFloat(totalDuration());
        var prevTime : Float = _time;
        var prevTotalTime : Float = _totalTime;
        var prevCycle : Float = _cycle;
        if (time >= totalDur)
        {
            _totalTime = totalDur;
            _cycle = _repeat;
            if (_yoyo && (_cycle & 1) != 0)
            {
                _time = 0;
                ratio = !!(_ease._calcEnd) ? as3hx.Compat.parseFloat(_ease.getRatio(0)) : 0;
            }
            else
            {
                _time = _duration;
                ratio = !!(_ease._calcEnd) ? as3hx.Compat.parseFloat(_ease.getRatio(1)) : 1;
            }
            if (!_reversed)
            {
                isComplete = true;
                callback = "onComplete";
            }
            if (_duration == 0)
            {
                rawPrevTime = _rawPrevTime;
                if (_startTime == _timeline._duration)
                {
                    time = 0;
                }
                if (time == 0 || rawPrevTime < 0 || rawPrevTime == _tinyNum)
                {
                    if (rawPrevTime != time)
                    {
                        force = true;
                        if (rawPrevTime > _tinyNum)
                        {
                            callback = "onReverseComplete";
                        }
                    }
                }
                _rawPrevTime = rawPrevTime = !(suppressEvents || time != 0 || _rawPrevTime == time) ? time : as3hx.Compat.parseFloat(_tinyNum);
            }
        }
        else if (time < 1e-7)
        {
            _totalTime = _time = _cycle = 0;
            ratio = !!(_ease._calcEnd) ? as3hx.Compat.parseFloat(_ease.getRatio(0)) : 0;
            if (prevTotalTime != 0 || _duration == 0 && _rawPrevTime > 0 && _rawPrevTime != _tinyNum)
            {
                callback = "onReverseComplete";
                isComplete = _reversed;
            }
            if (time < 0)
            {
                _active = false;
                if (_duration == 0)
                {
                    if (_rawPrevTime >= 0)
                    {
                        force = true;
                    }
                    _rawPrevTime = rawPrevTime = !(suppressEvents || time != 0 || _rawPrevTime == time) ? time : as3hx.Compat.parseFloat(_tinyNum);
                }
            }
            else if (!_initted)
            {
                force = true;
            }
        }
        else
        {
            _totalTime = _time = time;
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
                }
                else if (_time < 0)
                {
                    _time = 0;
                }
            }
            if (_easeType)
            {
                r = _time / _duration;
                type = _easeType;
                pow = _easePower;
                if (type == 1 || type == 3 && r >= 0.5)
                {
                    r = 1 - r;
                }
                if (type == 3)
                {
                    r *= 2;
                }
                if (pow == 1)
                {
                    r *= r;
                }
                else if (pow == 2)
                {
                    r *= r * r;
                }
                else if (pow == 3)
                {
                    r *= r * r * r;
                }
                else if (pow == 4)
                {
                    r *= r * r * r * r;
                }
                if (type == 1)
                {
                    ratio = 1 - r;
                }
                else if (type == 2)
                {
                    ratio = r;
                }
                else if (_time / _duration < 0.5)
                {
                    ratio = r / 2;
                }
                else
                {
                    ratio = 1 - r / 2;
                }
            }
            else
            {
                ratio = _ease.getRatio(_time / _duration);
            }
        }
        if (prevTime == _time && !force && _cycle == prevCycle)
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
            _init();
            if (!_initted || _gc)
            {
                return;
            }
            if (_time && !isComplete)
            {
                ratio = _ease.getRatio(_time / _duration);
            }
            else if (isComplete && _ease._calcEnd)
            {
                ratio = _ease.getRatio((_time == 0) ? 0 : 1);
            }
        }
        if (!_active)
        {
            if (!_paused && _time != prevTime && time >= 0)
            {
                _active = true;
            }
        }
        if (prevTotalTime == 0)
        {
            if (_startAt != null)
            {
                if (time >= 0)
                {
                    _startAt.render(time, suppressEvents, force);
                }
                else if (callback == null)
                {
                    callback = "_dummyGS";
                }
            }
            if (_totalTime != 0 || _duration == 0)
            {
                if (!suppressEvents)
                {
                    if (vars.onStart)
                    {
                        vars.onStart.apply(null, vars.onStartParams);
                    }
                    if (_dispatcher != null)
                    {
                        _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
                    }
                }
            }
        }
        pt = _firstPT;
        while (pt)
        {
            if (pt.f)
            {
                pt.t[pt.p](pt.c * ratio + pt.s);
            }
            else
            {
                pt.t[pt.p] = pt.c * ratio + pt.s;
            }
            pt = pt._next;
        }
        if (_onUpdate != null)
        {
            if (time < 0 && _startAt != null && _startTime != 0)
            {
                _startAt.render(time, suppressEvents, force);
            }
            if (!suppressEvents)
            {
                if (_totalTime != prevTotalTime || isComplete)
                {
                    _onUpdate.apply(null, vars.onUpdateParams);
                }
            }
        }
        if (_hasUpdateListener)
        {
            if (time < 0 && _startAt != null && _onUpdate == null && _startTime != 0)
            {
                _startAt.render(time, suppressEvents, force);
            }
            if (!suppressEvents)
            {
                _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
            }
        }
        if (_cycle != prevCycle)
        {
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
        }
        if (callback != null)
        {
            if (!_gc)
            {
                if (time < 0 && _startAt != null && _onUpdate == null && !_hasUpdateListener && _startTime != 0)
                {
                    _startAt.render(time, suppressEvents, true);
                }
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
                if (_duration == 0 && _rawPrevTime == _tinyNum && rawPrevTime != _tinyNum)
                {
                    _rawPrevTime = 0;
                }
            }
        }
    }
    
    override public function totalProgress(value : Float = Math.NaN, suppressEvents : Bool = false) : Dynamic
    {
        return !(arguments.length) ? _totalTime / totalDuration() : totalTime(totalDuration() * value, suppressEvents);
    }
    
    public function repeat(value : Int = 0) : Dynamic
    {
        if (!arguments.length)
        {
            return _repeat;
        }
        _repeat = value;
        return _uncache(true);
    }
    
    public function updateTo(vars : Dynamic, resetDuration : Bool = false) : Dynamic
    {
        var p : Dynamic = null;
        var prevTime : Float = Math.NaN;
        var inv : Float = Math.NaN;
        var pt : PropTween = null;
        var endValue : Float = Math.NaN;
        var curRatio : Float = ratio;
        if (resetDuration)
        {
            if (_startTime < _timeline._time)
            {
                _startTime = _timeline._time;
                _uncache(false);
                if (_gc)
                {
                    _enabled(true, false);
                }
                else
                {
                    _timeline.insert(this, _startTime - _delay);
                }
            }
        }
        for (p in Reflect.fields(vars))
        {
            this.vars[p] = Reflect.field(vars, Std.string(p));
        }
        if (_initted)
        {
            if (resetDuration)
            {
                _initted = false;
            }
            else
            {
                if (_gc)
                {
                    _enabled(true, false);
                }
                if (_notifyPluginsOfEnabled)
                {
                    if (_firstPT != null)
                    {
                        _onPluginEvent("_onDisable", this);
                    }
                }
                if (_time / _duration > 0.998)
                {
                    prevTime = _time;
                    render(0, true, false);
                    _initted = false;
                    render(prevTime, true, false);
                }
                else if (_time > 0)
                {
                    _initted = false;
                    _init();
                    inv = 1 / (1 - curRatio);
                    pt = _firstPT;
                    while (pt)
                    {
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
    
    public function repeatDelay(value : Float = Math.NaN) : Dynamic
    {
        if (!arguments.length)
        {
            return _repeatDelay;
        }
        _repeatDelay = value;
        return _uncache(true);
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
    
    override public function totalDuration(value : Float = Math.NaN) : Dynamic
    {
        if (!arguments.length)
        {
            if (_dirty)
            {
                _totalDuration = _repeat == -(1) ? 999999999999 : as3hx.Compat.parseFloat(_duration * (_repeat + 1) + _repeatDelay * _repeat);
                _dirty = false;
            }
            return _totalDuration;
        }
        return _repeat == -(1) ? this : duration((value - _repeat * _repeatDelay) / (_repeat + 1));
    }
    
    public function hasEventListener(type : String) : Bool
    {
        return (_dispatcher == null) ? cast(false, Bool) : cast(_dispatcher.hasEventListener(type), Bool);
    }
    private static var TweenMax_static_initializer = {
        {
            TweenPlugin.activate([AutoAlphaPlugin, EndArrayPlugin, FramePlugin, RemoveTintPlugin, TintPlugin, VisiblePlugin, VolumePlugin, BevelFilterPlugin, BezierPlugin, BezierThroughPlugin, BlurFilterPlugin, ColorMatrixFilterPlugin, ColorTransformPlugin, DropShadowFilterPlugin, FrameLabelPlugin, GlowFilterPlugin, HexColorsPlugin, RoundPropsPlugin, ShortRotationPlugin]);
        };
        true;
    }

}

