package com.greensock.plugins;

import haxe.Constraints.Function;
import com.greensock.TweenLite;

class DynamicPropsPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _prevFactor : Float;
    
    private var _tween : TweenLite;
    
    private var _target : Dynamic;
    
    private var _props : Array<Dynamic>;
    
    private var _prevTime : Float;
    
    public function new()
    {
        super("dynamicProps");
        _overwriteProps.pop();
        _props = [];
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
    
    override public function _roundProps(lookup : Dynamic, value : Bool = true) : Void
    {
        var i : Int = _props.length;
        while (--i > -1)
        {
            if (Lambda.has(lookup, "dynamicProps") || Lambda.has(lookup, _props[i].p))
            {
                _props[i].r = value;
            }
        }
    }
    
    override public function setRatio(v : Float) : Void
    {
        var i : Int = 0;
        var pt : DynamicProperty = null;
        var cur : Float = Math.NaN;
        var end : Float = Math.NaN;
        var ratio : Float = Math.NaN;
        var val : Float = Math.NaN;
        if (v != _prevFactor)
        {
            i = _props.length;
            if (_tween._time > _prevTime)
            {
                ratio = (v == 1 || _prevFactor == 1) ? 0 : as3hx.Compat.parseFloat(1 - (v - _prevFactor) / (1 - _prevFactor));
                while (--i > -1)
                {
                    pt = _props[i];
                    end = (cast(pt.params, Bool)) ? as3hx.Compat.parseFloat(pt.getter.apply(null, pt.params)) : as3hx.Compat.parseFloat(pt.getter());
                    cur = !(pt.f) ? as3hx.Compat.parseFloat(Reflect.field(_target, Std.string(pt.getProp))) : as3hx.Compat.parseFloat(Reflect.field(_target, Std.string(pt.getProp))());
                    val = end - (end - cur) * ratio;
                    if (pt.r)
                    {
                        val = (val > 0) ? as3hx.Compat.parseFloat(val + 0.5 >> 0) : as3hx.Compat.parseFloat(val - 0.5 >> 0);
                    }
                    if (pt.f)
                    {
                        Reflect.field(_target, Std.string(pt.p))(val);
                    }
                    else
                    {
                        Reflect.setField(_target, Std.string(pt.p), val);
                    }
                }
            }
            else
            {
                ratio = (v == 0 || _prevFactor == 0) ? 0 : as3hx.Compat.parseFloat(1 - (v - _prevFactor) / -_prevFactor);
                while (--i > -1)
                {
                    pt = _props[i];
                    cur = !(pt.f) ? as3hx.Compat.parseFloat(Reflect.field(_target, Std.string(pt.getProp))) : as3hx.Compat.parseFloat(Reflect.field(_target, Std.string(pt.getProp))());
                    val = !(pt.r) ? as3hx.Compat.parseFloat(pt.s + (cur - pt.s) * ratio) : (((val = pt.s + (cur - pt.s) * ratio) > 0) ? as3hx.Compat.parseFloat(val + 0.5 >> 0) : as3hx.Compat.parseFloat(val - 0.5 >> 0));
                    if (pt.f)
                    {
                        Reflect.field(_target, Std.string(pt.p))(val);
                    }
                    else
                    {
                        Reflect.setField(_target, Std.string(pt.p), val);
                    }
                }
            }
            _prevFactor = v;
        }
        _prevTime = _tween._time;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var p : Dynamic = null;
        _target = tween.target;
        _tween = tween;
        var params : Dynamic = value.params || { };
        _prevFactor = _prevTime = 0;
        for (p in Reflect.fields(value))
        {
            if (p != "params")
            {
                _props[_props.length] = new DynamicProperty(_target, p, try cast(Reflect.field(value, Std.string(p)), Function) catch(e:Dynamic) null, Reflect.field(params, Std.string(p)));
                _overwriteProps[_overwriteProps.length] = p;
            }
        }
        return true;
    }
}


class DynamicProperty
{
    
    
    public var f : Bool;
    
    public var getProp : String;
    
    public var getter : Function;
    
    public var p : String;
    
    public var s : Float;
    
    public var params : Array<Dynamic>;
    
    public var r : Bool;
    
    private function new(target : Dynamic, p : String, getter : Function, params : Array<Dynamic>)
    {
        super();
        this.p = p;
        this.f = Std.is(Reflect.field(target, p), Function);
        this.getProp = !f || p.indexOf("set") || !((Lambda.has(target, "get" + p.substr(3)))) ? p : "get" + p.substr(3);
        this.s = !!(f) ? as3hx.Compat.parseFloat(Reflect.field(target, getProp)()) : as3hx.Compat.parseFloat(Reflect.field(target, getProp));
        this.getter = getter;
        this.params = params;
    }
}
