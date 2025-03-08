package com.greensock.plugins;

import com.greensock.TweenLite;
import com.greensock.core.Animation;
import com.greensock.core.SimpleTimeline;

class PhysicsPropsPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _runBackwards : Bool;
    
    private var _stepsPerTimeUnit : Int;
    
    private var _step : Int;
    
    private var _tween : TweenLite;
    
    private var _target : Dynamic;
    
    private var _props : Array<Dynamic>;
    
    private var _hasFriction : Bool;
    
    public function new()
    {
        super("physicsProps");
        _overwriteProps.pop();
    }
    
    override public function _roundProps(lookup : Dynamic, value : Bool = true) : Void
    {
        var i : Int = _props.length;
        while (--i > -1)
        {
            if (Lambda.has(lookup, "physicsProps") || Lambda.has(lookup, _props[i].p))
            {
                _props[i].r = value;
            }
        }
    }
    
    override public function setRatio(v : Float) : Void
    {
        var curProp : PhysicsProp = null;
        var val : Float = Math.NaN;
        var steps : Int = 0;
        var remainder : Float = Math.NaN;
        var j : Int = 0;
        var tt : Float = Math.NaN;
        var i : Int = _props.length;
        var time : Float = _tween._time;
        if (_runBackwards)
        {
            time = _tween._duration - time;
        }
        if (_hasFriction)
        {
            time *= _stepsPerTimeUnit;
            steps = as3hx.Compat.parseInt(as3hx.Compat.parseInt(time) - _step);
            remainder = time % 1;
            if (steps >= 0)
            {
                while (--i > -1)
                {
                    curProp = _props[i];
                    j = steps;
                    while (--j > -1)
                    {
                        curProp.v += curProp.a;
                        curProp.v *= curProp.friction;
                        curProp.value += curProp.v;
                    }
                    val = curProp.value + curProp.v * remainder;
                    if (curProp.r)
                    {
                        val = val + ((val < 0) ? -0.5 : 0.5) | 0;
                    }
                    if (curProp.f)
                    {
                        Reflect.field(_target, Std.string(curProp.p))(val);
                    }
                    else
                    {
                        Reflect.setField(_target, Std.string(curProp.p), val);
                    }
                }
            }
            else
            {
                while (--i > -1)
                {
                    curProp = _props[i];
                    j = -steps;
                    while (--j > -1)
                    {
                        curProp.value -= curProp.v;
                        curProp.v /= curProp.friction;
                        curProp.v -= curProp.a;
                    }
                    val = curProp.value + curProp.v * remainder;
                    if (curProp.r)
                    {
                        val = val + ((val < 0) ? -0.5 : 0.5) | 0;
                    }
                    if (curProp.f)
                    {
                        Reflect.field(_target, Std.string(curProp.p))(val);
                    }
                    else
                    {
                        Reflect.setField(_target, Std.string(curProp.p), val);
                    }
                }
            }
            _step += steps;
        }
        else
        {
            tt = time * time * 0.5;
            while (--i > -1)
            {
                curProp = _props[i];
                val = curProp.start + (curProp.velocity * time + curProp.acceleration * tt);
                if (curProp.r)
                {
                    val = val + ((val < 0) ? -0.5 : 0.5) | 0;
                }
                if (curProp.f)
                {
                    Reflect.field(_target, Std.string(curProp.p))(val);
                }
                else
                {
                    Reflect.setField(_target, Std.string(curProp.p), val);
                }
            }
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var p : Dynamic = null;
        var curProp : Dynamic = null;
        _target = target;
        _tween = tween;
        _runBackwards = _tween.vars.runBackwards == true;
        _step = 0;
        var tl : SimpleTimeline = _tween._timeline;
        var cnt : Int = 0;
        while (tl._timeline)
        {
            tl = tl._timeline;
        }
        _stepsPerTimeUnit = (tl == Animation._rootFramesTimeline) ? 1 : 30;
        _props = [];
        for (p in Reflect.fields(value))
        {
            curProp = Reflect.field(value, Std.string(p));
            if (curProp.velocity || curProp.acceleration)
            {
                var _loc10_ : Dynamic = cnt++;
                Reflect.setField(_props, Std.string(_loc10_), new PhysicsProp(target, p, curProp.velocity, curProp.acceleration, curProp.friction, _stepsPerTimeUnit));
                _overwriteProps[cnt] = p;
                if (curProp.friction)
                {
                    _hasFriction = true;
                }
            }
        }
        return true;
    }
    
    override public function _kill(lookup : Dynamic) : Bool
    {
        var i : Int = _props.length;
        while (--i > -1)
        {
            if (Lambda.has(lookup, _props[i].p))
            {
                _props.splice(i, 1);
            }
        }
        return super._kill(lookup);
    }
}


class PhysicsProp
{
    
    
    public var friction : Float;
    
    public var start : Float;
    
    public var f : Bool;
    
    public var a : Float;
    
    public var acceleration : Float;
    
    public var p : String;
    
    public var value : Float;
    
    public var r : Bool;
    
    public var v : Float;
    
    public var velocity : Float;
    
    private function new(target : Dynamic, p : String, velocity : Float, acceleration : Float, friction : Float, stepsPerTimeUnit : Int)
    {
        super();
        this.p = p;
        this.f = Std.is(Reflect.field(target, p), Function);
        this.start = this.value = !(this.f) ? as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(Reflect.field(target, p))) : as3hx.Compat.parseFloat(Reflect.field(target, Std.string(p.indexOf("set") || !((Lambda.has(target, "get" + p.substr(3)))) ? p : "get" + p.substr(3)))());
        this.velocity = velocity || 0;
        this.v = this.velocity / stepsPerTimeUnit;
        if ((acceleration != 0 && !Math.isNaN(acceleration)) || acceleration == 0)
        {
            this.acceleration = acceleration;
            this.a = this.acceleration / (stepsPerTimeUnit * stepsPerTimeUnit);
        }
        else
        {
            this.acceleration = this.a = 0;
        }
        this.friction = 1 - (friction || 0);
    }
}
