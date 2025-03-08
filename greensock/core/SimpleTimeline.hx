package com.greensock.core;


class SimpleTimeline extends Animation
{
    
    
    public var _first : Animation;
    
    public var autoRemoveChildren : Bool;
    
    public var _last : Animation;
    
    public var smoothChildTiming : Bool;
    
    public var _sortChildren : Bool;
    
    public function new(vars : Dynamic = null)
    {
        super(0, vars);
        this.autoRemoveChildren = this.smoothChildTiming = true;
    }
    
    public function add(child : Dynamic, position : Dynamic = "+=0", align : String = "normal", stagger : Float = 0) : Dynamic
    {
        var st : Float = Math.NaN;
        child._startTime = as3hx.Compat.parseFloat(position || 0) + child._delay;
        if (child._paused)
        {
            if (this != child._timeline)
            {
                child._pauseTime = child._startTime + (rawTime() - child._startTime) / child._timeScale;
            }
        }
        if (child.timeline)
        {
            child.timeline._remove(child, true);
        }
        child.timeline = child._timeline = this;
        if (child._gc)
        {
            child._enabled(true, true);
        }
        var prevTween : Animation = _last;
        if (_sortChildren)
        {
            st = child._startTime;
            while (prevTween && prevTween._startTime > st)
            {
                prevTween = prevTween._prev;
            }
        }
        if (prevTween != null)
        {
            child._next = prevTween._next;
            prevTween._next = cast((child), Animation);
        }
        else
        {
            child._next = _first;
            _first = cast((child), Animation);
        }
        if (child._next)
        {
            child._next._prev = child;
        }
        else
        {
            _last = cast((child), Animation);
        }
        child._prev = prevTween;
        if (_timeline != null)
        {
            _uncache(true);
        }
        return this;
    }
    
    public function _remove(tween : Animation, skipDisable : Bool = false) : Dynamic
    {
        if (tween.timeline == this)
        {
            if (!skipDisable)
            {
                tween._enabled(false, true);
            }
            if (tween._prev)
            {
                tween._prev._next = tween._next;
            }
            else if (_first == tween)
            {
                _first = tween._next;
            }
            if (tween._next)
            {
                tween._next._prev = tween._prev;
            }
            else if (_last == tween)
            {
                _last = tween._prev;
            }
            tween._next = tween._prev = tween.timeline = null;
            if (_timeline != null)
            {
                _uncache(true);
            }
        }
        return this;
    }
    
    public function rawTime() : Float
    {
        return _totalTime;
    }
    
    override public function render(time : Float, suppressEvents : Bool = false, force : Bool = false) : Void
    {
        var next : Animation = null;
        var tween : Animation = _first;
        _totalTime = _time = _rawPrevTime = time;
        while (tween)
        {
            next = tween._next;
            if (tween._active || time >= tween._startTime && !tween._paused)
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
    
    public function insert(child : Dynamic, position : Dynamic = 0) : Dynamic
    {
        return add(child, position || 0);
    }
}

